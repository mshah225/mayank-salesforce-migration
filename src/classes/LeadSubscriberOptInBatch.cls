public without sharing class LeadSubscriberOptInBatch implements Database.Batchable<Sobject> {
    public String query;
    
    public LeadSubscriberOptInBatch() {
        query = 'SELECT Id ' +
        'FROM Lead ' +
        'WHERE HasOptedOutOfEmail = false ' +
        'AND Status = \'Open\' ' +
        'AND IsConverted = false ' +
        'AND RecordType.Name = \'Prospective Student\' ';
    }
    
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext batchableContext, List<sObject> scope) {
        List<Lead> leadsToAddSubscribers = (List<Lead>) scope;
        List<Subscriber__c> newSubscribers = new List<Subscriber__c>();
        for (Lead leadToSubscribe : leadsToAddSubscribers) {
            newSubscribers.add(new Subscriber__c(
                Subscription__c = 'a280W000007iaYX',
                Lead__c = leadToSubscribe.Id,
                Subscriber_Status__c = 'Subscribed'
            ));
        }
        insert newSubscribers;
    }
    
    public void finish(Database.BatchableContext batchableContext) {}
}
