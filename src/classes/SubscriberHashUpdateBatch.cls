public class SubscriberHashUpdateBatch implements Database.Batchable<sObject>, Schedulable{
	public final String query;

   public SubscriberHashUpdateBatch(){
       query = 'SELECT Id, HashSubscriberId__c FROM Subscriber__c';
   }

   public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Subscriber__c> cList = (List<Subscriber__c>) scope;
        for(Integer i = 0; i < cList.size(); i++){
            cList[i].HashSubscriberId__c = hashId(cList[i].Id);
        }     
        update scope;
    }

   public void finish(Database.BatchableContext BC){

   }
    
   public String hashId(String subIdIn) {
       Blob blobId = Blob.valueOf(subIdIn);
       Blob digestId = Crypto.generateDigest('SHA-512', blobId);
       String stringId = EncodingUtil.base64Encode((digestId));
       String encodedId = EncodingUtil.urlEncode(stringId, 'UTF-8');
       return encodedId;
   }
   
   public void execute(SchedulableContext sc) {
       BatchApplySubscriberPrivacy b = new BatchApplySubscriberPrivacy();
       database.executebatch(b, 200);
   }
}