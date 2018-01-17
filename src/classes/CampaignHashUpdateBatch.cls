public class CampaignHashUpdateBatch implements Database.Batchable<Campaign> {
    public final String query;
    
    public CampaignHashUpdateBatch() {
        query = 'SELECT Id, HashCampaignId__c FROM Campaign WHERE HashCampaignId__c = null';
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Campaign> scope) {
        for(Campaign camp : scope){
            camp.HashCampaignId__c = Hasher.hashId(camp.Id);
        }     
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}