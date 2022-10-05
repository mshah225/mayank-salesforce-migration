@isTest
public with sharing class AdvisorPortalFilterSavingServiceTest {
    private final static String testUsrAlias = 'testUsr';
    @TestSetup
    private static void setup() {
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'test.user@test.example.com',
            Email = 'test.user@test.example.com',
            Alias = testUsrAlias,
            CommunityNickname = 'testUsr',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileID('Standard User')
        );
        insert testUser;

        Success_Resource__c testSuccessResource = new Success_Resource__c(
            Role__c = 'User',
            Resource__c = testUser.Id,
            IsActive__c = true,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );
        insert testSuccessResource;
    }

    /**
     * Tests saving a filter and tests that it throws an error when saving a too large filter
     */
    @isTest
    public static void testSetFilter() {
        String filter =
            '{"version":"v2","caseSubject":"' +
            EncodingUtil.base64Encode(Blob.valueOf('Fallin\' through space')) +
            '"}';
        String largeFilter = '';
        for (Integer i = 0; i < Schema.SObjectType.Success_Resource__c.fields.Default_Filter__c.getLength(); i++) {
            largeFilter += 'A';
        }
        String tooLargeFilter = largeFilter + 'A';
        User u = [SELECT Id FROM User WHERE Alias = :testUsrAlias];

        Boolean preventedMaxLength = false;
        Boolean preventedLongerThanMaxLength = false;

        System.runAs(u) {
            try {
                AdvisorPortalFilterSavingService.setDefaultFilter(largeFilter);
            } catch (AdvisorPortalFilterSavingService.AdvisorPortalFilterSavingException e) {
                preventedMaxLength = true;
            }

            try {
                AdvisorPortalFilterSavingService.setDefaultFilter(tooLargeFilter);
            } catch (AdvisorPortalFilterSavingService.AdvisorPortalFilterSavingException e) {
                preventedLongerThanMaxLength = true;
            }

            AdvisorPortalFilterSavingService.setDefaultFilter(filter);
        }

        Success_Resource__c sr = [SELECT Default_Filter__c FROM Success_Resource__c];

        System.assertEquals(filter, sr.Default_Filter__c);
        System.assert(!preventedMaxLength, 'Should not have prevented a filter of max length');
        System.assert(preventedLongerThanMaxLength, 'Should have prevented a filter of max length + 1');
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
        String foundFilter;
        User u = [SELECT Id FROM User WHERE Alias = :testUsrAlias];

        Success_Resource__c sr = [SELECT Id, Default_Filter__c FROM Success_Resource__c];
        sr.Default_Filter__c = filter;
        update sr;

        System.runAs(u) {
            foundFilter = AdvisorPortalFilterSavingService.getDefaultFilter();
        }

        System.assert(foundFilter.contains('"version":"v2"'));
        System.assert(
            foundFilter.contains(
                '"caseSubject":"' +
                EncodingUtil.base64Encode(Blob.valueOf('Fallin\' through space')) +
                '"'
            )
        );
    }

    /**
     * Tests that any filters saved with version 1 filter are upgraded to version 2 before returning
     */
    @isTest
    public static void testGetFilterWithUpgradingFormat() {
        String filter = '{"version":"v1","caseSubject":"Fallin\' through space"}';
        String foundFilter;
        User u = [SELECT Id FROM User WHERE Alias = :testUsrAlias];

        Success_Resource__c sr = [SELECT Id, Default_Filter__c FROM Success_Resource__c];
        sr.Default_Filter__c = filter;
        update sr;

        System.runAs(u) {
            foundFilter = AdvisorPortalFilterSavingService.getDefaultFilter();
        }

        System.assert(foundFilter.contains('"version":"v2"'));
        System.assert(
            foundFilter.contains(
                '"caseSubject":"' +
                EncodingUtil.base64Encode(Blob.valueOf('Fallin\' through space')) +
                '"'
            )
        );
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
        User u = [SELECT Id FROM User WHERE Alias = :testUsrAlias];

        Success_Resource__c sr = [SELECT Id, Default_Filter__c FROM Success_Resource__c];
        sr.Default_Filter__c = filter;
        update sr;

        System.runAs(u) {
            AdvisorPortalFilterSavingService.clearDefaultFilter();
        }

        sr = [SELECT Default_Filter__c FROM Success_Resource__c];

        System.assertNotEquals(filter, sr.Default_Filter__c);
    }
}