global class ContactHashUpdateBatch implements Database.Batchable<sObject>{
    global final String Query;
    
    global ContactHashUpdateBatch(){
        Query = 'SELECT Id, HashContactId__c FROM Contact';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Contact> cList = (List<Contact>) scope;
        for(Integer i = 0; i < cList.size(); i++){
            cList[i].HashContactId__c = hashId(cList[i].Id);
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