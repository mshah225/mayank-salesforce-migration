public with sharing class ExactTargetWebService {
    private final static String PARTNER_NS = 'http://exacttarget.com/wsdl/partnerAPI';
    private ExactTargetAPIConfig__c config;

    public ExactTargetWebService(String appName) {
        config = ExactTargetAPIConfig__c.getValues(appName);
    }

    public String requestAuthToken() {
        String token;
        String clientId = config.ClientId__c;
        String clientSecret = config.ClientSecret__c;

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://auth.exacttargetapis.com/v1/requestToken');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody('{"clientId": "' + clientId + '","clientSecret": "' + clientSecret + '"}');

        try {
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                token = (String) results.get('accessToken');
            } else {
                System.debug('Status code: ' + response.getStatusCode() + ' ' + response.getStatus());
            }

        } catch (System.CalloutException e) {
            System.debug('Error: ' + e);
        }
        return token;
    }

    public String retrieveViewEmailUrl(String authToken, String jobId, String cssfId) {
        String url;
        String endpoint = config.Endpoint__c;
        String xml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" '+
            'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <soapenv:Header> '+
            '<fueloauth xmlns="http://exacttarget.com">'+authToken+
            '</fueloauth> </soapenv:Header> <soapenv:Body> '+
            '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI"> <RetrieveRequest> '+
            '<ObjectType>DataExtensionObject[B42D3D0C-98B5-425D-B5F4-1553548B8AD6]</ObjectType> '+
            '<Properties>JobID</Properties> <Properties>ListID</Properties> <Properties>SubID</Properties> '+
            '<Properties>MemberID</Properties> <Properties>SubscriberID</Properties> <Properties>CSSFID</Properties> '+
            '<Properties>view_email_url</Properties> <Filter xsi:type="ComplexFilterPart"> '+
            '<LeftOperand xsi:type="SimpleFilterPart"> <Property>JobID</Property> <SimpleOperator>equals</SimpleOperator> '+
            '<Value>'+jobId+'</Value> </LeftOperand> <LogicalOperator>AND</LogicalOperator> '+
            '<RightOperand xsi:type="SimpleFilterPart"> <Property>CSSFID</Property> '+
            '<SimpleOperator>equals</SimpleOperator> <Value>'+cssfId+'</Value> </RightOperand> </Filter> '+
            '</RetrieveRequest> </RetrieveRequestMsg> </soapenv:Body> </soapenv:Envelope>';

        try {
            HttpResponse response = postSOAPMessage(endpoint, xml);
            Map<String,String> properties = parseResponseProperties(response);
            url = properties.get('view_email_url');
        } catch (Exception e) {
            System.debug('Error: ' + e);
        }
        return url;
    }

    private HttpResponse postSOAPMessage(String endpoint, String xml) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('SOAPAction','Retrieve');
        req.setHeader('Accept-Encoding','gzip,deflate');
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        req.setHeader('User-Agent','Jakarta Commons-HttpClient/3.1');
        req.setBody(xml);
        req.setEndpoint(endpoint);

        HttpResponse response = new Http().send(req);

        return response;
    }

    /** 
    * This method is optomistic about the existence of certain XML nodes.
    * To avoid a fatal error, wrap in a try block and catch NullPointerException.
    */
    private Map<String,String> parseResponseProperties(HttpResponse response) {
        Map<String, String> properties = new Map<String, String>();
        
        Dom.XMLNode root = response.getBodyDocument().getRootElement();
        Dom.XMLNode body = root.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XMLNode props = body.getChildElement('RetrieveResponseMsg', PARTNER_NS)
            .getChildElement('Results', PARTNER_NS)
            .getChildElement('Properties', PARTNER_NS);

        for(Dom.XMLNode p : props.getChildElements()) {
            String name = p.getChildElement('Name', PARTNER_NS).getText();
            String value = p.getChildElement('Value', PARTNER_NS).getText();
            properties.put(name, value);
        }
        return properties;
    }
}