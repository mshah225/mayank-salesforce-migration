/**
 * File Name: CrossOrgShareCalloutMock
 * Description: Mock responses for HTTP
 * Author: Carl Hussey
 * Created: 04/22/2020
 */
@isTest
public class CrossOrgShareCalloutMock implements HttpCalloutMock {
    /**
     * Default interface method containing logic to handle GET, POST, etc.
     * @param The req request from the callout
     * @return A HTTPResponse containing the contact information from GET/POST
     */
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse fakeResponse = new HttpResponse();

        switch on request.getMethod() {
            when 'GET' {
                fakeResponse = callGetResponse();
            }
            when 'POST' {
                fakeResponse = callPostResponse();
            }
            when 'PUT' {
                fakeResponse = callPutResponse();
            }
            when 'DELETE' {
                fakeResponse = callDeleteResponse();
            }
        }

        return fakeResponse;
    }

    /**
     * Generates a mock response for GET request
     * @param The req request from the callout
     * @return A HTTPResponse containing the crosswalk information, if present on the system
     */
    public HTTPResponse callGetResponse() {
        List<String> criteria = new List<String>{ 'ASU', 'Sparky', 'Devil', 'LName0' };
        List<Contact> contactsForGet = new List<Contact>([SELECT Id FROM Contact WHERE LastName IN :criteria]);
        HttpResponse fakeGetResponse = new HttpResponse();
        fakeGetResponse.setHeader('Content-Type', 'application/json');

        if (contactsForGet.size() > 1) {
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            e.setMessage('Throw a callout exception to cover catch block.');
            throw e;
        } else if (contactsForGet.size() == 1) {
            fakeGetResponse.setBody(
                '[' +
                '{' +
                '"contactId": "' +
                contactsForGet.get(0).Id +
                '",' +
                '"guid": "9C7E57CF-2DC7-4C89-B476-11166DED34D0",' +
                '"lastModifiedDate": "' +
                String.valueOf(system.today().format()) +
                '",' +
                '"sourceOrgId": "' +
                UserInfo.getOrganizationId() +
                '"' +
                '}' +
                ']'
            );
        } else {
            fakeGetResponse.setBody('[]');
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
        List<String> criteria = new List<String>{ 'ASU', 'Sparky', 'Devil', 'LName0', 'LName1' };
        List<Contact> contactsForPost = new List<Contact>([SELECT Id FROM Contact WHERE LastName IN :criteria]);
        HttpResponse fakePostResponse = new HttpResponse();
        Integer statusCode = 201;
        fakePostResponse.setHeader('Content-Type', 'application/json');

        if (contactsForPost.size() > 1) {
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            e.setMessage('Throw a callout exception to cover catch block.');
            throw e;
        } else if (contactsForPost.size() == 1) {
            fakePostResponse.setBody('{' + '"status": ' + statusCode + ',' + '"message": "success"' + '}');
        }
        fakePostResponse.setStatusCode(statusCode);

        return fakePostResponse;
    }

    /**
     * Generates a mock response for PUT request
     * @param The req request from the callout
     * @return A HTTPResponse containing the crosswalk response
     */
    public HTTPResponse callPutResponse() {
        List<String> criteria = new List<String>{ 'ASU', 'Sparky', 'Devil', 'LName0', 'LName1' };
        List<Contact> contactsForPut = new List<Contact>([SELECT Id FROM Contact WHERE LastName IN :criteria]);
        HttpResponse fakePutResponse = new HttpResponse();
        Integer statusCode = 200;
        fakePutResponse.setHeader('Content-Type', 'application/json');

        if (contactsForPut.size() > 1) {
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            e.setMessage('Throw a callout exception to cover catch block.');
            throw e;
        } else if (contactsForPut.size() == 1) {
            fakePutResponse.setBody('{' + '"status": ' + statusCode + ',' + '"message": "success"' + '}');
        }
        fakePutResponse.setStatusCode(statusCode);

        return fakePutResponse;
    }

    /**
     * Generates a mock response for DELETE request
     * @param The req request from the callout
     * @return A HTTPResponse containing the crosswalk response
     */
    public HTTPResponse callDeleteResponse() {
        List<String> criteria = new List<String>{ 'ASU', 'Sparky', 'Devil', 'LName0' };
        List<Contact> contactsForDelete = new List<Contact>([SELECT Id FROM Contact WHERE LastName IN :criteria]);
        HttpResponse fakeDeleteResponse = new HttpResponse();
        Integer statusCode = 200;
        fakeDeleteResponse.setHeader('Content-Type', 'application/json');

        if (contactsForDelete.size() > 1) {
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            e.setMessage('Throw a callout exception to cover catch block.');
            throw e;
        } else if (contactsForDelete.size() == 1) {
            fakeDeleteResponse.setBody('{' + '"status": ' + statusCode + ',' + '"message": "success"' + '}');
        }
        fakeDeleteResponse.setStatusCode(statusCode);

        return fakeDeleteResponse;
    }
}
