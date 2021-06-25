global class DeferredTABatchScheduler implements Schedulable {
    // Code to schedule hourly at the bottom of the hour:
    // System.schedule('Deferred Territory Assignment', '0 30 * * * ?', new DeferredTABatchScheduler());

    global void execute(SchedulableContext sc) {
        database.executeBatch(new BatchAccountDeferredOppTA());
        database.executeBatch(new BatchAccountDeferredLeadTA());
        database.executeBatch(new BatchTARDeferredOppTA());
        database.executeBatch(new BatchTARDeferredLeadTA());
    }
}
