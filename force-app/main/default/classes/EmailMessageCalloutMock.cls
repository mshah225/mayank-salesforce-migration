@isTest
public class EmailMessageCalloutMock implements HttpCalloutMock {
    public Boolean shouldSucceed = true;

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if (shouldSucceed)
            res = createSuccessfulResponse(req);
        else
            res = createFailureResponse(req);
        return res;
    }

    public HTTPResponse createSuccessfulResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success", "message":"Mock Attachment Id"}');
        res.setStatusCode(200);
        return res;
    }

    public HTTPResponse createFailureResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"failure", "message":"Exception Generated"}');
        res.setStatusCode(400);
        return res;
    }
}
