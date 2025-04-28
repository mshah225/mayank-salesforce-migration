/**
 * The RecordController class is a utility for creating, updating, and deleting
 * multiple records at a time.  It is primarily intended for use with LWCs.
 * It primarily acts as a multi-record alternative to the create/update/delete
 * functions in the lightning/uiRecordApi module.
 *
 * Since we expect this is in use with LWC's, usually with the user filling in
 * a form as the frontend there are 2 main categories of errors:
 * 1. DML errors.  Since these are often based on form values, these
 *    are assumed to be recoverable, just requiring the user to change
 *    the values in the form.
 * 2. All other errors.  Which we generally assume are non-recoverable.
 *
 * -- DML Errors --
 *
 * Because DML Errors are meant to be recoverable, we always return a DMLResult object,
 * which indicates if the operation was successful or not.  If the operation failed,
 * it includes a errorMessage that can be shown to the user indicating what they
 * need to change before trying again.
 *
 * -- Non DML Errors --
 *
 * Non-recoverable errors fall into 2 cateogries.
 * a. Permission errors
 * b. All other errors.
 *
 * -- Permission Errors --
 * When creating/updating/deleting records the controller first verifies
 * that the current user has permission to do the operation, checking
 * object-level access, field-level access, and record-level access.
 * When we run into a permissions error, we raise the appropriate exception type.
 *
 * -- All other Errors --
 * All other error types get wrapped in a AuraHandledException error in order to
 * ensure the error message is in a consistent format.
 */
