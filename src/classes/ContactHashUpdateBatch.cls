public class ContactHashUpdateBatch implements Database.Batchable<Contact>{
    public final String query;
    
    public ContactHashUpdateBatch(){
        query = 'SELECT Id, HashContactId__c FROM Contact WHERE HashContactId__c = null';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        for(Contact con : scope){
            con.HashContactId__c = Hasher.hashId(con.Id);
        }     
        update scope;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}