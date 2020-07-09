/*****************************************
 * File: CrossOrgShareUtilitiesTest
 * Author: Carl Hussey, ASU
 * Description: Unit Tests for CrossOrgShareUtilities.cls
 ******************************************/
@IsTest
private class CrossOrgShareUtilitiesTest {
    private static Map<String, String> paramMap;

    /**
     * Create test data for tests
     */
    private static void createTestData() {
        paramMap = new Map<String, String>();
        paramMap.put( 'contactId', ( EncodingUtil.urlEncode(String.valueOf('003d000001C3lAPAAZ'), 'UTF-8') ) );
        paramMap.put( 'sourceOrgId', ( EncodingUtil.urlEncode(String.valueOf('00D0x0000000oQd'), 'UTF-8') ) );
        paramMap.put( 'guid', ( EncodingUtil.urlEncode(String.valueOf('BABF4E01-9A6E-4C95-A332-236F8A7D3357'), 'UTF-8') ) );
    }

    /**
     * Test Success Crosswalk Response for given GUID
     */
    @isTest
    private static void testGetCrosswalkRecords() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );
        createTestData();

        Contact c1 = TestDataFactory.createContact('ASU');
        insert c1;

        CrossOrgShareUtilities.CrosswalkGetWrapper record = new CrossOrgShareUtilities.CrosswalkGetWrapper();
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> mockResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> actualResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();

        record.contactId = c1.Id;
        record.guid = '9C7E57CF-2DC7-4C89-B476-11166DED34D0';
        record.lastModifiedDate = '2014-05-02T23:31:50Z';
        record.sourceOrgId = '012d0000000wzM5AAI';
        mockResponse.add(record);

        Test.startTest();
        actualResponse = CrossOrgShareUtilities.GetCrosswalkRecords(paramMap.get('guid') );
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
    private static void testGetCrosswalkRecordsById() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        Contact c1 = TestDataFactory.createContact('ASU');
        insert c1;

        CrossOrgShareUtilities.CrosswalkGetWrapper record = new CrossOrgShareUtilities.CrosswalkGetWrapper();
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> mockResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();

        record.contactId = c1.Id;
        record.guid = '9C7E57CF-2DC7-4C89-B476-11166DED34D0';
        record.lastModifiedDate = '2014-05-02T23:31:50Z';
        record.sourceOrgId = '012d0000000wzM5AAI';
        mockResponse.add(record);

        createTestData();

        Test.startTest();
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> actualResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        actualResponse = CrossOrgShareUtilities.GetCrosswalkRecordById(c1.Id);
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
    private static void testDeserializeCrosswalkResponse() {
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
    private static void testDeserializeCrosswalkReturnResponse() {
        CrossOrgShareUtilities.CrosswalkResponseWrapper wrapper = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        wrapper.status = 200;
        wrapper.message = 'success';
    }

    /**
     * Test converting Crosswalk response to List of Ids
     */
    @isTest
    private static void testCrosswalkIDToList() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        List<CrossOrgShareUtilities.CrosswalkGetWrapper> mockRecords = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        List<Contact> Contacts = new List<Contact>();

        // Create contacts
        for (Integer i = 0; i < 5; i++) {
            Contact con = TestDataFactory.createContact('ASU_' + i);
            Contacts.add(con);
        }
        insert Contacts;

        // Create list of crosswalk records
        for (Contact c: [SELECT Id FROM Contact WHERE LastName LIKE 'ASU_%']) {
            CrossOrgShareUtilities.CrosswalkGetWrapper record = new CrossOrgShareUtilities.CrosswalkGetWrapper();
            record.contactId = c.Id;
            record.guid = '9C7E57CF-2DC7-4C89-B476-11166DED34D0';
            record.lastModifiedDate = '2014-05-02T23:31:50Z';
            record.sourceOrgId = '012d0000000wzM5AAI';
            mockRecords.add(record);
        }

        Test.startTest();
        Set<Id> result = new Set<Id>();
        result.addAll(CrossOrgShareUtilities.CrosswalkToIDList(mockRecords) );
        Id testContact = [SELECT Id FROM Contact WHERE LastName = 'ASU_2' LIMIT 1].Id;
        Test.stopTest();

        System.assertEquals( 5, result.size() );
        System.assert ( result.contains(testContact) );
    }
}
