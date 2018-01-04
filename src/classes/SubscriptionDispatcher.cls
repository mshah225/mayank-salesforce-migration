public with sharing class SubscriptionDispatcher implements IDispatch {
    private static final boolean debug = false; // Toggle debug error reporting
    private static Map<Id,Subscription__c> newAttachments; // trigger.new
    private static Map<Id,Subscription__c> oldAttachments; // trigger.oldMap
    private static Map<Id,Case> casesToUpdate; // Map of cases that need to be updated based on business logic
    
    public SubscriptionDispatcher (Map<Id,Subscription__c> newMap, Map<Id,Subscription__c> oldMap) {
        newAttachments = newMap;
        oldAttachments = oldMap;
    }
    
    public void afterInsert() { 
    	List<Id> subId = new List<Id>();
        for(sObject s : Trigger.New) {
            subId.add(s.Id);
        }
        SubscriptionService.setHashId(subId);
    }
    
    public void beforeInsert() { }
    public void beforeUpdate() { }
    public void beforeDelete() { }
    public void afterUpdate() { }
    public void afterUndelete() { }
    public void afterDelete() { }

}