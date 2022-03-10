public class SuccessStudentDispatcher implements TriggerDispatcherInterface {
    private List<Success_Student__c> newList;
    private Map<Id, Success_Student__c> newMap;
    private List<Success_Student__c> oldList;
    private Map<Id, Success_Student__c> oldMap;

    public SuccessStudentDispatcher(
        List<Success_Student__c> newList,
        Map<Id, Success_Student__c> newMap,
        List<Success_Student__c> oldList,
        Map<Id, Success_Student__c> oldMap
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
    }
    public void afterUpdate() {
        new SuccessStudentService(newMap, oldMap);
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
