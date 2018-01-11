public class CampaignHashUpdateBatch implements Database.Batchable<sObject> {
    public final String query;
    
    public CampaignHashUpdateBatch() {
        query = 'SELECT Id, HashCampaignId__c FROM Campaign WHERE HashCampaignId__c = null';
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Campaign> cList = (List<Campaign>) scope;
        for(Integer i = 0; i < cList.size(); i++){
            cList[i].HashCampaignId__c = Hasher.hashId(cList[i].Id);
        }     
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}