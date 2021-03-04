public without sharing class LeadSubscriberOptInBatch implements Database.Batchable<Sobject> {
    public String query;

    public LeadSubscriberOptInBatch() {
        query =
            'SELECT Id ' +
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
        Set<Id> leadIds = new Set<Id>();

        for (Lead leadToSubscribe : leadsToAddSubscribers) {
            leadIds.add(leadToSubscribe.Id);
        }
        List<Subscriber__c> existingSubscribers = [
            SELECT Id, Lead__c
            FROM Subscriber__c
            WHERE Lead__c IN :leadIds AND Subscription__c = 'a280W000007iaYX'
        ];

        Set<Id> leadWithExistingSubscribers = new Set<Id>();
        for (Subscriber__c sub : existingSubscribers) {
            leadWithExistingSubscribers.add(sub.Lead__c);
        }

        for (Lead leadToSubscribe : leadsToAddSubscribers) {
            if (leadWithExistingSubscribers.contains(leadToSubscribe.Id)) {
                continue;
            }
            newSubscribers.add(
                new Subscriber__c(
                    Subscription__c = 'a271h00000068lr',
                    Lead__c = leadToSubscribe.Id,
                    Subscriber_Status__c = 'Subscribed'
                )
            );
        }
        insert newSubscribers;
    }

    public void finish(Database.BatchableContext batchableContext) {
    }
}
