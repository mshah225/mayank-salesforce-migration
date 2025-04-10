/**
 * Batchable and Schedulable class to unlock and fix mismatched drafts for Knowledge Articles.
 *
 * Specifically, this class:
 *   1) Selects all FAQ__kav records where PublishStatus = 'Draft' but ValidationStatus != 'Draft'.
 *   2) Unlocks them if they're stuck in an approval process.
 *   3) Updates ValidationStatus to 'Draft', ensuring the record is properly recognized as a draft
 *      so it can be edited or deleted without lock errors.
 */
global class KnowledgeArticleDraftUpdateBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    // ---------------------------------------
    // Members
    // ---------------------------------------

    /**
     * The number of records to process in each batch chunk.
     * Defaults to 20 if none provided or out of range (1-40).
     */
    private Integer batchSize;

    // ---------------------------------------
    // Constructors
    // ---------------------------------------

    /**
     * Default constructor. Uses default batch size of 20.
     */
    public KnowledgeArticleDraftUpdateBatch() {
        this(null);
    }

    /**
     * Parameterized constructor allowing customization of the batch size.
     *
     * @param batchSize The desired batch size (1-40).
     *                  If invalid or null, reverts to 20.
     */
    public KnowledgeArticleDraftUpdateBatch(Integer batchSize) {
        // Enforce a valid range for batch size
        if (batchSize != null && batchSize > 0 && batchSize <= 40) {
            this.batchSize = batchSize;
        } else {
            this.batchSize = 20;
        }
    }

    // ---------------------------------------
    // Batchable: start
    // ---------------------------------------

    /**
     * Defines the query to retrieve records for the batch.
     * Fetches all FAQ__kav records in a "Draft" publish status but with a
     * ValidationStatus != "Draft".
     *
     * @param bc Context object for the batch job.
     * @return A QueryLocator that contains the records to be processed.
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT Id, PublishStatus, ValidationStatus
                FROM FAQ__kav
                WHERE PublishStatus = 'Draft' AND ValidationStatus != 'Draft'
            ]
        );
    }

    // ---------------------------------------
    // Batchable: execute
    // ---------------------------------------

    /**
     * Processes each chunk (scope) of retrieved records.
     *  1) Unlocks the FAQ__kav records if they're locked by an approval process.
     *  2) Updates their ValidationStatus to "Draft" so they're recognized as proper drafts.
     *
     * @param bc    Batch context.
     * @param scope List of SObject records (in this case, FAQ__kav) to process in this chunk.
     */
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        // If there's nothing to process, just bail out
        if (scope.isEmpty()) {
            return;
        }

        // Cast our scope to a strongly-typed list of FAQ__kav
        List<FAQ__kav> draftFaqs = (List<FAQ__kav>) scope;

        try {
            // 1) Unlock them if they're stuck in an active approval
            // Note: Approval.unlock() returns an array, so we wrap it as a List
            List<Approval.UnlockResult> unlockResults = new List<Approval.UnlockResult>(
                Approval.unlock(draftFaqs, false)
            );

            // (Optional) Inspect unlockResults for partial successes or failures if desired

            // 2) Update ValidationStatus to 'Draft'
            for (FAQ__kav faq : draftFaqs) {
                faq.ValidationStatus = 'Draft';
            }
            update draftFaqs;

            System.debug(LoggingLevel.INFO, 'Unlocked and updated ValidationStatus for FAQ__kav drafts in this batch.');
        } catch (Exception e) {
            // If something goes wrong, log the details.
            // You could also store them in a custom object or send an email, if needed.
            System.debug(LoggingLevel.ERROR, 'Error in KnowledgeArticleDraftUpdateBatch execute(): ' + e.getMessage());
        }
    }

    // ---------------------------------------
    // Batchable: finish
    // ---------------------------------------

    /**
     * Final method that runs once after all batches have been processed.
     * Can be used for post-processing, logging, or sending notifications.
     *
     * @param bc Batch context.
     */
    global void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO, 'KnowledgeArticleDraftUpdateBatch has finished processing all records.');
    }

    // ---------------------------------------
    // Schedulable: execute
    // ---------------------------------------

    /**
     * Allows the batch to be scheduled using the Apex Scheduler.
     *
     * @param sc Schedulable context.
     */
    global void execute(SchedulableContext sc) {
        // Kick off the batch with the chosen batch size
        Database.executeBatch(new KnowledgeArticleDraftUpdateBatch(batchSize), batchSize);
    }
}