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
}