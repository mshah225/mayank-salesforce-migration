@isTest
global class MockHttpResponseGen_EnterpriseContact implements HttpCalloutMock {
    
    /**
    * Default interface method containing logic to handle GET, POST, etc.
    * @param The req request from the callout
    * @return A HTTPResponse containing the contact information from GET/POST
    */
    global HTTPResponse respond(HTTPRequest request) {
		HttpResponse fakeResponse = new HttpResponse();
        if (request.getMethod() == 'GET') {
            fakeResponse = callGetResponse(request);
        } else if (request.getMethod() == 'POST') {
            fakeResponse = callPostResponse(request);
        }
        return fakeResponse;
    }
    
    /**
    * Generates a mock response for GET request
    * @param The req request from the callout
    * @return A HTTPResponse containing the contact information, if present on the system
    */
    global HTTPResponse callGetResponse(HTTPRequest req) {
        system.assertEquals('callout:Mule_ESB_Contact_Service?birthdate=2017-04-27&city=Tempe&email=TestBulk%40asu.edu.sid&firstname=Mister&lastname=Sidhant&phone=1115556567&postalcode=85281&statecode=AZ', req.getEndpoint());
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+
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
                    '}'
                   );
        res.setStatusCode(200);
        return res;
    }
	
    /**
    * Generates a mock response for POST request
    * @param The req request from the callout
    * @return A HTTPResponse containing the contact information mostly Id
    */
    global HTTPResponse callPostResponse(HTTPRequest req) {
        
        system.assertEquals('callout:Mule_ESB_Contact_Service',req.getEndpoint());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+
                      '"upsertResults": ['+
                        '{'+
                          '"created": null,'+
							'"id": "0031h000004v7h6AAA",'+
                          	'"success": true,'+
                         	'"message": null'+
                    	'}]'+
                    '}');
        res.setStatusCode(201);
        return res;
    }
}