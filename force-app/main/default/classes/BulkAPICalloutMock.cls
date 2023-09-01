@isTest
public class BulkAPICalloutMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('<id>003M0000012A8X5</id>');
        res.setStatusCode(200);

        return res;
    }
}
