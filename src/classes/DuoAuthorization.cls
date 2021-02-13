public with sharing class DuoAuthorization {
    private String dateOfRequest;
    private String timezone;
    private String host;
    private String path;
    private String method;
    private String params;
    private String integrationKey;
    private String secret;

    /**
     * Creates the Authentication header that is required for all DuoAPI
     * requests.
     *
     * See documentation at https://duo.com/docs/authapi#-authentication- for
     * full description on requirements.
     *
     * @param configuration the DuoConfig metadata record that should be used
     * for generating Authentication headers
     */
    public DuoAuthorization(DuoConfig__mdt configuration) {
        this.host = configuration.Hostname__c;
        this.timezone = configuration.Timezone__c;
        this.integrationKey = configuration.Key__c;
        this.secret = configuration.Secret__c;
    }

    /**
     * Sets the path of the endpoint of the API that is to be invoked
     *
     * @param path the path of the endpoint (e.g. "/auth/v2/auth")
     *
     * @return the current DuoAuthorization instance
     */
    public DuoAuthorization setPath(String path) {
        this.path = path;
        return this;
    }

    /**
     * Sets the REST Method that for the endpoint of the API that is to be
     * invoked
     *
     * @param method the REST Method to be invoked
     *
     * @return the current DuoAuthorization instance
     */
    public DuoAuthorization setMethod(String method) {
        this.method = method;
        return this;
    }

    /**
     * Sets the parameters
     *
     * @param params
     *
     * @return
     */
    public DuoAuthorization setParams(Map<String, Object> params) {
        this.params = params != null && params.size() > 0 ? DuoUtil.urlEncodeParams(params) : '';
        return this;
    }

    public DuoAuthorization setDateOfRequest(Datetime dateOfRequest) {
        this.dateOfRequest = DuoUtil.formatAsRFC2822(dateOfRequest, timezone);
        return this;
    }

    public String getDateOfRequest() {
        return dateOfRequest;
    }

    /*
     * Returns the formatted and encrypted password required for Duo
     * Authentication
     */
    public String getAuthorization() {
        Blob hmacData = Crypto.generateMac('hmacSHA1', Blob.valueOf(generatePassword()), Blob.valueOf(secret));

        String password = EncodingUtil.convertToHex(hmacData);

        return 'BASIC ' + EncodingUtil.base64Encode(Blob.valueOf(integrationKey + ':' + password));
    }

    private String generatePassword() {
        String password = '';

        password += dateOfRequest + '\n';
        password += method + '\n';
        password += host + '\n';
        password += path + '\n';
        password += params;

        return password;
    }
}
