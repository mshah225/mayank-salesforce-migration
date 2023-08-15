public class TagBatchUpdateRecordType implements Database.Batchable<sObject>{
    public final String QUERY;
    public final String RTID;
 
    public TagBatchUpdateRecordType(String oldRecordType, String newRecordType) {
              QUERY = 'SELECT Id FROM Tag__c WHERE RecordType.DeveloperName = ' + oldRecordType;
              RTID = (String) Schema.SObjectType.Object_Tag__c.getRecordTypeInfosByDeveloperName().get(newRecordType).getRecordTypeId();        
    }
 
    public Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        for (Sobject s : scope) {
            s.put('RecordTypeId', RTID); 
        }

        update scope;
    }
 
    public void finish(Database.BatchableContext BC){
 
    }
 
 }