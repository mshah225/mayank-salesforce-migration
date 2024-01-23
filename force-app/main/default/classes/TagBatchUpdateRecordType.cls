public class TagBatchUpdateRecordType implements Database.Batchable<sObject> {
    public final String QUERY;
    public final String RTID;

    public TagBatchUpdateRecordType(String newRecordType, Id tagId) {
        QUERY = 'SELECT Id FROM Object_Tag__c WHERE Tag__c = \'' + tagId + '\'';
        RTID = (String) Schema.SObjectType.Object_Tag__c.getRecordTypeInfosByDeveloperName()
            .get(newRecordType)
            .getRecordTypeId();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Object_Tag__c> objectTagsToUpdate = (List<Object_Tag__c>) scope;

        for (Object_Tag__c ot : objectTagsToUpdate) {
            ot.RecordTypeId = RTID;
        }

        update scope;
    }

    public void finish(Database.BatchableContext BC) {
    }
}