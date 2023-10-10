public class TagDispatcher implements TriggerDispatcherInterface {
    private List<Tag__c> newList;
    private Map<Id, Tag__c> newMap;
    private List<Tag__c> oldList;
    private Map<Id, Tag__c> oldMap;

    public TagDispatcher(List<Tag__c> newList, Map<Id, Tag__c> newMap, List<Tag__c> oldList, Map<Id, Tag__c> oldMap) {
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
        TagService.updateRecordTypes(newMap, oldMap);
    }

    public void afterDelete() {
    }

    public void afterUndelete() {
    }
}