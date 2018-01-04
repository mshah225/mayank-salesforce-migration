public class HTTPRestService_MarketingCloud {
	public static Http objhttp;
    public static HttpRequest req;
    public static HttpResponse res;
    public static String authorizationHeader;
    public static String baseUrl;
    public static String reqBody;
    public static List<Util_JSONParser> parsers;

    private mcAuthResult authResult = new mcAuthResult();

    public static JSONParser parser;

// Sample payload for queueMO mobile opt-in with Salesforce Contact ID Subscriber Key
// {"subscribers":[{"subscriberkey":"003d000003J6FNEAA3","mobilenumber":"14807663728"}],"shortCode":"61086","messageText":"FRESHMAN"}

    public String queueMO(String subscriberKeyParm, String mobilenumberParm, String shortCodeParm, String messageTextParm)
    {
        queueMODetail qmd = new queueMODetail(subscriberKeyParm, mobilenumberParm, shortCodeParm, messageTextParm);
        if (!getAuthorization())
            return '';
        HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:Marketing_Cloud/queueMO/');
		req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + authResult.accessToken);
        req.setHeader('Accept','application/json');
		req.setHeader('Content-Type', 'application/json');

		req.setBody(JSON.serialize(qmd));
		Http http = new Http();
		HTTPResponse res = http.send(req);
        return res.getBody();

    }

    // Method to call MC REST API's non-standard authorization method
	private Boolean getAuthorization()
	{
		HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:Marketing_Cloud/requestToken');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setBody('{"clientId":"{!$Credential.Username}","clientSecret":"{!$Credential.Password}"}');
		Http http = new Http();
		HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 200)
        {
            authResult = (mcAuthResult)JSON.deserialize(res.getBody(), mcAuthResult.class);
            return true;
        }
        return false;
	}

    // Inner classes used for JSON interaction
    public class subscriberDetail
    {
        public String subscriberkey {get; set;}
        public String mobilenumber {get; set;}
    }

    public class queueMODetail
    {
        public List<subscriberDetail> subscribers {get; set;}
        public String shortCode {get; set;}
        public String messageText {get; set;}

        public queueMODetail(String subscriberKeyParm, String mobilenumberParm, String shortCodeParm, String messageTextParm)
        {
            subscriberDetail sd = new subscriberDetail();
            sd.subscriberkey = subscriberKeyParm;
            sd.mobilenumber = mobilenumberParm;

            subscribers = new List<subscriberDetail>{sd};
            shortCode = shortCodeParm;
            messageText = messageTextParm;
        }
    }

	public class mcAuthResult
	{
		public String accessToken {get; set;}
		public Integer expiresIn {get; set;}
	}

}