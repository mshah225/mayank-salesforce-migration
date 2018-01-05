public class SubscriptionService {

    @future
    public static void setHashId(List<Id> subIdList) {
        List<Subscription__c> subList = new List<Subscription__c>();
        for(Id i : subIdList) {
            Subscription__c c = new Subscription__c(Id = i, HashSubscriptionID__c = hashId(i));
            subList.add(c);
        }
        update subList;
    }
    
    static String hashId(String IdIn) {
        Blob blobId = Blob.valueOf(IdIn);
        Blob digestId = Crypto.generateDigest('SHA-512', blobId);
        String stringId = EncodingUtil.base64Encode((digestId));
        String encodedId = EncodingUtil.urlEncode(stringId, 'UTF-8');
        return encodedId;
    }
}