@isTest
public with sharing class AdvisorPortalFilterSavingServiceTest {
    @TestSetup
    private static void setup() {
        // Initialize needed test users
        User testSysAdmin = TestUserHelper.createTestSysAdmin();
        USer testStandardUser = TestUserHelper.createTestStandardUser();

        insert new List<User>{ testSysAdmin, testStandardUser };

        Success_Resource__c testSuccessResource = new Success_Resource__c(
            Role__c = 'User',
            Resource__c = testSysAdmin.Id,
            IsActive__c = true,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );
        Success_Resource__c testSuccessResource2 = new Success_Resource__c(
            Role__c = 'User',
            Resource__c = testStandardUser.Id,
            IsActive__c = true,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );

        insert new List<Success_Resource__c>{ testSuccessResource, testSuccessResource2 };
    }

    /**
     * Tests saving a filter and tests that it throws an error when saving a too large filter
     */
    @isTest
    public static void testSetFilter() {
        String largeFilter = '';
        for (Integer i = 0; i < Schema.SObjectType.Success_Resource__c.fields.Default_Filter__c.getLength(); i++) {
            largeFilter += 'A';
        }
        User u = TestUserHelper.getTestSysAdmin();

        System.runAs(u) {
            AdvisorPortalFilterSavingService.setDefaultFilter(largeFilter);
        }

        Success_Resource__c sr = [SELECT Default_Filter__c FROM Success_Resource__c WHERE Resource__c = :u.Id];

        // Happy path - no error and saved successfully
        Assert.areEqual(largeFilter, sr.Default_Filter__c);
    }

    /**
     * Tests that returning a saved filter
     */
    @isTest
    public static void testGetFilter() {
        String filter =
            '{"version":"v2","caseSubject":"' +
            EncodingUtil.base64Encode(Blob.valueOf('Fallin\' through space')) +
            '"}';
        AdvisorPortalFilter foundFilter;
        User u = TestUserHelper.getTestSysAdmin();

        Success_Resource__c sr = [SELECT Id, Default_Filter__c FROM Success_Resource__c WHERE Resource__c = :u.id];
        sr.Default_Filter__c = filter;
        update sr;

        System.runAs(u) {
            foundFilter = AdvisorPortalFilterSavingService.getDefaultFilter();
        }

        Assert.areEqual('v2', foundFilter.version);
        Assert.areEqual(EncodingUtil.base64Encode(Blob.valueOf('Fallin\' through space')), foundFilter.caseSubject);
    }

    /**
     * Tests that any filters saved with version 1 filter are upgraded to version 2 before returning
     */
    @isTest
    public static void testGetFilterWithUpgradingFormat() {
        String filter = '{"version":"v1","caseSubject":"Fallin\' through space"}';
        AdvisorPortalFilter foundFilter;
        User u = TestUserHelper.getTestSysAdmin();

        Success_Resource__c sr = [SELECT Id, Default_Filter__c FROM Success_Resource__c WHERE Resource__c = :u.Id];
        sr.Default_Filter__c = filter;
        update sr;

        System.runAs(u) {
            foundFilter = AdvisorPortalFilterSavingService.getDefaultFilter();
        }

        Assert.areEqual('v2', foundFilter.version);
        Assert.areEqual(EncodingUtil.base64Encode(Blob.valueOf('Fallin\' through space')), foundFilter.caseSubject);
    }

    /**
     * Tests clearing a filter
     */
    @isTest
    public static void testClearFilter() {
        String filter =
            '{"version":"v2","caseSubject":"' +
            EncodingUtil.base64Encode(Blob.valueOf('Fallin\' through space')) +
            '"}';
        User u = TestUserHelper.getTestSysAdmin();

        Success_Resource__c sr = [SELECT Id, Default_Filter__c FROM Success_Resource__c WHERE Resource__c = :u.Id];
        sr.Default_Filter__c = filter;
        update sr;

        System.runAs(u) {
            AdvisorPortalFilterSavingService.clearDefaultFilter();
        }

        sr = [SELECT Default_Filter__c FROM Success_Resource__c WHERE Resource__c = :u.Id];

        Assert.areNotEqual(filter, sr.Default_Filter__c);
    }

    /**
     * Test default UGRAD Advisor user filter
     */
    @isTest
    public static void testDefaultUgradAdvisorUser() {
        User u = TestUserHelper.getTestStandardUser();

        // Give UGRAD perms
        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Role_Academic_Advisor_Portal_Service_Users'
            LIMIT 1
        ];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        insert psa;

        AdvisorPortalFilter foundFilter;

        System.runAs(u) {
            foundFilter = AdvisorPortalFilterSavingService.getDefaultFilter();
        }

        Assert.areEqual('UGRD', foundFilter.career);
    }

    /**
     * Test default GRAD Advisor user filter
     */
    @isTest
    public static void testDefaultGradAdvisorUser() {
        User u = TestUserHelper.getTestStandardUser();

        // Give GRAD perms
        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Role_Graduate_Academic_Advisor_Portal_Service_Users'
            LIMIT 1
        ];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        insert psa;

        AdvisorPortalFilter foundFilter;

        System.runAs(u) {
            foundFilter = AdvisorPortalFilterSavingService.getDefaultFilter();
        }

        Assert.areEqual('GRD', foundFilter.career);
    }

    /**
     * Test default UGRAD and GRAD (mixed) Advisor user filter
     */
    @isTest
    public static void testDefaultMixedUgradAndGradAdvisorUser() {
        User u = TestUserHelper.getTestStandardUser();

        // Give GRAD perms
        List<PermissionSet> ps = [
            SELECT Id
            FROM PermissionSet
            WHERE
                Name IN (
                    'Role_Academic_Advisor_Portal_Service_Users',
                    'Role_Graduate_Academic_Advisor_Portal_Service_Users'
                )
            LIMIT 2
        ];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps[0].Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps[1].Id);
        insert new List<PermissionSetAssignment>{ psa, psa2 };

        AdvisorPortalFilter foundFilter;

        System.runAs(u) {
            foundFilter = AdvisorPortalFilterSavingService.getDefaultFilter();
        }

        Assert.areEqual('v2', foundFilter.version);
        Assert.areEqual('UGRD', foundFilter.career);
    }

    /**
     * Test default no access user filter
     */
    @isTest
    public static void testErrorNoAccessUser() {
        Exception thrownEx = null;

        System.runAs(TestUserHelper.getTestStandardUser()) {
            try {
                AdvisorPortalFilterSavingService.getDefaultFilter();
            } catch (Exception e) {
                thrownEx = e;
            }
        }

        Assert.isInstanceOfType(
            thrownEx,
            AdvisorPortalFilterSavingService.AdvisorPortalFilterCannotGetDefaultPermissionsException.class,
            'Expected to throw an exception of type AdvisorPortalFilterSavingService.AdvisorPortalFilterCannotGetDefaultPermissionsException, but actually threw ' +
            thrownEx?.getTypeName()
        );
    }

    /**
     * Tests saving a filter and tests that it throws an error when saving a too large filter
     */
    @isTest
    public static void testErrorFilterTooLong() {
        String tooLargeFilter = '';
        for (Integer i = 0; i < Schema.SObjectType.Success_Resource__c.fields.Default_Filter__c.getLength(); i++) {
            tooLargeFilter += 'A';
        }
        tooLargeFilter += 'A';
        User u = TestUserHelper.getTestSysAdmin();

        Exception expectedException = null;

        System.runAs(u) {
            try {
                AdvisorPortalFilterSavingService.setDefaultFilter(tooLargeFilter);
            } catch (Exception e) {
                expectedException = e;
            }
        }

        // Error path - filter too large
        Assert.isInstanceOfType(
            expectedException,
            AdvisorPortalFilterSavingService.AdvisorPortalFilterCannotSaveDefaultException.class,
            'Expected to throw an exception of type AdvisorPortalFilterSavingService.AdvisorPortalFilterCannotSaveDefaultException, but actually threw ' +
            expectedException?.getTypeName()
        );
        Assert.isTrue(
            expectedException.getMessage().contains('Filter too large'),
            'Message should indicate filter is too large'
        );
    }

    /**
     * Tests getting a filter that is corrupted and not a valid format
     */
    @isTest
    public static void testErrorFilterCorrupted() {
        String corruptFilter = 'OH NO!';
        User u = TestUserHelper.getTestSysAdmin();

        Success_Resource__c sr = [SELECT Id, Default_Filter__c FROM Success_Resource__c WHERE Resource__c = :u.Id];
        sr.Default_Filter__c = corruptFilter;
        update sr;

        Exception expectedException = null;

        System.runAs(u) {
            try {
                AdvisorPortalFilterSavingService.getDefaultFilter();
            } catch (Exception e) {
                expectedException = e;
            }
        }

        // Error path - filter corrupted
        Assert.isInstanceOfType(
            expectedException,
            AdvisorPortalFilterSavingService.AdvisorPortalFilterCannotGetDefaultCorruptedException.class,
            'Expected to throw an exception of type AdvisorPortalFilterSavingService.AdvisorPortalFilterCannotGetDefaultCorruptedException, but actually threw ' +
            expectedException?.getTypeName()
        );
        Assert.isTrue(
            expectedException.getMessage().contains('This user has a filter - but it\'s format is corrupted'),
            'Message should indicate filter is corrupted'
        );
    }

    /**
     * Tests saving a filter without having a success resource - throws error
     */
    @isTest
    public static void testErrorNoSuccessResourceSetFilter() {
        String filter =
            '{"version":"v2","caseSubject":"' +
            EncodingUtil.base64Encode(Blob.valueOf('Fallin\' through space')) +
            '"}';

        User u = TestUserHelper.getTestSysAdmin();

        Exception expectedException = null;

        Success_Resource__c sr = [SELECT Default_Filter__c FROM Success_Resource__c WHERE Resource__c = :u.Id];
        delete sr;

        System.runAs(u) {
            try {
                AdvisorPortalFilterSavingService.setDefaultFilter(filter);
            } catch (Exception e) {
                expectedException = e;
            }
        }

        // Error path - no success resource
        Assert.isInstanceOfType(
            expectedException,
            AdvisorPortalFilterSavingService.AdvisorPortalFilterCannotSaveDefaultException.class,
            'Expected to throw an exception of type AdvisorPortalFilterSavingService.AdvisorPortalFilterCannotSaveDefaultException, but actually threw ' +
            expectedException?.getTypeName()
        );
        Assert.isTrue(
            expectedException.getMessage().contains('user doesn\'t have a success resource'),
            'Message should indicate user doesn\'t have a success resource and therefore can\'t use the save filter feature'
        );
    }

    /**
     * Tests clearing saved filters without having a success resource - throws error
     */
    @isTest
    public static void testErrorNoSuccessResourceClearFilter() {
        String tooLargeFilter = '';
        for (Integer i = 0; i < Schema.SObjectType.Success_Resource__c.fields.Default_Filter__c.getLength(); i++) {
            tooLargeFilter += 'A';
        }
        User u = TestUserHelper.getTestSysAdmin();

        Exception expectedException = null;

        Success_Resource__c sr = [SELECT Default_Filter__c FROM Success_Resource__c WHERE Resource__c = :u.Id];
        delete sr;

        System.runAs(u) {
            try {
                AdvisorPortalFilterSavingService.clearDefaultFilter();
            } catch (Exception e) {
                expectedException = e;
            }
        }

        // Error path - no success resource
        Assert.isInstanceOfType(
            expectedException,
            AdvisorPortalFilterSavingService.AdvisorPortalFilterCannotSaveDefaultException.class,
            'Expected to throw an exception of type AdvisorPortalFilterSavingService.AdvisorPortalFilterCannotSaveDefaultException, but actually threw ' +
            expectedException?.getTypeName()
        );
        Assert.isTrue(
            expectedException.getMessage().contains('user doesn\'t have a success resource'),
            'Message should indicate user doesn\'t have a success resource and therefore can\'t use the save filter feature'
        );
    }
}
