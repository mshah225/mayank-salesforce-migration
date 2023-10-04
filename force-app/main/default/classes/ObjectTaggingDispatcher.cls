public class ObjectTaggingDispatcher implements TriggerDispatcherInterface {
    private List<Object_Tag__c> newList;
    private Map<Id, Object_Tag__c> newMap;
    private List<Object_Tag__c> oldList;
    private Map<Id, Object_Tag__c> oldMap;

    public ObjectTaggingDispatcher(List<Object_Tag__c> newList, Map<Id, Object_Tag__c> newMap, List<Object_Tag__c> oldList, Map<Id, Object_Tag__c> oldMap) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {   
        ObjectTaggingService.applyRelatedObject(newList);     
        ObjectTaggingService.initData(newList);
        ObjectTaggingService.createName(newList);
        ObjectTaggingService.updateCreationDateTime(newList);
    }

    public void beforeUpdate() {
        ObjectTaggingService.initData(newList);
        ObjectTaggingService.fixName(newList);
        ObjectTaggingService.updateCreationOrRemovalDate(newMap, oldMap);
    }

    public void beforeDelete() {
    }

    public void afterInsert() {
    }

    public void afterUpdate() {
    }

    public void afterDelete() {
    }

    public void afterUndelete() {
    }
}