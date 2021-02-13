public interface DuoRequest {
    /**
     * Returns the REST method that this request uses
     *
     * @return a DuoAPI.Method enumeration
     */
    DuoAPI.Method getMethod();

    /**
     * Returns the path of the endpoint for this request
     *
     * @return a String representation of the path (e.g. "/api/v1/path")
     */
    String getPath();

    /**
     * Returns a collection of key value pair parameters that should be used
     * against this request implementation
     *
     * @return a Map of request parameters
     */
    Map<String, Object> getParams();

    /**
     * Returns an Object that contains response data from the DuoAPI
     *
     * @param body the raw body response from an HttpRequest
     *
     * @return an Object with response data from Duo
     */
    Object handleSuccess(String body);
}
