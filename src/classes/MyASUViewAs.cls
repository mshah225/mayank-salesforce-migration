public class MyASUViewAs 
{
	private static final String SECRET_KEY = '543d32e1eer10c3360X0916b16d4098q9ebc93d4';
	private static final String GET_EFFECTIVE_IDENTITY_SERVICE_NAME = 'getEffIdent';

	/**
	* Returns the values needed to verify view as access from My ASU
	* @param The masqScopeIdCookie passed in the URL from My ASU
	* @param The user who is viewing as asurite
	* @return A Map containing the values
	*/
  	public static Map<String, String> getCalloutResponseContents(String idCookie, String asurite) 
  	{
		// Store these configuration parameters wherever you store your general app config/properties
		String appid = 'salesforce_app';
		String sharedSecret = SECRET_KEY; // this is the secret key assigned to the appid
		String myAsuUrl = 'https://webapp4-qa.asu.edu/myasu'; // prod url = https://webapp4.asu.edu/myasu
		// TODO: update the myAsuUrl to prod before migration.

		// Gather/determine input parameters to web service call
		String realAsurite = asurite; // the real user identity -- get this from asuwebauth/SSO
		String scopeIdCookie = idCookie; // this is from a cookie that My ASU sets to be visible by the domain .asu.edu
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

		Blob sigBlob = Crypto.generateMac('hmacSHA256', Blob.valueOf(stringToSign), Blob.valueOf(sharedSecret));
		String signature = EncodingUtil.convertToHex(sigBlob);

		// Build request url
		String requestUrl = myAsuUrl;
		requestUrl += '/ws/' + GET_EFFECTIVE_IDENTITY_SERVICE_NAME;
		requestUrl += '?appid=' + appid;
		requestUrl += '&signaturetime=' + signatureTime;
		requestUrl += '&real-asurite=' + EncodingUtil.urlEncode(realAsurite, 'UTF-8');
		requestUrl += '&scopeid-cookie=' + EncodingUtil.urlEncode(scopeIdCookie, 'UTF-8');
		requestUrl += '&signature=' + EncodingUtil.urlEncode(signature, 'UTF-8');

	    // Instantiate a new http object
	    Http h = new Http();

	     // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(requestUrl);
	    req.setMethod('GET');

	    // Send the request, and return a response
	    // req.setTimeout(20000);
	    HttpResponse res = h.send(req);
	    String xml = res.getBody();
	    Dom.Document doc = new Dom.Document();
	    doc.load(xml);
        
        // Retrieve the root element for this document.
        Dom.XMLNode address = doc.getRootElement();

        Map<String, String> viewAsValues = new Map<String, String>();
        viewAsValues.put('authorizedToViewAs', address.getChildElement('authorizedToViewAs', null).getText());
        viewAsValues.put('isViewingAs', address.getChildElement('isViewingAs', null).getText());
        viewAsValues.put('effectiveAsurite', address.getChildElement('effectiveAsurite', null).getText());
        viewAsValues.put('signoutUrl', address.getChildElement('signoutUrl', null).getText());
        viewAsValues.put('viewAsUrl', address.getChildElement('viewAsUrl', null).getText());
        viewAsValues.put('stopViewAsUrl', address.getChildElement('stopViewAsUrl', null).getText());

	    return viewAsValues;
  	}

	/**
	* Checks View As Map response to ensure user has rights to View As
	* @param The Map recieved from the My ASU web service.
	* @return A boolean stating if the user will be viewing as or not.
	*/
	public static Boolean checkViewAsRights(Map<String, String> viewAsMap, String userAsurite)
	{
		if (!viewAsMap.isEmpty()
				&& viewAsMap.get('authorizedToViewAs') == 'true'
				&& viewAsMap.get('isViewingAs') == 'true'
				&& userAsurite != viewAsMap.get('effectiveAsurite'))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}