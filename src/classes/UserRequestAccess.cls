global class UserRequestAccess
{
    @InvocableMethod
    public static void callMuleSoft()
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://esb-dev.asu.edu/bbcourses');
        req.setMethod('GET');

        String username = 'sfdc_bb_check';
        String password = 'ze#|emFKGnMA@7';

        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
    }
}