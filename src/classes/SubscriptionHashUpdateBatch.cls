global class SubscriptionHashUpdateBatch implements Database.Batchable<sObject>{
	global final String Query;

   global SubscriptionHashUpdateBatch(){
       Query = 'SELECT Id, HashSubscriptionId__c FROM Subscription__c';
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Subscription__c> cList = (List<Subscription__c>) scope;
        for(Integer i = 0; i < cList.size(); i++){
            cList[i].HashSubscriptionId__c = Hasher.hashId(cList[i].Id);
        }     
        update scope;
    }

   global void finish(Database.BatchableContext BC){

   }
}