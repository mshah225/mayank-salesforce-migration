global class CampaignHashUpdateBatch implements Database.Batchable<sObject>{
    global final String Query;
    
    global CampaignHashUpdateBatch(){
        Query = 'SELECT Id, HashCampaignId__c FROM Campaign';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Campaign> cList = (List<Campaign>) scope;
        for(Integer i = 0; i < cList.size(); i++){
            cList[i].HashCampaignId__c = hashId(cList[i].Id);
        }     
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    global String hashId(String subIdIn) {
        Blob blobId = Blob.valueOf(subIdIn);
        Blob digestId = Crypto.generateDigest('SHA-512', blobId);
        String stringId = EncodingUtil.base64Encode((digestId));
        String encodedId = EncodingUtil.urlEncode(stringId, 'UTF-8');
        return encodedId;
    }
}