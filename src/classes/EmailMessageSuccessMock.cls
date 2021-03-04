@isTest
public class EmailMessageSuccessMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success", "message":"Mock Attachment Id"}');
        res.setStatusCode(200);
        return res;
    }
}
