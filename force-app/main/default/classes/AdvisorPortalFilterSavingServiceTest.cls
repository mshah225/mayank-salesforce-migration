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

    @isTest
    public static void testSetFilter() {
        String filter = '{descr: "This should be json"}';
        String largeFilter = '';
        for (Integer i = 0; i < 2048; i++) {
            largeFilter += 'A';
        }
        String tooLargeFilter = largeFilter + 'A';
        User u = [SELECT Id FROM User WHERE Alias = :testUsrAlias];

        Boolean preventedLength2048 = false;
        Boolean preventedLength2049 = false;

        System.runAs(u) {
            try {
                AdvisorPortalFilterSavingService.setDefaultFilter(largeFilter);
            } catch (AdvisorPortalFilterSavingService.AdvisorPortalFilterSavingException e) {
                preventedLength2048 = true;
            }

            try {
                AdvisorPortalFilterSavingService.setDefaultFilter(tooLargeFilter);
            } catch (AdvisorPortalFilterSavingService.AdvisorPortalFilterSavingException e) {
                preventedLength2049 = true;
            }

            AdvisorPortalFilterSavingService.setDefaultFilter(filter);
        }

        Success_Resource__c sr = [SELECT Default_Filter__c FROM Success_Resource__c];

        System.assertEquals(filter, sr.Default_Filter__c);
        System.assert(!preventedLength2048, 'Should not have prevented a filter of length 2048');
        System.assert(preventedLength2049, 'Should have prevented a filter of length 2049');
    }

    @isTest
    public static void testGetFilter() {
        String filter = '{descr: "This should be json"}';
        String foundFilter;
        User u = [SELECT Id FROM User WHERE Alias = :testUsrAlias];

        Success_Resource__c sr = [SELECT Id, Default_Filter__c FROM Success_Resource__c];
        sr.Default_Filter__c = filter;
        update sr;

        System.runAs(u) {
            foundFilter = AdvisorPortalFilterSavingService.getDefaultFilter();
        }

        System.assertEquals(filter, foundFilter);
    }

    @isTest
    public static void testClearFilter() {
        String filter = '{descr: "This should be json"}';
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
