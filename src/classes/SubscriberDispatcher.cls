public with sharing class SubscriberDispatcher implements IDispatch {
    private List<Subscriber__c> newList;
    private Map<Id, Subscriber__c> newMap;
    private List<Subscriber__c> oldList;
    private Map<Id, Subscriber__c> oldMap;

    public SubscriberDispatcher (List<Subscriber__c> newList, Map<Id, Subscriber__c> newMap, 
        List<Subscriber__c> oldList, Map<Id, Subscriber__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        SubscriberService.enforceOwnerPolicies(newList);
    }

    public void beforeUpdate() { }
     
    public void beforeDelete() { }
     
    public void afterInsert() {
        SubscriberService.syncParentSubscribers(newList);
        List<Subscriber__c> subId = new List<Subscriber__c>();
        for(sObject s : Trigger.New) {
            subId.add((Subscriber__c)s);
        }
        SubscriberService.setHashId(subId);
     }
     
    public void afterUpdate() {
        SubscriberService.syncParentSubscribers(newList);
    }
     
    public void afterDelete() { }
     
    public void afterUndelete() {
        SubscriberService.syncParentSubscribers(newList);
    }
}