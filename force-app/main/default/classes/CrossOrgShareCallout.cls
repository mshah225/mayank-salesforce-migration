/**
 * File Name: CrossOrgShareCallout
 * Description: HTTP Callout methods for CrossOrg Data Sharing
 * Author: Carl Hussey
 * Created: 04/22/2020
 */
public class CrossOrgShareCallout {
    /**
     * Overload GET callout to to transform param map
     * into a query string
     *
     * @param Map<String, String> value of inbound params to convert
     * @return HttpResponse containing the API response
     */
    public HttpResponse makeGetCallout(Map<String, String> paramMap) {
        String queryString = '';
        Boolean firstParam = true;
        for (String key : paramMap.keySet()) {
            if (!String.isBlank(paramMap.get(key))) {
                queryString += (firstParam ? '' : '&') + key + '=' + EncodingUtil.urlEncode(paramMap.get(key), 'UTF-8');
            }
            firstParam = false;
        }

        return makeGetCallout(queryString);
    }

    /**
     * API Callout to ESB Service for Crosswalk records
     * Method: GET
     *
     * @param String value for Contact lookup
     * @return HttpResponse containing the API response
     */
    public HttpResponse makeGetCallout(String queryString) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Mule_ESB_Crosswalk_Service?' + queryString);
        request.setMethod('GET');

        HttpResponse response;

        try {
            response = http.send(request);
        } catch (System.CalloutException calloutException) {
            throw new CrossOrgShareCalloutException(calloutException.getMessage());
        }

        return response;
    }

    /**
     * API Callout to ESB Service for Crosswalk records
     * Method: GET (No Params)
     *
     * @param String recordId for Contact lookup
     * @return HttpResponse containing the API response
     */
    public HttpResponse makeGetCalloutById(String recordId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Mule_ESB_Crosswalk_Service/' + recordId);
        request.setMethod('GET');

        HttpResponse response;

        try {
            response = http.send(request);
        } catch (System.CalloutException calloutException) {
            throw new CrossOrgShareCalloutException(calloutException.getMessage());
        }

        return response;
    }

    /**
     * API Callout to ESB Service to create a crosswalk record
     * Method: POST
     *
     * @param String json collection value for a new crosswalk record(s)
     * @return HttpResponse containing the API response
     */
    public HttpResponse makePostCallout(String jsonRecords) {
        HttpRequest request = new HttpRequest();
        HttpResponse response;

        request.setEndpoint('callout:Mule_ESB_Crosswalk_Service');
        request.setHeader('Content-Type', 'application/json; charset=utf8');
        request.setHeader('Accept', 'application/json');
        request.setMethod('POST');
        request.setBody(jsonRecords);

        try {
            response = new http().send(request);
        } catch (System.CalloutException calloutException) {
            throw new CrossOrgShareCalloutException(calloutException.getMessage());
        }

        return response;
    }

    /**
     * API Callout to ESB Service to update a crosswalk record
     * Method: PUT
     *
     * @param String json collection value for a new crosswalk record(s)
     * @return HttpResponse containing the API response
     */
    public HttpResponse makePutCallout(String jsonRecords) {
        HttpRequest request = new HttpRequest();
        HttpResponse response;

        request.setEndpoint('callout:Mule_ESB_Crosswalk_Service');
        request.setHeader('Content-Type', 'application/json; charset=utf8');
        request.setHeader('Accept', 'application/json');
        request.setMethod('PUT');
        request.setBody(jsonRecords);

        try {
            response = new http().send(request);
        } catch (System.CalloutException calloutException) {
            throw new CrossOrgShareCalloutException(calloutException.getMessage());
        }

        return response;
    }

    /**
     * API Callout to ESB Service to delete a crosswalk record
     * Method: DELETE
     *
     * @param String json collection value for a new crosswalk record(s)
     * @return HttpResponse containing the API response
     */
    public HttpResponse makeDeleteCallout(String jsonRecords) {
        HttpRequest request = new HttpRequest();
        HttpResponse response;

        request.setEndpoint('callout:Mule_ESB_Crosswalk_Service');
        request.setHeader('Content-Type', 'application/json; charset=utf8');
        request.setHeader('Accept', 'application/json');
        request.setMethod('DELETE');
        request.setBody(jsonRecords);

        try {
            response = new http().send(request);
        } catch (System.CalloutException calloutException) {
            throw new CrossOrgShareCalloutException(calloutException.getMessage());
        }

        return response;
    }

    public class CrossOrgShareCalloutException extends Exception {
    }
}
