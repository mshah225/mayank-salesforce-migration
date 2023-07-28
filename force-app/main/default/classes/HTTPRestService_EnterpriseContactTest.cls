@isTest
private class HTTPRestService_EnterpriseContactTest {
    private static Map<String, String> parmMap;

    private static void createTestData() {
        parmMap = new Map<String, String>();
        parmMap.put('birthdate', (EncodingUtil.urlEncode('2017-04-27', 'UTF-8')));
        parmMap.put('city', (EncodingUtil.urlEncode(String.valueOf('Tempe'), 'UTF-8')));
        parmMap.put('email', (EncodingUtil.urlEncode(String.valueOf('TestBulk@asu.edu.sid'), 'UTF-8')));
        parmMap.put('firstname', (EncodingUtil.urlEncode(String.valueOf('Mister'), 'UTF-8')));
        parmMap.put('lastname', (EncodingUtil.urlEncode(String.valueOf('Sidhant'), 'UTF-8')));
        parmMap.put('phone', (EncodingUtil.urlEncode(String.valueOf(1115556567), 'UTF-8')));
        parmMap.put('postalcode', (EncodingUtil.urlEncode(String.valueOf(85281), 'UTF-8')));
        parmMap.put('statecode', (EncodingUtil.urlEncode(String.valueOf('AZ'), 'UTF-8')));
    }

    @isTest
    private static void testGetCalloutNoContactCheckNullId() {
        String mockResponse =
            '{' +
            '"searchOrder": "10",' +
            '"searchFields": [' +
            '"FirstName",' +
            '"Email"],"contact": []}';

        Test.setMock(HttpCalloutMock.class, new EnterpriseContactCalloutMock());
        createTestData();

        HTTPRestService_EnterpriseContact contactService = new HTTPRestService_EnterpriseContact();

        Test.startTest();
        String actualResponse = contactService.get(parmMap);
        Test.stopTest();

        System.assertEquals(mockResponse, actualResponse);
    }

    @isTest
    private static void testGetCalloutFailure() {
        Test.setMock(HttpCalloutMock.class, new EnterpriseContactCalloutMock());

        createTestData();
        Contact contASURecord = TestDataFactory.createContact('ASU');
        insert contASURecord;

        Contact contWPCRecord = TestDataFactory.createContact('WPC');
        insert contWPCRecord;
        HTTPRestService_EnterpriseContact contactService = new HTTPRestService_EnterpriseContact();

        try {
            Test.startTest();
            String actualResponse = contactService.get(parmMap);
            Test.stopTest();
        } catch (CalloutException calloutException) {
            System.assertEquals(calloutException.getMessage(), 'Throw a callout exception to cover catch block.');
        }
    }

    @isTest
    private static void testPostCalloutNoContactCheckNullId() {
        String mockResponse =
            '{' +
            '"upsertResults": [' +
            '{' +
            '"created": null,' +
            '"id": "null",' +
            '"success": true,' +
            '"message": null' +
            '}]' +
            '}';
        Test.setMock(HttpCalloutMock.class, new EnterpriseContactCalloutMock());
        createTestData();
        HTTPRestService_EnterpriseContact contactService = new HTTPRestService_EnterpriseContact();

        Test.startTest();
        String actualResponse = contactService.post(parmMap);
        Test.stopTest();

        System.assertEquals(mockResponse, actualResponse);
    }

    @isTest
    private static void testPostCalloutFailure() {
        Test.setMock(HttpCalloutMock.class, new EnterpriseContactCalloutMock());
        createTestData();
        Contact contASURecord = TestDataFactory.createContact('ASU');
        insert contASURecord;
        Contact contWPCRecord = TestDataFactory.createContact('WPC');
        insert contWPCRecord;
        HTTPRestService_EnterpriseContact contactService = new HTTPRestService_EnterpriseContact();

        try {
            Test.startTest();
            String actualResponse = contactService.post(parmMap);
            Test.stopTest();
        } catch (CalloutException calloutException) {
            System.assertEquals(calloutException.getMessage(), 'Throw a callout exception to cover catch block.');
        }
    }
}
