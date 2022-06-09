public with sharing class MarketingCloudUsersCallout {
    private final static String PARTNER_NS = 'http://exacttarget.com/wsdl/partnerAPI';
    public Marketing_Cloud_Utilities_Config__c apiConfiguration { get; private set; }

    /**
     * API Config
     */
    public MarketingCloudUsersCallout(String appName) {
        apiConfiguration = Marketing_Cloud_Utilities_Config__c.getValues(appName);
    }

    /**
     * Get users
     */
    public List<MarketingCloudUser> getUsers() {
        try {
            String authToken = getAuthTokenFromMarketingCloud();
            return getUsersFromMarketingCloud(authToken);
        } catch (Exception e) {
            throw new MarketingCloudCalloutException('Error: ' + e.getMessage());
        }
    }

    /**
     * Get the auth token for requests
     */
    private String getAuthTokenFromMarketingCloud() {
        HttpRequest request = buildAuthorizationRequest();
        HttpResponse response = new Http().send(request);
        return parseAuthTokenFromResponse(response);
    }

    /**
     * Build request for auth token
     */
    private HttpRequest buildAuthorizationRequest() {
        String accountId = apiConfiguration.AccountId__c;
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Marketing_Cloud/v2/Token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(
            '{"client_id": "{!$Credential.Username}","client_secret": "{!$Credential.Password}", "account_id": "' +
            accountId +
            '", "grant_type": "client_credentials"}'
        );
        return request;
    }

    /**
     * Parse the auth request for the token
     */
    private String parseAuthTokenFromResponse(HttpResponse response) {
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) Json.deserializeUntyped(response.getBody());
            return (String) results.get('access_token');
        } else {
            throw new MarketingCloudCalloutException(
                'Status Code: ' +
                response.getStatusCode() +
                ' ' +
                response.getStatus()
            );
        }
    }

    /**
     * Get users via soap callout
     */
    private List<MarketingCloudUser> getUsersFromMarketingCloud(String authToken) {
        HttpRequest request = buildUserRequest(authToken);
        HttpResponse response = new Http().send(request);
        List<MarketingCloudUser> nodes = parseResponseNodes(response);
        return nodes;
    }

    /**
     * Build user soap request
     */
    private HttpRequest buildUserRequest(String authToken) {
        String endpoint = apiConfiguration.Endpoint__c;
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
            '<ObjectType>AccountUser</ObjectType>' +
            '<Properties>Name</Properties>' +
            '<Properties>ID</Properties>' +
            '<Properties>AccountUserID</Properties>' +
            '<Properties>CreatedDate</Properties>' +
            '<Properties>UserID</Properties>' +
            '<Properties>Email</Properties>' +
            '<Properties>CustomerKey</Properties>' +
            '<Properties>MustChangePassword</Properties>' +
            '<Properties>ActiveFlag</Properties>' +
            '<Properties>LastSuccessfulLogin</Properties>' +
            '<Properties>IsAPIUser</Properties>' +
            '<Properties>NotificationEmailAddress</Properties>' +
            '<Properties>IsLocked</Properties>' +
            '<Properties>DefaultBusinessUnit</Properties>' +
            '</RetrieveRequest>' +
            '</RetrieveRequestMsg>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('SOAPAction', 'Retrieve');
        request.setHeader('Content-Type', 'text/xml');
        request.setBody(xml);
        request.setEndpoint(endpoint);
        return request;
    }

    /**
     * Parse the nodes
     */
    private List<MarketingCloudUser> parseResponseNodes(HttpResponse response) {
        List<MarketingCloudUser> u = new List<MarketingCloudUser>();

        Dom.Document doc = response.getBodyDocument();
        Dom.XmlNode methodResponse = doc.getRootElement();

        List<Dom.XmlNode> dataNodes = methodResponse
            .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
            .getChildElement('RetrieveResponseMsg', PARTNER_NS)
            .getChildElements();

        // Loop through each node
        for (Dom.XmlNode dNode : dataNodes) {
            // If we are on the results node, continue
            if (dNode.getName() == 'Results') {
                // Hold this iterations node data
                MarketingCloudUser us = new MarketingCloudUser();

                // Get child elements
                us.AccountUserId = Integer.valueOf(dNode.getChildElement('AccountUserID', PARTNER_NS).getText());
                us.DefaultBusinessUnit = Integer.valueOf(
                    dNode.getChildElement('DefaultBusinessUnit', PARTNER_NS).getText()
                );
                us.Id = Integer.valueOf(dNode.getChildElement('ID', PARTNER_NS).getText());

                String createdDate = dNode.getChildElement('CreatedDate', PARTNER_NS).getText();
                us.CreatedDate = DateTime.valueOf(createdDate.replace('T', ' ')).format('yyyy-MM-dd HH:mm:ss');

                String lastLoginDate = dNode.getChildElement('LastSuccessfulLogin', PARTNER_NS).getText();
                us.LastSuccessfulLogin = DateTime.valueOf(lastLoginDate.replace('T', ' '))
                    .format('yyyy-MM-dd HH:mm:ss');

                us.IsAPIUser = Boolean.valueOf(dNode.getChildElement('IsAPIUser', PARTNER_NS).getText());
                us.IsLocked = Boolean.valueOf(dNode.getChildElement('IsLocked', PARTNER_NS).getText());
                us.MustChangePassword = Boolean.valueOf(
                    dNode.getChildElement('MustChangePassword', PARTNER_NS).getText()
                );
                us.ActiveFlag = Boolean.valueOf(dNode.getChildElement('ActiveFlag', PARTNER_NS).getText());
                us.Deleted = Boolean.valueOf(dNode.getChildElement('Delete', PARTNER_NS).getText());

                us.Name = dNode.getChildElement('Name', PARTNER_NS).getText();
                us.NotificationEmailAddress = dNode.getChildElement('NotificationEmailAddress', PARTNER_NS).getText();
                us.CustomerKey = dNode.getChildElement('CustomerKey', PARTNER_NS).getText();
                us.UserId = dNode.getChildElement('UserID', PARTNER_NS).getText();
                us.Email = dNode.getChildElement('Email', PARTNER_NS).getText();

                // Add users to list
                u.add(us);
            }
        }
        return u;
    }

    /**
     * Exception
     */
    public class MarketingCloudCalloutException extends Exception {
    }

    /**
     * Define our MC user shape
     */
    public class MarketingCloudUser {
        @AuraEnabled
        public String createdDate { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public Integer accountUserId { get; set; }
        @AuraEnabled
        public Integer id { get; set; }
        @AuraEnabled
        public String customerKey { get; set; }
        @AuraEnabled
        public String userId { get; set; }
        @AuraEnabled
        public String email { get; set; }
        @AuraEnabled
        public Boolean mustChangePassword { get; set; }
        @AuraEnabled
        public Boolean activeFlag { get; set; }
        @AuraEnabled
        public Boolean deleted { get; set; }
        @AuraEnabled
        public String lastSuccessfulLogin { get; set; }
        @AuraEnabled
        public Boolean isAPIUser { get; set; }
        @AuraEnabled
        public String notificationEmailAddress { get; set; }
        @AuraEnabled
        public Boolean isLocked { get; set; }
        @AuraEnabled
        public Integer defaultBusinessUnit { get; set; }
    }
}
