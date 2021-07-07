/*****************************************
 * File: CrossOrgShareUtilitiesTest
 * Author: Carl Hussey, ASU
 * Description: Unit Tests for CrossOrgShareUtilities.cls
 ******************************************/
@IsTest
private class CrossOrgShareUtilitiesTest {
    /**
     * Create test contacts
     */
    static List<Contact> createContacts(Integer qty) {
        List<Contact> testContacts = new List<Contact>();
        for (integer i = 0; i < qty; i++) {
            Contact c = new Contact(
                LastName = 'LName' + i,
                FirstName = 'FName' + i,
                SSB_CRMSYSTEM_Contact_ID__c = '9C7E57CF-2DC7-4C89-B476-11166DED34D' + i
            );
            testContacts.add(c);
        }
        return testContacts;
    }

    /**
     * Test Success Crosswalk Response for given GUID
     */
    @isTest
    private static void testgetCrosswalkRecords() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        // Set up the Contacts
        List<Contact> contacts = createContacts(1);
        insert contacts;

        CrossOrgShareUtilities.CrosswalkGetWrapper record = new CrossOrgShareUtilities.CrosswalkGetWrapper();
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> mockResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> actualResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();

        Contact testContact = [
            SELECT Id, SSB_CRMSYSTEM_Contact_ID__c, LastModifiedDate
            FROM Contact
            WHERE LastName = 'LName0'
            LIMIT 1
        ];

        record.contactId = testContact.Id;
        record.guid = testContact.SSB_CRMSYSTEM_Contact_ID__c;
        record.lastModifiedDate = String.valueOf(testContact.LastModifiedDate.format('M/d/yyyy'));
        record.sourceOrgId = UserInfo.getOrganizationId();
        mockResponse.add(record);

        Test.startTest();
        actualResponse = CrossOrgShareUtilities.getCrosswalkRecords(testContact.SSB_CRMSYSTEM_Contact_ID__c);
        Test.stopTest();

        System.assertEquals(mockResponse[0].guid, actualResponse[0].guid);
        System.assertEquals(mockResponse[0].lastModifiedDate, actualResponse[0].lastModifiedDate);
        System.assertEquals(mockResponse[0].contactId, actualResponse[0].contactId);
        System.assertEquals(mockResponse[0].sourceOrgId, actualResponse[0].sourceOrgId);
    }

    /**
     * Test Success Crosswalk Response for given ContactId
     */
    @isTest
    private static void testgetCrosswalkRecordsById() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        // Set up the Contacts
        List<Contact> contacts = createContacts(1);
        insert contacts;

        CrossOrgShareUtilities.CrosswalkGetWrapper record = new CrossOrgShareUtilities.CrosswalkGetWrapper();
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> mockResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();

        Contact testContact = [
            SELECT Id, SSB_CRMSYSTEM_Contact_ID__c, LastModifiedDate
            FROM Contact
            WHERE LastName = 'LName0'
            LIMIT 1
        ];

        record.contactId = testContact.Id;
        record.guid = testContact.SSB_CRMSYSTEM_Contact_ID__c;
        record.lastModifiedDate = String.valueOf(testContact.LastModifiedDate.format('M/d/yyyy'));
        record.sourceOrgId = UserInfo.getOrganizationId();
        mockResponse.add(record);

        Test.startTest();
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> actualResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        actualResponse = CrossOrgShareUtilities.getCrosswalkRecordById(testContact.Id);
        Test.stopTest();

        System.assertEquals(mockResponse[0].guid, actualResponse[0].guid);
        System.assertEquals(mockResponse[0].lastModifiedDate, actualResponse[0].lastModifiedDate);
        System.assertEquals(mockResponse[0].contactId, actualResponse[0].contactId);
        System.assertEquals(mockResponse[0].sourceOrgId, actualResponse[0].sourceOrgId);
    }

    /**
     * Test deserializing crosswalk JSON response against wrapper
     */
    @isTest
    private static void testdeserializeCrosswalkResponse() {
        CrossOrgShareUtilities.CrosswalkGetWrapper wrapper = new CrossOrgShareUtilities.CrosswalkGetWrapper();
        wrapper.contactId = '003d000001C3lAPAAZ';
        wrapper.guid = '9C7E57CF-2DC7-4C89-B476-11166DED34DZ';
        wrapper.lastModifiedDate = '2020-04-16 21:53:12.133';
        wrapper.sourceOrgId = '00D5400000023W1';
    }

    /**
     * Test deserializing crosswalk return status JSON response against wrapper
     */
    @isTest
    private static void testdeserializeCrosswalkReturnResponse() {
        CrossOrgShareUtilities.CrosswalkResponseWrapper wrapper = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        wrapper.status = 200;
        wrapper.message = 'success';
    }

    /**
     * Test converting Crosswalk response to List of Ids
     */
    @isTest
    private static void testCrosswalkIDToList() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        List<CrossOrgShareUtilities.CrosswalkGetWrapper> mockRecords = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        List<Contact> Contacts = new List<Contact>();

        // Create contacts
        for (Integer i = 0; i < 5; i++) {
            Contact con = TestDataFactory.createContact('ASU_' + i);
            Contacts.add(con);
        }
        insert Contacts;

        // Create list of crosswalk records
        for (Contact c : [SELECT Id FROM Contact WHERE LastName LIKE 'ASU_%']) {
            CrossOrgShareUtilities.CrosswalkGetWrapper record = new CrossOrgShareUtilities.CrosswalkGetWrapper();
            record.contactId = c.Id;
            record.guid = '9C7E57CF-2DC7-4C89-B476-11166DED34D0';
            record.lastModifiedDate = '2014-05-02T23:31:50Z';
            record.sourceOrgId = '012d0000000wzM5AAI';
            mockRecords.add(record);
        }

        Test.startTest();
        Set<Id> result = new Set<Id>();
        result.addAll(CrossOrgShareUtilities.crosswalkToIDList(mockRecords));
        Id testContact = [SELECT Id FROM Contact WHERE LastName = 'ASU_2' LIMIT 1].Id;
        Test.stopTest();

        System.assertEquals(5, result.size());
        System.assert(result.contains(testContact));
    }
}
