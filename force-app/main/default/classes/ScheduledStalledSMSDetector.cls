global with sharing class ScheduledStalledSMSDetector implements Schedulable {
    global void execute(SchedulableContext SC) {
        List<SMS_Stall_Detection_Rule__mdt> allRules = getMetadata();

        for (SMS_Stall_Detection_Rule__mdt rule : allRules) {
            Database.executeBatch(new ScheduledStalledSMSDetectorBatch(rule));
        }
    }

    private List<SMS_Stall_Detection_Rule__mdt> getMetadata() {
        List<SMS_Stall_Detection_Rule__mdt> allRules = [
            SELECT
                MasterLabel,
                At_Least_N_Hours_Old__c,
                Number_Of_Days__c,
                Email_Addresses__c,
                Report_Fields__c,
                Sender_Id_Units__c,
                Statuses__c
            FROM SMS_Stall_Detection_Rule__mdt
            WHERE Enabled__c = TRUE
        ];

        // When running tests return fake data
        if (Test.isRunningTest()) {
            return TEST_METADATA;
        }

        return allRules;
    }

    @TestVisible
    private static List<SMS_Stall_Detection_Rule__mdt> TEST_METADATA = new List<SMS_Stall_Detection_Rule__mdt>();
}
