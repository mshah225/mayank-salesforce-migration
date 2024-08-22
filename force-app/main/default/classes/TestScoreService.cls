public with sharing class TestScoreService {
    
    public static void checkIfTestShouldSyncWithMasterTracker(Map<Id, Test_Score__c> newMap) {

        List<Id> testScoreContactId = new List<Id>();

        for (Test_Score__c ts : newMap.values()) {
            testScoreContactId.add(ts.Contact__c);
        }

        Map<Id, Opportunity> oppsThatNeedSyncing = new Map<Id, Opportunity>([
            SELECT Id, Contact__c, Admission_Test_Type__c
            FROM Opportunity
            WHERE Contact__c IN: testScoreContactId
            AND Sync_to_Master_Tracker_Record__c = true
        ]);

        MasterTrackerService.updateMasterTrackerWithNewTestScores(oppsThatNeedSyncing);

    }
}