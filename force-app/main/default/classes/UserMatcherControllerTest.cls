@isTest
public class UserMatcherControllerTest {
    private static final Integer userCount = 10;
    private static final String aliasPrefix = 'testUsr';
    private static final String asuritePrefix = '100010001';

    @TestSetup
    private static void setup() {
        List<User> testUsers = new List<User>();

        for (Integer i = 0; i < userCount; i++) {
            testUsers.add(
                new User(
                    FirstName = 'Test-' + i,
                    LastName = 'User',
                    Username = 'test.user.' + i + '@test.test',
                    Email = 'test.user' + i + '@test.test',
                    Alias = aliasPrefix + i,
                    ASURITE_for_External_ID__c = asuritePrefix + i,
                    TimeZoneSidKey = 'America/Phoenix',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'ISO-8859-1',
                    ProfileId = RecordIdHelper.getProfileID('System Administrator'),
                    LanguageLocaleKey = 'en_US'
                )
            );
        }

        insert testUsers;
    }

    /**
     * Test getting role options
     */
    @isTest
    private static void testGetRolesList() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            ),
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'PS Team',
                DeveloperName = 'PS_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_PS_Team__c'
            )
        };

        Test.startTest();
        List<LabelValue> options = UserMatcherController.getUserSearchRoleCustomMetadata();
        Test.stopTest();

        // Correct first option
        Assert.areEqual('SF Team', options[0].label);
        Assert.areEqual('SF_Team', options[0].value);

        // Correct second option
        Assert.areEqual('PS Team', options[1].label);
        Assert.areEqual('PS_Team', options[1].value);
    }

    /**
     * Test getting fields list
     */
    @isTest
    private static void testGetFieldsList() {
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        Test.startTest();
        List<LabelValue> options = UserMatcherController.getUserSearchCustomMetadata();
        Test.stopTest();

        // Correct first option
        Assert.areEqual('ASURITE', options[0].label);
        Assert.areEqual('ASURITE_for_External_ID__c', options[0].value);

        // Correct second option
        Assert.areEqual('First Name', options[1].label);
        Assert.areEqual('FirstName', options[1].value);

        // Correct third option
        Assert.areEqual('Email Address', options[2].label);
        Assert.areEqual('Email', options[2].value);
    }

    /**
     * Creates User_Audit_Log__c record and enqueues batch job
     */
    @isTest
    private static void testStartAudit() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');

        User_Audit_Log__c auditRecord = [
            SELECT Id, Async_Job_Coordinator__r.Job_Id__c
            FROM User_Audit_Log__c
            WHERE Id = :auditRecordId
        ];

        AsyncApexJob batchJob = [
            SELECT Id, Status, ApexClass.Name
            FROM AsyncApexJob
            WHERE Id = :auditRecord.Async_Job_Coordinator__r.Job_Id__c
        ];

        Assert.areEqual('Queued', batchJob.Status);
        Assert.areEqual('UserMatcherBatch', batchJob.ApexClass.Name);
    }

    /**
     * Status is queued
     */
    @isTest
    private static void testGetStatusJobIsQueued() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');
        AsyncJobCoordinatorManager.RunStatus status = UserMatcherController.checkStatus(auditRecordId);

        Assert.areEqual(false, status.done);
    }

    /**
     * Status is complete
     */
    @isTest
    private static void testGetStatusJobIsComplete() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Test.startTest();
        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');
        Test.stopTest();

        AsyncJobCoordinatorManager.RunStatus status = UserMatcherController.checkStatus(auditRecordId);

        Assert.areEqual(true, status.done);
    }

    /**
     * Test get download link when job has completed successfully
     */
    @isTest
    private static void testGetDownloadLinkJobIsComplete() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Test.startTest();
        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');
        Test.stopTest();

        String downloadLink = UserMatcherController.getDownloadLink(auditRecordId);

        User_Audit_Log__c auditLog = [
            SELECT Id, Async_Job_Coordinator__c
            FROM User_Audit_Log__c
            WHERE Id = :auditRecordId
            LIMIT 1
        ];

        List<ContentDocumentLink> cdls = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :auditLog.Async_Job_Coordinator__c
            LIMIT 1
        ];

        Assert.areEqual('/sfc/servlet.shepherd/document/download/' + cdls[0].ContentDocumentId, downloadLink);
    }

    /**
     * Verifies CSV header
     */
    @isTest
    private static void testGetFileHeader() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Test.startTest();
        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');
        Test.stopTest();

        String csvFile = UserMatcherController.getFileContents(auditRecordId);

        CsvReader csvReader = new CsvReader(csvFile, ',', '\n');
        List<List<String>> csvRows = csvReader.getLines();

        List<String> csvHeaderRow = csvRows[0];

        // Each test user should appear in results
        Assert.areEqual(3, csvHeaderRow.size());
        Assert.areEqual('ASURITE', csvHeaderRow[0]);
        Assert.areEqual('First Name', csvHeaderRow[1]);
        Assert.areEqual('Email Address', csvHeaderRow[2]);
    }

    /**
     * Verifies CSV has a row for each user
     */
    @isTest
    private static void testGetFileCheckContainsAllUsers() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Test.startTest();
        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');
        Test.stopTest();

        String csvFile = UserMatcherController.getFileContents(auditRecordId);

        CsvReader csvReader = new CsvReader(csvFile, ',', '\n');
        List<List<String>> csvRows = csvReader.getLines();

        // Each test user should appear in results
        Assert.areEqual(testUsers.size() + 1, csvRows.size());
        for (User testUser : testUsers) {
            List<String> compareMe = null;
            for (List<String> csvRow : csvRows) {
                if (csvRow[0] == testUser.ASURITE_for_External_ID__c) {
                    compareMe = csvRow;
                    break;
                }
            }
            Assert.areNotEqual(null, compareMe, 'Missing CSV row for user ' + testUser.ASURITE_for_External_ID__c);

            // Created row for each field on User
            Assert.areEqual(3, compareMe.size());
            Assert.areEqual(testUser.ASURITE_for_External_ID__c, compareMe[0]);
            Assert.areEqual(testUser.FirstName, compareMe[1]);
            Assert.areEqual(testUser.Email, compareMe[2]);
        }
    }

    /**
     * Verifies detail records
     */
    @isTest
    private static void testDetailRecords() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Test.startTest();
        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');
        Test.stopTest();

        List<User_Audit_Log_Detail__c> detailRecords = [
            SELECT Id, User__c, (SELECT Id, Field_Name__c, Value__c FROM User_Audit_Log_Detail_Fields__r)
            FROM User_Audit_Log_Detail__c
            WHERE User_Audit_Log__c = :auditRecordId
        ];

        for (User testUser : testUsers) {
            User_Audit_Log_Detail__c compareMe = null;
            for (User_Audit_Log_Detail__c detailRecord : detailRecords) {
                if (detailRecord.User__c == testUser.Id) {
                    compareMe = detailRecord;
                    break;
                }
            }
            Assert.areNotEqual(null, compareMe, 'Missing detail record for user ' + testUser.Id);

            // Created record for each field on User
            Assert.areEqual(3, compareMe.User_Audit_Log_Detail_Fields__r.size());
            for (User_Audit_Log_Detail_Field__c detailField : compareMe.User_Audit_Log_Detail_Fields__r) {
                Assert.areEqual(testUser.get(detailField.Field_Name__c), detailField.Value__c);
            }
        }
    }

    /**
     * Verifies detail records
     */
    @isTest
    private static void testSaveInFolder() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        // Setup test workspace and folder
        ContentWorkspace ws = new ContentWorkspace(Name = 'Test Workspace');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert ws;
        }
        ContentFolder wsRootFolder = [SELECT Id FROM ContentFolder WHERE Name = :ws.Id];
        UserMatcherBatch.TEST_CONFIG_SETTING = new List<User_Search_Config_Setting__mdt>{
            new User_Search_Config_Setting__mdt(DeveloperName = 'User_Audit_Folder_Id', Value__c = ws.Id)
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);

        Test.startTest();
        UserMatcherController.startAudit(testAsurites, 'SF_Team');
        Test.stopTest();

        // Check file created in folder
        List<ContentFolderMember> cfm = [
            SELECT Id, ChildRecordId
            FROM ContentFolderMember
            WHERE ParentContentFolderId = :wsRootFolder.Id
            LIMIT 1
        ];

        Assert.isFalse(cfm.isEmpty(), 'Missing file in folder');
    }

    /**
     * Test get status using invalid audit log id
     */
    @isTest
    private static void testGetStatusIllegalAuditId() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Exception thrownEx;
        try {
            AsyncJobCoordinatorManager.RunStatus status = UserMatcherController.checkStatus(
                ObjectService.getFakeId(User_Audit_Log__c.SObjectType)
            );
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            UserMatcherController.UserMatcherControllerException.class,
            'Expected to throw an exception of type UserMatcherController.UserMatcherControllerException, but actually threw ' +
            thrownEx?.getTypeName()
        );
        Assert.isTrue(
            thrownEx?.getMessage()?.contains('Invalid audit log id'),
            'Expected error message to contain "Invalid audit log id" but it instead said "' +
                thrownEx?.getMessage() +
                '"'
        );
    }

    /**
     * Test get download link using invalid audit log id
     */
    @isTest
    private static void testGetDownloadLinkIllegalAuditId() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Exception thrownEx;
        try {
            String downloadLink = UserMatcherController.getDownloadLink(
                ObjectService.getFakeId(User_Audit_Log__c.SObjectType)
            );
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            UserMatcherController.UserMatcherControllerException.class,
            'Expected to throw an exception of type UserMatcherController.UserMatcherControllerException, but actually threw ' +
            thrownEx?.getTypeName()
        );
        Assert.isTrue(
            thrownEx?.getMessage()?.contains('Invalid audit log id'),
            'Expected error message to contain "Invalid audit log id" but it instead said "' +
                thrownEx?.getMessage() +
                '"'
        );
    }

    /**
     * Test get download link when job is still running
     */
    @isTest
    private static void testGetDownloadLinkJobIsRunning() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');

        Exception thrownEx;
        try {
            String downloadLink = UserMatcherController.getDownloadLink(auditRecordId);
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            UserMatcherController.UserMatcherControllerException.class,
            'Expected to throw an exception of type UserMatcherController.UserMatcherControllerException, but actually threw ' +
            thrownEx?.getTypeName()
        );
        Assert.isTrue(
            thrownEx?.getMessage()?.contains('Audit still running, cannot get download link'),
            'Expected error message to contain "Audit still running, cannot get download link" but it instead said "' +
                thrownEx?.getMessage() +
                '"'
        );
    }

    /**
     * Test get download link when job errored
     */
    @isTest
    private static void testGetDownloadLinkJobHasError() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'Nonexisting_Field_Name__z'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Test.startTest();
        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');
        Test.stopTest();

        Exception thrownEx;
        try {
            String downloadLink = UserMatcherController.getDownloadLink(auditRecordId);
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            UserMatcherController.UserMatcherControllerException.class,
            'Expected to throw an exception of type UserMatcherController.UserMatcherControllerException, but actually threw ' +
            thrownEx?.getTypeName()
        );
        Assert.isTrue(
            thrownEx?.getMessage()?.contains('Audit failed, review error logger cases for more detail'),
            'Expected error message to contain "Audit failed, review error logger cases for more detail" but it instead said "' +
                thrownEx?.getMessage() +
                '"'
        );
    }

    /**
     * Test get file using invalid audit log id
     */
    @isTest
    private static void testGetFileIllegalAuditId() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Exception thrownEx;
        try {
            String csvFile = UserMatcherController.getFileContents(
                ObjectService.getFakeId(User_Audit_Log__c.SObjectType)
            );
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            UserMatcherController.UserMatcherControllerException.class,
            'Expected to throw an exception of type UserMatcherController.UserMatcherControllerException, but actually threw ' +
            thrownEx?.getTypeName()
        );
        Assert.isTrue(
            thrownEx?.getMessage()?.contains('Invalid audit log id'),
            'Expected error message to contain "Invalid audit log id" but it instead said "' +
                thrownEx?.getMessage() +
                '"'
        );
    }

    /**
     * Test get file when job is still running
     */
    @isTest
    private static void testGetFileJobIsRunning() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'PS_Audit_Date_SF_Team__c'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');

        Exception thrownEx;
        try {
            String csvFile = UserMatcherController.getFileContents(auditRecordId);
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            UserMatcherController.UserMatcherControllerException.class,
            'Expected to throw an exception of type UserMatcherController.UserMatcherControllerException, but actually threw ' +
            thrownEx?.getTypeName()
        );
        Assert.isTrue(
            thrownEx?.getMessage()?.contains('Audit still running, cannot get download link'),
            'Expected error message to contain "Audit still running, cannot get download link" but it instead said "' +
                thrownEx?.getMessage() +
                '"'
        );
    }

    /**
     * Test get file when job errored
     */
    @isTest
    private static void testGetFileJobHasError() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'Nonexisting_Field_Name__z'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Test.startTest();
        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');
        Test.stopTest();

        Exception thrownEx;
        try {
            String csvFile = UserMatcherController.getFileContents(auditRecordId);
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            UserMatcherController.UserMatcherControllerException.class,
            'Expected to throw an exception of type UserMatcherController.UserMatcherControllerException, but actually threw ' +
            thrownEx?.getTypeName()
        );
        Assert.isTrue(
            thrownEx?.getMessage()?.contains('Audit failed, review error logger cases for more detail'),
            'Expected error message to contain "Audit failed, review error logger cases for more detail" but it instead said "' +
                thrownEx?.getMessage() +
                '"'
        );
    }

    /**
     * Use invalid date field on User
     */
    @isTest
    private static void testErrorInvalidDateField() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>{
            new User_Search_Roles_Setting__mdt(
                MasterLabel = 'SF Team',
                DeveloperName = 'SF_Team',
                User_Audit_Date_Field_Name__c = 'Nonexisting_Field_Name__z'
            )
        };
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Test.startTest();
        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');
        Test.stopTest();

        AsyncJobCoordinatorManager.RunStatus status = UserMatcherController.checkStatus(auditRecordId);

        Assert.areEqual(true, status.done);

        List<Case> errorLoggerCase = [SELECT Id, Subject, Description FROM Case WHERE Subject LIKE 'Apex Exception%'];

        Assert.isTrue(errorLoggerCase.size() > 0, 'Expected error logger case but none was found');
    }

    /**
     * Missing metadata records
     */
    @isTest
    private static void testErrorMissingRoleMetadata() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>();
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>{
            new User_Search_Setting__mdt(
                MasterLabel = 'ASURITE',
                Field_Name__c = 'ASURITE_for_External_ID__c',
                Search_Field__c = true,
                Order__c = 10
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'First Name',
                Field_Name__c = 'FirstName',
                Search_Field__c = false,
                Order__c = 20
            ),
            new User_Search_Setting__mdt(
                MasterLabel = 'Email Address',
                Field_Name__c = 'Email',
                Search_Field__c = false,
                Order__c = 30
            )
        };

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Test.startTest();
        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');
        Test.stopTest();

        AsyncJobCoordinatorManager.RunStatus status = UserMatcherController.checkStatus(auditRecordId);

        Assert.areEqual(true, status.done);

        List<Case> errorLoggerCase = [SELECT Id, Subject, Description FROM Case WHERE Subject LIKE 'Apex Exception%'];

        Assert.isTrue(errorLoggerCase.size() > 0, 'Expected error logger case but none was found');
    }

    /**
     * Missing metadata records
     */
    @isTest
    private static void testErrorMissingFieldMetadata() {
        UserMatcherBatch.TEST_SEARCH_ROLES_METADATA = new List<User_Search_Roles_Setting__mdt>();
        UserMatcherBatch.TEST_SEARCH_SETTING_METADATA = new List<User_Search_Setting__mdt>();

        List<String> testAsurites = new List<String>();
        for (Integer i = 0; i < userCount; i++)
            testAsurites.add(asuritePrefix + i);
        List<User> testUsers = [
            SELECT Id, FirstName, Email, ASURITE_for_External_ID__c
            FROM User
            WHERE ASURITE_for_External_ID__c IN :testAsurites
        ];

        List<String> asuritesList = new List<String>();

        Test.startTest();
        Id auditRecordId = UserMatcherController.startAudit(testAsurites, 'SF_Team');
        Test.stopTest();

        AsyncJobCoordinatorManager.RunStatus status = UserMatcherController.checkStatus(auditRecordId);

        Assert.areEqual(true, status.done);

        List<Case> errorLoggerCase = [SELECT Id, Subject, Description FROM Case WHERE Subject LIKE 'Apex Exception%'];

        Assert.isTrue(errorLoggerCase.size() > 0, 'Expected error logger case but none was found');
    }
}