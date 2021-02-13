public with sharing class DuoAPI {
    private DuoConfig__mdt duoConfig;
    private String url;

    /**
     * Handles requests to the Duo API by loading all necessary configurations
     * and generating the authorization header.
     *
     */
    public DuoAPI() {
        duoConfig = [
            SELECT Hostname__c, Timezone__c, Key__c, Secret__c
            FROM DuoConfig__mdt
            WHERE IsActive__c = TRUE
            ORDER BY Priority__c ASC
            LIMIT 1
        ];

        url = 'https://' + duoConfig.Hostname__c;
    }

    /**
     * Sends a request to the DuoAPI from the provided DuoRequest implementation
     *
     * @param request a DuoRequest implementation that defines a Duo endpoint
     *
     * @return a DuoResponse that details the response from the DuoAPI
     */
    public DuoResponse send(DuoRequest request) {
        DuoAuthorization auth = new DuoAuthorization(duoConfig)
            .setDateOfRequest(System.now())
            .setMethod(methodToString(request.getMethod()))
            .setPath(request.getPath());

        HttpRequest api = new HttpRequest();
        api.setMethod(methodToString(request.getMethod()));
        switch on request.getMethod() {
            when POSTX {
                api.setEndpoint(url + request.getPath());
                api.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                api.setBody(JSON.serialize(request.getParams()));
            }
            when GETX, DELETEX {
                api.setEndpoint(url + request.getPath() + request.getParams());
                auth.setParams(request.getParams());
            }
            when else {
                //TODO: consider throwing some custom exception instead
                throw new NullPointerException();
            }
        }

        api.setHeader('Authorization', auth.getAuthorization());
        api.setHeader('Date', auth.getDateOfRequest());

        return new DuoResponse(new Http().send(api), request);
    }

    private static String methodToString(Method requestMethod) {
        String methodToString = '';

        switch on requestMethod {
            when GETX {
                methodToString = 'GET';
            }
            when POSTX {
                methodToString = 'POST';
            }
            when DELETEX {
                methodToString = 'DELETE';
            }
        }

        return methodToString;
    }

    /**
     * Enumerates various RESTful API methods that are supported by DUO's API
     */
    public enum Method {
        GETX,
        POSTX,
        DELETEX
    }

    /**
     * Defines an Error response from the Duo API
     */
    public class Error {
        public Integer code;
        public String message;
        public transient String message_detail;
    }
}
