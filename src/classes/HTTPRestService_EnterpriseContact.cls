public with sharing class HTTPRestService_EnterpriseContact {
	public HTTPRestService_EnterpriseContact() {

	}

	public String get(Map<String, String> parmMap)
	{
		String queryString = '';
		Boolean firstParm = true;
		for (String key: parmMap.keySet())
		{
			if (!String.isBlank(parmMap.get(key)))
				queryString += (firstParm ? '' : '&') + key + '=' + EncodingUtil.urlEncode(parmMap.get(key), 'UTF-8');
			firstParm = false;
		}

		return get(queryString);
	}

	public String get(String queryString)
	{
		string returnValue = '';
		HttpRequest req = new HttpRequest();
		HTTPResponse res;
		string endPointWithParms = 'callout:Mule_ESB_Contact_Service?' + queryString;
		req.setEndpoint(endPointWithParms);
		req.setMethod('GET');
		Http http = new Http();
		try
		{
			res = http.send(req);
		}
		catch (System.CalloutException e)
		{
			System.debug('Callout Error: ' + e);
		}
		System.debug(res.getBody());
		if (res.getStatusCode() == 200)
		{
			returnValue = res.getBody();
		}

		return returnValue;
	}

	public String post(Map<String, String> parmMap)
	{
		string returnValue = '';
		HttpRequest req = new HttpRequest();
		HTTPResponse res;
		string endPoint = 'callout:Mule_ESB_Contact_Service';

		JSONGenerator reqBody = JSON.createGenerator(true);
		reqBody.writeStartObject();
		for (String key: parmMap.keySet())
		{
			reqBody.writeStringField(key, parmMap.get(key));
		}
		reqBody.writeEndObject();

		req.setEndpoint(endPoint);
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json; charset=utf8');
		req.setHeader('Accept', 'application/json');
		req.setBody(reqBody.getAsString());
		Http http = new Http();
		try
		{
			res = http.send(req);
		}
		catch (System.CalloutException e)
		{
			System.debug('Callout Error: ' + e);
		}
		System.debug(res.getBody());
		//if (res.getStatusCode() == 200)
		//{
			returnValue = res.getBody();
		//}

		return returnValue;
	}
}