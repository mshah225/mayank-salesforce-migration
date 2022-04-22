@isTest
public class MarketingCloudUtilitiesMockCallout implements HttpCalloutMock {
    private HttpRequest request;
    public static final String ACCOUNT_ID = '1234567';

    public HttpResponse respond(HttpRequest request) {
        this.request = request;

        HttpResponse response;
        if (isAuthorizationCallout()) {
            response = getMockAuthorizationResponse();
        } else if (isGetUsersCallout()) {
            response = getMockGetUsersResponse();
        }

        return response;
    }

    private Boolean isAuthorizationCallout() {
        return request.getBody().contains('client_id');
    }

    private Boolean isGetUsersCallout() {
        return request.getHeader('SOAPAction').equals('Retrieve');
    }

    private HttpResponse getMockAuthorizationResponse() {
        if (request.getBody().contains(ACCOUNT_ID)) {
            return getAuthorizationResponse();
        } else {
            return getUnauthorizedResponse();
        }
    }

    private HttpResponse getAuthorizationResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('Success');
        response.setBody('{"access_token" : "authorizationToken"}');
        return response;
    }

    private HttpResponse getUnauthorizedResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(400);
        response.setStatus('Unauthorized');
        return response;
    }

    private HttpResponse getMockGetUsersResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('Success');
        response.setBody(
            '<?xml version="1.0" encoding="utf-8"?>' +
            '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
            '<soap:Header>' +
            '<wsa:Action>RetrieveResponse</wsa:Action>' +
            '<wsa:MessageID>urn:uuid:0075a0e1-50e1-4968-a443-9d0355334bf5</wsa:MessageID>' +
            '<wsa:RelatesTo>urn:uuid:4ef5df55-b4c6-45c4-b157-9e89b101e883</wsa:RelatesTo>' +
            '<wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To>' +
            '<wsse:Security>' +
            '<wsu:Timestamp wsu:Id="Timestamp-74594896-c8bb-498e-a1b5-08d88a67a256">' +
            '<wsu:Created>2022-04-06T21:06:57Z</wsu:Created>' +
            '<wsu:Expires>2022-04-06T21:11:57Z</wsu:Expires>' +
            '</wsu:Timestamp>' +
            '</wsse:Security>' +
            '</soap:Header>' +
            '<soap:Body>' +
            '<RetrieveResponseMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">' +
            '<OverallStatus>OK</OverallStatus>' +
            '<RequestID>7dd364c7-a84b-4535-85ff-76cc19f9c5d5</RequestID>' +
            '<Results xsi:type="AccountUser">' +
            '<Client>' +
            '<ID>1234567</ID>' +
            '</Client>' +
            '<PartnerKey xsi:nil="true" />' +
            '<CreatedDate>2016-05-10T07:00:32.94</CreatedDate>' +
            '<ID>1234567</ID>' +
            '<ObjectID xsi:nil="true" />' +
            '<CustomerKey>45372cbb-06e0-438e-88d8-008981f7a18b</CustomerKey>' +
            '<AccountUserID>8675309</AccountUserID>' +
            '<UserID>421ddbac-cc4e-4d0f-80b1-b8b831ad16bf</UserID>' +
            '<Name>app user</Name>' +
            '<Email />' +
            '<MustChangePassword>true</MustChangePassword>' +
            '<ActiveFlag>true</ActiveFlag>' +
            '<Delete>0</Delete>' +
            '<LastSuccessfulLogin>2016-05-10T07:00:32.94</LastSuccessfulLogin>' +
            '<IsAPIUser>true</IsAPIUser>' +
            '<NotificationEmailAddress />' +
            '<IsLocked>false</IsLocked>' +
            '<DefaultBusinessUnit>7275894</DefaultBusinessUnit>' +
            '<DefaultBusinessUnitObject>' +
            '<PartnerKey xsi:nil="true" />' +
            '<ID>1234567</ID>' +
            '<ObjectID xsi:nil="true" />' +
            '<AccountType>None</AccountType>' +
            '<Subscription xsi:nil="true" />' +
            '</DefaultBusinessUnitObject>' +
            '</Results>' +
            '</RetrieveResponseMsg>' +
            '</soap:Body>' +
            '</soap:Envelope>'
        );
        return response;
    }
}
