@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('"success"');
        res.setStatusCode(200);
        return res;
    }
}