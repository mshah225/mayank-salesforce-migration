global without sharing class InactiveRelationshipNightlyJob implements Schedulable {
    global void execute(SchedulableContext sc) {
        InactiveRelationshipBatchJob batchJob = new InactiveRelationshipBatchJob();
        Database.executeBatch(batchJob, 200);
    } 
}