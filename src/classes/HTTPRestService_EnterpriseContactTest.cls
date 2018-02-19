@isTest
private class HTTPRestService_EnterpriseContactTest {
	
    @isTest static void testGetCallout() {
        Contact contRecord = TestDataFactory.createContact('Sidhant');
        contRecord.Email = 'TestBulk@asu.edu.sid';
        contRecord.Phone = '1115556567';
        insert contRecord;
        
        Test.startTest();
            String mockResponse = '{'+
                '"searchOrder": "10",'+
                '"searchFields": ['+
                    +'"FirstName",'+
                    +'"Email"'+
                '],'+
                '"contact": ['+
                    '{'+
                        '"id": "003d000001jLBxeAAG",'+
                        '"emplid": null,'+
                        '"asurite": null,'+
                        '"firstname": "Sally",'+
                        '"lastname": "Student",'+
                        '"middlename": null,'+
                        '"birthdate": null,'+
                        '"email": "suzeeq223@gmail.com.dev",'+
                        '"phone": "(623) 555-1212",'+
                        '"city": null,'+
                        '"country": "United States",'+
                        '"countrycode": "US",'+
                        '"street": "111 E North Drive",'+
                        '"postalcode": "85287",'+
                        '"state": "Arizona",'+
                        '"statecode": "AZ",'+
                        '"createddate": "2014-05-02T23:31:50Z",'+
                        '"recordtypeid": "012d0000000wzM5AAI"'+
                    '}'+
                ']'+
            '}';
            
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGen_EnterpriseContact());
            Map<String, String> parmMap = new Map<String, String>();
            parmMap.put('birthdate', (EncodingUtil.urlEncode( '2017-04-27' ,'UTF-8')));
            parmMap.put('city', (EncodingUtil.urlEncode( String.valueOf('Tempe'),'UTF-8')));
            parmMap.put('email', (EncodingUtil.urlEncode( String.valueOf('TestBulk@asu.edu.sid'),'UTF-8')));
            parmMap.put('firstname', (EncodingUtil.urlEncode( String.valueOf('Mister'),'UTF-8')));
            parmMap.put('lastname', (EncodingUtil.urlEncode( String.valueOf('Sidhant'),'UTF-8')));
            parmMap.put('phone', (EncodingUtil.urlEncode( String.valueOf(1115556567),'UTF-8')));
            parmMap.put('postalcode', (EncodingUtil.urlEncode( String.valueOf(85281),'UTF-8')));
            parmMap.put('statecode', (EncodingUtil.urlEncode( String.valueOf('AZ'),'UTF-8')));
            HTTPRestService_EnterpriseContact contactService = new HTTPRestService_EnterpriseContact();
            String actualResponse = contactService.get(parmMap);
        Test.stopTest();
        
        system.assertEquals(mockResponse, actualResponse);
    }
    
    
    @isTest static void testPostCallout() {
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGen_EnterpriseContact());
            Map<String, String> parmMap = new Map<String, String>();
            parmMap.put('birthdate', (EncodingUtil.urlEncode( '2017-04-27' ,'UTF-8')));
            parmMap.put('city', (EncodingUtil.urlEncode( String.valueOf('Tempe'),'UTF-8')));
            parmMap.put('email', (EncodingUtil.urlEncode( String.valueOf('TestBulk@asu.edu.sid'),'UTF-8')));
            parmMap.put('firstname', (EncodingUtil.urlEncode( String.valueOf('Mister'),'UTF-8')));
            parmMap.put('lastname', (EncodingUtil.urlEncode( String.valueOf('Sidhant'),'UTF-8')));
            parmMap.put('phone', (EncodingUtil.urlEncode( String.valueOf(1115556567),'UTF-8')));
            parmMap.put('postalcode', (EncodingUtil.urlEncode( String.valueOf(85281),'UTF-8')));
            parmMap.put('statecode', (EncodingUtil.urlEncode( String.valueOf('AZ'),'UTF-8')));
            HTTPRestService_EnterpriseContact contactService = new HTTPRestService_EnterpriseContact();
            String actualResponse = contactService.post(parmMap);
        Test.stopTest();
    }
}