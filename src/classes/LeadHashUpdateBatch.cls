public class LeadHashUpdateBatch implements Database.Batchable<Lead>{
    public final String query;
    
    public LeadHashUpdateBatch(){
        query = 'SELECT Id, HashLeadId__c FROM Lead';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> scope) {
        for(Lead leadIn : scope){
            leadIn.HashLeadId__c = Hasher.hashId(leadIn.Id);
        }     
        update scope;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }

}