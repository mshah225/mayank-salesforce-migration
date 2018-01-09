public class LeadHashUpdateBatch implements Database.Batchable<sObject>{
    public final String query;
    
    public LeadHashUpdateBatch(){
        query = 'SELECT Id, HashLeadId__c FROM Lead';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Lead> cList = (List<Lead>) scope;
        for(Integer i = 0; i < cList.size(); i++){
            cList[i].HashLeadId__c = hashId(cList[i].Id);
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
}