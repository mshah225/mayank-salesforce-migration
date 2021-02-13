public class DuoResponse {
    private HttpResponse response;
    private DuoRequest request;

    /**
     * Creates a wrapper for interacting with a response from the Duo API
     *
     * @param response the HttpResponse from calling the Duo API
     * @param request the DuoRequest that was used to call the Duo API
     */
    public DuoResponse(HttpResponse response, DuoRequest request) {
        this.response = response;
        this.request = request;
    }

    /**
     * If the request to the Duo API was successful, returns an Object that
     * defines the successful response data. Otherwise, returns an Error
     * object which details why the request may have failed
     *
     * @return an Object defining the result from the Duo API
     */
    public Object getResult() {
        /*
         * Successful responses from Duo will always result in a 200 HTTP
         * status code.
         *
         * See https://help.duo.com/s/article/1338?language=en_US for more
         * information on Duo responses
         */
        if (response.getStatusCode() == 200) {
            return request.handleSuccess(response.getBody());
        } else {
            return handleError();
        }
    }

    private DuoAPI.Error handleError() {
        return (DuoAPI.Error) JSON.deserialize(response.getBody(), DuoAPI.Error.class);
    }
}
