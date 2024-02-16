public class PreviousEducationDispatcher implements TriggerDispatcherInterface {
    private List<Previous_Education__c> newList;
    private Map<Id, Previous_Education__c> newMap;
    private List<Previous_Education__c> oldList;
    private Map<Id, Previous_Education__c> oldMap;

    public PreviousEducationDispatcher(
        List<Previous_Education__c> newList,
        Map<Id, Previous_Education__c> newMap,
        List<Previous_Education__c> oldList,
        Map<Id, Previous_Education__c> oldMap
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
        PreviousEducationService.updateContactsLastEducations(newList);
        PreviousEducationService.assignTerritory(newList);
    }
    public void afterUpdate() {
        PreviousEducationService.updateContactsLastEducations(newList);
        PreviousEducationService.assignTerritory(newList);
    }
    public void afterDelete() {
        PreviousEducationService.updateContactsLastEducations(oldList);
    }
    public void afterUndelete() {
        PreviousEducationService.updateContactsLastEducations(newList);
    }
}