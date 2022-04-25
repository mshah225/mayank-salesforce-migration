public with sharing class PersistenceOutlookDispatcher implements TriggerDispatcherInterface {
    private static final Boolean debug = false; // Toggle debug error reporting
    private List<Persistence_Outlook__c> newList; // trigger.new
    private Map<Id, Persistence_Outlook__c> newMap; // trigger.newMap
    private List<Persistence_Outlook__c> oldList; // trigger.old
    private Map<Id, Persistence_Outlook__c> oldMap; // trigger.oldMap

    public PersistenceOutlookDispatcher(
        List<Persistence_Outlook__c> newList,
        Map<Id, Persistence_Outlook__c> newMap,
        List<Persistence_Outlook__c> oldList,
        Map<Id, Persistence_Outlook__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    
    public void beforeInsert() {
        PersistenceOutlookService.updateOldPersistenceOutlookRecords(newList);
    }    
    public void beforeUpdate() {
    }
    public void beforeDelete() {
    }
    public void afterInsert() {         
    }
    public void afterUpdate() {
    }
    public void afterUndelete() {
    }
    public void afterDelete() {
    }
}
