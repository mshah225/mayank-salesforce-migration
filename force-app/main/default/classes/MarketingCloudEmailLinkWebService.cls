public with sharing class MarketingCloudEmailLinkWebService {
    private final static String PARTNER_NS = 'http://exacttarget.com/wsdl/partnerAPI';
    private final static String DATA_EXTENTION_NAME = 'Email_Send_Logs';
    private final static String VIEW_EMAIL_URL_PROPERTY = 'view_email_url';
    public ExactTargetApiConfig__c apiConfiguration { get; private set; }
    private String jobId;
    private String subscriberKey;

    public MarketingCloudEmailLinkWebService(String appName) {
        apiConfiguration = ExactTargetApiConfig__c.getValues(appName);
    }

    public String retrieveViewEmailUrl(String jobId, String subscriberKey) {
        this.jobId = jobId;
        this.subscriberKey = subscriberKey;
        try {
            String authToken = getAuthTokenFromMarketingCloud();
            return getViewEmailUrlFromMarketingCloud(authToken);
        } catch (Exception e) {
            throw new MarketingCloudCalloutException('Error: ' + e.getMessage());
        }
    }

    private String getAuthTokenFromMarketingCloud() {
        HttpRequest request = buildAuthorizationRequest();
        HttpResponse response = new Http().send(request);
        return parseAuthTokenFromResponse(response);
    }

    private HttpRequest buildAuthorizationRequest() {
        HttpRequest request = new HttpRequest();
        String clientId = apiConfiguration.ClientId__c;
        String clientSecret = apiConfiguration.ClientSecret__c;
        request.setEndpoint('https://auth.exacttargetapis.com/v1/requestToken');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody('{"clientId": "' + clientId + '","clientSecret": "' + clientSecret + '"}');
        return request;
    }

    private String parseAuthTokenFromResponse(HttpResponse response) {
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) Json.deserializeUntyped(response.getBody());
            return (String) results.get('accessToken');
        } else {
            throw new MarketingCloudCalloutException(
                'Status Code: ' +
                response.getStatusCode() +
                ' ' +
                response.getStatus()
            );
        }
    }

    private String getViewEmailUrlFromMarketingCloud(String authToken) {
        HttpRequest request = buildViewEmailRequest(authToken);
        HttpResponse response = new Http().send(request);
        Map<String, String> properties = parseResponseProperties(response);
        return properties.get(VIEW_EMAIL_URL_PROPERTY);
    }

    private HttpRequest buildViewEmailRequest(String authToken) {
        String endpoint = apiConfiguration.Endpoint__c;
        String businessUnitId = getBusinessUnitId();
        String xml =
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
            '<soapenv:Header>' +
            '<fueloauth xmlns="http://exacttarget.com">' +
            authToken +
            '</fueloauth>' +
            '</soapenv:Header>' +
            '<soapenv:Body>' +
            '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">' +
            '<RetrieveRequest>' +
            '<ClientIDs>' +
            '<ClientID>' +
            businessUnitId +
            '</ClientID>' +
            '</ClientIDs>' +
            '<ObjectType>DataExtensionObject[' +
            DATA_EXTENTION_NAME +
            ']</ObjectType>' +
            '<Properties>view_email_url</Properties>' +
            '<Filter xsi:type="ComplexFilterPart">' +
            '<LeftOperand xsi:type="SimpleFilterPart">' +
            '<Property>JobID</Property>' +
            '<SimpleOperator>equals</SimpleOperator>' +
            '<Value>' +
            jobId +
            '</Value>' +
            '</LeftOperand>' +
            '<LogicalOperator>AND</LogicalOperator>' +
            '<RightOperand xsi:type="SimpleFilterPart">' +
            '<Property>SubscriberKey</Property>' +
            '<SimpleOperator>equals</SimpleOperator>' +
            '<Value>' +
            subscriberKey +
            '</Value>' +
            '</RightOperand>' +
            '</Filter>' +
            '</RetrieveRequest>' +
            '</RetrieveRequestMsg>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('SOAPAction', 'Retrieve');
        request.setHeader('Accept-Encoding', 'gzip,deflate');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('User-Agent', 'Jakarta Commons-HttpClient/3.1');
        request.setBody(xml);
        request.setEndpoint(endpoint);

        return request;
    }

    private String getBusinessUnitId() {
        return [
            SELECT et4ae5__Business_Unit__r.et4ae5__Business_Unit_ID__c
            FROM et4ae5__SendDefinition__c
            WHERE et4ae5__JobId__c = :jobId
            LIMIT 1
        ]
        .et4ae5__Business_Unit__r.et4ae5__Business_Unit_Id__c;
    }

    private Map<String, String> parseResponseProperties(HttpResponse response) {
        Dom.XMLNode xmlProperties = response.getBodyDocument()
            .getRootElement()
            .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
            .getChildElement('RetrieveResponseMsg', PARTNER_NS)
            .getChildElement('Results', PARTNER_NS)
            .getChildElement('Properties', PARTNER_NS);
        Map<String, String> properties = new Map<String, String>();
        for (Dom.XMLNode property : xmlProperties.getChildElements()) {
            String name = property.getChildElement('Name', PARTNER_NS).getText();
            String value = property.getChildElement('Value', PARTNER_NS).getText();
            properties.put(name, value);
        }
        return properties;
    }

    public class MarketingCloudCalloutException extends Exception {
    }
}
