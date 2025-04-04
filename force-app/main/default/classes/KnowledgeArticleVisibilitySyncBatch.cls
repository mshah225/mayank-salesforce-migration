/**
 * Batchable and Schedulable class to synchronize visibility settings for Knowledge Articles.
 * This class updates visibility flags for articles and ensures consistency by publishing updated drafts.
 */
public class KnowledgeArticleVisibilitySyncBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    // SOQL query to fetch online articles with inconsistent visibility settings
    private static final String MIXED_VISIBILITY_ARTICLES_QUERY =
        'SELECT Id, KnowledgeArticleId, Title, PublishStatus, IsVisibleInCsp, IsVisibleInPkb, Visible_to_Students_Public__c ' +
        'FROM FAQ__kav ' +
        'WHERE PublishStatus = \'Online\' ' +
        'AND (IsVisibleInCsp = true OR IsVisibleInPkb = true) ' +
        'AND Visible_to_Students_Public__c = false';

    // Batch size for processing articles
    private Integer batchSize;

    // Map to hold articles in the current batch
    private Map<Id, FAQ__kav> articleMap = new Map<Id, FAQ__kav>();

    // List to capture error messages during batch execution
    private List<String> errorMessages = new List<String>();

    /**
     * Default constructor to initialize with the default batch size.
     */
    public KnowledgeArticleVisibilitySyncBatch() {
        this(null);
    }

    /**
     * Parameterized constructor to set a custom batch size.
     * @param batchSize Custom batch size to use for processing.
     */
    public KnowledgeArticleVisibilitySyncBatch(Integer batchSize) {
        this.batchSize = (batchSize != null && batchSize > 0 && batchSize <= 40) ? batchSize : 20; // Default batch size 20
    }

    /**
     * Start method to fetch records for processing.
     * @param batchContext Batchable context.
     * @return A QueryLocator object containing the SOQL query results.
     */
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        return Database.getQueryLocator(MIXED_VISIBILITY_ARTICLES_QUERY);
    }

    /**
     * Execute method to process each batch of articles.
     * @param batchContext Batchable context.
     * @param scope List of articles to process in this batch.
     */
    public void execute(Database.BatchableContext batchContext, List<SObject> scope) {
        // Map the articles for easier handling
        articleMap = new Map<Id, FAQ__kav>((List<FAQ__kav>) scope);

        // Process each article in the scope
        for (FAQ__kav article : articleMap.values()) {
            try {
                processArticle(article); // Process the article
            } catch (Exception e) {
                // Log any errors encountered while processing the article
                errorMessages.add('Failed to process article ' + article.Id + ': ' + e.getMessage());
            }
        }
    }

    /**
     * Processes a single article:
     * - Checks if a draft exists for the article.
     * - Creates a draft if none exists.
     * - Updates visibility settings on the draft.
     * - Publishes the draft.
     * @param article The article to process.
     */
    private void processArticle(FAQ__kav article) {
        Id draftId;

        try {
            // Fetch the existing draft for the article, if any
            FAQ__kav draft = getDraftForArticle(article.KnowledgeArticleId);

            if (draft == null) {
                // Create a new draft for the article if no draft exists
                draftId = KbManagement.PublishingService.editOnlineArticle(article.KnowledgeArticleId, false);

                if (draftId == null) {
                    System.debug('Failed to create draft for article.');
                    return;
                }

                // Fetch the newly created draft
                draft = [
                    SELECT Id, KnowledgeArticleId, IsVisibleInCsp, IsVisibleInPkb, Visible_to_Students_Public__c
                    FROM FAQ__kav
                    WHERE Id = :draftId
                    LIMIT 1
                ];
            }

            // Update visibility flags on the draft
            draft.IsVisibleInCsp = true;
            draft.IsVisibleInPkb = true;
            draft.Visible_to_Students_Public__c = true;

            // Save the updated draft
            Database.update(draft);

            // Publish the updated draft
            KbManagement.PublishingService.publishArticle(draft.KnowledgeArticleId, true);
        } catch (Exception e) {
            // Capture any errors during processing
            errorMessages.add(
                'Error processing draft for article ' + article.KnowledgeArticleId + ': ' + e.getMessage()
            );
        }
    }

    /**
     * Fetches the draft for a given article ID.
     * @param knowledgeArticleId The ID of the KnowledgeArticle to fetch a draft for.
     * @return The draft article, or null if no draft exists.
     */
    private FAQ__kav getDraftForArticle(Id knowledgeArticleId) {
        List<FAQ__kav> drafts = [
            SELECT Id, KnowledgeArticleId, PublishStatus, IsVisibleInCsp, IsVisibleInPkb, Visible_to_Students_Public__c
            FROM FAQ__kav
            WHERE PublishStatus = 'Draft' AND KnowledgeArticleId = :knowledgeArticleId
            LIMIT 1
        ];
        return drafts.isEmpty() ? null : drafts[0];
    }

    /**
     * Finish method to log any errors encountered during execution.
     * @param batchContext Batchable context.
     */
    public void finish(Database.BatchableContext batchContext) {
        if (!errorMessages.isEmpty()) {
            System.debug('Errors encountered during execution: ' + String.join(errorMessages, '\n'));
        }
    }

    /**
     * Schedulable method to execute the batch as part of a scheduled job.
     * @param ctx Schedulable context.
     */
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new KnowledgeArticleVisibilitySyncBatch(batchSize));
    }
}