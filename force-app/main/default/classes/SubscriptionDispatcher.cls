public with sharing class SubscriptionDispatcher implements TriggerDispatcherInterface {
    private List<Subscription__c> newList;
    private Map<Id, Subscription__c> newMap;
    private List<Subscription__c> oldList;
    private Map<Id, Subscription__c> oldMap;

    public SubscriptionDispatcher(
        List<Subscription__c> newList,
        Map<Id, Subscription__c> newMap,
        List<Subscription__c> oldList,
        Map<Id, Subscription__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void afterInsert() {
        List<Id> subId = new List<Id>();
        for (Subscription__c s : newList) {
            subId.add(s.Id);
        }
        SubscriptionService.setHashId(subId);
    }

    public void beforeInsert() {
    }
    public void beforeUpdate() {
    }
    public void beforeDelete() {
    }
    public void afterUpdate() {
    }
    public void afterUndelete() {
    }
    public void afterDelete() {
    }
}
