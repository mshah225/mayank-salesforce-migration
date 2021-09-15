@isTest
public class MarketingCloudEmailLinkMockCallout implements HttpCalloutMock {
    private HttpRequest request;
    public static final String CLIENT_ID = 'testClientId';
    public static final String CLIENT_SECRET = 'testClientSecret';
    public static String VIEW_EMAIL_URL = 'http://view.testreply.asu.edu/?qs=testDocumentId';

    public HttpResponse respond(HttpRequest request) {
        this.request = request;

        HttpResponse response;
        if (isAuthorizationCallout()) {
            response = getMockAuthorizationResponse();
        } else if (isGetLinkCallout()) {
            response = getMockGetViewEmailLinkResponse();
        }

        return response;
    }

    private Boolean isAuthorizationCallout() {
        return request.getBody().contains('clientId');
    }

    private Boolean isGetLinkCallout() {
        return request.getHeader('SOAPAction').equals('Retrieve');
    }

    private HttpResponse getMockAuthorizationResponse() {
        if (request.getBody().contains(CLIENT_SECRET)) {
            return getAuthorizationResponse();
        } else {
            return getUnauthorizedResponse();
        }
    }

    private HttpResponse getAuthorizationResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('Success');
        response.setBody('{"accessToken" : "authorizationToken"}');
        return response;
    }

    private HttpResponse getUnauthorizedResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(400);
        response.setStatus('Unauthorized');
        return response;
    }

    private HttpResponse getMockGetViewEmailLinkResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('Success');
        response.setBody(
            '<?xml version="1.0" encoding="utf-8"?>' +
            '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
            '<soap:Header>' +
            '<wsa:Action>RetrieveResponse</wsa:Action>' +
            '<wsa:MessageID>urn:uuid:a206cadd-72d2-45ca-aac8-783cd158c6cc</wsa:MessageID>' +
            '<wsa:RelatesTo>urn:uuid:9030f86e-0dd8-49da-ae89-793d6899fdad</wsa:RelatesTo>' +
            '<wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To>' +
            '<wsse:Security>' +
            '<wsu:Timestamp wsu:Id="Timestamp-9c187e2b-e2c4-401b-b198-ba8e930a9390">' +
            '<wsu:Created>2018-03-20T19:30:42Z</wsu:Created>' +
            '<wsu:Expires>2018-03-20T19:35:42Z</wsu:Expires>' +
            '</wsu:Timestamp>' +
            '</wsse:Security>' +
            '</soap:Header>' +
            '<soap:Body>' +
            '<RetrieveResponseMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">' +
            '<OverallStatus>OK</OverallStatus>' +
            '<RequestID>3cabd3f5-c90e-46f8-b9dd-ca1458a93e95</RequestID>' +
            '<Results xsi:type="DataExtensionObject">' +
            '<PartnerKey xsi:nil="true" />' +
            '<ObjectID xsi:nil="true" />' +
            '<Type>DataExtensionObject</Type>' +
            '<Properties>' +
            '<Property>' +
            '<Name>view_email_url</Name>' +
            '<Value>' +
            VIEW_EMAIL_URL +
            '</Value>' +
            '</Property>' +
            '</Properties>' +
            '</Results>' +
            '</RetrieveResponseMsg>' +
            '</soap:Body>' +
            '</soap:Envelope>'
        );
        return response;
    }
}
