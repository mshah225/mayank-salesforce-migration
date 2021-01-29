public with sharing class HTTPRestService_EnterpriseContact {
    public HTTPRestService_EnterpriseContact() {
    }

    public String get(Map<String, String> parmMap) {
        String queryString = '';
        Boolean firstParm = true;
        for (String key : parmMap.keySet()) {
            if (!String.isBlank(parmMap.get(key))) {
                queryString += (firstParm ? '' : '&') + key + '=' + EncodingUtil.urlEncode(parmMap.get(key), 'UTF-8');
            }
            firstParm = false;
        }
        return get(queryString);
    }

    public String get(String queryString) {
        String returnValue = '';
        HttpRequest req = new HttpRequest();
        HTTPResponse response;
        String endPointWithParms = 'callout:Mule_ESB_Contact_Service?' + queryString;
        req.setEndpoint(endPointWithParms);
        req.setMethod('GET');
        Http http = new Http();
        try {
            response = http.send(req);
        } catch (System.CalloutException calloutException) {
            List<String> vars = new List<String>();
            vars.add(
                ErrorLogger.convertStringToJSON('Callout Exception Message in GET: ', calloutException.getMessage())
            );
            ErrorLogger.log(calloutException, vars, false);
        }
        if (response != null && response.getStatusCode() == 200) {
            returnValue = response.getBody();
        }

        return returnValue;
    }

    public String post(Map<String, String> parmMap) {
        String returnValue = '';
        HttpRequest req = new HttpRequest();
        HTTPResponse response;
        String endPoint = 'callout:Mule_ESB_Contact_Service';

        JSONGenerator reqBody = JSON.createGenerator(true);
        reqBody.writeStartObject();
        for (String key : parmMap.keySet()) {
            reqBody.writeStringField(key, parmMap.get(key));
        }

        reqBody.writeEndObject();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=utf8');
        req.setHeader('Accept', 'application/json');
        req.setBody(reqBody.getAsString());
        Http http = new Http();
        try {
            response = http.send(req);
        } catch (System.CalloutException calloutException) {
            List<String> vars = new List<String>();
            vars.add(
                ErrorLogger.convertStringToJSON('Callout Exception Message in POST: ', calloutException.getMessage())
            );
            ErrorLogger.log(calloutException, vars, false);
        }
        if (response != null && response.getStatusCode() == 201) {
            returnValue = response.getBody();
        }
        return returnValue;
    }
}
