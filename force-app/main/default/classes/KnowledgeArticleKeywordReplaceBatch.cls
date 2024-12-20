public class KnowledgeArticleKeywordReplaceBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    // Query constants
    private final String ONLINE_ARTICLE_QUERY = 'SELECT Id, Title, Answer__c, AWS_Website__c, PublishStatus, KnowledgeArticleId FROM FAQ__kav WHERE PublishStatus = \'Online\'';
    private final String EMPTY_QUERY = 'SELECT Id FROM FAQ__kav LIMIT 0'; // Save for when Classic is phased out, and we need to add an empty query if Lightning Knowledge isn't enabled

    // State variables
    private Integer batchSize;
    private Boolean isLightningKnowledgeEnabled;
    private Map<String, String> keywordReplacementMap = new Map<String, String>();
    private List<FAQ__kav> articlesForUpdate = new List<FAQ__kav>();
    private Set<Id> processedArticleIds = new Set<Id>();
    private List<String> articlesWithValidKeywords = new List<String>();
    private List<String> articlesWithNoKeywordsToReplace = new List<String>();
    private List<String> articlesWithUpdatedKeywords = new List<String>();
    private List<String> errorMessages = new List<String>();

    public KnowledgeArticleKeywordReplaceBatch() {
        initialize(null);
    }

    public KnowledgeArticleKeywordReplaceBatch(Integer batchSize) {
        initialize(batchSize);
    }

    private void initialize(Integer batchSize) {
        this.batchSize = (batchSize != null && batchSize > 0 && batchSize <= 40) ? batchSize : 20; // Default to 20 if null

        checkLightningKnowledgeAvailability();
        loadKeywordReplacements();
    }

    /**
     * Checks if Lightning Knowledge is enabled
     */
    private void checkLightningKnowledgeAvailability() {
        System.debug('Checking Lightning Knowledge availability...');

        isLightningKnowledgeEnabled = false;
        try {
            Database.query('SELECT ArticleType FROM FAQ__kav LIMIT 1');
        } catch (QueryException e) {
            if (e.getMessage().contains('No such column')) {
                isLightningKnowledgeEnabled = true;
            }
        }
    }

    /**
     * Loads keyword replacements from custom metadata
     */
    private void loadKeywordReplacements() {
        if (isLightningKnowledgeEnabled) {
            System.debug('Initializing keyword replacements for Lightning articles...');
        } else {
            System.debug('Initializing keyword replacements for Classic articles...');
        }

        for (
            Knowledge_Article_Keyword_Replacement__mdt keywordReplacement : Knowledge_Article_Keyword_Replacement__mdt.getAll()
                .values()
        ) {
            if (keywordReplacement.Replacement_Enabled__c) {
                keywordReplacementMap.put(
                    keywordReplacement.Old_Keyword__c.trim(),
                    keywordReplacement.New_Keyword__c.trim()
                );
            }
        }
    }

    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        System.debug('Starting batch with query for online articles...');
        return Database.getQueryLocator(ONLINE_ARTICLE_QUERY);
    }

    public void execute(Database.BatchableContext batchContext, List<SObject> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }

        Map<Id, FAQ__kav> articleMap = new Map<Id, FAQ__kav>((List<FAQ__kav>) scope);
        Set<Id> articleIdsToProcess = filterArticlesByKeywords(articleMap);
        Set<Id> articlesWithExistingDrafts = handleArticleDrafts(articleIdsToProcess);
        createOrUpdateDrafts(articleMap, articlesWithExistingDrafts);
        publishDrafts();
        processedArticleIds.addAll(articleIdsToProcess);
    }

    private Set<Id> filterArticlesByKeywords(Map<Id, FAQ__kav> articleMap) {
        Set<Id> articleIds = new Set<Id>();
        for (FAQ__kav article : articleMap.values()) {
            if (!processedArticleIds.contains(article.KnowledgeArticleId)) {
                if (!articleContainsKeywords(article.Answer__c) && !articleContainsKeywords(article.AWS_Website__c)) {
                    articlesWithNoKeywordsToReplace.add(article.Id + ' - ' + article.Title);
                } else if (articleRequiresKeywordUpdate(article)) {
                    articleIds.add(article.KnowledgeArticleId);
                } else {
                    articlesWithValidKeywords.add(article.Id + ' - ' + article.Title);
                }
            }
        }
        return articleIds;
    }

    private Boolean articleContainsKeywords(String content) {
        if (content == null)
            return false;
        for (String oldKeyword : keywordReplacementMap.keySet()) {
            if (content.contains(oldKeyword)) {
                return true;
            }
        }
        return false;
    }

    private Boolean articleRequiresKeywordUpdate(FAQ__kav article) {
        return articleContainsKeywords(article.Answer__c) || articleContainsKeywords(article.AWS_Website__c);
    }

    private Set<Id> handleArticleDrafts(Set<Id> articleIds) {
        List<FAQ__kav> draftArticles = [
            SELECT Id, Title, Answer__c, AWS_Website__c, PublishStatus, KnowledgeArticleId
            FROM FAQ__kav
            WHERE PublishStatus = 'Draft' AND KnowledgeArticleId IN :articleIds
        ];

        Set<Id> articlesWithDrafts = new Set<Id>();
        for (FAQ__kav draftArticle : draftArticles) {
            articlesWithDrafts.add(draftArticle.KnowledgeArticleId);
            updateDraftIfNecessary(draftArticle);
        }
        return articlesWithDrafts;
    }

    private void createOrUpdateDrafts(Map<Id, FAQ__kav> articleMap, Set<Id> articlesWithDrafts) {
        for (FAQ__kav article : articleMap.values()) {
            if (!articlesWithDrafts.contains(article.KnowledgeArticleId) && articleRequiresKeywordUpdate(article)) {
                Id draftId = KbManagement.PublishingService.editOnlineArticle(article.KnowledgeArticleId, false);
                if (draftId != null) {
                    FAQ__kav draftArticle = fetchDraftArticle(draftId);
                    updateDraftIfNecessary(draftArticle);
                }
            }
        }
    }

    private FAQ__kav fetchDraftArticle(Id draftId) {
        return [
            SELECT Id, Title, Answer__c, AWS_Website__c, PublishStatus, KnowledgeArticleId
            FROM FAQ__kav
            WHERE Id = :draftId
        ];
    }

    private void updateDraftIfNecessary(FAQ__kav draftArticle) {
        if (draftArticle.PublishStatus == 'Draft') {
            Boolean updated = false;

            if (draftArticle.Answer__c != null) {
                String updatedAnswer = replaceOldKeywords(draftArticle.Answer__c);
                if (!updatedAnswer.equals(draftArticle.Answer__c)) {
                    draftArticle.Answer__c = updatedAnswer;
                    updated = true;
                }
            }

            if (draftArticle.AWS_Website__c != null) {
                String updatedWebsite = replaceOldKeywords(draftArticle.AWS_Website__c);
                if (!updatedWebsite.equals(draftArticle.AWS_Website__c)) {
                    draftArticle.AWS_Website__c = updatedWebsite;
                    updated = true;
                }
            }

            if (updated) {
                articlesForUpdate.add(draftArticle);
                articlesWithUpdatedKeywords.add(draftArticle.Id + ' - ' + draftArticle.Title);
            }
        }
    }

    private String replaceOldKeywords(String content) {
        if (content == null)
            return null;
        for (String oldKeyword : keywordReplacementMap.keySet()) {
            content = content.replace(oldKeyword, keywordReplacementMap.get(oldKeyword));
        }
        return content;
    }

    private void publishDrafts() {
        if (!articlesForUpdate.isEmpty()) {
            List<Database.SaveResult> updateResults = Database.update(articlesForUpdate, false);
            handleUpdateResults(updateResults);
            articlesForUpdate.clear();
        }
    }

    private void handleUpdateResults(List<Database.SaveResult> updateResults) {
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
    }

    public void finish(Database.BatchableContext batchContext) {
        System.debug('KnowledgeArticleKeywordReplaceBatch is finishing up...');

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
        Database.executeBatch(new KnowledgeArticleKeywordReplaceBatch(), batchSize);
    }
}