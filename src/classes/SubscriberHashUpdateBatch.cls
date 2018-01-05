global class SubscriberHashUpdateBatch implements Database.Batchable<sObject>{
	global final String Query;

   global SubscriberHashUpdateBatch(){
       Query = 'SELECT Id, HashSubscriberId__c FROM Subscriber__c';
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Subscriber__c> cList = (List<Subscriber__c>) scope;
        for(Integer i = 0; i < cList.size(); i++){
            cList[i].HashSubscriberId__c = Hasher.hashId(cList[i].Id);
        }     
        update scope;
    }

   global void finish(Database.BatchableContext BC){

   }
}