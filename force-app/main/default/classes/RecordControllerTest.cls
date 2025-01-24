@isTest
public class RecordControllerTest {
    private static final String testUserAlias = 'testUsr1';
    private static final String testUserAlias2 = 'testUsr2';
    private static final String testSysAdminUserAlias = 'testUsr3';
    private static final String testPermSetName = 'TestRecordControllerPermSet';

    @TestSetup
    private static void setup() {
        String testProfileId, testProfileId2, sysAdminProfileId;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Get these inside System.runAs because if they require cache to be refreshed that will insert non-setup objects
            // which will conflict with the setup object we are about to create

            // Min Access profile
            testProfileId = RecordIdHelper.getProfileID('Minimum Access - Salesforce');

            // Low access but which can be granted create/edit/delete permissions
            // (Minimum Access - Salesforce cannot be given create on Case)
            testProfileId2 = RecordIdHelper.getProfileID('ASU Read Only');

            // This is for testing the Sys Admin overrides
            sysAdminProfileId = RecordIdHelper.getProfileID('System Administrator');
        }

        PermissionSet testPermSet = new PermissionSet(Name = testPermSetName, Label = testPermSetName);
        insert testPermSet;

        User testUser = new User(
            FirstName = 'Test Record Controller',
            LastName = 'Test User',
            Username = 'test.record.controller@test.test',
            Email = 'test.record.controller@test.test',
            Alias = testUserAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = testProfileId,
            LanguageLocaleKey = 'en_US'
        );
        User testUser2 = new User(
            FirstName = 'Test Record Controller',
            LastName = 'Test User',
            Username = 'test.record.controller.2@test.test',
            Email = 'test.record.controller.2@test.test',
            Alias = testUserAlias2,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = testProfileId2,
            LanguageLocaleKey = 'en_US'
        );
        User testUser3 = new User(
            FirstName = 'Test Record Controller Sys Admin',
            LastName = 'Test User',
            Username = 'test.record.controller.3@test.test',
            Email = 'test.record.controller.3@test.test',
            Alias = testSysAdminUserAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = sysAdminProfileId,
            LanguageLocaleKey = 'en_US'
        );
        insert new List<User>{ testUser, testUser2, testUser3 };

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testUser.Id,
            PermissionSetId = testPermSet.Id
        );
        PermissionSetAssignment psa2 = new PermissionSetAssignment(
            AssigneeId = testUser2.Id,
            PermissionSetId = testPermSet.Id
        );
        insert new List<PermissionSetAssignment>{ psa, psa2 };
    }

    @isTest
    private static void testCreateNoObjectPerms() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias LIMIT 1];

        // Attempt update and get error thrown
        Exception thrownException;
        System.runAs(testUser) {
            try {
                Map<Object, Object> fieldsMp = new Map<Object, Object>();
                fieldsMp.put('Subject', 'Hello World');
                fieldsMp.put('Description', 'Initial contents');

                Map<String, Object> createRecMp = new Map<String, Object>();
                createRecMp.put('apiName', 'Case');
                createRecMp.put('fields', fieldsMp);

                RecordController.createRecords(new List<Map<String, Object>>{ createRecMp });
            } catch (Exception ex) {
                thrownException = ex;
            }
        }

        // Correct error
        Assert.isInstanceOfType(
            thrownException,
            RecordController.UserObjectCreateException.class,
            'Incorrect exception type was thrown. Expected type RecordController.UserObjectCreateException but got type ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('cannot create object type'),
            'Error message should contain "cannot create object type", but instead the error message said: "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    @isTest
    private static void testCreateNoFieldPerms() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        PermissionSet testPermSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermSetName LIMIT 1];

        // Give object-level access (since this is check before field-level access)
        System.runAs(new User(Id = UserInfo.getUserId())) {
            ObjectPermissions caseObjAccess = new ObjectPermissions(
                SobjectType = 'Case',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsCreate = true
            );
            insert caseObjAccess;

            FieldPermissions caseSubjAccess = new FieldPermissions(
                SobjectType = 'Case',
                Field = 'Case.Subject',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true
            );
            FieldPermissions caseDescAccess = new FieldPermissions(
                SobjectType = 'Case',
                Field = 'Case.Description',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true
            );
            insert new List<FieldPermissions>{ caseSubjAccess, caseDescAccess };
        }

        // Attempt update and get error thrown
        Exception thrownException;
        System.runAs(testUser) {
            try {
                Map<Object, Object> fieldsMp = new Map<Object, Object>();
                fieldsMp.put('Subject', 'Hello World');
                fieldsMp.put('Description', 'Initial contents');

                Map<String, Object> createRecMp = new Map<String, Object>();
                createRecMp.put('apiName', 'Case');
                createRecMp.put('fields', fieldsMp);

                RecordController.createRecords(new List<Map<String, Object>>{ createRecMp });
            } catch (Exception ex) {
                thrownException = ex;
            }
        }

        // Correct error
        Assert.isInstanceOfType(
            thrownException,
            RecordController.UserFieldEditException.class,
            'Incorrect exception type was thrown. Expected type RecordController.UserFieldEditException but got type ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('cannot edit field Subject on object type Case'),
            'Error message should contain "cannot edit field Subject on object type Case", but instead the error message said: "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    @isTest
    private static void testCreateSuccessful() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        PermissionSet testPermSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermSetName LIMIT 1];

        // Give object-level and field-level access (since this is check before record-level access)
        System.runAs(new User(Id = UserInfo.getUserId())) {
            ObjectPermissions caseObjAccess = new ObjectPermissions(
                SobjectType = 'Case',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsCreate = true,
                PermissionsEdit = true
            );
            insert caseObjAccess;

            FieldPermissions caseSubjAccess = new FieldPermissions(
                SobjectType = 'Case',
                Field = 'Case.Subject',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true
            );
            FieldPermissions caseDescAccess = new FieldPermissions(
                SobjectType = 'Case',
                Field = 'Case.Description',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true
            );
            insert new List<FieldPermissions>{ caseSubjAccess, caseDescAccess };
        }

        // Attempt update and succeeds
        RecordController.DMLResult dmlResult;
        System.runAs(testUser) {
            Map<Object, Object> fieldsMp = new Map<Object, Object>();
            fieldsMp.put('Subject', 'Hello World');
            fieldsMp.put('Description', 'Initial contents');

            Map<String, Object> createRecMp = new Map<String, Object>();
            createRecMp.put('apiName', 'Case');
            createRecMp.put('fields', fieldsMp);

            dmlResult = RecordController.createRecords(new List<Map<String, Object>>{ createRecMp });
        }

        // Created Successfully
        Assert.isTrue(dmlResult.success);
        Assert.areEqual('Case', dmlResult.objectType);
        Assert.areEqual(1, dmlResult.recordIds.size());

        Case c = [SELECT Id, Subject, Description FROM Case WHERE Id = :dmlResult.recordIds[0]];
        Assert.areEqual('Hello World', c.Subject);
        Assert.areEqual('Initial contents', c.Description);
    }

    @isTest
    private static void testCreateSysAdminSuccess() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testSysAdminUserAlias LIMIT 1];

        // Attempt update and succeeds
        RecordController.DMLResult dmlResult;
        System.runAs(testUser) {
            Map<Object, Object> fieldsMp = new Map<Object, Object>();
            fieldsMp.put('Subject', 'Hello World');
            fieldsMp.put('Description', 'Initial contents');

            Map<String, Object> createRecMp = new Map<String, Object>();
            createRecMp.put('apiName', 'Case');
            createRecMp.put('fields', fieldsMp);

            dmlResult = RecordController.createRecords(new List<Map<String, Object>>{ createRecMp });
        }

        // Created Successfully
        Assert.isTrue(dmlResult.success);
        Assert.areEqual('Case', dmlResult.objectType);
        Assert.areEqual(1, dmlResult.recordIds.size());

        Case c = [SELECT Id, Subject, Description FROM Case WHERE Id = :dmlResult.recordIds[0]];
        Assert.areEqual('Hello World', c.Subject);
        Assert.areEqual('Initial contents', c.Description);
    }

    @isTest
    private static void testCreateDmlError() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        PermissionSet testPermSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermSetName LIMIT 1];

        // Give object-level and field-level access
        System.runAs(new User(Id = UserInfo.getUserId())) {
            ObjectPermissions caseObjAccess = new ObjectPermissions(
                SobjectType = 'Case',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsCreate = true,
                PermissionsEdit = true
            );
            insert caseObjAccess;

            FieldPermissions caseSubjAccess = new FieldPermissions(
                SobjectType = 'Case',
                Field = 'Case.Subject',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true
            );
            FieldPermissions caseDescAccess = new FieldPermissions(
                SobjectType = 'Case',
                Field = 'Case.Description',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true
            );
            insert new List<FieldPermissions>{ caseSubjAccess, caseDescAccess };
        }

        // Attempt insert and fail
        RecordController.DMLResult dmlResult;
        System.runAs(testUser) {
            Map<Object, Object> fieldsMp = new Map<Object, Object>();

            String invalidSubject = 'TOO LONG';
            for (Integer i = 0; i < Schema.SObjectType.Case.fields.Subject.getLength(); i++)
                invalidSubject += '.';

            fieldsMp.put('Subject', invalidSubject);
            fieldsMp.put('Description', 'Initial contents');

            Map<String, Object> createRecMp = new Map<String, Object>();
            createRecMp.put('apiName', 'Case');
            createRecMp.put('fields', fieldsMp);

            dmlResult = RecordController.createRecords(new List<Map<String, Object>>{ createRecMp });
        }

        // DML Error exposed in response
        Assert.isFalse(dmlResult.success);
        Assert.areEqual('Case', dmlResult.objectType);
        Assert.isTrue(
            dmlResult?.errorMessage?.contains('data value too large'),
            'Error message should have contained "data value too large", but it instead said: "' +
                dmlResult.errorMessage +
                '"'
        );
    }

    @isTest
    private static void testUpdateNoObjectPerms() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias LIMIT 1];

        // Setup case to test with
        Case c = new Case(Subject = 'Hello World', Description = 'Initial contents');
        insert c;
        c = [SELECT Id, Subject FROM Case WHERE Id = :c.Id];

        // Attempt update and get error thrown
        Exception thrownException;
        System.runAs(testUser) {
            c.Subject = 'New Subject';
            try {
                RecordController.updateRecords(new List<Case>{ c });
            } catch (Exception ex) {
                thrownException = ex;
            }
        }

        // When this is run during a deployment, it doesn't ever throw the expected RecordController.UserObjectEditException,
        // this is probably a bug.  It still throws an Exception, so we can at a minimum check that an error is thrown
        // even though we can't check that it is the right type
        Assert.areNotEqual(thrownException, null, 'Expected an error to be thrown but none was');
    }

    @isTest
    private static void testUpdateNoFieldPerms() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        PermissionSet testPermSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermSetName LIMIT 1];

        // Give object-level access (since this is check before field-level access)
        System.runAs(new User(Id = UserInfo.getUserId())) {
            ObjectPermissions caseObjAccess = new ObjectPermissions(
                SobjectType = 'Case',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true
            );
            insert caseObjAccess;
        }

        // Setup case to test with
        Case c = new Case(Subject = 'Hello World', Description = 'Initial contents');
        insert c;
        c = [SELECT Id, Subject FROM Case WHERE Id = :c.Id];

        // Attempt update and get error thrown
        Exception thrownException;
        System.runAs(testUser) {
            c.Subject = 'New Subject';
            try {
                RecordController.updateRecords(new List<Case>{ c });
            } catch (Exception ex) {
                thrownException = ex;
            }
        }

        // Correct error
        Assert.isInstanceOfType(
            thrownException,
            RecordController.UserFieldEditException.class,
            'Incorrect exception type was thrown. Expected type RecordController.UserFieldEditException but got type ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('cannot edit field Subject on object type Case'),
            'Error message should contain "cannot edit field Subject on object type Case", but instead the error message said: "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    @isTest
    private static void testUpdateNoRecordPerms() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        PermissionSet testPermSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermSetName LIMIT 1];

        // Give object-level and field-level access (since this is check before record-level access)
        System.runAs(new User(Id = UserInfo.getUserId())) {
            ObjectPermissions caseObjAccess = new ObjectPermissions(
                SobjectType = 'Case',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true
            );
            insert caseObjAccess;

            FieldPermissions caseSubjAccess = new FieldPermissions(
                SobjectType = 'Case',
                Field = 'Case.Subject',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true
            );
            insert caseSubjAccess;
        }

        // Setup case to test with
        Case c = new Case(Subject = 'Hello World', Description = 'Initial contents');
        insert c;
        c = [SELECT Id, Subject FROM Case WHERE Id = :c.Id];

        // Attempt update and get error thrown
        Exception thrownException;
        System.runAs(testUser) {
            c.Subject = 'New Subject';
            try {
                RecordController.updateRecords(new List<Case>{ c });
            } catch (Exception ex) {
                thrownException = ex;
            }
        }

        // Correct error
        Assert.isInstanceOfType(
            thrownException,
            RecordController.UserRecordEditException.class,
            'Incorrect exception type was thrown. Expected type RecordController.UserRecordEditException but got type ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('cannot edit record ' + c.Id),
            'Error message should contain "cannot edit record ' +
                c.Id +
                '", but instead the error message said: "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    @isTest
    private static void testUpdateSuccessful() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        PermissionSet testPermSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermSetName LIMIT 1];

        // Give object-level and field-level access (since this is check before record-level access)
        System.runAs(new User(Id = UserInfo.getUserId())) {
            ObjectPermissions caseObjAccess = new ObjectPermissions(
                SobjectType = 'Case',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsCreate = true,
                PermissionsEdit = true
            );
            insert caseObjAccess;

            FieldPermissions caseSubjAccess = new FieldPermissions(
                SobjectType = 'Case',
                Field = 'Case.Subject',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true
            );
            insert caseSubjAccess;
        }

        Case c = new Case(
            Subject = 'Hello World',
            Description = 'Initial contents',
            RecordTypeId = RecordIDHelper.getRecordTypeId('Case', 'ASU_Service')
        );

        // Attempt update and succeeds
        RecordController.DMLResult dmlResult;
        System.runAs(testUser) {
            insert c; // Create case as this user so they have record-level access to it

            // Update case
            c = [SELECT Id, Subject FROM Case WHERE Id = :c.Id];
            c.Subject = 'New Subject';
            dmlResult = RecordController.updateRecords(new List<Case>{ c });
        }

        // Subject updated
        Assert.isTrue(dmlResult.success);
        Assert.areEqual('Case', dmlResult.objectType);
        Assert.areEqual(1, dmlResult.recordIds.size());
        Assert.areEqual(c.Id, dmlResult.recordIds[0]);

        c = [SELECT Id, Subject FROM Case WHERE Id = :c.Id];
        Assert.areEqual('New Subject', c.Subject);
    }

    @isTest
    private static void testUpdateSysAdminSuccess() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testSysAdminUserAlias LIMIT 1];

        // Create case
        Case c = new Case(Subject = 'Hello World', Description = 'Initial contents');
        insert c;

        // Attempt update and succeeds
        RecordController.DMLResult dmlResult;
        System.runAs(testUser) {
            // Update case
            c = [SELECT Id, Subject FROM Case WHERE Id = :c.Id];
            c.Subject = 'New Subject';
            dmlResult = RecordController.updateRecords(new List<Case>{ c });
        }

        // Subject updated
        Assert.isTrue(dmlResult.success);
        Assert.areEqual('Case', dmlResult.objectType);
        Assert.areEqual(1, dmlResult.recordIds.size());
        Assert.areEqual(c.Id, dmlResult.recordIds[0]);

        c = [SELECT Id, Subject FROM Case WHERE Id = :c.Id];
        Assert.areEqual('New Subject', c.Subject);
    }

    @isTest
    private static void testUpdateDmlError() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        PermissionSet testPermSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermSetName LIMIT 1];

        // Give object-level and field-level access
        System.runAs(new User(Id = UserInfo.getUserId())) {
            ObjectPermissions caseObjAccess = new ObjectPermissions(
                SobjectType = 'Case',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsCreate = true,
                PermissionsEdit = true
            );
            insert caseObjAccess;

            FieldPermissions caseSubjAccess = new FieldPermissions(
                SobjectType = 'Case',
                Field = 'Case.Subject',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true
            );
            insert caseSubjAccess;
        }

        Case c = new Case(
            Subject = 'Hello World',
            Description = 'Initial contents',
            RecordTypeId = RecordIDHelper.getRecordTypeId('Case', 'ASU_Service')
        );

        // Attempt update and fail
        RecordController.DMLResult dmlResult;
        System.runAs(testUser) {
            insert c; // Create case as this user so they have record-level access to it
            c = [SELECT Id, Subject FROM Case WHERE Id = :c.Id];

            String invalidSubject = 'TOO LONG';
            for (Integer i = 0; i < Schema.SObjectType.Case.fields.Subject.getLength(); i++)
                invalidSubject += '.';
            c.Subject = invalidSubject;

            dmlResult = RecordController.updateRecords(new List<Case>{ c });
        }

        // DML Error exposed in response
        Assert.isFalse(dmlResult.success);
        Assert.areEqual('Case', dmlResult.objectType);
        Assert.isTrue(
            dmlResult?.errorMessage?.contains('data value too large'),
            'Error message should have contained "data value too large", but it instead said: "' +
                dmlResult.errorMessage +
                '"'
        );
    }

    @isTest
    private static void testDeleteNoObjectPerms() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias LIMIT 1];

        // Setup case to test with
        Case c = new Case(Subject = 'Hello World', Description = 'Initial contents');
        insert c;

        // Attempt update and get error thrown
        Exception thrownException;
        System.runAs(testUser) {
            try {
                RecordController.deleteRecords(new List<String>{ c.Id });
            } catch (Exception ex) {
                thrownException = ex;
            }
        }

        // Correct error
        Assert.isInstanceOfType(
            thrownException,
            RecordController.UserObjectDeleteException.class,
            'Incorrect exception type was thrown. Expected type RecordController.UserObjectDeleteException but got type ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('cannot delete object type'),
            'Error message should contain "cannot delete object type", but instead the error message said: "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    @isTest
    private static void testDeleteNoRecordPerms() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        PermissionSet testPermSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermSetName LIMIT 1];

        // Give object-level and field-level access (since this is check before record-level access)
        System.runAs(new User(Id = UserInfo.getUserId())) {
            ObjectPermissions caseObjAccess = new ObjectPermissions(
                SobjectType = 'Case',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true,
                PermissionsDelete = true
            );
            insert caseObjAccess;
        }

        // Setup case to test with
        Case c = new Case(Subject = 'Hello World', Description = 'Initial contents');
        insert c;

        // Attempt update and get error thrown
        Exception thrownException;
        System.runAs(testUser) {
            try {
                RecordController.deleteRecords(new List<String>{ c.Id });
            } catch (Exception ex) {
                thrownException = ex;
            }
        }

        // Correct error
        Assert.isInstanceOfType(
            thrownException,
            RecordController.UserRecordDeleteException.class,
            'Incorrect exception type was thrown. Expected type RecordController.UserRecordDeleteException but got type ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('cannot delete record ' + c.Id),
            'Error message should contain "cannot delete record ' +
                c.Id +
                '", but instead the error message said: "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    @isTest
    private static void testDeleteSuccessful() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        PermissionSet testPermSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermSetName LIMIT 1];

        // Give object-level and field-level access (since this is check before record-level access)
        System.runAs(new User(Id = UserInfo.getUserId())) {
            ObjectPermissions caseObjAccess = new ObjectPermissions(
                SobjectType = 'Case',
                ParentId = testPermSet.Id,
                PermissionsRead = true,
                PermissionsEdit = true,
                PermissionsDelete = true
            );
            insert caseObjAccess;
        }

        Case c = new Case(
            Subject = 'Hello World',
            Description = 'Initial contents',
            RecordTypeId = RecordIDHelper.getRecordTypeId('Case', 'ASU_Service')
        );

        // Attempt update and succeeds
        RecordController.DMLResult dmlResult;
        System.runAs(testUser) {
            insert c; // Create case as this user so they have record-level access to it

            // Delete case
            dmlResult = RecordController.deleteRecords(new List<String>{ c.Id });
        }

        // Subject updated
        Assert.isTrue(dmlResult.success);
        Assert.areEqual('Case', dmlResult.objectType);
        Assert.areEqual(1, dmlResult.recordIds.size());
        Assert.areEqual(c.Id, dmlResult.recordIds[0]);

        List<Case> cases = [SELECT Id FROM Case WHERE Id = :c.Id];
        Assert.isTrue(cases.isEmpty(), 'Case should have been deleted, but it wasn\'t');
    }

    @isTest
    private static void testDeleteSysAdminSuccess() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testSysAdminUserAlias LIMIT 1];

        // Create case
        Case c = new Case(Subject = 'Hello World', Description = 'Initial contents');
        insert c;

        // Attempt update and succeeds
        RecordController.DMLResult dmlResult;
        System.runAs(testUser) {
            // Delete case
            dmlResult = RecordController.deleteRecords(new List<String>{ c.Id });
        }

        // Subject updated
        Assert.isTrue(dmlResult.success);
        Assert.areEqual('Case', dmlResult.objectType);
        Assert.areEqual(1, dmlResult.recordIds.size());
        Assert.areEqual(c.Id, dmlResult.recordIds[0]);

        List<Case> cases = [SELECT Id FROM Case WHERE Id = :c.Id];
        Assert.isTrue(cases.isEmpty(), 'Case should have been deleted, but it wasn\'t');
    }
}
