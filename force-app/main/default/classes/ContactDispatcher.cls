public with sharing class ContactDispatcher implements TriggerDispatcherInterface {
    private List<Contact> newList;
    private Map<Id, Contact> newMap;
    private List<Contact> oldList;
    private Map<Id, Contact> oldMap;
    private static List<Account> accountList;

    public ContactDispatcher(
        List<Contact> newList,
        Map<Id, Contact> newMap,
        List<Contact> oldList,
        Map<Id, Contact> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        ContactService.setRecordTypes(newList);
        ContactService.beforeTriggerSyncAccounts(newList);
        ContactService.setSelfServicePins(newList);
    }
    public void beforeUpdate() {
        ContactService.setRecordTypes(newList);
        ContactService.beforeTriggerSyncAccounts(newList);
        ContactService.syncUsers(newList, oldMap);
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
        ContactService.afterTriggerSyncAccounts(newList);
        ContactService.setHashIds(newList);
    }
    public void afterUpdate() {
        ContactService.afterTriggerSyncAccounts(newList);

        TerritoryAssignmentContact ta = new TerritoryAssignmentContact();
        ta.assignTerritory();
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
