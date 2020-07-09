/**
 * File Name: CrossOrgShareCalloutTest
 * Description: Test class for Cross Org HTTP Callouts
 * Author: Carl Hussey
 * Created: 04/22/2020
 */
@isTest
private class CrossOrgShareCalloutTest {
    private static Map<String, String> paramMap;
    private static List<Id> deletePayload = new List<Id>();

    /**
     * Create test data for tests
     */
    private static void createTestData() {
        paramMap = new Map<String, String>();
        paramMap.put( 'contactId', ( EncodingUtil.urlEncode(String.valueOf('003d000001C3lAPAAZ'), 'UTF-8') ) );
        paramMap.put( 'sourceOrgId', ( EncodingUtil.urlEncode(String.valueOf('00D0x0000000oQd'), 'UTF-8') ) );
        paramMap.put( 'guid', ( EncodingUtil.urlEncode(String.valueOf('BABF4E01-9A6E-4C95-A332-236F8A7D3357'), 'UTF-8') ) );

        Contact d1 = new Contact(FirstName = 'Test', LastName = 'Delete', SSB_CRMSYSTEM_Contact_ID__c = 'BABF4E01-9A6E-4C95-A332-236F8A7D3357');
        insert d1;
        deletePayload.add(d1.Id);
    }

    /**
     * Test GET callout where no records are returned
     */
    @isTest
    private static void testGetCalloutNoRecords() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        List<CrossOrgShareUtilities.CrosswalkGetWrapper> mockResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        createTestData();

        Test.startTest();
        HttpResponse crosswalkResponse = crosswalkService.makeGetCallout(paramMap);
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> actualResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        actualResponse = CrossOrgShareUtilities.DeserializeCrosswalkResponse(crosswalkResponse.getBody() );
        Test.stopTest();

