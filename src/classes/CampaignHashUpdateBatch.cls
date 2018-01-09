public class CampaignHashUpdateBatch implements Database.Batchable<sObject> {
    public final String query;
    
    public CampaignHashUpdateBatch() {
        query = 'SELECT Id, HashCampaignId__c FROM Campaign WHERE HashCampaignId__c = null';
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        for (Campaign thisCampaign : (List<Campaign>) scope) {
            thisCampaign.HashCampaignId__c = CampaignService.hashId(thisCampaign.HashCampaignId__c);
        }
        update scope;
    }
    
    public void finish(Database.BatchableContext bc) {}
}