public class SubscriptionHashUpdateBatch implements Database.Batchable<sObject> {
    public final String query;

    public SubscriptionHashUpdateBatch() {
        query = 'SELECT Id, HashSubscriptionId__c FROM Subscription__c';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Subscription__c> cList = (List<Subscription__c>) scope;
        for (Subscription__c subscription : (List<Subscription__c>) scope) {
            subscription.HashSubscriptionId__c = hashId(subscription.Id);
        }    
        update scope;
    }

    public void finish(Database.BatchableContext bc) { }
    
    public String hashId(String subIdIn) {
        Blob blobId = Blob.valueOf(subIdIn);
        Blob digestId = Crypto.generateDigest('SHA-512', blobId);
        String stringId = EncodingUtil.base64Encode((digestId));
        String encodedId = EncodingUtil.urlEncode(stringId, 'UTF-8');
        return encodedId;
    }
}