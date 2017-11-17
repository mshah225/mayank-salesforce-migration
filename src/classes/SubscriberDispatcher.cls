public with sharing class SubscriberDispatcher implements IDispatch {
    private static Map<Id, Subscriber__c> newSubs;
    private static Map<Id, Subscriber__c> oldSubs;

    public SubscriberDispatcher (Map<Id, Subscriber__c> newMap, Map<Id, Subscriber__c> oldMap) {
        // Commented out; current functionality does not require these values
        /*
        newSubs = newMap;
        oldSubs = oldMap;
        */
    }

    public void beforeInsert() {
        SubscriberService.enforceOwnerPolicies(Trigger.new);
    }

    //Required by Dispatcher Interface
     public void beforeUpdate() { }
     public void beforeDelete() { }
     public void afterInsert() {
         SubscriberService.syncParentSubscribers(Trigger.new);
     }
     public void afterUpdate() {
         SubscriberService.syncParentSubscribers(Trigger.new);
     }
     public void afterDelete() { }
     public void afterUndelete() {
         SubscriberService.syncParentSubscribers(Trigger.new);
      }
}