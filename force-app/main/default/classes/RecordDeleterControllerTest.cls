@isTest
public class RecordDeleterControllerTest {
    @TestSetup
    private static void setup() {
        // Initialize needed test users
        User testUser = TestUserHelper.createTestSysAdmin();
        insert new List<User>{ testUser };

        // Other test data
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        // 800 parent records
        List<Event> testParentRecords = new List<Event>();
        for (Integer i = 0; i < 800; i++)
            testParentRecords.add(
                new Event(ClientGuid = 'Test-' + i, DurationInMinutes = 30, ActivityDateTime = System.now())
            );
        insert testParentRecords;

        // Test child records (2 per parent)
        List<Contract> testChildRecords = new List<Contract>();
        for (Event c : testParentRecords)
            for (Integer i = 0; i < 2; i++) {
                Contract cs = new Contract(Name = c.ClientGuid, AccountId = testAcc.Id);
                testChildRecords.add(cs);
            }
        insert testChildRecords;
    }

    /**
     * Check that a user with no access is reported as much
     */
    @isTest
    private static void testHasAccessNoAccess() {
        User u = TestUserHelper.getTestSysAdmin();

        Boolean hasAccess;

        System.runAs(u) {
            hasAccess = RecordDeleterController.hasAccess();
        }

        Assert.isFalse(hasAccess, 'User should have no access, but they do');
    }

    /**
     * Check that a user with no access is reported as much
     */
    @isTest
    private static void testHasAccessYesAccess() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        Boolean hasAccess;

        System.runAs(u) {
            hasAccess = RecordDeleterController.hasAccess();
        }

