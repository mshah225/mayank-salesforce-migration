public class SubscriptionHashUpdateBatch implements Database.Batchable<sObject> {
    public final String query;

    public SubscriptionHashUpdateBatch() {
        query = 'SELECT Id, HashSubscriptionId__c FROM Subscription__c';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Subscription__c> scope) {
        for (Subscription__c sub : scope) {
            sub.HashSubscriptionId__c = Hasher.hashId(sub.Id);
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
    }
}
