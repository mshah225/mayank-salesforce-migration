@isTest
public class EmailMessageFailureMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"failure", "message":"Exception Generated"}');
        res.setStatusCode(400);
        return res;
    }
}
