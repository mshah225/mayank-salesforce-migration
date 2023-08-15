public class TagService {

    public static void updateRecordTypes(Map<Id, Tag__c> newMap, Map<Id, Tag__c> oldMap) {

        for (Id tagId : newMap.keyset()) {
            String newRecordTypeName = newMap.get(tagId).RecordType.DeveloperName;
            String oldRecordTypeName = oldMap.get(tagId).RecordType.DeveloperName;

            if (newRecordTypeName != oldRecordTypeName) {
                Id batchInstanceId = Database.executeBatch(new UpdateObjectTags(oldRecordTypeName, newRecordTypeName), 200);
            }
        }

    }


    public class UpdateObjectTags implements Database.Batchable<sObject>{
        public final String QUERY;
        public final String RTID;
     
        public UpdateObjectTags(String oldRecordType, String newRecordType) {
                  QUERY = 'SELECT Id FROM Tag__c WHERE RecordType.DeveloperName = ' + oldRecordType;
                  RTID = (String) Schema.SObjectType.Object_Tag__c.getRecordTypeInfosByDeveloperName().get(newRecordType).getRecordTypeId();        
        }
     
        public Database.QueryLocator start(Database.BatchableContext BC){
           return Database.getQueryLocator(query);
        }
     
        public void execute(Database.BatchableContext BC, List<sObject> scope) {
            for (Sobject s : scope) {
                s.put(RecordTypeId, RTID); 
            }

            update scope;
        }
     
        public void finish(Database.BatchableContext BC){
     
        }
     
     }
}