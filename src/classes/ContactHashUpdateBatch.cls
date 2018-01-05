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
            cList[i].HashContactId__c = Hasher.hashId(cList[i].Id);
        }     
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}