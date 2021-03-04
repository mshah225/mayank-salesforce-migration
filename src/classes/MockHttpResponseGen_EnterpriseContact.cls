@isTest
public class MockHttpResponseGen_EnterpriseContact implements HttpCalloutMock {
    /**
     * Default interface method containing logic to handle GET, POST, etc.
     * @param The req request from the callout
     * @return A HTTPResponse containing the contact information from GET/POST
     */
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse fakeResponse = new HttpResponse();
        if (request.getMethod() == 'GET') {
            fakeResponse = callGetResponse();
        } else if (request.getMethod() == 'POST') {
            fakeResponse = callPostResponse();
        }
        return fakeResponse;
    }

    /**
     * Generates a mock response for GET request
     * @param The req request from the callout
     * @return A HTTPResponse containing the contact information, if present on the system
     */
    public HTTPResponse callGetResponse() {
        List<Contact> contactsForGet = new List<Contact>(
            [SELECT Id FROM Contact WHERE LastName = 'ASU' OR LastName = 'WPC']
        );
        HttpResponse fakeGetResponse = new HttpResponse();
        fakeGetResponse.setHeader('Content-Type', 'application/json');

        if (contactsForGet.size() > 1) {
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            e.setMessage('Throw a callout exception to cover catch block.');
            throw e;
        } else if (contactsForGet.size() == 1) {
            fakeGetResponse.setBody(
                '{' +
                '"searchOrder": "10",' +
                '"searchFields": [' +
                +'"FirstName",' +
                +'"Email"' +
                '],' +
                '"contact": [' +
                '{' +
                '"id": "' +
                contactsForGet.get(0).Id +
                '",' +
                '"emplid": null,' +
                '"asurite": null,' +
                '"firstname": "Sally",' +
                '"lastname": "Student",' +
                '"middlename": null,' +
                '"birthdate": null,' +
                '"email": "suzeeq223@gmail.com.dev",' +
                '"phone": "(623) 555-1212",' +
                '"city": null,' +
                '"country": "United States",' +
                '"countrycode": "US",' +
                '"street": "111 E North Drive",' +
                '"postalcode": "85287",' +
                '"state": "Arizona",' +
                '"statecode": "AZ",' +
                '"createddate": "2014-05-02T23:31:50Z",' +
                '"recordtypeid": "012d0000000wzM5AAI"' +
                '}' +
                ']' +
                '}'
            );
        } else {
            fakeGetResponse.setBody(
                '{' +
                '"searchOrder": "10",' +
                '"searchFields": [' +
                '"FirstName",' +
                '"Email"],"contact": []}'
            );
        }
        fakeGetResponse.setStatusCode(200);
        return fakeGetResponse;
    }

    /**
     * Generates a mock response for POST request
     * @param The req request from the callout
     * @return A HTTPResponse containing the contact information mostly Id
     */
    public HTTPResponse callPostResponse() {
        List<Contact> contactsForPost = new List<Contact>(
            [SELECT Id FROM Contact WHERE LastName = 'ASU' OR LastName = 'WPC']
        );
        HttpResponse fakePostResponse = new HttpResponse();
        fakePostResponse.setHeader('Content-Type', 'application/json');

        if (contactsForPost.size() > 1) {
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            e.setMessage('Throw a callout exception to cover catch block.');
            throw e;
        } else if (contactsForPost.size() == 1) {
            fakePostResponse.setBody(
                '{' +
                '"upsertResults": [' +
                '{' +
                '"created": null,' +
                '"id": "' +
                contactsForPost.get(0).Id +
                '",' +
                '"success": true,' +
                '"message": null' +
                '}]' +
                '}'
            );
        } else {
            fakePostResponse.setBody(
                '{' +
                '"upsertResults": [' +
                '{' +
                '"created": null,' +
                '"id": "null",' +
                '"success": true,' +
                '"message": null' +
                '}]' +
                '}'
            );
        }
        fakePostResponse.setStatusCode(201);
        return fakePostResponse;
    }
}
