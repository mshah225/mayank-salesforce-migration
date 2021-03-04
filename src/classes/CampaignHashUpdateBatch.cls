public class CampaignHashUpdateBatch implements Database.Batchable<sObject> {
    public final String query;

    public CampaignHashUpdateBatch() {
        query = 'SELECT Id, HashCampaignId__c FROM Campaign WHERE HashCampaignId__c = null';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Campaign> scope) {
        for (Campaign camp : scope) {
            camp.HashCampaignId__c = Hasher.hashId(camp.Id);
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
    }
}
