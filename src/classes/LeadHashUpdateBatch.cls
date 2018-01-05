global class LeadHashUpdateBatch implements Database.Batchable<sObject>{
    global final String Query;
    
    global LeadHashUpdateBatch(){
        Query = 'SELECT Id, HashLeadId__c FROM Lead';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Lead> cList = (List<Lead>) scope;
        for(Integer i = 0; i < cList.size(); i++){
            cList[i].HashLeadId__c = Hasher.hashId(cList[i].Id);
        }     
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}