public with sharing class RecordController {
    /**
     * Inserts all records in list while obeying user's object, field, and record
     * level access rules.
     *
     * Need to pass CreateRecordSObject records, since we don't have any record ids
     * to deduce object type information from. Also, when coming from LWC we cannot coerce
     * directly to List<CreateRecordSObject> hence accepting a map and then manually
     * converting it
     *
     * @param records List of records to insert
     * @return A DMLResult object indicating either success or failure
     *         if this failed due to failing a validation rule, then the error
     *         message can be found here.
     * @throws UserObjectCreateException If the user is missing object-level create access
     * @throws UserFieldEditException If the user is missing field-level edit access
     * @throws AuraHandledException For all other non-DML exceptions
     */
    @AuraEnabled
    public static DMLResult createRecords(List<Map<String, Object>> createRecords) {
        DMLResult dmlResult = new DMLResult();
        try {
            // Add object type to result object
            if (!createRecords.isEmpty())
                dmlResult.setObjectType(new CreateRecordSObject(createRecords[0]).apiName);

            List<SObject> records = new List<SObject>();

            for (Integer i = 0; i < createRecords.size(); i++) {
                Map<String, Object> createRecMp = createRecords[i];

                // Convert to expected object
                CreateRecordSObject createRec = new CreateRecordSObject(createRecMp);

                // Verify has necessary fields
                if (createRec.apiName == null)
                    throw new IllegalArgumentException(
                        'All create records must include the object\'s apiName. Record at index=' +
                            i +
                            ' does not have apiName specified.'
                    );

                // Create a corresponding record
                SObject record = (SObject) (Type.forName('Schema.' + createRec.apiName)?.newInstance());
                for (String field : createRec.fields.keySet())
                    record.put(field, createRec.fields.get(field));

                records.add(record);
            }

            // If we need to check perms, do so
            if (needToCheckPermissions()) {
                assertHasPermissionToCreateObjects(UserInfo.getUserId(), records);
                assertHasPermissionToEditFields(UserInfo.getUserId(), records);
            }

            // If we are meant to check permissions, use USER MODE in case our assertions above have some edge cases
            Database.insert(records, true, needToCheckPermissions() ? AccessLevel.USER_MODE : AccessLevel.SYSTEM_MODE);

            // Add all record ids to result object now that we've succeeded
            for (SObject rec : records)
                dmlResult.addRecordId(rec.Id);
        } catch (DmlException e) {
            // We need to parse the DmlException error so we can display to the user the errors in a clean form
            // we also want to do it this way so that it is clear when the issue is a data error rather than a
            // a permission error or some other unrecoverable error
            dmlResult.parseError(e);
        } catch (UserObjectCreateException e) {
            // Don't wrap this error type
            throw e;
        } catch (UserFieldEditException e) {
            // Don't wrap this error type
            throw e;
        } catch (Exception e) {
            // Unexpect error (wrap in an AuraHandledException to consistently format error response)
            throw new AuraHandledException(e.getMessage());
        }

        return dmlResult;
    }

    /**
     * Update all records in list while obeying user's object, field, and record
     * level access rules.
     *
     * As long as reach record has an Id, Salesforce can coerce the data into SObjects
     *
     * @param records List of records to update
     * @return A DMLResult object indicating either success or failure
     *         if this failed due to failing a validation rule, then the error
     *         message can be found here.
     * @throws UserObjectEditException If the user is missing object-level edit access
     * @throws UserFieldEditException If the user is missing field-level edit access
     * @throws UserRecordEditException If the user is missing record-level edit access
     * @throws AuraHandledException For all other non-DML exceptions
     */
    @AuraEnabled
    public static DMLResult updateRecords(List<SObject> records) {
        DMLResult dmlResult = new DMLResult();

        try {
            // Add object type to result object
            if (!records.isEmpty())
                dmlResult.setObjectType(records[0].getSObjectType().getDescribe().getName());

            // Add all records to result object
            for (SObject rec : records)
                dmlResult.addRecordId(rec.Id);

            // If we need to check perms, do so
            if (needToCheckPermissions()) {
                assertHasPermissionToEditObjects(UserInfo.getUserId(), records);
                assertHasPermissionToEditFields(UserInfo.getUserId(), records);
                assertHasPermissionToEditRecords(UserInfo.getUserId(), records);
            }

            // If we are meant to check permissions, use USER MODE in case our assertions above have some edge cases
            Database.update(records, true, needToCheckPermissions() ? AccessLevel.USER_MODE : AccessLevel.SYSTEM_MODE);
        } catch (DmlException e) {
            // We need to parse the DmlException error so we can display to the user the errors in a clean form
            // we also want to do it this way so that it is clear when the issue is a data error rather than a
            // a permission error or some other unrecoverable error
            dmlResult.parseError(e);
        } catch (UserObjectEditException e) {
            // Don't wrap this error type
            throw e;
        } catch (UserFieldEditException e) {
            // Don't wrap this error type
            throw e;
        } catch (UserRecordEditException e) {
            // Don't wrap this error type
            throw e;
        } catch (Exception e) {
            // Unexpect error (wrap in an AuraHandledException to consistently format error response)
            throw new AuraHandledException(e.getMessage());
        }

        return dmlResult;
    }

    /**
     * Delete all records in list while obeying user's object, field, and record
     * level access rules.
     *
     * Since we are just deleting, a list of ids is enough
     * Though we will check object type, so these ids must still be valid/real
     *
     * @param records List of records to delete
     * @return A DMLResult object indicating either success or failure
     *         if this failed due to failing a validation rule, then the error
     *         message can be found here.
     * @throws UserObjectDeleteException If the user is missing object-level delete access
     * @throws UserRecordDeleteException If the user is missing record-level delete access
     * @throws AuraHandledException For all other non-DML exceptions
     */
    @AuraEnabled
    public static DMLResult deleteRecords(List<String> recordIds) {
        DMLResult dmlResult = new DMLResult();

        try {
            // Add object type to result object
            if (!recordIds.isEmpty())
                dmlResult.setObjectType(RecordIdHelper.findObjectNameFromRecordIdPrefix(recordIds[0]));

            // Add all records to result object
            for (String recordId : recordIds)
                dmlResult.addRecordId(recordId);

            List<SObject> records = new List<SObject>();

            for (String recordId : recordIds) {
                String objectName = RecordIdHelper.findObjectNameFromRecordIdPrefix(recordId);

                // Type is unknown - throw an error since this means we can't check if the user has access to this
                // object type/record (they probably don't if we can't find the record id prefix)
                if (objectName == RecordIDHelper.CANNOT_FIND_PREFIX_OBJECT_MAPPING_RESPONSE) {
                    throw new IllegalArgumentException(
                        'All deleted record ids must be valid record ids. Record id "' +
                            recordId +
                            '" could not be matched to any object type'
                    );
                }

                // Create a corresponding record
                SObject record = (SObject) (Type.forName('Schema.' + objectName)?.newInstance());
                record.Id = recordId;

                records.add(record);
            }

            // If we need to check perms, do so
            if (needToCheckPermissions()) {
                assertHasPermissionToDeleteObjects(UserInfo.getUserId(), records);
                assertHasPermissionToDeleteRecords(UserInfo.getUserId(), records);
            }

            // If we are meant to check permissions, use USER MODE in case our assertions above have some edge cases
            Database.delete(records, true, needToCheckPermissions() ? AccessLevel.USER_MODE : AccessLevel.SYSTEM_MODE);
        } catch (DmlException e) {
            // We need to parse the DmlException error so we can display to the user the errors in a clean form
            // we also want to do it this way so that it is clear when the issue is a data error rather than a
            // a permission error or some other unrecoverable error
            dmlResult.parseError(e);
        } catch (UserObjectDeleteException e) {
            // Don't wrap this error type
            throw e;
        } catch (UserRecordDeleteException e) {
            // Don't wrap this error type
            throw e;
        } catch (Exception e) {
            // Unexpect error (wrap in an AuraHandledException to consistently format error response)
            throw new AuraHandledException(e.getMessage());
        }

        return dmlResult;
    }

    /**
     * Check if, based on the running context, if the user needs to have permissions validated.
     * By default, permissions should be checked, permissions don't need to be validated
     * when the current user is a System Administrator.
     *
     * @return true if permissions should be validated
     */
    private static Boolean needToCheckPermissions() {
        // Don't need to check for System Admin users
        if (UserInfo.getProfileId() == RecordIdHelper.getProfileID('System Administrator'))
            return false;
        // Should check by default
        return true;
    }

    /**
     * Asserts that the user has permission to create all the SObjectTypes present in records
     * If the user is missing create permission on mulutple object types, it will throw an
     * error for the first encountered in the list
     *
     * @param records List of records user wants to create
     * @throws UserObjectCreateException If the user does not has create access to any object type
     */
    public static void assertHasPermissionToCreateObjects(Id userId, List<SObject> records) {
        for (SObject sObj : records) {
            DescribeSObjectResult descr = sObj.getSObjectType().getDescribe();
            if (!descr.isCreateable())
                throw new UserObjectCreateException('User ' + userId + ' cannot create object type ' + descr.getName());
        }
    }

    /**
     * Asserts that the user has permission to update all the SObjectTypes present in records
     * If the user is missing update permission on mulutple object types, it will throw an
     * error for the first encountered in the list
     *
     * @param records List of records user wants to update
     * @throws UserObjectEditException If the user does not has update access to any object type
     */
    public static void assertHasPermissionToEditObjects(Id userId, List<SObject> records) {
        for (SObject sObj : records) {
            DescribeSObjectResult descr = sObj.getSObjectType().getDescribe();
            if (!descr.isUpdateable())
                throw new UserObjectEditException('User ' + userId + ' cannot edit object type ' + descr.getName());
        }
    }

    /**
     * Asserts that the user has permission to update all the fields populate on records
     * If the user is missing update permission on mulutple fields, it will throw an
     * error for the first encountered in the list
     *
     * @param records List of records user wants to update
     * @throws UserFieldEditException If the user does not has update access to any populated field
     */
    public static void assertHasPermissionToEditFields(Id userId, List<SObject> records) {
        for (SObject sObj : records) {
            DescribeSObjectResult descr = sObj.getSObjectType().getDescribe();
            Map<String, Schema.SObjectField> descrFieldsMp = descr.fields.getMap();
            Map<String, Object> populatedFields = sObj.getPopulatedFieldsAsMap();

            for (String populatedField : populatedFields.keySet()) {
                // Id is a special case, they won't have permission to edit it (since you can't edit an id)
                // but it must be included to perform an update
                if (populatedField.toLowerCase() == 'id')
                    continue;

                // For all other fields, check if they can update it
                if (descrFieldsMp.containsKey(populatedField)) {
                    DescribeFieldResult fDescr = descrFieldsMp.get(populatedField).getDescribe();
                    if (!fDescr.isUpdateable()) {
                        throw new UserFieldEditException(
                            'User ' +
                                userId +
                                ' cannot edit field ' +
                                fDescr.getName() +
                                ' on object type ' +
                                descr.getName()
                        );
                    }
                } else {
                    throw new UserFieldEditException(
                        'User is trying to edit field ' +
                            populatedField +
                            ' on object type ' +
                            descr.getName() +
                            ' but this field doesn\'t exist'
                    );
                }
            }
        }
    }

    /**
     * Asserts that the user has permission to update all the records in records
     * If the user is missing update permission on mulutple records, it will throw an
     * error for the first encountered in the list
     *
     * @param records List of records user wants to update
     * @throws UserRecordEditException If the user does not has update access to any record
     */
    public static void assertHasPermissionToEditRecords(Id userId, List<SObject> records) {
        List<Id> recordIds = new List<Id>();
        for (SObject sObj : records)
            recordIds.add(sObj.Id);

        List<UserRecordAccess> recordAccessList = [
            SELECT RecordId, HasEditAccess
            FROM UserRecordAccess
            WHERE UserId = :userId AND RecordId IN :recordIds
        ];

        Set<Id> canEditIds = new Set<Id>();
        for (UserRecordAccess recordAccess : recordAccessList)
            if (recordAccess.HasEditAccess)
                canEditIds.add(recordAccess.RecordId);

        // If missing edit access for a record, throw error
        for (Id recordId : recordIds)
            if (!canEditIds.contains(recordId))
                throw new UserRecordEditException('User ' + userId + ' cannot edit record ' + recordId);
    }

    /**
     * Asserts that the user has permission to create all the SObjectTypes present in records
     * If the user is missing create permission on mulutple object types, it will throw an
     * error for the first encountered in the list
     *
     * @param records List of records user wants to update
     * @throws UserObjectDeleteException If the user does not has delete access to any object type
     */
    public static void assertHasPermissionToDeleteObjects(Id userId, List<SObject> records) {
        for (SObject sObj : records) {
            DescribeSObjectResult descr = sObj.getSObjectType().getDescribe();
            if (!descr.isDeletable())
                throw new UserObjectDeleteException('User ' + userId + ' cannot delete object type ' + descr.getName());
        }
    }

    /**
     * Asserts that the user has permission to update all the records in records
     * If the user is missing update permission on mulutple records, it will throw an
     * error for the first encountered in the list
     *
     * @param records List of records user wants to delete
     * @throws UserRecordDeleteException If the user does not has delete access to any record
     */
    public static void assertHasPermissionToDeleteRecords(Id userId, List<SObject> records) {
        List<Id> recordIds = new List<Id>();
        for (SObject sObj : records)
            recordIds.add(sObj.Id);

        List<UserRecordAccess> recordAccessList = [
            SELECT RecordId, HasDeleteAccess
            FROM UserRecordAccess
            WHERE UserId = :userId AND RecordId IN :recordIds
        ];

        Set<Id> canDeleteIds = new Set<Id>();
        for (UserRecordAccess recordAccess : recordAccessList)
            if (recordAccess.HasDeleteAccess)
                canDeleteIds.add(recordAccess.RecordId);

        // If missing edit access for a record, throw error
        for (Id recordId : recordIds)
            if (!canDeleteIds.contains(recordId))
                throw new UserRecordDeleteException('User ' + userId + ' cannot delete record ' + recordId);
    }

    /**
     * Wrapper class for creating a new record - apiName should be the name of the object
     * and fields should map each field name to the desired value
     */
    public class CreateRecordSObject {
        @AuraEnabled
        public String apiName;

        @AuraEnabled
        public Map<String, Object> fields;

        public CreateRecordSObject() {
        }

        public CreateRecordSObject(Map<String, Object> mp) {
            apiName = (String) mp.get('apiName');
            fields = new Map<String, Object>();

            Map<Object, Object> fieldMp = (Map<Object, Object>) mp.get('fields');

            if (fieldMp != null)
                for (Object key : fieldMp.keySet())
                    fields.put((String) key, fieldMp.get(key));
        }
    }

    /**
     * Wrapper class for result of performed DML operations
     * Allows us to report when failed due to update (such as from failing validation rules)
     */
    public class DMLResult {
        @AuraEnabled
        public Boolean success = true;

        @AuraEnabled
        public String objectType;

        @AuraEnabled
        public List<Id> recordIds = new List<Id>();

        @AuraEnabled
        public String errorMessage;

        public DMLResult() {
        }

        /**
         * Set record type
         */
        public void setObjectType(String objectType) {
            this.objectType = objectType;
        }

        /**
         * Add a record to the list of ids
         */
        public void addRecordId(String recordId) {
            recordIds.add(recordId);
        }

        /**
         * There was a DmlException during the operation, set corresponding fields on wrapper
         * we use the first DmlMessage as the error message
         */
        public void parseError(DmlException e) {
            success = false;
            errorMessage = e.getDmlMessage(0);
        }
    }

    // Lacking permissions to create this object type
    public class UserObjectCreateException extends Exception {
    }

    // Lacking permissions to edit this object type/field/record
    public class UserObjectEditException extends Exception {
    }
    public class UserFieldEditException extends Exception {
    }
    public class UserRecordEditException extends Exception {
    }

    // Lacking permissions to delete this object type/record
    public class UserObjectDeleteException extends Exception {
    }
    public class UserRecordDeleteException extends Exception {
    }
}
