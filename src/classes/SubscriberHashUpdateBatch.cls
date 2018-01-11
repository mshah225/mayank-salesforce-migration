public class SubscriberHashUpdateBatch implements Database.Batchable<sObject>, Schedulable{
	public final String query;

   public SubscriberHashUpdateBatch(){
       query = 'SELECT Id, HashSubscriberId__c FROM Subscriber__c';
   }

   public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Subscriber__c> cList = (List<Subscriber__c>) scope;
        for(Integer i = 0; i < cList.size(); i++){
            cList[i].HashSubscriberId__c = Hasher.hashId(cList[i].Id);
        }     
        update scope;
    }

   public void finish(Database.BatchableContext BC){

   }

}