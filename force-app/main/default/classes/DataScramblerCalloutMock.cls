@isTest
public class DataScramblerCalloutMock implements HttpCalloutMock {
    public String reqBody = '';
    public Boolean shouldSucceed = true;

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();

        reqBody = req.getBody();

        if (shouldSucceed)
            res = createSuccessfulResponse(req);
        else
            res = createFailureResponse(req);

        return res;
    }

    public HTTPResponse createSuccessfulResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('<id>003M0000012A8X5</id>');
        res.setStatusCode(200);
        return res;
    }

    public HTTPResponse createFailureResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/plain');
        res.setBody('FAILURE_CODE_BAMT_01');
        res.setStatusCode(500);
        return res;
    }
}
