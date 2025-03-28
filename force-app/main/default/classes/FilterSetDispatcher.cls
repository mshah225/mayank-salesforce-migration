public with sharing class FilterSetDispatcher implements TriggerDispatcherInterface {
    private List<Filter_Set__c> newList;
    private Map<Id, Filter_Set__c> newMap;
    private List<Filter_Set__c> oldList;
    private Map<Id, Filter_Set__c> oldMap;

    public FilterSetDispatcher(
        List<Filter_Set__c> newList,
        Map<Id, Filter_Set__c> newMap,
        List<Filter_Set__c> oldList,
        Map<Id, Filter_Set__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        FilterSetService.setOwner(newList);
        FilterSetService.checkUniqueName(newList);
    }
    public void beforeUpdate() {
        FilterSetService.checkOwnerBeforeRename(newList, oldMap);
        FilterSetService.checkUniqueName(newList);
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
        FilterSetService.createFSUAForOwners(newList);
    }
    public void afterUpdate() {
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}