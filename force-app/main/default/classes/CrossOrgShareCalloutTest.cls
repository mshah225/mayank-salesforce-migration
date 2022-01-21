/**
 * File Name: CrossOrgShareCalloutTest
 * Description: Test class for Cross Org HTTP Callouts
 * Author: Carl Hussey
 * Created: 04/22/2020
 */
@isTest
private class CrossOrgShareCalloutTest {
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
     * Test GET callout where no records are returned
     */
    @isTest
    private static void testGetCalloutNoRecords() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        List<CrossOrgShareUtilities.CrosswalkGetWrapper> mockResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        Test.startTest();
        HttpResponse crosswalkResponse = crosswalkService.makeGetCallout('guid=');
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> actualResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        actualResponse = CrossOrgShareUtilities.deserializeCrosswalkResponse(crosswalkResponse.getBody());
        Test.stopTest();

        System.assertEquals(mockResponse, actualResponse);
    }

    /**
     * Test GET callout failure resulting in an exception thrown
     */
    @isTest
    private static void testGetCalloutException() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        // Set up the Contacts
        List<Contact> contacts = createContacts(5);
        insert contacts;
        Contact testContact = [
            SELECT Id, SSB_CRMSYSTEM_Contact_ID__c, LastModifiedDate
            FROM Contact
            WHERE LastName = 'LName0'
            LIMIT 1
        ];

        Test.startTest();
        try {
            HttpResponse actualResponse = crosswalkService.makeGetCallout(
                'guid=' + testContact.SSB_CRMSYSTEM_Contact_ID__c
            );
        } catch (Exception calloutException) {
            System.assertEquals(calloutException.getMessage(), 'Throw a callout exception to cover catch block.');
        }
        Test.stopTest();
    }

    /**
     * Test GET by ID callout failure resulting in an exception thrown
     */
    @isTest
    private static void testGetByIdCalloutException() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        // Set up the Contacts
        List<Contact> contacts = createContacts(5);
        insert contacts;
        Contact testContact = [
            SELECT Id, SSB_CRMSYSTEM_Contact_ID__c, LastModifiedDate
            FROM Contact
            WHERE LastName = 'LName0'
            LIMIT 1
        ];

        Test.startTest();
        try {
            HttpResponse actualResponse = crosswalkService.makeGetCalloutById(testContact.Id);
        } catch (Exception calloutException) {
            System.assertEquals(calloutException.getMessage(), 'Throw a callout exception to cover catch block.');
        }
        Test.stopTest();
    }

    /**
     * Test GET callout success
     */
    @isTest
    private static void testGetCalloutSuccess() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        // Set up the Contacts
        List<Contact> contacts = createContacts(2);
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
        HttpResponse crosswalkResponse = crosswalkService.makeGetCallout(
            'guid=' + testContact.SSB_CRMSYSTEM_Contact_ID__c
        );
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> actualResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        actualResponse = CrossOrgShareUtilities.deserializeCrosswalkResponse(crosswalkResponse.getBody());
        Test.stopTest();

        System.assertEquals(mockResponse[0].guid, actualResponse[0].guid);
        System.assertEquals(mockResponse[0].lastModifiedDate, actualResponse[0].lastModifiedDate);
        System.assertEquals(mockResponse[0].contactId, actualResponse[0].contactId);
        System.assertEquals(mockResponse[0].sourceOrgId, actualResponse[0].sourceOrgId);
    }

    /**
     * Test GET callout success
     */
    @isTest
    private static void testGetCalloutSuccessUsingParamMap() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        // Set up the Contacts
        List<Contact> contacts = createContacts(2);
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
        Map<String, String> urlParamMap = new Map<String, String>();
        urlParamMap.put('guid', testContact.SSB_CRMSYSTEM_Contact_ID__c);
        HttpResponse crosswalkResponse = crosswalkService.makeGetCallout(urlParamMap);
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> actualResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        actualResponse = CrossOrgShareUtilities.deserializeCrosswalkResponse(crosswalkResponse.getBody());
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
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        // Set up the Contacts
        List<Contact> contacts = createContacts(5);
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
        HttpResponse crosswalkResponse = crosswalkService.makeGetCalloutById(testContact.Id);
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> actualResponse = new List<CrossOrgShareUtilities.CrosswalkGetWrapper>();
        actualResponse = CrossOrgShareUtilities.deserializeCrosswalkResponse(crosswalkResponse.getBody());
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
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        CrossOrgShareUtilities.CrosswalkResponseWrapper mockResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        mockResponse.message = 'success';
        mockResponse.status = 201;

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        // Set up the Contacts
        List<Contact> contacts = createContacts(1);
        insert contacts;
        Contact testContact = [
            SELECT Id, SSB_CRMSYSTEM_Contact_ID__c, LastModifiedDate
            FROM Contact
            WHERE LastName = 'LName0'
            LIMIT 1
        ];

        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('contactId', (EncodingUtil.urlEncode(String.valueOf(testContact.Id), 'UTF-8')));
        paramMap.put('sourceOrgId', (EncodingUtil.urlEncode(String.valueOf(UserInfo.getOrganizationId()), 'UTF-8')));
        paramMap.put(
            'guid',
            (EncodingUtil.urlEncode(String.valueOf(testContact.SSB_CRMSYSTEM_Contact_ID__c), 'UTF-8'))
        );

        Test.startTest();
        String jsonPayload = JSON.serialize(paramMap);
        HttpResponse crosswalkResponse = crosswalkService.makePostCallout(jsonPayload);
        CrossOrgShareUtilities.CrosswalkResponseWrapper actualResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        actualResponse = CrossOrgShareUtilities.deserializeCrosswalkReturnResponse(crosswalkResponse.getBody());
        Test.stopTest();

        System.assertEquals(mockResponse.message, actualResponse.message);
        System.assertEquals(mockResponse.status, actualResponse.status);
    }

    /**
     * Test POST callout failure resulting in an exception thrown
     */
    @isTest
    private static void testPostCalloutException() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        List<Contact> contacts = createContacts(5);
        insert contacts;
        Contact testContact = [
            SELECT Id, SSB_CRMSYSTEM_Contact_ID__c, LastModifiedDate
            FROM Contact
            WHERE LastName = 'LName0'
            LIMIT 1
        ];

        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('contactId', (EncodingUtil.urlEncode(String.valueOf(testContact.Id), 'UTF-8')));
        paramMap.put('sourceOrgId', (EncodingUtil.urlEncode(String.valueOf(UserInfo.getOrganizationId()), 'UTF-8')));
        paramMap.put(
            'guid',
            (EncodingUtil.urlEncode(String.valueOf(testContact.SSB_CRMSYSTEM_Contact_ID__c), 'UTF-8'))
        );

        Test.startTest();
        try {
            String jsonPayload = JSON.serialize(paramMap);
            HttpResponse actualResponse = crosswalkService.makePostCallout(jsonPayload);
        } catch (Exception calloutException) {
            System.assertEquals(calloutException.getMessage(), 'Throw a callout exception to cover catch block.');
        }
        Test.stopTest();
    }

    /**
     * Test PUT callout failure resulting in an exception thrown
     */
    @isTest
    private static void testPutCalloutException() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();
        List<Contact> contacts = createContacts(5);
        insert contacts;
        Contact testContact = [
            SELECT Id, SSB_CRMSYSTEM_Contact_ID__c, LastModifiedDate
            FROM Contact
            WHERE LastName = 'LName0'
            LIMIT 1
        ];

        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('contactId', (EncodingUtil.urlEncode(String.valueOf(testContact.Id), 'UTF-8')));
        paramMap.put('sourceOrgId', (EncodingUtil.urlEncode(String.valueOf(UserInfo.getOrganizationId()), 'UTF-8')));
        paramMap.put(
            'guid',
            (EncodingUtil.urlEncode(String.valueOf(testContact.SSB_CRMSYSTEM_Contact_ID__c), 'UTF-8'))
        );

        Test.startTest();
        try {
            String jsonPayload = JSON.serialize(paramMap);
            HttpResponse actualResponse = crosswalkService.makePutCallout(jsonPayload);
        } catch (Exception calloutException) {
            System.assertEquals(calloutException.getMessage(), 'Throw a callout exception to cover catch block.');
        }
        Test.stopTest();
    }

    /**
     * Test PUT callout success
     */
    @isTest
    private static void testPutCalloutSuccess() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        CrossOrgShareUtilities.CrosswalkResponseWrapper mockResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        mockResponse.message = 'success';
        mockResponse.status = 200;

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        List<Contact> contacts = createContacts(1);
        insert contacts;
        Contact testContact = [
            SELECT Id, SSB_CRMSYSTEM_Contact_ID__c, LastModifiedDate
            FROM Contact
            WHERE LastName = 'LName0'
            LIMIT 1
        ];

        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('contactId', (EncodingUtil.urlEncode(String.valueOf(testContact.Id), 'UTF-8')));
        paramMap.put('sourceOrgId', (EncodingUtil.urlEncode(String.valueOf(UserInfo.getOrganizationId()), 'UTF-8')));
        paramMap.put(
            'guid',
            (EncodingUtil.urlEncode(String.valueOf(testContact.SSB_CRMSYSTEM_Contact_ID__c), 'UTF-8'))
        );

        Test.startTest();
        String jsonPayload = JSON.serialize(paramMap);
        HttpResponse crosswalkResponse = crosswalkService.makePutCallout(jsonPayload);
        CrossOrgShareUtilities.CrosswalkResponseWrapper actualResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        actualResponse = CrossOrgShareUtilities.deserializeCrosswalkReturnResponse(crosswalkResponse.getBody());
        Test.stopTest();

        System.assertEquals(mockResponse.message, actualResponse.message);
        System.assertEquals(mockResponse.status, actualResponse.status);
    }

    /**
     * Test DELETE callout failure resulting in an exception thrown
     */
    @isTest
    private static void testDeleteCalloutException() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();
        List<Contact> contacts = createContacts(5);
        insert contacts;
        Contact testContact = [
            SELECT Id, SSB_CRMSYSTEM_Contact_ID__c, LastModifiedDate
            FROM Contact
            WHERE LastName = 'LName4'
            LIMIT 1
        ];

        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('contactId', (EncodingUtil.urlEncode(String.valueOf(testContact.Id), 'UTF-8')));
        paramMap.put('sourceOrgId', (EncodingUtil.urlEncode(String.valueOf(UserInfo.getOrganizationId()), 'UTF-8')));
        paramMap.put(
            'guid',
            (EncodingUtil.urlEncode(String.valueOf(testContact.SSB_CRMSYSTEM_Contact_ID__c), 'UTF-8'))
        );

        List<Id> deletePayload = new List<Id>();
        deletePayload.add(testContact.Id);

        Test.startTest();
        try {
            String jsonPayload = '\"' + String.join(deletePayload, '\",\"') + '\"';
            jsonPayload = '[' + jsonPayload + ']';
            HttpResponse actualResponse = crosswalkService.makeDeleteCallout(jsonPayload);
        } catch (Exception calloutException) {
            System.assertEquals(calloutException.getMessage(), 'Throw a callout exception to cover catch block.');
        }
        Test.stopTest();
    }

    /**
     * Test DELETE callout success
     */
    @isTest
    private static void testDeleteCalloutSuccess() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        CrossOrgShareUtilities.CrosswalkResponseWrapper mockResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        mockResponse.message = 'success';
        mockResponse.status = 200;

        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();
        List<Contact> contacts = createContacts(1);
        insert contacts;
        Contact testContact = [
            SELECT Id, SSB_CRMSYSTEM_Contact_ID__c, LastModifiedDate
            FROM Contact
            WHERE LastName = 'LName0'
            LIMIT 1
        ];

        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('contactId', (EncodingUtil.urlEncode(String.valueOf(testContact.Id), 'UTF-8')));
        paramMap.put('sourceOrgId', (EncodingUtil.urlEncode(String.valueOf(UserInfo.getOrganizationId()), 'UTF-8')));
        paramMap.put(
            'guid',
            (EncodingUtil.urlEncode(String.valueOf(testContact.SSB_CRMSYSTEM_Contact_ID__c), 'UTF-8'))
        );

        List<Id> deletePayload = new List<Id>();
        deletePayload.add(testContact.Id);

        Test.startTest();

        String jsonPayload = '\"' + String.join(deletePayload, '\",\"') + '\"';
        jsonPayload = '[' + jsonPayload + ']';

        HttpResponse crosswalkResponse = crosswalkService.makeDeleteCallout(jsonPayload);
        CrossOrgShareUtilities.CrosswalkResponseWrapper actualResponse = new CrossOrgShareUtilities.CrosswalkResponseWrapper();
        actualResponse = CrossOrgShareUtilities.deserializeCrosswalkReturnResponse(crosswalkResponse.getBody());
        Test.stopTest();

        System.assertEquals(mockResponse.message, actualResponse.message);
        System.assertEquals(mockResponse.status, actualResponse.status);
    }
}
