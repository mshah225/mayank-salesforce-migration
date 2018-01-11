public class SubscriptionHashUpdateBatch implements Database.Batchable<sObject> {
    public final String query;

    public SubscriptionHashUpdateBatch() {
        query = 'SELECT Id, HashSubscriptionId__c FROM Subscription__c';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Subscription__c> cList = (List<Subscription__c>) scope;
        for(Integer i = 0; i < cList.size(); i++){
            cList[i].HashSubscriptionId__c = Hasher.hashId(cList[i].Id);
        }     
        update scope;
    }

   global void finish(Database.BatchableContext BC){

   }
}