        Assert.isTrue(hasAccess, 'User should have access, but they do not');
    }

    /**
     * Tests that we can get the object name
     */
    @isTest
    private static void testGetObjectName() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        String objectName;

        System.runAs(u) {
            objectName = RecordDeleterController.getObjectName(ObjectService.getFakeId(Contact.SObjectType));
        }
        Assert.areEqual('Contact', objectName);
    }

    /**
     * Tests that throws error if type is unknown
     */
    @isTest
    private static void testGetObjectNameError() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        Exception thrownEx;
        try {
            System.runAs(u) {
                String objectName = RecordDeleterController.getObjectName('');
            }
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            RecordDeleterController.RecordDeleterControllerInvalidIdException.class,
            'Expected to throw an exception of type RecordDeleterController.RecordDeleterControllerInvalidIdException, but actually threw ' +
            thrownEx?.getTypeName()
        );
        Assert.isTrue(
            thrownEx?.getMessage()?.contains('Could not determine object type using prefix'),
            'Expected error message to contain "Could not determine object type using prefix" but it instead said "' +
                thrownEx?.getMessage() +
                '"'
        );
    }

    /**
     * Tests that the queueable is queued
     */
    @isTest
    private static void testJobIsQueued() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        String coordinatorId;

        System.runAs(u) {
            coordinatorId = RecordDeleterController.performMassDelete(
                new List<String>{
                    ObjectService.getFakeId(Contact.SObjectType),
                    ObjectService.getFakeId(Contact.SObjectType),
                    ObjectService.getFakeId(Contact.SObjectType)
                }
            );
        }

        Async_Job_Coordinator__c coordinator = [
            SELECT Id, Job_Id__c, Status__c
            FROM Async_Job_Coordinator__c
            WHERE Id = :coordinatorId
        ];

        AsyncApexJob batchJob = [SELECT Id, Status, ApexClass.Name FROM AsyncApexJob WHERE Id = :coordinator.Job_Id__c];

        Assert.areEqual('Queued', coordinator.Status__c);
        Assert.areEqual('Queued', batchJob.Status);
        Assert.areEqual('RecordDeleterBatchable', batchJob.ApexClass.Name);
    }

    /**
     * Tests that checkStatus reports not the job is NOT done (and percent=0) when job has
     * just been queued
     */
    @isTest
    private static void testJobIsQueuedCheckStatus() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        String coordinatorId;

        System.runAs(u) {
            coordinatorId = RecordDeleterController.performMassDelete(
                new List<String>{
                    ObjectService.getFakeId(Contact.SObjectType),
                    ObjectService.getFakeId(Contact.SObjectType),
                    ObjectService.getFakeId(Contact.SObjectType)
                }
            );
        }

        RecordDeleterController.RunStatus rs;
        System.runAs(u) {
            rs = RecordDeleterController.checkStatus(coordinatorId);
        }

        Assert.areEqual(false, rs.done);
        Assert.areEqual(0.0, rs.percent);
    }

    /**
     * Tests that records are actually deleted
     */
    @isTest
    private static void testDeletesRecords() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        List<Event> testParentRecords = [SELECT Id, ClientGuid FROM Event LIMIT 20];

        List<String> recordIds = new List<String>();
        List<String> recordNames = new List<String>();
        for (Event c : testParentRecords) {
            recordIds.add(c.Id);
            recordNames.add(c.ClientGuid);
        }

        List<Contract> testChildren = [SELECT Id FROM Contract WHERE Name IN :recordNames];

        // Setup metadata to autodelete cases
        RecordDeleter.TEST_METADATA = new List<Record_Deleter_Setting__mdt>{
            new Record_Deleter_Setting__mdt(
                Parent_Object_Type__c = 'Event',
                Child_Object_Type__c = 'Contract',
                Parent_Field_Key__c = '$.ClientGuid',
                Child_Field_Key__c = '$.Name'
            )
        };

        Test.startTest();
        System.runAs(u) {
            RecordDeleterController.performMassDelete(recordIds);
        }
        Test.stopTest();

        testParentRecords = [SELECT Id FROM Event WHERE Id IN :recordIds];
        Assert.isTrue(
            testParentRecords.isEmpty(),
            'Should be no parents remaining but there are ' + testParentRecords.size() + ' parents left'
        );

        List<String> childIds = new List<String>();
        for (Contract c : testChildren)
            childIds.add(c.Id);
        testChildren = [SELECT Id FROM Contract WHERE Id IN :childIds];
        Assert.isTrue(
            testChildren.isEmpty(),
            'Should be no children remaining but there are ' + testChildren.size() + ' children left'
        );
    }

    /**
     * Tests report is generated correctly
     */
    @isTest
    private static void testDeleteRecordsReportCsv() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        List<Event> testParentRecords = [SELECT Id FROM Event LIMIT 20];

        List<String> recordIds = new List<String>();
        for (Event c : testParentRecords)
            recordIds.add(c.Id);

        // Setup metadata to autodelete cases
        RecordDeleter.TEST_METADATA = new List<Record_Deleter_Setting__mdt>{
            new Record_Deleter_Setting__mdt(
                Parent_Object_Type__c = 'Event',
                Child_Object_Type__c = 'Contract',
                Parent_Field_Key__c = '$.ClientGuid',
                Child_Field_Key__c = '$.Name'
            )
        };

        Test.startTest();
        String coordinatorId;
        System.runAs(u) {
            coordinatorId = RecordDeleterController.performMassDelete(recordIds);
        }
        Test.stopTest();

        RecordDeleterController.RunStatus rs;
        System.runAs(u) {
            rs = RecordDeleterController.checkStatus(coordinatorId);
        }

        // Finished running
        Assert.isTrue(rs.done);
        Assert.areEqual(1.0, rs.percent);

        String results;
        System.runAs(u) {
            results = RecordDeleterController.getResults(coordinatorId);
        }
        List<String> resultsSplit = results.split('\n');

        // First row is headers
        List<String> headerRow = resultsSplit[0].split(',');
        Assert.areEqual('Record Id', headerRow[0]);
        Assert.areEqual('Status', headerRow[1]);
        Assert.areEqual('Error', headerRow[2]);

        // One row per record id (-1, one for header row)
        Assert.areEqual(recordIds.size(), resultsSplit.size() - 1);
        for (Integer i = 0; i < recordIds.size(); i++) {
            String recordId = recordIds[i];
            String result = resultsSplit[i + 1];

            List<String> rowSplit = result.split(',');

            Assert.areEqual(recordId, rowSplit[0]);
            Assert.areEqual('TRUE', rowSplit[1]);
        }
    }

    /**
     * Tests that getReport throws an error before the job is complete
     */
    @isTest
    private static void testErrorJobIsQueuedGetReport() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        String coordinatorId;
        System.runAs(u) {
            coordinatorId = RecordDeleterController.performMassDelete(
                new List<String>{
                    ObjectService.getFakeId(Contact.SObjectType),
                    ObjectService.getFakeId(Contact.SObjectType),
                    ObjectService.getFakeId(Contact.SObjectType)
                }
            );
        }

        Exception thrownEx;
        try {
            System.runAs(u) {
                RecordDeleterController.getResults(coordinatorId);
            }
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            RecordDeleterController.RecordDeleterControllerNoReportException.class,
            'Expected to throw an exception of type RecordDeleterController.RecordDeleterControllerNoReportException, but actually threw ' +
            thrownEx?.getTypeName()
        );
    }
    /**
     * Tests that throws an error for empty lists
     */
    @isTest
    private static void testErrorInvalidJobs() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        Exception nullListException, emptyListException, invalidIdException, mixedListException;

        try {
            System.runAs(u) {
                RecordDeleterController.performMassDelete(null);
            }
        } catch (Exception ex) {
            nullListException = ex;
        }
        try {
            System.runAs(u) {
                RecordDeleterController.performMassDelete(new List<String>());
            }
        } catch (Exception ex) {
            emptyListException = ex;
        }
        try {
            System.runAs(u) {
                RecordDeleterController.performMassDelete(new List<String>{ '' });
            }
        } catch (Exception ex) {
            invalidIdException = ex;
        }
        try {
            System.runAs(u) {
                RecordDeleterController.performMassDelete(
                    new List<String>{
                        ObjectService.getFakeId(Contact.SObjectType),
                        ObjectService.getFakeId(Case.SObjectType)
                    }
                );
            }
        } catch (Exception ex) {
            mixedListException = ex;
        }

        Assert.isInstanceOfType(
            nullListException,
            RecordDeleterController.RecordDeleterControllerInvalidIdException.class,
            'Expected to throw an exception of type RecordDeleterController.RecordDeleterControllerInvalidIdException, but actually threw ' +
            nullListException?.getTypeName()
        );
        Assert.isTrue(
            nullListException?.getMessage()?.contains('No records queued for deletion'),
            'Expected error message to contain "No records queued for deletion" but it instead said "' +
                nullListException?.getMessage() +
                '"'
        );

        Assert.isInstanceOfType(
            emptyListException,
            RecordDeleterController.RecordDeleterControllerInvalidIdException.class,
            'Expected to throw an exception of type RecordDeleterController.RecordDeleterControllerInvalidIdException, but actually threw ' +
            emptyListException?.getTypeName()
        );
        Assert.isTrue(
            emptyListException?.getMessage()?.contains('No records queued for deletion'),
            'Expected error message to contain "No records queued for deletion" but it instead said "' +
                emptyListException?.getMessage() +
                '"'
        );

        Assert.isInstanceOfType(
            invalidIdException,
            RecordDeleterController.RecordDeleterControllerInvalidIdException.class,
            'Expected to throw an exception of type RecordDeleterController.RecordDeleterControllerInvalidIdException, but actually threw ' +
            invalidIdException?.getTypeName()
        );
        Assert.isTrue(
            invalidIdException?.getMessage()?.contains('Could not determine object type'),
            'Expected error message to contain "Could not determine object type" but it instead said "' +
                invalidIdException?.getMessage() +
                '"'
        );

        Assert.isInstanceOfType(
            mixedListException,
            RecordDeleterController.RecordDeleterControllerInvalidIdException.class,
            'Expected to throw an exception of type RecordDeleterController.RecordDeleterControllerInvalidIdException, but actually threw ' +
            mixedListException?.getTypeName()
        );
        Assert.isTrue(
            mixedListException?.getMessage()?.contains('Mixed object types'),
            'Expected error message to contain "Mixed object types" but it instead said "' +
                mixedListException?.getMessage() +
                '"'
        );
    }

    /**
     * Tests that checkStatus and getResults return null or throw errors for null or invalid coordinator ids
     */
    @isTest
    private static void testErrorInvalidCoordinatorId() {
        User u = TestUserHelper.getTestSysAdmin();
        activateCustomPerm(u.Id, 'Record_Deleter_Access');

        Exception checkStatusNullCoordinatorIdException,
            checkStatusEmptyCoordinatorIdException,
            getResultsNullCoordinatorIdException,
            getResultsEmptyCoordinatorIdException;

        try {
            System.runAs(u) {
                RecordDeleterController.checkStatus(null);
            }
        } catch (Exception ex) {
            checkStatusNullCoordinatorIdException = ex;
        }
        try {
            System.runAs(u) {
                RecordDeleterController.checkStatus('');
            }
        } catch (Exception ex) {
            checkStatusEmptyCoordinatorIdException = ex;
        }
        try {
            System.runAs(u) {
                RecordDeleterController.getResults(null);
            }
        } catch (Exception ex) {
            getResultsNullCoordinatorIdException = ex;
        }
        try {
            System.runAs(u) {
                RecordDeleterController.getResults('');
            }
        } catch (Exception ex) {
            getResultsEmptyCoordinatorIdException = ex;
        }

        Assert.areEqual(
            null,
            checkStatusNullCoordinatorIdException,
            'null coordinator id should return null, not throw an error'
        );

        Assert.isInstanceOfType(
            checkStatusEmptyCoordinatorIdException,
            RecordDeleterController.RecordDeleterControllerInvalidCoordinatorIdException.class,
            'Expected to throw an exception of type RecordDeleterController.RecordDeleterControllerInvalidCoordinatorIdException, but actually threw ' +
            checkStatusEmptyCoordinatorIdException?.getTypeName()
        );
        Assert.isTrue(
            checkStatusEmptyCoordinatorIdException?.getMessage()?.contains('Could not find job using coordinator id'),
            'Expected error message to contain "Could not find job using coordinator id" but it instead said "' +
                checkStatusEmptyCoordinatorIdException?.getMessage() +
                '"'
        );

        Assert.areEqual(
            null,
            getResultsNullCoordinatorIdException,
            'null coordinator id should return null, not throw an error'
        );

        Assert.isInstanceOfType(
            getResultsEmptyCoordinatorIdException,
            RecordDeleterController.RecordDeleterControllerInvalidCoordinatorIdException.class,
            'Expected to throw an exception of type RecordDeleterController.RecordDeleterControllerInvalidCoordinatorIdException, but actually threw ' +
            getResultsEmptyCoordinatorIdException?.getTypeName()
        );
        Assert.isTrue(
            getResultsEmptyCoordinatorIdException?.getMessage()?.contains('Could not find job using coordinator id'),
            'Expected error message to contain "Could not find job using coordinator id" but it instead said "' +
                getResultsEmptyCoordinatorIdException?.getMessage() +
                '"'
        );
    }

    @isTest
    private static void throwsErrorsIfNoPermission() {
        User u = TestUserHelper.getTestSysAdmin();

        Exception getObjectNamePermException,
            performMassDeletePermException,
            checkStatusPermException,
            getResultsPermException;

        try {
            System.runAs(u) {
                RecordDeleterController.getObjectName(null);
            }
        } catch (Exception ex) {
            getObjectNamePermException = ex;
        }
        try {
            System.runAs(u) {
                RecordDeleterController.performMassDelete(null);
            }
        } catch (Exception ex) {
            performMassDeletePermException = ex;
        }
        try {
            System.runAs(u) {
                RecordDeleterController.checkStatus(null);
            }
        } catch (Exception ex) {
            checkStatusPermException = ex;
        }
        try {
            System.runAs(u) {
                RecordDeleterController.getResults(null);
            }
        } catch (Exception ex) {
            getResultsPermException = ex;
        }

        Assert.isInstanceOfType(
            getObjectNamePermException,
            RecordDeleterController.RecordDeleterControllerPermissionException.class,
            'Expected to throw an exception of type RecordDeleterController.RecordDeleterControllerPermissionException, but actually threw ' +
            getObjectNamePermException?.getTypeName()
        );
        Assert.isTrue(
            getObjectNamePermException?.getMessage()?.contains('does not have permission to use the RecordDeleter'),
            'Expected error message to contain "does not have permission to use the RecordDeleter" but it instead said "' +
                getObjectNamePermException?.getMessage() +
                '"'
        );

        Assert.isInstanceOfType(
            performMassDeletePermException,
            RecordDeleterController.RecordDeleterControllerPermissionException.class,
            'Expected to throw an exception of type RecordDeleterController.RecordDeleterControllerPermissionException, but actually threw ' +
            performMassDeletePermException?.getTypeName()
        );
        Assert.isTrue(
            performMassDeletePermException?.getMessage()?.contains('does not have permission to use the RecordDeleter'),
            'Expected error message to contain "does not have permission to use the RecordDeleter" but it instead said "' +
                performMassDeletePermException?.getMessage() +
                '"'
        );

        Assert.isInstanceOfType(
            checkStatusPermException,
            RecordDeleterController.RecordDeleterControllerPermissionException.class,
            'Expected to throw an exception of type RecordDeleterController.RecordDeleterControllerPermissionException, but actually threw ' +
            checkStatusPermException?.getTypeName()
        );
        Assert.isTrue(
            checkStatusPermException?.getMessage()?.contains('does not have permission to use the RecordDeleter'),
            'Expected error message to contain "does not have permission to use the RecordDeleter" but it instead said "' +
                checkStatusPermException?.getMessage() +
                '"'
        );

        Assert.isInstanceOfType(
            getResultsPermException,
            RecordDeleterController.RecordDeleterControllerPermissionException.class,
            'Expected to throw an exception of type RecordDeleterController.RecordDeleterControllerPermissionException, but actually threw ' +
            getResultsPermException?.getTypeName()
        );
        Assert.isTrue(
            getResultsPermException?.getMessage()?.contains('does not have permission to use the RecordDeleter'),
            'Expected error message to contain "does not have permission to use the RecordDeleter" but it instead said "' +
                getResultsPermException?.getMessage() +
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
