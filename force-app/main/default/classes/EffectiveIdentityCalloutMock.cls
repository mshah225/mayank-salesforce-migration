@isTest
public class EffectiveIdentityCalloutMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse fakeResponse = new HttpResponse();
        if (request.getMethod() == 'GET') {
            fakeResponse = callGetResponse();
        }
        return fakeResponse;
    }

    private HTTPResponse callGetResponse() {
        HttpResponse fakeGetResponse = new HttpResponse();
        fakeGetResponse.setHeader('Content-Type', 'application/json');

        fakeGetResponse.setBody(
            '<?xml version ="1.0" encoding ="UTF-8"?>' +
            +'<getEffIdent> <authorizedToViewAs>false</authorizedToViewAs>' +
            '<isViewingAs>false</isViewingAs><effectiveAsurite>tester</effectiveAsurite>' +
            '<signoutUrl>https://webapp4.asu.edu/myasu/Signout</signoutUrl><viewAsUrl>' +
            '</viewAsUrl><stopViewAsUrl></stopViewAsUrl></getEffIdent>'
        );
        fakeGetResponse.setStatusCode(200);
        return fakeGetResponse;
    }
}
