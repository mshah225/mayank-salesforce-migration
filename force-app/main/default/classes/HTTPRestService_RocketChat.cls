public class HTTPRestService_RocketChat {
    public static Http objhttp;
    public static HttpRequest req;
    public static HttpResponse res;
    public static String authorizationHeader;
    public static String baseUrl;
    public static String reqBody;

    public static List<Util_JSONParser> parsers;

    public static JSONParser parser;

    public static string GETRestCallout(string endpoint) {
        string retVal = '';
        login();

        objhttp = new Http();
        req = new HttpRequest();
        res = new HttpResponse();

        req.setMethod('GET');
        req.setEndpoint(baseUrl + endpoint);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-type', 'application/json');
        req.setTimeout(120000);

        try {
            res = objhttp.send(req);
        } catch (System.CalloutException e) {
            System.debug('Callout error: ' + e);
        }

        if (res.getStatusCode() == 200) {
            string jsonContent = res.getBody();
            //parser = JSON.createParser(jsonContent);
            retVal = jsonContent;
        }
        return retVal;
    }

    private static string login() {
        string retVal = '';

        Rest_Service_Setting__mdt custMeta = [
            SELECT Id, Label, Login_Endpoint__c, Authorization_Key__c, Username__c, Password__c
            FROM Rest_Service_Setting__mdt
            WHERE DeveloperName = 'RocketChat_API_Settings'
        ];

        baseUrl = custMeta.Login_Endpoint__c;
        authorizationHeader = custMeta.Authorization_Key__c;
        return retVal;
    }
}
