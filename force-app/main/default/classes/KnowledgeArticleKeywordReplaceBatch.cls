/**
 * Batchable and Schedulable class to replace keywords in Knowledge Articles.
 * Updates articles with specific keywords defined in custom metadata.
 */
public class KnowledgeArticleKeywordReplaceBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    // Query constants
    private static final String ONLINE_ARTICLE_QUERY =
        'SELECT Id, Title, Answer__c, AWS_Website__c, PublishStatus, KnowledgeArticleId ' +
        'FROM FAQ__kav WHERE PublishStatus = \'Online\'';
    private static final String EMPTY_QUERY = 'SELECT Id FROM FAQ__kav LIMIT 0';

    // State variables
    private Integer batchSize;
    private Boolean isLightningKnowledgeEnabled = false;
    private Map<String, String> keywordReplacementMap = new Map<String, String>();
    private Map<Id, FAQ__kav> articleMap = new Map<Id, FAQ__kav>();
    private Set<Id> articleIdsToProcess = new Set<Id>();
    private Set<Id> articlesWithDrafts = new Set<Id>();
    private Set<Id> processedArticleIds = new Set<Id>();
    private Set<Id> processedDraftIds = new Set<Id>();
    private List<FAQ__kav> articlesForUpdate = new List<FAQ__kav>();
    private List<String> errorMessages = new List<String>();

    public KnowledgeArticleKeywordReplaceBatch() {
        initialize(null);
    }

    public KnowledgeArticleKeywordReplaceBatch(Integer batchSize) {
        initialize(batchSize);
    }

    /**
     * Initializes the batch process with default or specified batch size.
     * @param batchSize Number of records per batch.
     */
    private void initialize(Integer batchSize) {
        System.debug('KnowledgeArticleKeywordReplaceBatch is starting up...');

        this.batchSize = (batchSize != null && batchSize > 0 && batchSize <= 40) ? batchSize : 20; // Default to 20
        checkLightningKnowledgeAvailability();
        loadKeywordReplacements();
    }

    /**
     * Checks if Lightning Knowledge is enabled.
     */
    private void checkLightningKnowledgeAvailability() {
        try {
            Database.query('SELECT ArticleType FROM FAQ__kav LIMIT 1');
        } catch (QueryException e) {
            if (e.getMessage().contains('No such column')) {
                isLightningKnowledgeEnabled = true;
            }
        }
    }

    /**
     * Loads keyword replacements from custom metadata.
     */
    private void loadKeywordReplacements() {
        for (
            Knowledge_Article_Keyword_Replacement__mdt keyword : Knowledge_Article_Keyword_Replacement__mdt.getAll()
                .values()
        ) {
            if (keyword.Replacement_Enabled__c) {
                keywordReplacementMap.put(keyword.Old_Keyword__c.trim(), keyword.New_Keyword__c.trim());
            }
        }
    }

    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        return Database.getQueryLocator(isLightningKnowledgeEnabled ? ONLINE_ARTICLE_QUERY : EMPTY_QUERY);
    }

    public void execute(Database.BatchableContext batchContext, List<SObject> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }

        articleMap = new Map<Id, FAQ__kav>((List<FAQ__kav>) scope);
        filterArticlesForProcessing();
        handleExistingDrafts();
        createOrUpdateDrafts();
        publishDrafts();
    }

    /**
     * Filters articles requiring keyword updates and prepares for processing.
     */
    private void filterArticlesForProcessing() {
        for (FAQ__kav article : articleMap.values()) {
            if (!processedArticleIds.contains(article.KnowledgeArticleId) && articleRequiresKeywordUpdate(article)) {
                articleIdsToProcess.add(article.KnowledgeArticleId);
            }
        }
    }

    /**
     * Determines if an article requires keyword updates.
     */
    private Boolean articleRequiresKeywordUpdate(FAQ__kav article) {
        return containsKeywords(article.Answer__c) || containsKeywords(article.AWS_Website__c);
    }

    private Boolean containsKeywords(String content) {
        if (content == null)
            return false;
        for (String oldKeyword : keywordReplacementMap.keySet()) {
            if (content.contains(oldKeyword)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Handles updates for existing draft articles.
     */
    private void handleExistingDrafts() {
        List<FAQ__kav> draftArticles = [
            SELECT Id, Title, Answer__c, AWS_Website__c, PublishStatus, KnowledgeArticleId
            FROM FAQ__kav
            WHERE PublishStatus = 'Draft' AND KnowledgeArticleId IN :articleIdsToProcess
        ];

        for (FAQ__kav draft : draftArticles) {
            if (!processedDraftIds.contains(draft.Id)) {
                articlesWithDrafts.add(draft.KnowledgeArticleId);
                updateDraftIfNecessary(draft);
                processedDraftIds.add(draft.Id);
            }
        }
    }

    /**
     * Creates or updates drafts for articles needing keyword replacements.
     */
    private void createOrUpdateDrafts() {
        List<Id> draftIdsToFetch = new List<Id>();

        for (FAQ__kav article : articleMap.values()) {
            if (!articlesWithDrafts.contains(article.KnowledgeArticleId)) {
                Id draftId = KbManagement.PublishingService.editOnlineArticle(article.KnowledgeArticleId, false);
                if (draftId != null && !processedDraftIds.contains(draftId)) {
                    draftIdsToFetch.add(draftId); // Collect draft IDs for bulk fetching
                    articlesWithDrafts.add(article.KnowledgeArticleId); // Track articles with drafts
                }
            }
        }

        // Fetch and process drafts in bulk
        if (!draftIdsToFetch.isEmpty()) {
            fetchDraftArticles(draftIdsToFetch);
        }
    }

    /**
     * Fetches and updates articles requiring keyword replacement for a list of draft IDs.
     * @param draftIds List of draft article IDs to fetch and process.
     */
    private void fetchDraftArticles(List<Id> draftIds) {
        List<FAQ__kav> drafts = [
            SELECT Id, Title, Answer__c, AWS_Website__c, PublishStatus, KnowledgeArticleId
            FROM FAQ__kav
            WHERE Id IN :draftIds
        ];

        for (FAQ__kav draft : drafts) {
            if (!processedDraftIds.contains(draft.Id)) {
                updateDraftIfNecessary(draft);
                processedDraftIds.add(draft.Id); // Track processed drafts to avoid reprocessing
            }
        }
    }

    /**
     * Updates a draft if keywords require replacement.
     */
    private void updateDraftIfNecessary(FAQ__kav draft) {
        if (draft.PublishStatus != 'Draft')
            return;

        Boolean updated = false;

        if (draft.Answer__c != null) {
            String updatedAnswer = replaceKeywords(draft.Answer__c);
            if (!updatedAnswer.equals(draft.Answer__c)) {
                draft.Answer__c = updatedAnswer;
                updated = true;
            }
        }

        if (draft.AWS_Website__c != null) {
            String updatedWebsite = replaceKeywords(draft.AWS_Website__c);
            if (!updatedWebsite.equals(draft.AWS_Website__c)) {
                draft.AWS_Website__c = updatedWebsite;
                updated = true;
            }
        }

        if (updated) {
            articlesForUpdate.add(draft);
        }
    }

    /**
     * Replaces old keywords with new ones in the given content.
     */
    private String replaceKeywords(String content) {
        if (content == null)
            return null;
        for (String oldKeyword : keywordReplacementMap.keySet()) {
            content = content.replace(oldKeyword, keywordReplacementMap.get(oldKeyword));
        }
        return content;
    }

    /**
     * Publishes drafts after updating and clears relevant state variables for the next batch.
     */
    private void publishDrafts() {
        if (articlesForUpdate.isEmpty())
            return;

        List<Database.SaveResult> updateResults = Database.update(articlesForUpdate, false);
        for (Integer i = 0; i < updateResults.size(); i++) {
            if (updateResults[i].isSuccess()) {
                try {
                    KbManagement.PublishingService.publishArticle(articlesForUpdate[i].KnowledgeArticleId, true);
                } catch (Exception e) {
                    errorMessages.add('Failed to publish article: ' + e.getMessage());
                }
            } else {
                errorMessages.add('Failed to update article: ' + updateResults[i].getErrors()[0].getMessage());
            }
        }

        // Clear relevant variables for the next batch
        articlesForUpdate.clear(); // Clear the list of articles pending update
        articleIdsToProcess.clear(); // Clear processed article IDs for this batch
        articleMap.clear(); // Clear the article map for this batch
        articlesWithDrafts.clear(); // Reset draft tracking for the next batch
    }

    public void finish(Database.BatchableContext batchContext) {
        System.debug('...KnowledgeArticleKeywordReplaceBatch is finishing up');

        AsyncApexJob batchJob = [SELECT Id, CreatedById, Status FROM AsyncApexJob WHERE Id = :batchContext.getJobId()];
        System.debug(
            'Batch job (' +
                batchJob.Id +
                ') started by ' +
                batchJob.CreatedById +
                ' finished with status: ' +
                batchJob.Status +
                '.'
        );
    }

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new KnowledgeArticleKeywordReplaceBatch(batchSize));
    }
}