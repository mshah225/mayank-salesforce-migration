public class TestScoreDispatcher implements TriggerDispatcherInterface {
    private List<Test_Score__c> newList;
    private Map<Id, Test_Score__c> newMap;
    private List<Test_Score__c> oldList;
    private Map<Id, Test_Score__c> oldMap;

    public TestScoreDispatcher(
        List<Test_Score__c> newList,
        Map<Id, Test_Score__c> newMap,
        List<Test_Score__c> oldList,
        Map<Id, Test_Score__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() { 
    }
    public void beforeUpdate() {
    }
    public void beforeDelete() {
    }
    public void afterInsert() {        
        TestScoreService.checkIfTestShouldSyncWithMasterTracker(newMap);
    }
    public void afterUpdate() {
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}