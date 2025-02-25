/**
 * Recursively delete records and their child records using the Record_Deleter_Setting__mdt custom metadata
 * You should probably chunk what you pass into this to avoid running into governor limits.  I suggest using
 * a Batchable to operate on all records in batches of ~200
 */
public inherited sharing class RecordDeleter {
    /**
     * Check if the current user even has permission to use the RecordDeleter
     *
     * Generally, this is called by whichever class the user is using, before that class
     * starts using the other functions in this class
     */
    public static Boolean currentUserHasAccess() {
        return CustomPermissionHelper.currentUserHasCustomPermission('Record_Deleter_Access');
    }

    String objectType;
    List<String> recordIds;
    RecordHelper.GetValueConfig GET_VALUE_CONFIG;

    public RecordDeleter(String objectType, List<String> recordIds) {
        this.objectType = objectType;
        if (recordIds != null) {
            this.recordIds = new List<String>();
            // convert all to 18 character IDs
            for (String recId : recordIds)
                this.recordIds.add(Id.valueOf(recId).toString());
        }
        this.GET_VALUE_CONFIG = new RecordHelper.GetValueConfig();
        this.GET_VALUE_CONFIG.cache = true;
    }

    /**
     * Do the record deletions
     * Gets all need fields on records it is about to delete
     * Then retrieves all child records and attempts to delete them
     * If all child deletions were successful, then deletes parent record
     */
    public List<DeleteStatus> deleteRecords() {
        LogSuite.logUntuncated('codeflow', 'Deleting ' + objectType + ' records ' + recordIds);

        Map<String, SObject> recordsToDelete = getRecordsMp();
        Map<String, DeleteStatus> results = new Map<String, DeleteStatus>();

        Boolean hasChildren = false;
        Map<String, Set<String>> childrenOfEachType = new Map<String, Set<String>>();
        // Get child records for every record we need to delete
        // group them by type
        for (String parentId : recordsToDelete.keySet()) {
            Map<String, List<String>> childRecordsPerParent = getChildRecords(parentId);

            LogSuite.logUntuncated(
                'codeflow',
                'Got all children for record id=' + parentId + ': ' + childRecordsPerParent
            );

            for (String childObjectType : childRecordsPerParent.keySet()) {
                List<String> childIds = childRecordsPerParent.get(childObjectType);
                for (String childId : childIds) {
                    // At least one child
                    hasChildren = true;
                    // Get children by type (so we can delete them all together)
                    if (!childrenOfEachType.containsKey(childObjectType))
                        childrenOfEachType.put(childObjectType, new Set<String>());
                    childrenOfEachType.get(childObjectType).add(childId);
                }
            }
        }

        Map<String, SObject> safeToDeleteRecordsMp = new Map<String, SObject>();
        Map<String, DeleteStatus> childIdToDeleteStatus = new Map<String, DeleteStatus>();

        // Populate map of which records we /can/ delete
        // if we have children, we need to try deleting those child records to determine if we can safely delete this record
        // if we have no children, then we can definitely attempt deleting this record
        if (hasChildren) {
            LogSuite.logUntuncated('codeflow', 'Deleting ' + objectType + '\'s child records');

            // If we have children means we need to call the RecordDeleter for the children
            for (String childObjectType : childrenOfEachType.keySet()) {
                LogSuite.logUntuncated(
                    'codeflow',
                    'Need to delete child ' + childObjectType + ' records ' + childrenOfEachType.get(childObjectType)
                );
                RecordDeleter childRecordDeleter = new RecordDeleter(
                    childObjectType,
                    new List<String>(childrenOfEachType.get(childObjectType))
                );
                List<DeleteStatus> childResults = childRecordDeleter.deleteRecords();
                for (DeleteStatus childStatus : childResults)
                    childIdToDeleteStatus.put(childStatus.recordId, childStatus);
            }

            // Find which parents we can continue deleting and which need errors propagated
            List<String> parentsWithChildErrors = new List<String>();
            for (String parentId : recordsToDelete.keySet()) {
                Map<String, List<String>> childRecordsPerParent = getChildRecords(parentId);
                for (String childObjectType : childRecordsPerParent.keySet()) {
                    List<String> childIds = childRecordsPerParent.get(childObjectType);
                    for (String childId : childIds) {
                        DeleteStatus childStatus = childIdToDeleteStatus.get(childId);
                        if (!childStatus.isSuccess())
                            parentsWithChildErrors.add(parentId);
                    }
                }
            }

            // Include those with no errors for deletion
            for (String parentId : recordsToDelete.keySet())
                if (!parentsWithChildErrors.contains(parentId))
                    safeToDeleteRecordsMp.put(parentId, recordsToDelete.get(parentId));
        } else {
            LogSuite.logUntuncated('codeflow', 'No children found for ' + objectType + ' records');
            // No children means we are at the end of the delete chain
            // include all for deletion
            for (SObject rec : recordsToDelete.values())
                safeToDeleteRecordsMp.put(rec.Id, rec);
        }

        // Delete any we can safely delete
        // and populate result object
        if (!safeToDeleteRecordsMp.isEmpty()) {
            // Check governor limit safe to delete
            GovernorLimitPreemptException.assertCanDML(
                1,
                'Cannot delete records due to reaching DML governor limit - unable to delete: ' +
                String.join(safeToDeleteRecordsMp.keySet(), ', ')
            );

            // Do delete, allow paritial successes
            LogSuite.logUntuncated('codeflow', 'Deleting ' + objectType + ' records');
            List<Database.DeleteResult> dbResults = Database.delete(safeToDeleteRecordsMp.values(), false);
            LogSuite.logUntuncated('codeflow', 'Deleted ' + objectType + ' records');
            // Check success/fail
            for (Database.DeleteResult dbResult : dbResults) {
                // Extract error messsage
                String errorMsg = null;
                List<String> errorMsgs = new List<String>();
                for (Database.Error dbErr : dbResult.getErrors()) {
                    if (dbErr.getMessage().contains('entity is deleted'))
                        continue; // ignore already deleted errors
                    errorMsgs.add(dbErr.getMessage());
                }
                if (!errorMsgs.isEmpty())
                    errorMsg = String.join(errorMsgs, '. '); // failed delete

                // Map record id to success/failure
                results.put(
                    dbResult.getId(),
                    new DeleteStatus(objectType, dbResult.getId(), errorMsg == null, errorMsg)
                );
                LogSuite.logUntuncated(
                    'codeflow',
                    'Attempted to delete ' +
                        objectType +
                        ' record (id=' +
                        dbResult.getId() +
                        ') and it ' +
                        (errorMsg == null ? 'succeeded' : 'failed with error msg "' + errorMsg + '"')
                );
            }
        }

        // Append child results to each parent record
        for (String parentId : recordsToDelete.keySet()) {
            DeleteStatus status;
            if (results.containsKey(parentId)) {
                status = results.get(parentId); // was deleted already
            } else {
                status = new DeleteStatus(objectType, parentId, false, null); // skipped bc child failed to delete
                results.put(parentId, status);
            }

            Map<String, List<String>> childRecordsPerParent = getChildRecords(parentId);
            for (String childObjectType : childRecordsPerParent.keySet()) {
                List<String> childIds = childRecordsPerParent.get(childObjectType);
                for (String childId : childIds) {
                    DeleteStatus childStatus = childIdToDeleteStatus.get(childId);
                    status.addChildDeleteStatus(childStatus);
                }
            }
        }

        // Finally generate list in original order and return
        List<DeleteStatus> resultsLs = new List<DeleteStatus>();
        for (String recordId : recordIds)
            resultsLs.add(results.get(recordId));
        return resultsLs;
    }

    /**
     * Get all the records we need to delete, a mapping from record id to Sobject
     * If we need any fields other than ID, we will query to get that information
     * @throws ParentKeyException If the parent key path does not start with "$."
     * @throws ChildKeyException If the child key path does not start with "$."
     * @throws KeyTypeException If the key path points at a field that is an invalid type
     * @throws GovernorLimitPreemptException If we need to perform SOQL but are already at the governor limit
     */
    public Map<String, SObject> getRecordsMp() {
        if (recordsMp == null) {
            LogSuite.logUntuncated('codeflow', 'Need to retrieve all fields for ' + objectType + ' records');

            recordsMp = new Map<String, SObject>();
            Set<String> parentFieldsToQuery = new Set<String>();

            // Get all fields we need to query - if we need fields other than id, we will need to do a query to get them
            for (DeleteMap deleteMp : getDeleteMapsForType(objectType)) {
                // Don't need to query id
                if (deleteMp.parentKey == '$.Id')
                    continue;

                // Add to fields to query
                parentFieldsToQuery.add(deleteMp.parentKey.substringAfter('$.'));
                LogSuite.logUntuncated('codeflow', 'Need to query field ' + deleteMp.parentKey);
            }

            // Check all field types
            for (String fieldToQuery : parentFieldsToQuery) {
                LogSuite.logUntuncated('codeflow', 'Verifying field ' + fieldToQuery);

                Schema.DescribeFieldResult fieldDescr = ObjectHelper.getFieldDescribe(objectType, fieldToQuery);

                // Valid type? (we only support string-coerceable types - since we later must cast to string query records)
                Schema.DisplayType fieldType = fieldDescr.getType();

                if (
                    !(fieldType == Schema.DisplayType.ID ||
                    fieldType == Schema.DisplayType.STRING ||
                    fieldType == Schema.DisplayType.REFERENCE)
                ) {
                    throw new KeyTypeException(
                        'Cannot key on a field named ' +
                            fieldToQuery +
                            ', which is of type ' +
                            fieldType +
                            '. Please use a different key field (we support string, id, and lookup fields)'
                    );
                }
            }

            // Query fields and create mapping
            if (!parentFieldsToQuery.isEmpty()) {
                LogSuite.logUntuncated('codeflow', 'Query needed to get fields for ' + objectType);
                DynamicSoqlBuilder queryMaker = new DynamicSoqlBuilder(objectType)
                    .returnField('Id')
                    .bind('recordIds', recordIds)
                    .restrictIn('Id', new DynamicSoqlBuilderRestriction.Bind('recordIds'));
                // Add all fields
                for (String fieldToQuery : parentFieldsToQuery)
                    queryMaker.returnField(fieldToQuery);
                // Safe to run
                GovernorLimitPreemptException.assertCanQueryN(
                    1,
                    'Cannot query ' + objectType + ' records due to reaching SOQL query governor limit'
                );
                GovernorLimitPreemptException.assertCanQueryRowsN(
                    recordIds.size(),
                    'Cannot query ' + objectType + ' records due to reaching SOQL row governor limit'
                );
                // Actually run it and create mapping
                for (SObject rec : queryMaker.query())
                    recordsMp.put(rec.Id, rec);

                // for any records that didn't exist, map to an empty object as nonexisting records
                // is not worth complaining about
                for (String recId : recordIds) {
                    if (recordsMp.containsKey(recId))
                        continue;

                    Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objectType);

                    SObject mockRecord = sObjType.newSObject(recId);
                    Schema.DescribeSObjectResult descr = sObjType.getDescribe();

                    for (String fieldToQuery : parentFieldsToQuery) {
                        String firstStepOfPath = fieldToQuery.split('\\.')[0];
                        if (firstStepOfPath.toLowerCase() == 'id')
                            continue;
                        if (descr.fields.getMap().containsKey(firstStepOfPath))
                            mockRecord.put(firstStepOfPath, null);
                        else
                            mockRecord.put(
                                ObjectHelper.getDescribeFromLookupName(descr, firstStepOfPath).getName(),
                                null
                            );
                    }

                    recordsMp.put(recId, mockRecord);
                }
            } else {
                LogSuite.logUntuncated('codeflow', 'No query needed to get fields for ' + objectType);
                // We don't need any field other than the id - we already have that, so just create a mapping
                for (String recId : recordIds)
                    recordsMp.put(recId, Schema.getGlobalDescribe().get(objectType).newSObject(recId));
            }
        }
        return recordsMp;
    }
    private Map<String, SObject> recordsMp;

    /**
     * Get a list (grouped by object type) of all the child records
     * you need to delete for a specific parent record id
     * @throws ParentKeyException If the parent key path does not start with "$."
     * @throws ChildKeyException If the child key path does not start with "$."
     * @throws GovernorLimitPreemptException If we need to perform SOQL but are already at the governor limit
     */
    public Map<String, List<String>> getChildRecords(String parentId) {
        if (parentIdToChildTypeToChildIds == null) {
            LogSuite.logUntuncated('codeflow', 'Need to retrieve all children for ' + objectType + ' records');
            parentIdToChildTypeToChildIds = new Map<String, Map<String, List<String>>>();

            for (DeleteMap deleteMp : getDeleteMapsForType(objectType)) {
                LogSuite.logUntuncated('codeflow', 'Need to query for child ' + deleteMp.childType + ' records');
                // Query the child id field
                DynamicSoqlBuilder queryChildRecords = new DynamicSoqlBuilder(deleteMp.childType)
                    .returnField('Id')
                    .returnField(deleteMp.childKey.substringAfter('$.'));

                // Get valid values from parent records
                List<String> validValues = new List<String>();
                String parentKey = deleteMp.parentKey;
                for (SObject record : getRecordsMp().values()) {
                    Object obj = RecordHelper.getValue(record, parentKey, GET_VALUE_CONFIG);
                    String s = (String) obj;
                    if (String.isNotBlank(s))
                        validValues.add(s);
                }

                // Add restriction
                queryChildRecords.restrictIn(deleteMp.childKey.substringAfter('$.'), validValues);

                // Safe to run
                GovernorLimitPreemptException.assertCanQueryN(
                    1,
                    'Cannot query ' + deleteMp.childType + ' records due to reaching SOQL query governor limit'
                );
                GovernorLimitPreemptException.assertCanQueryRowsN(
                    validValues.size(),
                    'Cannot query ' + deleteMp.childType + ' records due to reaching SOQL row governor limit'
                );

                // Do the query!
                List<SObject> childrenToDelete = queryChildRecords.query();

                // Find which child is for which parent (so we can propagate errors correctly)
                LogSuite.logUntuncated(
                    'codeflow',
                    'Need to match child ' +
                        deleteMp.childType +
                        '(' +
                        deleteMp.childKey +
                        ') records to their parent ' +
                        objectType +
                        '(' +
                        parentKey +
                        ') record'
                );

                for (SObject childToDelete : childrenToDelete) {
                    LogSuite.logUntuncated('codeflow', 'Matching child record id=' + childToDelete.Id);

                    // Get field value from child path
                    Object childKeyValue = RecordHelper.getValue(childToDelete, deleteMp.childKey, GET_VALUE_CONFIG);
                    if (String.isBlank((String) childKeyValue))
                        continue;

                    LogSuite.logUntuncated('codeflow', 'Matching on value ' + childKeyValue);

                    // Find which parent (or parents) object this child is for
                    Boolean noParent = true;
                    for (SObject record : getRecordsMp().values()) {
                        Object parentFieldValue = RecordHelper.getValue(record, parentKey, GET_VALUE_CONFIG);
                        if (String.isBlank((String) parentFieldValue))
                            continue;

                        if (parentFieldValue.equals(childKeyValue)) {
                            LogSuite.logUntuncated(
                                'codeflow',
                                'Matched child record id=' +
                                    childToDelete.Id +
                                    ' matched to parent record id=' +
                                    record.Id
                            );

                            String matchedParentId = record.Id;
                            noParent = false;

                            if (!parentIdToChildTypeToChildIds.containsKey(matchedParentId))
                                parentIdToChildTypeToChildIds.put(matchedParentId, new Map<String, List<String>>());
                            if (!parentIdToChildTypeToChildIds.get(matchedParentId).containsKey(deleteMp.childType))
                                parentIdToChildTypeToChildIds.get(matchedParentId)
                                    .put(deleteMp.childType, new List<String>());
                            parentIdToChildTypeToChildIds.get(matchedParentId)
                                .get(deleteMp.childType)
                                .add(childToDelete.Id);
                        }
                    }

                    // If we somehow fail to find a parent for this record, then raise an error, since it should not have been returned
                    // (this should never happen and indicates an error in either the SOQL or the child->parent mapping logic above)
                    if (noParent)
                        throw new ChildParentMatchingException(
                            'Child record with id=' +
                                childToDelete.Id +
                                ' was returned for deletion, but we couldn\'t programically associate it with any parent record. This means we would be unable to properly propagate errors. Stopping record deleter.'
                        );
                }
            }
        }

        if (parentIdToChildTypeToChildIds.containsKey(parentId))
            return parentIdToChildTypeToChildIds.get(parentId);
        else
            return new Map<String, List<String>>();
    }
    Map<String, Map<String, List<String>>> parentIdToChildTypeToChildIds;

    /**
     * Get a list of all delete maps for this object type
     * This list will contain all the mappings to all other object types
     * that you need to delete in order to prevent orphaning records
     * @throws ParentKeyException If the parent key path does not start with "$."
     * @throws ChildKeyException If the child key path does not start with "$."
     */
    public static List<DeleteMap> getDeleteMapsForType(String objectType) {
        if (deleteMapListMp == null) {
            deleteMapListMp = new Map<String, List<DeleteMap>>();

            List<Record_Deleter_Setting__mdt> configMetadata = null;
            if (Test.isRunningTest() && TEST_METADATA != null)
                configMetadata = TEST_METADATA;
            else
                configMetadata = [
                    SELECT
                        Parent_Object_Type__c,
                        Child_Object_Type__c,
                        Parent_Field_Key__c,
                        Child_Field_Key__c,
                        Order__c
                    FROM Record_Deleter_Setting__mdt
                ];

            for (Record_Deleter_Setting__mdt configMetadatum : configMetadata) {
                DeleteMap dm = new DeleteMap(configMetadatum);

                if (!deleteMapListMp.containsKey(dm.objectType))
                    deleteMapListMp.put(dm.objectType, new List<DeleteMap>());

                deleteMapListMp.get(dm.objectType).add(dm);
            }

            for (List<DeleteMap> deleteMapLs : deleteMapListMp.values()) {
                deleteMapLs.sort();
            }

            LogSuite.logUntuncated('codeflow', 'All delete maps ' + deleteMapListMp);
        }

        List<DeleteMap> deleteMapsForType = new List<DeleteMap>();
        if (deleteMapListMp.containsKey(objectType)) {
            deleteMapsForType = deleteMapListMp.get(objectType);
        }
        LogSuite.logUntuncated('codeflow', 'Delete map list for type=' + objectType + ' ' + deleteMapsForType);

        return deleteMapsForType;
    }
    private static Map<String, List<DeleteMap>> deleteMapListMp;

    // This class is used to report if a record deletion was successful or not
    public class DeleteStatus {
        public String recordId;
        public String objectType;
        public Boolean success;
        public String errorMsg;

        public DeleteStatus(String objType, String recId, Boolean success, String errMsg) {
            this.objectType = objType;
            this.recordId = recId;
            this.success = success;
            this.errorMsg = errMsg;
        }
        public String getRecordId() {
            return this.recordId;
        }
        public String getObjectType() {
            return this.objectType;
        }
        public Boolean isSuccess() {
            return this.success;
        }
        public String getErrorMessage() {
            return this.errorMsg;
        }

        /**
         * Add a child status, and propagate errors
         */
        public void addChildDeleteStatus(DeleteStatus childStatus) {
            if (!childStatus.isSuccess()) {
                this.success = false;
                String detailedErrorMsg =
                    'Failed to delete child ' +
                    childStatus.getObjectType() +
                    ' record (id=' +
                    childStatus.getRecordId() +
                    ') because: ' +
                    childStatus.getErrorMessage();
                // append to existing if already has some errors
                if (this.errorMsg != null)
                    detailedErrorMsg += this.errorMsg + '; ' + detailedErrorMsg;
                this.errorMsg = detailedErrorMsg;
            }
        }
    }

    // This class is a mapping of what records will need to be deleted
    public class DeleteMap implements Comparable {
        public String objectType;
        public String childType;
        public String parentKey;
        public String childKey;
        public Decimal order;

        /**
         * @throws ParentKeyException If the parent key path does not start with "$."
         * @throws ChildKeyException If the child key path does not start with "$."
         */
        public DeleteMap(Record_Deleter_Setting__mdt customSetting) {
            objectType = customSetting.Parent_Object_Type__c;
            childType = customSetting.Child_Object_Type__c;
            parentKey = customSetting.Parent_Field_Key__c;
            childKey = customSetting.Child_Field_Key__c;
            order = customSetting.Order__c;

            if (!parentKey.startsWith('$.'))
                throw new ParentKeyException(
                    'Parent key should begin with "$.", but it instead is "' + parentKey + '".'
                );
            if (!childKey.startsWith('$.'))
                throw new ChildKeyException('Child key should begin with "$.", but it instead is "' + childKey + '".');
        }

        /**
         * Order by ASC `order` value
         * if order is null, then it goes AFTER any numbered value
         */
        public Integer compareTo(Object instance) {
            DeleteMap that = (DeleteMap) instance;

            if (this.order == that.order)
                return 0;
            if (this.order == null)
                return -1;
            if (that.order == null)
                return 1;

            return that.order > this.order ? 1 : -1;
        }
    }

    // Exception classes
    public class ParentKeyException extends Exception {
    }
    public class ChildKeyException extends Exception {
    }
    public class ChildParentMatchingException extends Exception {
    }
    public class KeyTypeException extends Exception {
    }

    // Test overrides (to allow us to test failure paths that generally should not happen)
    @TestVisible
    private static List<Record_Deleter_Setting__mdt> TEST_METADATA = null;
}
