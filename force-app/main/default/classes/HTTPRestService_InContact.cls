public class HTTPRestService_InContact {
    public static Http objhttp;
    public static HttpRequest req;
    public static HttpResponse res;
    public static String authorizationHeader;
    public static String baseUrl;

    public static HTTPResponse GETRestCallout(string endpoint) {
        string retVal = '';
        login();

        objhttp = new Http();
        req = new HttpRequest();
        res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(baseUrl + endpoint);
        req.setHeader('Authorization', 'Bearer ' + authorizationHeader);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-type', 'application/json');
        req.setTimeout(120000);

        res = objhttp.send(req);
        return res;
    }

    private static string login() {
        string retVal = '';
        objhttp = new Http();
        req = new HttpRequest();
        res = new HttpResponse();
        req.setMethod('POST');

        Rest_Service_Setting__mdt custMeta = [
            SELECT Id, Label, Login_Endpoint__c, Authorization_Key__c, Username__c, Password__c
            FROM Rest_Service_Setting__mdt
            WHERE DeveloperName = 'InContact_API_Settings'
        ];
        req.setEndpoint(custMeta.Login_Endpoint__c);
        Blob headerValue = Blob.valueOf(custMeta.Authorization_Key__c);
        authorizationHeader = 'basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-type', 'application/json');
        //req.setHeader('Accept-Language', 'en-CA');
        req.setTimeout(120000);

        //Set request format
        string reqBody =
            '{"grant_type" : "password","username" : "' +
            custMeta.Username__c +
            '","password" : "' +
            custMeta.Password__c +
            '","scope" : ""}';
        req.setBody(reqBody);
        res = objhttp.send(req);

        if (res.getStatusCode() == 200) {
            string jsonContent = res.getBody();
            Util_JSONParser parser = Util_JSONParser.createParser(jsonContent);
            authorizationHeader = parser.get('access_token').Value;
            baseUrl = parser.get('resource_server_base_uri').Value;
        }

        return retVal;
    }
}
