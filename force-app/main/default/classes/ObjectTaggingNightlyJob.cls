global class ObjectTaggingNightlyJob implements Schedulable  {

    global void execute(SchedulableContext SC) {

        String objectTagQuery = 'SELECT Id FROM Object_Tag__c WHERE ';
        Map<String, Object_Tag_Mapping__mdt> relatedObjectMap = Object_Tag_Mapping__mdt.getAll();

        String objectQueryFilter = '';
        for (Object_Tag_Mapping__mdt objectTagMap : relatedObjectMap.values()) {
            if (!objectTagMap.Use_Related_Object__c) {
                if (objectQueryFilter != '') {
                    objectQueryFilter += 'AND ';
                }
                objectQueryFilter += objectTagMap.Related_Field_Name__c + '= null ';
            }
            
        }

        objectTagQuery += objectQueryFilter;

        List<Object_Tag__c> objectTagsToDelete = Database.query(objectTagQuery);
    
        if (objectTagsToDelete.size() > 0) {
            delete objectTagsToDelete;
        }
     }

}