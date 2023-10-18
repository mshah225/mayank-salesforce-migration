public class TagService {

    public static void updateRecordTypes(Map<Id, Tag__c> newMap, Map<Id, Tag__c> oldMap) {

        for (Id tagId : newMap.keyset()) {
            String newRecordType = newMap.get(tagId).RecordTypeId;
            String oldRecordType = oldMap.get(tagId).RecordTypeId;
            
            if (newRecordType != oldRecordType) {
                String oldRecordTypeName = [SELECT DeveloperName FROM RecordType WHERE Id =: oldRecordType LIMIT 1].DeveloperName;
                String newRecordTypeName = [SELECT DeveloperName FROM RecordType WHERE Id =: newRecordType LIMIT 1].DeveloperName;
                Id batchInstanceId = Database.executeBatch(new TagBatchUpdateRecordType(oldRecordTypeName, newRecordTypeName), 200);
            }
        }
    }
}