        System.assertEquals(mockResponse, actualResponse);
    }

    /**
     * Test GET callout failure resulting in an exception thrown
     */
    @isTest
    private static void testGetCalloutException() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();
        createTestData();

        Contact c1 = TestDataFactory.createContact('ASU');
        insert c1;

        Contact c2 = TestDataFactory.createContact('Sparky');
        insert c2;

        try {
            Test.startTest();
            HttpResponse actualResponse = crosswalkService.makeGetCallout(paramMap);
            Test.stopTest();
        } catch (CalloutException calloutException) {
            System.debug( calloutException.getMessage() );
            System.assertEquals(calloutException.getMessage(), 'Throw a callout exception to cover catch block.');
        }
    }

    /**
     * Test GET by ID callout failure resulting in an exception thrown
     */
    @isTest
    private static void testGetByIdCalloutException() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();
        createTestData();

        Contact c1 = TestDataFactory.createContact('ASU');
        insert c1;

        Contact c2 = TestDataFactory.createContact('Sparky');
        insert c2;

        try {
            Test.startTest();
            HttpResponse actualResponse = crosswalkService.makeGetCalloutById(c1.Id);
            Test.stopTest();
        } catch (CalloutException calloutException) {
            System.debug( calloutException.getMessage() );
            System.assertEquals(calloutException.getMessage(), 'Throw a callout exception to cover catch block.');
        }
    }

    /**
     * Test GET callout success
     */
    @isTest
    private static void testGetCalloutSuccess() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        Contact c1 = TestDataFactory.createContact('ASU');
        insert c1;

        CrossOrgShareUtilities.CrosswalkGetWrapper record = new CrossOrgShareUtilities.CrosswalkGetWrapper();
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> mockResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();

        record.contactId = c1.Id;
        record.guid = '9C7E57CF-2DC7-4C89-B476-11166DED34D0';
        record.lastModifiedDate = '2014-05-02T23:31:50Z';
        record.sourceOrgId = '012d0000000wzM5AAI';
        mockResponse.add(record);

        Test.startTest();
        HttpResponse crosswalkResponse = crosswalkService.makeGetCallout('guid=9C7E57CF-2DC7-4C89-B476-11166DED34D0');
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> actualResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        actualResponse = CrossOrgShareUtilities.DeserializeCrosswalkResponse(crosswalkResponse.getBody() );
        Test.stopTest();

        System.assertEquals(mockResponse[0].guid, actualResponse[0].guid);
        System.assertEquals(mockResponse[0].lastModifiedDate, actualResponse[0].lastModifiedDate);
        System.assertEquals(mockResponse[0].contactId, actualResponse[0].contactId);
        System.assertEquals(mockResponse[0].sourceOrgId, actualResponse[0].sourceOrgId);
    }

    /**
     * Test GET callout by ID success
     */
    @isTest
    private static void testGetCalloutByIdSuccess() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        Contact c1 = TestDataFactory.createContact('ASU');
        insert c1;

        CrossOrgShareUtilities.CrosswalkGetWrapper record = new CrossOrgShareUtilities.CrosswalkGetWrapper();
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> mockResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();

        record.contactId = c1.Id;
        record.guid = '9C7E57CF-2DC7-4C89-B476-11166DED34D0';
        record.lastModifiedDate = '2014-05-02T23:31:50Z';
        record.sourceOrgId = '012d0000000wzM5AAI';
        mockResponse.add(record);

        Test.startTest();
        HttpResponse crosswalkResponse = crosswalkService.makeGetCalloutById(c1.Id);
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> actualResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        actualResponse = CrossOrgShareUtilities.DeserializeCrosswalkResponse(crosswalkResponse.getBody() );
        Test.stopTest();

        System.assertEquals(mockResponse[0].guid, actualResponse[0].guid);
        System.assertEquals(mockResponse[0].lastModifiedDate, actualResponse[0].lastModifiedDate);
        System.assertEquals(mockResponse[0].contactId, actualResponse[0].contactId);
        System.assertEquals(mockResponse[0].sourceOrgId, actualResponse[0].sourceOrgId);
    }

    /**
     * Test POST callout success
     */
    @isTest
    private static void testPostCalloutSuccess() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareUtilities.CrosswalkResponseWrapper mockResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        mockResponse.message = 'success';
        mockResponse.status = 201;

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        createTestData();

        Contact c1 = TestDataFactory.createContact('ASU');
        insert c1;

        Test.startTest();
        String jsonPayload = JSON.serialize(paramMap);
        HttpResponse crosswalkResponse = crosswalkService.makePostCallout(jsonPayload);
        CrossOrgShareUtilities.CrosswalkResponseWrapper actualResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        actualResponse = CrossOrgShareUtilities.DeserializeCrosswalkReturnResponse(crosswalkResponse.getBody() );
        Test.stopTest();

        System.assertEquals(mockResponse.message, actualResponse.message);
        System.assertEquals(mockResponse.status, actualResponse.status);
    }

    /**
     * Test POST callout failure resulting in an exception thrown
     */
    @isTest
    private static void testPostCalloutException() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();
        createTestData();

        Contact c1 = TestDataFactory.createContact('ASU');
        insert c1;

        Contact c2 = TestDataFactory.createContact('Sparky');
        insert c2;

        try {
            Test.startTest();
            String jsonPayload = JSON.serialize(paramMap);
            HttpResponse actualResponse = crosswalkService.makePostCallout(jsonPayload);
            Test.stopTest();
        } catch (CalloutException calloutException) {
            System.assertEquals(calloutException.getMessage(), 'Throw a callout exception to cover catch block.');
        }
    }

    /**
     * Test POST callout conflict
     */
    @isTest
    private static void testPostCalloutConflict() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareUtilities.CrosswalkResponseWrapper mockResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        mockResponse.message = 'Database Conflict';
        mockResponse.status = 409;

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        createTestData();

        Test.startTest();
        String jsonPayload = JSON.serialize(paramMap);
        HttpResponse crosswalkResponse = crosswalkService.makePostCallout(jsonPayload);
        CrossOrgShareUtilities.CrosswalkResponseWrapper actualResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        actualResponse = CrossOrgShareUtilities.DeserializeCrosswalkReturnResponse(crosswalkResponse.getBody() );
        Test.stopTest();

        System.assertEquals(mockResponse.message, actualResponse.message);
        System.assertEquals(mockResponse.status, actualResponse.status);
    }

    /**
     * Test PUT callout failure resulting in an exception thrown
     */
    @isTest
    private static void testPutCalloutException() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();
        createTestData();

        Contact c1 = TestDataFactory.createContact('ASU');
        insert c1;

        Contact c2 = TestDataFactory.createContact('Sparky');
        insert c2;

        try {
            Test.startTest();
            String jsonPayload = JSON.serialize(paramMap);
            HttpResponse actualResponse = crosswalkService.makePutCallout(jsonPayload);
            Test.stopTest();
        } catch (CalloutException calloutException) {
            System.assertEquals(calloutException.getMessage(), 'Throw a callout exception to cover catch block.');
        }
    }

    /**
     * Test PUT callout success
     */
    @isTest
    private static void testPutCalloutSuccess() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareUtilities.CrosswalkResponseWrapper mockResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        mockResponse.message = 'success';
        mockResponse.status = 200;

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        createTestData();

        Contact c1 = TestDataFactory.createContact('ASU');
        insert c1;

        Test.startTest();
        String jsonPayload = JSON.serialize(paramMap);
        HttpResponse crosswalkResponse = crosswalkService.makePutCallout(jsonPayload);
        CrossOrgShareUtilities.CrosswalkResponseWrapper actualResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        actualResponse = CrossOrgShareUtilities.DeserializeCrosswalkReturnResponse(crosswalkResponse.getBody() );
        Test.stopTest();

        System.assertEquals(mockResponse.message, actualResponse.message);
        System.assertEquals(mockResponse.status, actualResponse.status);
    }

    /**
     * Test PUT callout conflict
     */
    @isTest
    private static void testPutCalloutConflict() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareUtilities.CrosswalkResponseWrapper mockResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        mockResponse.message = 'Database Conflict';
        mockResponse.status = 409;

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        createTestData();

        Test.startTest();
        String jsonPayload = JSON.serialize(paramMap);
        HttpResponse crosswalkResponse = crosswalkService.makePutCallout(jsonPayload);
        CrossOrgShareUtilities.CrosswalkResponseWrapper actualResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        actualResponse = CrossOrgShareUtilities.DeserializeCrosswalkReturnResponse(crosswalkResponse.getBody() );
        Test.stopTest();

        System.assertEquals(mockResponse.message, actualResponse.message);
        System.assertEquals(mockResponse.status, actualResponse.status);
    }

    /**
     * Test DELETE callout failure resulting in an exception thrown
     */
    @isTest
    private static void testDeleteCalloutException() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();
        createTestData();

        Contact c1 = TestDataFactory.createContact('ASU');
        insert c1;

        Contact c2 = TestDataFactory.createContact('Sparky');
        insert c2;

        try {
            Test.startTest();
            String jsonPayload = '\"' + String.join(deletePayload, '\",\"') + '\"';
            jsonPayload = '[' + jsonPayload + ']';

            HttpResponse actualResponse = crosswalkService.makeDeleteCallout(jsonPayload);
            Test.stopTest();
        } catch (CalloutException calloutException) {
            System.assertEquals(calloutException.getMessage(), 'Throw a callout exception to cover catch block.');
        }
    }

    /**
     * Test DELETE callout success
     */
    @isTest
    private static void testDeleteCalloutSuccess() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareUtilities.CrosswalkResponseWrapper mockResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        mockResponse.message = 'success';
        mockResponse.status = 200;

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        createTestData();

        Contact c1 = TestDataFactory.createContact('ASU');
        insert c1;

        Test.startTest();

        String jsonPayload = '\"' + String.join(deletePayload, '\",\"') + '\"';
        jsonPayload = '[' + jsonPayload + ']';

        HttpResponse crosswalkResponse = crosswalkService.makeDeleteCallout(jsonPayload);
        CrossOrgShareUtilities.CrosswalkResponseWrapper actualResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        actualResponse = CrossOrgShareUtilities.DeserializeCrosswalkReturnResponse(crosswalkResponse.getBody() );
        Test.stopTest();

        System.assertEquals(mockResponse.message, actualResponse.message);
        System.assertEquals(mockResponse.status, actualResponse.status);
    }

    /**
     * Test DELETE callout conflict
     */
    @isTest
    private static void testDeleteCalloutConflict() {
        Test.setMock( HttpCalloutMock.class, new CrossOrgShareCalloutMock() );

        CrossOrgShareUtilities.CrosswalkResponseWrapper mockResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        mockResponse.message = 'Database Conflict';
        mockResponse.status = 409;

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        createTestData();

        Test.startTest();

        String jsonPayload = '\"' + String.join(deletePayload, '\",\"') + '\"';
        jsonPayload = '[' + jsonPayload + ']';

        HttpResponse crosswalkResponse = crosswalkService.makeDeleteCallout(jsonPayload);
        CrossOrgShareUtilities.CrosswalkResponseWrapper actualResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        actualResponse = CrossOrgShareUtilities.DeserializeCrosswalkReturnResponse(crosswalkResponse.getBody() );
        Test.stopTest();

        System.assertEquals(mockResponse.message, actualResponse.message);
        System.assertEquals(mockResponse.status, actualResponse.status);
    }
}
