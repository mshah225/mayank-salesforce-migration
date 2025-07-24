public without sharing class UserMatcherBatch implements Database.Batchable<User>, Database.Stateful {
    // Batch job coordinator id
    Id coordinatorId = null;
    AsyncJobCoordinatorManager asyncManager = null;
    // Audit log info
    Id auditLogId = null;
    String auditRole = null;
    List<String> identifiers = null;
    // Fields to query and a few special purpose fields
    private String timestampFieldName = null;
    private String searchFieldName = null;
    private List<String> queryFieldLabels = new List<String>();
    private Map<String, String> fieldLabelToNameMp = new Map<String, String>();
    // Generate CSV
    List<String> newCsvRows = new List<String>();
    Integer matchedCount = 0;
    Set<String> matchedIdentifiers = new Set<String>();
    // Flags to track state over multiple batches
    Boolean threwError = false;
    // Start time
    Datetime startTime;

    public UserMatcherBatch(Id coordinatorId, Id auditLogId, List<String> identifiers, String auditRole) {
        this.coordinatorId = coordinatorId;
        this.auditLogId = auditLogId;
        this.auditRole = auditRole;
        this.identifiers = identifiers;
    }

    public List<User> start(Database.BatchableContext bc) {
        startTime = System.now();

        try {
            /**
             * ==== Update coordinator ====
             */
            asyncManager = new AsyncJobCoordinatorManager(coordinatorId);
            asyncManager.setRunning();

            /**
             * ==== Get timestamp field for this audit role ====
             */
            List<User_Search_Roles_Setting__mdt> roleMetadata = getUserSearchRoleCustomMetadata();
            for (User_Search_Roles_Setting__mdt roleMetadatum : roleMetadata) {
                if (roleMetadatum.DeveloperName == auditRole) {
                    timestampFieldName = roleMetadatum.User_Audit_Date_Field_Name__c;
                    break;
                }
            }
            if (timestampFieldName == null)
                throw new UserMatcherBatchException('Missing metadata mapping for auditRole=' + auditRole);

            /**
             * ==== Build SOQL Query ====
             */
            DynamicSoqlBuilder soqlBuilder = new DynamicSoqlBuilder('User');

            // ignore ASU Community and ASU Community CAP profiles
            soqlBuilder.restrictNotIn('Profile.Name', new List<String>{ 'ASU Community', 'ASU Community CAP' });

            // Add all fields to query and create maps for later
            List<User_Search_Setting__mdt> auditFieldsList = getUserSearchCustomMetadata();

            Boolean alreadyQueryingId = false;

            for (User_Search_Setting__mdt fld : auditFieldsList) {
                queryFieldLabels.add(fld.MasterLabel);
                fieldLabelToNameMp.put(fld.MasterLabel, fld.Field_Name__c);
                soqlBuilder.returnField(fld.Field_Name__c);

                // Also track if we need to inject querying id or not (since if we are, we will remove it in the final report)
                if (fld.Field_Name__c.toLowerCase() == 'id') {
                    alreadyQueryingId = true;
                }

                // Track which field is being used for filtering
                if (fld.Search_Field__c)
                    searchFieldName = fld.MasterLabel;
            }

            // Missing required search field
            if (searchFieldName == null)
                throw new UserMatcherBatchException('Missing search field, cannot begin audit');

            newCsvRows.add(String.join(queryFieldLabels, ','));

            if (!alreadyQueryingId)
                soqlBuilder.returnField(Schema.SObjectType.User.fields.Id);

            soqlBuilder.restrictIn(fieldLabelToNameMp.get(searchFieldName), identifiers);

            /**
             * ==== Run Query ====
             */
            return soqlBuilder.query();
        } catch (Exception e) {
            List<String> errorLogVars = new List<String>();
            errorLogVars.add(ErrorLogger.convertIdToJSON('jobId', bc.getJobId()));
            errorLogVars.add(ErrorLogger.convertIdToJSON('coordinatorId', coordinatorId));
            errorLogVars.add(ErrorLogger.convertIdToJSON('auditLogId', auditLogId));
            errorLogVars.add(ErrorLogger.convertStringToJSON('auditRole', auditRole));
            errorLogVars.add(ErrorLogger.convertListToJSON('identifiers', identifiers));

            ErrorLogger.log(e, errorLogVars, false);
            threwError = true;

            return new List<User>();
        }
    }

    public void execute(Database.BatchableContext bc, List<User> scope) {
        if (scope.isEmpty())
            return; // do nothing if scope is empty
        if (threwError)
            return; //don't continue if there was an error previously
        List<String> errorLogVars = new List<String>();
        matchedCount += scope.size();

        try {
            List<User_Audit_Log_Detail__c> detailRecords = new List<User_Audit_Log_Detail__c>();
            Map<Id, List<User_Audit_Log_Detail_Field__c>> userIdToDetailFieldsMp = new Map<Id, List<User_Audit_Log_Detail_Field__c>>();

            RecordHelper.GetValueConfig GET_VAL_CONF = new RecordHelper.GetValueConfig();
            GET_VAL_CONF.safe = false;

            for (User u : scope) {
                List<String> csvRow = new List<String>();

                String seachFieldValue = RecordHelper.getValue(u, fieldLabelToNameMp.get(searchFieldName), GET_VAL_CONF)
                    .toString();

                User_Audit_Log_Detail__c detailRecord = new User_Audit_Log_Detail__c(
                    Name = seachFieldValue + ' @ ' + startTime.format('YYYY-MM-dd HH:mm:ss zzz'),
                    User_Audit_Log__c = auditLogId,
                    User__c = u.Id,
                    Alias__c = seachFieldValue,
                    Matched__c = true
                );
                detailRecords.add(detailRecord);
                List<User_Audit_Log_Detail_Field__c> detailFieldRecords = new List<User_Audit_Log_Detail_Field__c>();

                matchedIdentifiers.add(seachFieldValue);

                // Set timestamp since to indicate it was in report
                u.put(timestampFieldName, startTime.date());

                userIdToDetailFieldsMp.put(u.Id, new List<User_Audit_Log_Detail_Field__c>());

                // Build CSV row and detail records
                for (String fieldLabel : queryFieldLabels) {
                    String fieldName = fieldLabelToNameMp.get(fieldLabel);

                    Object fieldObj = RecordHelper.getValue(u, fieldName, GET_VAL_CONF);
                    String fieldValue = null;

                    // Get string from field object
                    if (fieldObj == null) {
                        fieldValue = 'NULL';
                    } else if (fieldObj instanceof DateTime) {
                        fieldValue = ((DateTime) fieldObj).format();
                    } else {
                        // By default use toString to convert
                        fieldValue = fieldObj?.toString();
                    }

                    // Create an audit log
                    User_Audit_Log_Detail_Field__c fieldDetail = new User_Audit_Log_Detail_Field__c(
                        Field_Name__c = fieldName,
                        Value__c = fieldValue,
                        Display_Value__c = fieldValue
                            ?.left(User_Audit_Log_Detail_Field__c.Display_Value__c.getDescribe().getLength())
                    );
                    userIdToDetailFieldsMp.get(u.Id).add(fieldDetail);
                    detailFieldRecords.add(fieldDetail);

                    // Add to CSV
                    String csvVal = fieldValue?.escapeCsv();
                    csvRow.add(csvVal == null ? 'NULL' : csvVal);
                }
                newCsvRows.add(String.join(csvRow, ','));
            }

            // Create audit log per-user
            if (!detailRecords.isEmpty())
                insert detailRecords;

            // Create per field records
            List<User_Audit_Log_Detail_Field__c> allFieldRecords = new List<User_Audit_Log_Detail_Field__c>();
            for (User_Audit_Log_Detail__c detailRecord : detailRecords) {
                for (User_Audit_Log_Detail_Field__c fieldDetail : userIdToDetailFieldsMp.get(detailRecord.User__c)) {
                    fieldDetail.User_Audit_Log_Detail__c = detailRecord.Id;
                    allFieldRecords.add(fieldDetail);
                }
            }
            if (!allFieldRecords.isEmpty()) {
                insert allFieldRecords;
            }

            // Update users
            if (!scope.isEmpty())
                update scope;
        } catch (Exception e) {
            errorLogVars.add(ErrorLogger.convertIdToJSON('jobId', bc.getJobId()));
            errorLogVars.add(ErrorLogger.convertIdToJSON('coordinatorId', coordinatorId));
            errorLogVars.add(ErrorLogger.convertIdToJSON('auditLogId', auditLogId));
            errorLogVars.add(ErrorLogger.convertStringToJSON('auditRole', auditRole));
            errorLogVars.add(ErrorLogger.convertListToJSON('identifiers', identifiers));

            ErrorLogger.log(e, errorLogVars, false);
            threwError = true;
        }
    }

    public void finish(Database.BatchableContext bc) {
        try {
            if (threwError) {
                asyncManager.setError();
            } else {
                asyncManager.setSuccess();
            }

            /**
             * Add unmatched value records and rows to report
             */
            List<User_Audit_Log_Detail__c> skippedUsers = new List<User_Audit_Log_Detail__c>();
            for (String identifier : identifiers) {
                if (matchedIdentifiers.contains(identifier))
                    continue;

                // Create the record for the skipped user
                User_Audit_Log_Detail__c detailRecord = new User_Audit_Log_Detail__c(
                    Name = identifier + ' @ ' + startTime.format('YYYY-MM-dd HH:mm:ss zzz'),
                    User_Audit_Log__c = auditLogId,
                    Alias__c = identifier,
                    Matched__c = false
                );
                skippedUsers.add(detailRecord);

                // Build CSV row (all empty except the row for the search field)
                List<String> csvRow = new List<String>();
                for (String fieldLabel : queryFieldLabels)
                    if (searchFieldName == fieldLabel)
                        csvRow.add(identifier);
                    else
                        csvRow.add('');
                newCsvRows.add(String.join(csvRow, ','));
            }
            if (!skippedUsers.isEmpty()) {
                insert skippedUsers;
            }

            /**
             * Record total number on audit log
             */
            update new User_Audit_Log__c(Id = auditLogId, Matched_Count__c = matchedCount);

            saveReportMap();
        } catch (Exception e) {
            List<String> errorLogVars = new List<String>();
            errorLogVars.add(ErrorLogger.convertIdToJSON('jobId', bc.getJobId()));
            errorLogVars.add(ErrorLogger.convertIdToJSON('coordinatorId', coordinatorId));
            errorLogVars.add(ErrorLogger.convertIdToJSON('auditLogId', auditLogId));
            errorLogVars.add(ErrorLogger.convertStringToJSON('auditRole', auditRole));
            errorLogVars.add(ErrorLogger.convertListToJSON('identifiers', identifiers));

            ErrorLogger.log(e, errorLogVars, false);
            asyncManager.setError();
        }
    }

    public void saveReportMap() {
        String fileName = 'audit_' + startTime.format('YYYY-MM-dd HH:mm:ss zzz') + '.csv';

        // Create file
        ContentVersion cv = new ContentVersion(
            Title = fileName,
            PathOnClient = '/tmp/' + fileName,
            VersionData = Blob.valueOf(String.join(newCsvRows, '\n'))
        );
        insert cv;

        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        // Attach file to coordinator
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = coordinatorId
        );

        // Attach file to audit job
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = auditLogId
        );

        insert new List<ContentDocumentLink>{ cdl, cdl2 };

        Map<String, User_Search_Config_Setting__mdt> configMp = getUserSearchConfigCustomMetadata();

        // Add file to workspace/folder
        if (String.isNotBlank(configMp.get('User_Audit_Folder_Id')?.Value__c)) {
            String folderId = configMp.get('User_Audit_Folder_Id').Value__c;

            // Add folder to workspace (we can't add to folder directly)
            ContentDocumentLink cdlWorkspace = new ContentDocumentLink(
                ContentDocumentId = cv.ContentDocumentId,
                LinkedEntityId = folderId
            );
            insert cdlWorkspace;
        }
    }

    /**
     * Get search fields
     */
    public static List<User_Search_Setting__mdt> getUserSearchCustomMetadata() {
        List<User_Search_Setting__mdt> userSearchSettingList = [
            SELECT Field_Name__c, MasterLabel, Search_Field__c, Order__c
            FROM User_Search_Setting__mdt
            WHERE Enabled__c = TRUE
            ORDER BY Order__c ASC
        ];

        if (Test.isRunningTest()) {
            userSearchSettingList = TEST_SEARCH_SETTING_METADATA;
        }

        return userSearchSettingList;
    }
    @TestVisible
    private static List<User_Search_Setting__mdt> TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>();

    /**
     * Get role options
     */
    public static List<User_Search_Roles_Setting__mdt> getUserSearchRoleCustomMetadata() {
        List<User_Search_Roles_Setting__mdt> userSearchRoleSettingList = [
            SELECT MasterLabel, DeveloperName, User_Audit_Date_Field_Name__c
            FROM User_Search_Roles_Setting__mdt
            WHERE Enabled__c = TRUE
            ORDER BY MasterLabel ASC
        ];

        if (Test.isRunningTest()) {
            userSearchRoleSettingList = TEST_SEARCH_ROLES_METADATA;
        }

        return userSearchRoleSettingList;
    }
    @TestVisible
    private static List<User_Search_Roles_Setting__mdt> TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>();

    /**
     * Get other one-off configurations
     */
    public static Map<String, User_Search_Config_Setting__mdt> getUserSearchConfigCustomMetadata() {
        List<User_Search_Config_Setting__mdt> userSearchConfigSettingList = [
            SELECT DeveloperName, Value__c
            FROM User_Search_Config_Setting__mdt
        ];

        if (Test.isRunningTest()) {
            userSearchConfigSettingList = TEST_CONFIG_SETTING;
        }

        Map<String, User_Search_Config_Setting__mdt> mp = new Map<String, User_Search_Config_Setting__mdt>();
        for (User_Search_Config_Setting__mdt userSearchConfigSetting : userSearchConfigSettingList) {
            mp.put(userSearchConfigSetting.DeveloperName, userSearchConfigSetting);
        }
        return mp;
    }
    @TestVisible
    private static List<User_Search_Config_Setting__mdt> TEST_CONFIG_SETTING = new List<User_Search_Config_Setting__mdt>();

    public class UserMatcherBatchException extends Exception {
    }
}