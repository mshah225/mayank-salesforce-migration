public with sharing class EmailSendDispatcher implements IDispatch {
    private List<et4ae5__SendDefinition__c> newList; // trigger.new
    private Map<Id, et4ae5__SendDefinition__c> newMap; // trigger.newMap
    private List<et4ae5__SendDefinition__c> oldList; // trigger.old
    private Map<Id, et4ae5__SendDefinition__c> oldMap; // trigger.oldMap

    public EmailSendDispatcher(
        List<et4ae5__SendDefinition__c> newList,
        Map<Id, et4ae5__SendDefinition__c> newMap,
        List<et4ae5__SendDefinition__c> oldList,
        Map<Id, et4ae5__SendDefinition__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        for (et4ae5__SendDefinition__c send : newList) {
            if (!String.isBlank(send.et4ae5__Campaigns__c)) {
                EmailSendService.setCampaignLookup(send);
            }
        }
    }

    public void beforeUpdate() {
        for (et4ae5__SendDefinition__c send : newList) {
            if (!String.isBlank(send.et4ae5__Campaigns__c)) {
                EmailSendService.setCampaignLookup(send);
            }
        }
    }

    //Required by Dispatcher Interface
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
