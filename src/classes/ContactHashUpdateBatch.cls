public class ContactHashUpdateBatch implements Database.Batchable<sObject>{
    public final String query;
    
    public ContactHashUpdateBatch(){
        query = 'SELECT Id, HashContactId__c FROM Contact WHERE HashContactId__c = null';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Contact> cList = (List<Contact>) scope;
        for(Integer i = 0; i < cList.size(); i++){
            cList[i].HashContactId__c = Hasher.hashId(cList[i].Id);
        }     
        update scope;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}