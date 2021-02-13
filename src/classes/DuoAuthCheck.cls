public with sharing class DuoAuthCheck implements DuoRequest {
    /**
     * Returns the REST method that this API uses
     *
     * @return a DuoRequest.Method enumeration
     */
    public DuoAPI.Method getMethod() {
        return DuoAPI.Method.GETX;
    }

    /**
     * Returns the path of the endpoint for this API
     *
     * @return a String representation of the path (e.g. "/auth/v2/check")
     */
    public String getPath() {
        return '/auth/v2/check';
    }

    /**
     * Returns a collection of key value pair parameters that should be used
     * against this API implementation
     *
     * @return a Map of API parameters
     */
    public Map<String, Object> getParams() {
        return null;
    }

    /**
     * Returns an Object that contains response data from the DuoAPI
     *
     * @param body the raw body response from an HttpRequest
     *
     * @return an Object with response data from Duo
     */
    public Object handleSuccess(String body) {
        return DuoUtil.parseResponse(body.replace('"time"', '"timex"'), Success.class);
    }

    /**
     * Defines a successful response from the Check endpoint
     */
    public class Success {
        public Integer timex;
    }
}
