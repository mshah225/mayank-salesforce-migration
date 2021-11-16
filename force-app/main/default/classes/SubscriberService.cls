public without sharing class SubscriberService {
    @TestVisible
    private static Boolean parentSubsSynced = false;

    /**
     * Updates Subscriber OwnerID and Private in Salesforce values to match their corresponding
     * formula field values
     * @param A List of Subscriber records to process
     */
    public static void enforceOwnerPolicies(List<Subscriber__c> subList) {
        for (Subscriber__c sub : subList) {
            if (
                (sub.OwnerId != sub.Apex_Owner_Should_Be__c && sub.Apex_Owner_Should_Be__c != null) ||
                (sub.Apex_Private_in_Salesforce_Should_Be__c != null &&
                sub.Private_in_Salesforce__c != Boolean.valueOf(sub.Apex_Private_in_Salesforce_Should_Be__c))
            ) {
                sub.OwnerId = sub.Apex_Owner_Should_Be__c;
                sub.Private_in_Salesforce__c = sub.Apex_Private_in_Salesforce_Should_Be__c != null
                    ? Boolean.valueOf(sub.Apex_Private_in_Salesforce_Should_Be__c)
                    : false;
            }
        }
    }

    /**
     * Upon opt-in, creates a Subscriber record for the parent Subscription if it does not already exist
     *
     * @param A List of Subscriber records to process
     */

    public static void syncParentSubscribers(List<Subscriber__c> subList) {
        if (parentSubsSynced) {
            return;
        }

        Set<Id> subscriptionIds = new Set<Id>();
        Set<Id> contactAndLeadIds = new Set<Id>();
        for (Subscriber__c sub : subList) {
            if (sub.Subscriber_Status__c == 'Subscribed') {
                subscriptionIds.add(sub.Subscription__c);
                if (sub.Contact__c != null)
                    contactAndLeadIds.add(sub.Contact__c);
                else if (sub.Lead__c != null)
                    contactAndLeadIds.add(sub.Lead__c);
            }
        }
        Map<Id, Subscription__c> subscriptionMap = new Map<Id, Subscription__c>(
            [SELECT Id, Parent_Subscription__c, Subscription_Type__c FROM Subscription__c WHERE Id IN :subscriptionIds]
        );

        Set<id> parentSubIds = new Set<Id>();
        for (Id subId : subscriptionMap.keySet()) {
            if (subscriptionMap.get(subId).Subscription_Type__c != 'Business Unit') {
                parentSubIds.add(subscriptionMap.get(subId).Parent_Subscription__c);
            }
        }

        Map<String, Subscriber__c> buSubAndContactToSubscriberMap = new Map<String, Subscriber__c>();
        for (Subscriber__c sub : [
            SELECT Id, Subscription__c, Subscriber_Status__c, Contact__c, Lead__c
            FROM Subscriber__c
            WHERE
                (Contact__c IN :contactAndLeadIds
                OR Lead__c IN :contactAndLeadIds)
                AND Subscription__c IN :parentSubIds
        ]) {
            if (sub.Contact__c != null) {
                buSubAndContactToSubscriberMap.put(sub.Subscription__c + '|' + sub.Contact__c, sub);
            } else if (sub.Lead__c != null) {
                buSubAndContactToSubscriberMap.put(sub.Subscription__c + '|' + sub.Lead__c, sub);
            }
        }

        List<Subscriber__c> subscribersToUpdate = new List<Subscriber__c>();
        List<Subscriber__c> subscribersToInsert = new List<Subscriber__c>();
        Set<String> itemsProcessed = new Set<String>();
        for (Subscriber__c sub : subList) {
            if (!subscriptionMap.containsKey(sub.Subscription__c)) {
                continue;
            }
            if (sub.Subscriber_Status__c != 'Subscribed') {
                continue;
            }
            if (subscriptionMap.get(sub.Subscription__c).Subscription_Type__c == 'Business Unit') {
                continue;
            }
            String compositeKey;
            if (sub.Contact__c != null) {
                compositeKey = subscriptionMap.get(sub.Subscription__c).Parent_Subscription__c + '|' + sub.Contact__c;
            } else if (sub.Lead__c != null) {
                compositeKey = subscriptionMap.get(sub.Subscription__c).Parent_Subscription__c + '|' + sub.Lead__c;
            }

            if (itemsProcessed.contains(compositeKey)) {
                continue;
            }
            if (buSubAndContactToSubscriberMap.containsKey(compositeKey)) {
                Subscriber__c buSubscriber = buSubAndContactToSubscriberMap.get(compositeKey);
                if (buSubscriber.Subscriber_Status__c != 'Subscribed') {
                    buSubscriber.Subscriber_Status__c = 'Subscribed';
                    subscribersToUpdate.add(buSubscriber);
                }
            } else {
                subscribersToInsert.add(
                    new Subscriber__c(
                        Contact__c = sub.Contact__c,
                        Lead__c = sub.Lead__c,
                        Subscription__c = subscriptionMap.get(sub.Subscription__c).Parent_Subscription__c,
                        Subscriber_Status__c = 'Subscribed'
                    )
                );
            }
            itemsProcessed.add(compositeKey);
        }

        parentSubsSynced = true;

        if (subscribersToUpdate.size() > 0) {
            update subscribersToUpdate;
        }
        if (subscribersToInsert.size() > 0) {
            insert subscribersToInsert;
        }
    }

    /**
     * Returns all the fields on Subscriber in a String
     * @return A string containing all the Subscriber fields
     */
    public static String subscriberFieldsToString() {
        String subscriberFields = null;
        Map<String, SObjectField> subscriberFieldMap = ObjectService.getObjectFieldMap('Subscriber__c');
        subscriberFields = ObjectService.objectFieldsToString(subscriberFieldMap);
        return subscriberFields;
    }

    /**
     * Get a list of Subscribers for the provided Contact Id
     * @param The Id of the Contact to search on
     * @return A list of Subscribers for the provided Contact Id
     */
    public static List<Subscriber__c> getSubscribers(Id contactId) {
        String subFields = subscriberFieldsToString();
        List<Subscriber__c> subs = new List<Subscriber__c>();
        String soql =
            '' +
            'SELECT ' +
            subFields +
            ', Subscription__r.Name, Subscription__r.Subscription_Type__c, ' +
            'Subscription__r.Business_Unit__r.Name ' +
            'FROM Subscriber__c ' +
            'WHERE Contact__c = :contactId ' +
            'ORDER BY Subscription__r.Name ';
        subs = Database.query(soql);
        return subs;
    }

    /**
     * Creates a hash from the Subscriber ID and sets it as a unique identifier
     * @param subIdList the subscriber Id List
     */
    @future
    public static void setHashId(List<Id> subIdList) {
        List<Subscriber__c> subList = new List<Subscriber__c>();
        for (Id subscriberId : subIdList) {
            Subscriber__c subscriberToHash = new Subscriber__c(
                Id = subscriberId,
                HashSubscriberID__c = Hasher.hashId(subscriberId)
            );
            subList.add(subscriberToHash);
        }
        update subList;
    }

    /**
     * Creates a hash from the Subscriber ID and sets it as a unique identifier
     * @param subIdList the list of subscribers
     */
    public static void setHashIdNotFuture(List<Id> subIdList) {
        List<Subscriber__c> subscribersWithHashes = new List<Subscriber__c>();
        for (Subscriber__c subscriber : [SELECT ID, HashSubscriberID__c FROM Subscriber__c WHERE ID IN :subIdList]) {
            if (subscriber.HashSubscriberID__c == null) {
                subscriber.HashSubscriberID__c = Hasher.hashId(subscriber.ID);
                subscribersWithHashes.add(subscriber);
            }
        }
        update subscribersWithHashes;
    }
}
