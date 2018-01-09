public class ContactHashUpdateBatch implements Database.Batchable<sObject>{
    public final String query;
    
    public ContactHashUpdateBatch(){
        query = 'SELECT Id, HashContactId__c FROM Contact WHERE HashContactId__c = null';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        for (Contact thisContact : (List<Contact>) scope) {
            thisContact.HashContactId__c = ContactHandler.hashId(thisContact.Id);
        }
        update scope;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}