public class SubscriberHashUpdateBatch implements Database.Batchable<sObject> {
    public final String query;

    public SubscriberHashUpdateBatch() {
        query = 'SELECT Id, HashSubscriberId__c FROM Subscriber__c';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Subscriber__c> scope) {
        for (Subscriber__c sub : scope) {
            sub.HashSubscriberId__c = Hasher.hashId(sub.Id);
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
    }
}
