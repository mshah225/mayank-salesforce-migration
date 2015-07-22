public class MyASUViewAs 
{
	public static final String SECRET_KEY = '543d32e1eer10c3360X0916b16d4098q9ebc93d4';
	public static final String GET_EFFECTIVE_IDENTITY_SERVICE_NAME = 'getEffIdent';

	// Pass in the endpoint to be used using the string url
  	public String getCalloutResponseContents() 
  	{
		// Store these configuration parameters wherever you store your general app config/properties
		String appid = 'salesforce_app';
		String sharedSecret = SECRET_KEY; // this is the secret key assigned to the appid
		String myAsuUrl = 'https://webapp4-qa.asu.edu/myasu'; // prod url = https://webapp4.asu.edu/myasu

		// Gather/determine input parameters to web service call
		String realAsurite = 'meruff'; // the real user identity -- get this from asuwebauth/SSO
		String scopeIdCookie = ApexPages.currentPage().getParameters().get('masqScopeIdCooke'); // this is from a cookie that My ASU sets to be visible by the domain .asu.edu
		if (scopeIdCookie == null)
		{
			scopeIdCookie = '';
		}

		// Generate request signature to authenticate our request to the web service
		String signatureTime = String.valueOf(System.currentTimeMillis()/1000);
		String stringToSign = 'service=' + GET_EFFECTIVE_IDENTITY_SERVICE_NAME;
		stringToSign += '&appid=' + appid;
		stringToSign += '&signaturetime=' + signatureTime;
		stringToSign += '&real-asurite=' + realAsurite;
		stringToSign += '&scopeid-cookie=' + scopeIdCookie;
		String algorithmName = 'HmacSHA256';
		Blob signature = Crypto.generateMac(algorithmName, Blob.valueOf(stringToSign), Blob.valueOf(sharedSecret));

		// Build request url
		String requestUrl = myAsuUrl;
		requestUrl += '/ws/' + GET_EFFECTIVE_IDENTITY_SERVICE_NAME;
		requestUrl += '?appid=' + appid;
		requestUrl += '&signaturetime=' + signatureTime;
		requestUrl += '&real-asurite=' + EncodingUtil.urlEncode(realAsurite, 'UTF-8');
		requestUrl += '&scopeid-cookie=' + EncodingUtil.urlEncode(scopeIdCookie, 'UTF-8');
		requestUrl += '&signature=' + EncodingUtil.urlEncode(String.valueOf(signature), 'UTF-8');

	    // Instantiate a new http object
	    Http h = new Http();

	     // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(requestUrl);
	    req.setMethod('GET');

	    // Send the request, and return a response
	    req.setTimeout(20000);
	    HttpResponse res = h.send(req);
	    return res.getBody();
  	}
}