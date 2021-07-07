public class BatchApplySubscriberPrivacy implements Database.Batchable<sObject>, Database.Stateful {
    private static final Boolean debug = false; // Toggle debug error reporting
    private Set<Id> subscriptionIdSet = new Set<Id>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query =
            'SELECT Id, OwnerId, Apex_Owner_Should_Be__c, Private_in_Salesforce__c, ' +
            'Apex_Private_in_Salesforce_Should_Be__c, Subscription__c ' +
            'FROM Subscriber__c ' +
            'WHERE Subscription__r.Subscriber_Privacy_Changed__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        // Check each Subscriber record, and set the Owner and Private_In_Salesforce fields to match the values
        // calculated by their corresponding formula fields if they don't match
        List<Subscriber__c> subUpdateList = new List<Subscriber__c>();
        for (Subscriber__c sub : (List<Subscriber__c>) scope) {
            if (
                sub.OwnerId != sub.Apex_Owner_Should_Be__c ||
                sub.Private_in_Salesforce__c != Boolean.valueOf(sub.Apex_Private_in_Salesforce_Should_Be__c)
            ) {
                sub.OwnerId = sub.Apex_Owner_Should_Be__c;
                sub.Private_in_Salesforce__c = Boolean.valueOf(sub.Apex_Private_in_Salesforce_Should_Be__c);
                subUpdateList.add(sub);
            }
            // Add to the ID set so we can reset the Subscriber_Privacy_Changed flags in the finish method
            subscriptionIdSet.add(sub.Subscription__c);
        }
        if (!subUpdateList.isEmpty()) {
            try {
                update subUpdateList;
            } catch (Exception ex) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('scope', scope));
                vars.add(ErrorLogger.convertListToJSON('subUpdateList', subUpdateList));
                ErrorLogger.log(ex, vars, debug);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Reset all of the Subscriber_Privacy_Changed flags to false
        List<Subscription__c> subscriptions = new List<Subscription__c>();
        for (Id subId : subscriptionIdSet) {
            Subscription__c sub = new Subscription__c();
            sub.Id = subId;
            sub.Subscriber_Privacy_Changed__c = false;
            subscriptions.add(sub);
        }
        if (!subscriptions.isEmpty()) {
            try {
                update subscriptions;
            } catch (Exception ex) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('subscriptions', subscriptions));
                ErrorLogger.log(ex, vars, debug);
            }
        }
    }
}
