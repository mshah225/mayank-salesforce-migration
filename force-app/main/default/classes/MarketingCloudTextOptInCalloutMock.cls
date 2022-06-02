@isTest
public class MarketingCloudTextOptInCalloutMock implements HttpCalloutMock {
    public static Boolean shouldFindExistingContact = true;
    public static Boolean shouldFailAuthorization = false;
    public static Boolean shouldReturnNoId = false;
    public static Boolean shouldReturnMalformedContact = false;
    public static Boolean shouldReturnEmptyWhenCreatingContact = false;
    public static Boolean shouldReturnEmptyWhenOptIn = false;

    /**
     * Default interface method containing logic to handle GET, POST, etc.
     * @param HTTPRequest The req request from the callout
     * @return A HTTPResponse containing the contact information from GET/POST
     */
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response;

        if (isAuthorizationRequest(request)) {
            response = authorizationResponse();
        } else if (isOptInRequest(request)) {
            response = optInResponse();
        } else if (isExistingContactRequest(request)) {
            response = existingContactResponse();
        } else if (isNewContactRequest(request)) {
            response = newContactResponse();
        }

        return response;
    }

    private Boolean isAuthorizationRequest(HTTPRequest request) {
        return request.getMethod().equals('POST') &&
            request.getEndpoint().contains('callout:Marketing_Cloud/requestToken');
    }

    private HTTPResponse authorizationResponse() {
        HttpResponse response = new HttpResponse();
        if (!shouldFailAuthorization) {
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"accessToken": "ACCESS_TOKEN", "expiresIn": 12000}');
        } else {
            response.setStatusCode(400);
        }

        return response;
    }

    private Boolean isOptInRequest(HTTPRequest request) {
        return request.getMethod().equals('POST') && request.getEndpoint().contains('callout:Marketing_Cloud/queueMO/');
    }

    private HTTPResponse optInResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(201);
        response.setHeader('Content-Type', 'application/json');
        if (!shouldReturnEmptyWhenOptIn) {
            response.setBody('{"success": true}');
        }

        return response;
    }

    private Boolean isExistingContactRequest(HTTPRequest request) {
        return request.getMethod().equals('GET') && request.getEndpoint().contains('callout:Mule_ESB_Contact_Service');
    }

    private HTTPResponse existingContactResponse() {
        Contact c = [SELECT Id FROM Contact];

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        if (shouldFindExistingContact) {
            response.setBody(
                '{' +
                (shouldReturnMalformedContact ? '"MALFORMED"::{]]]: [' : '"contact": [') +
                '{' +
                '"id": "' +
                (shouldReturnNoId ? '' : c.Id) +
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
            response.setBody('{"contactDetails": []}');
        }

        return response;
    }

    private Boolean isNewContactRequest(HTTPRequest request) {
        return request.getMethod().equals('POST') && request.getEndpoint().contains('callout:Mule_ESB_Contact_Service');
    }

    private HTTPResponse newContactResponse() {
        Contact c = [SELECT Id FROM Contact];

        HttpResponse response = new HttpResponse();
        response.setStatusCode(201);
        if (!shouldReturnEmptyWhenCreatingContact) {
            response.setBody(
                '{' +
                (shouldReturnMalformedContact ? '"MALFORMED"::{]]] [{' : '"upsertResults": [{') +
                '"created": "true",' +
                '"id": "' +
                (shouldReturnNoId ? '' : c.Id) +
                '",' +
                '"success": "true",' +
                '"message": "MESSAGE_HERE"' +
                '}]' +
                '}'
            );
        }

        return response;
    }
}
