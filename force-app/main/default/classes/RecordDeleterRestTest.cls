@isTest
public class RecordDeleterRestTest {
    @TestSetup
    private static void setup() {
        // Initialize needed test users
        User testUser = TestUserHelper.createTestSysAdmin();
        insert new List<User>{ testUser };

        // Other test data
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 20; i++)
            testContacts.add(
                new Contact(
                    FirstName = 'Test-Contact-' + i,
                    LastName = 'Record Deleter Test',
                    Email = 'record.deleter.test.' + i + '@test.test'
                )
            );
        insert testContacts;

        List<Case> testCases = new List<Case>();
        for (Contact c : testContacts)
            for (Integer i = 0; i < 2; i++) {
                Case cs = new Case(
                    Subject = 'Record Deleter Test Case for ' + c.FirstName + ' #' + i,
                    ContactId = c.Id
                );
                testCases.add(cs);
            }
        insert testCases;
    }

    @isTest
    static void testHappyPath() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        LogSuite.activateLogSuite('testflow');

        // Get all contacts to delete
        List<Contact> testContacts = [SELECT Id FROM Contact];
        List<String> recordIds = new List<String>();
        for (Contact c : testContacts)
            recordIds.add(c.Id);

        // Setup metadata to delete cases
        RecordDeleter.TEST_METADATA = new List<Record_Deleter_Setting__mdt>{
            new Record_Deleter_Setting__mdt(
                Parent_Object_Type__c = 'Contact',
                Child_Object_Type__c = 'Case',
                Parent_Field_Key__c = '$.Id',
                Child_Field_Key__c = '$.ContactId'
            )
        };

        // Create request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RecordDeleter';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Map<String, Object> bodyMp = new Map<String, Object>();
        bodyMp.put('recordIds', recordIds);
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMp));

        // Send request
        Test.startTest();
        System.runAs(u) {
            RecordDeleterRest.deleteRecords(recordIds);
        }
        Test.stopTest();

        System.debug(RestContext.response.responseBody.toString());

        List<RecordDeleterRest.DeleteStatus> response = (List<RecordDeleterRest.DeleteStatus>) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            List<RecordDeleterRest.DeleteStatus>.class
        );

        // Response for all records deleted
        Assert.areEqual(200, RestContext.response.statusCode);
        Assert.areEqual(recordIds.size(), response.size());
        for (Integer i = 0; i < recordIds.size(); i++) {
            String recordId = recordIds[i];
            RecordDeleterRest.DeleteStatus ds = response[i];

            Assert.areEqual(recordId, ds.recordId, 'Response out of order (indx=' + i + ')');
            Assert.isTrue(ds.success, 'Failed to delete ' + recordId + ' (indx=' + i + '):' + ds.errorMsg);
        }
    }

    @isTest
    static void testErrorNoIds() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        LogSuite.activateLogSuite('testflow');

        List<String> recordIds = new List<String>();

        // Create request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RecordDeleter';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Map<String, Object> bodyMp = new Map<String, Object>();
        bodyMp.put('recordIds', recordIds);
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMp));

        // Send request
        Test.startTest();
        System.runAs(u) {
            RecordDeleterRest.deleteRecords(recordIds);
        }
        Test.stopTest();

        RecordDeleterRest.ErrorResponse response = (RecordDeleterRest.ErrorResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            RecordDeleterRest.ErrorResponse.class
        );

        // Error response
        Assert.areEqual(400, RestContext.response.statusCode);
        Assert.isTrue(
            response.error.contains('No records passed for deletion'),
            'Expected error to contain "No records passed for deletion" but it instead said "' + response.error + '"'
        );
    }

    @isTest
    static void testErrorInvalidIds() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        LogSuite.activateLogSuite('testflow');

        List<String> recordIds = new List<String>{ 'XXX' };

        // Create request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RecordDeleter';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Map<String, Object> bodyMp = new Map<String, Object>();
        bodyMp.put('recordIds', recordIds);
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMp));

        // Send request
        Test.startTest();
        System.runAs(u) {
            RecordDeleterRest.deleteRecords(recordIds);
        }
        Test.stopTest();

        RecordDeleterRest.ErrorResponse response = (RecordDeleterRest.ErrorResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            RecordDeleterRest.ErrorResponse.class
        );

        // Error response
        Assert.areEqual(400, RestContext.response.statusCode);
        Assert.isTrue(
            response.error.contains('Could not determine object type'),
            'Expected error to contain "Could not determine object type" but it instead said "' + response.error + '"'
        );
    }

    @isTest
    static void testErrorMixedIds() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        LogSuite.activateLogSuite('testflow');

        List<String> recordIds = new List<String>{
            ObjectService.getFakeId(Contact.SObjectType),
            ObjectService.getFakeId(Case.SObjectType)
        };

        // Create request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RecordDeleter';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Map<String, Object> bodyMp = new Map<String, Object>();
        bodyMp.put('recordIds', recordIds);
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMp));

        // Send request
        Test.startTest();
        System.runAs(u) {
            RecordDeleterRest.deleteRecords(recordIds);
        }
        Test.stopTest();

        RecordDeleterRest.ErrorResponse response = (RecordDeleterRest.ErrorResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            RecordDeleterRest.ErrorResponse.class
        );

        // Error response
        Assert.areEqual(400, RestContext.response.statusCode);
        Assert.isTrue(
            response.error.contains('Mixed object types'),
            'Expected error to contain "Mixed object types" but it instead said "' + response.error + '"'
        );
    }

    @isTest
    static void testErrorNoPermission() {
        User u = TestUserHelper.getTestSysAdmin();
        LogSuite.activateLogSuite('testflow');

        List<String> recordIds = new List<String>{
            ObjectService.getFakeId(Contact.SObjectType),
            ObjectService.getFakeId(Contact.SObjectType)
        };

        // Create request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RecordDeleter';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Map<String, Object> bodyMp = new Map<String, Object>();
        bodyMp.put('recordIds', recordIds);
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMp));

        // Send request
        Test.startTest();
        System.runAs(u) {
            RecordDeleterRest.deleteRecords(recordIds);
        }
        Test.stopTest();

        RecordDeleterRest.ErrorResponse response = (RecordDeleterRest.ErrorResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            RecordDeleterRest.ErrorResponse.class
        );

        // Error response
        Assert.areEqual(403, RestContext.response.statusCode);
        Assert.isTrue(
            response.error.contains('does not have permission to use RecordDeleter'),
            'Expected error to contain "does not have permission to use RecordDeleter" but it instead said "' +
                response.error +
                '"'
        );
    }

    /**
     * Expensive per-test activate a custom permission for a user.
     *
     * Because of how FeatureManagement.checkPermission works, we need to create a new permission set that grants the permission
     * and assign the user that permission set in order to get it to detect the custom permission.
     * We CANNOT use an already existing permission set.
     *
     */
    private static void activateCustomPerm(String userId, String permissionName) {
        PermissionSet ps = new PermissionSet(
            Name = permissionName + '_Enabled_' + permSetIndx,
            Label = permissionName + ' Enabled ' + permSetIndx
        );
        insert ps;
        permSetIndx += 1;

        SetupEntityAccess sea = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = [
                SELECT Id
                FROM CustomPermission
                WHERE DeveloperName = :permissionName
                LIMIT 1
            ]
            .Id
        );

        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);

        insert new List<SObject>{ sea, psa };
    }
    private static Integer permSetIndx = 0;
}
