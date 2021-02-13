public with sharing abstract class DuoAuth implements DuoRequest {
    protected DuoAuthFactor factor;
    protected String ipaddr;

    /**
     * The IP address of the user to be authenticated, in dotted quad format.
     * This will cause an "allow" response to be sent if appropriate for
     * requests from a trusted network.
     *
     * @param ipaddr an IP address (xxxx.xxxx.xxxx.xxxx)
     *
     * @return the current DuoAuth instance
     */
    public DuoAuth setIPAddress(String ipaddr) {
        this.ipaddr = ipaddr;
        return this;
    }

    /**
     * Returns the POST REST method for the Auth API
     *
     * @return a DuoRequest.Method enumeration
     */
    public DuoAPI.Method getMethod() {
        return DuoAPI.Method.POSTX;
    }

    /**
     * Returns the path for the Auth API
     *
     * @return a String representation of the path (e.g. "/auth/v2/auth")
     */
    public String getPath() {
        return '/auth/v2/auth';
    }

    /**
     * Returns the user information and factor method for the Auth API
     *
     * @return a Map of Auth API parameters
     */
    public Map<String, Object> getParams() {
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(factor.serialize());

        if (ipaddr != null) {
            params.put('ipaddr', ipaddr);
        }

        return params;
    }

    /**
     * Returns an Object that contains response data from the DuoAPI
     *
     * @param body the raw body response from an HttpRequest
     *
     * @return an Object with response data from Duo
     */
    public Object handleSuccess(String body) {
        return DuoUtil.parseResponse(body, Success.class);
    }

    /**
     * Defines a successful response from the Auth endpoint
     */
    public class Success {
        public String result;
        public String status;
        public String status_msg;
    }
}
