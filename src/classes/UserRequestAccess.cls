global class UserRequestAccess
{
    @InvocableMethod
    public static void callMuleSoft()
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://mulesoftdev01.asu.edu/bbcourses');
        req.setMethod('POST');

        String username = 'sfdc_bb_check';
        String password = 'ze#|emFKGnMA@7';

        Blob headerValue = Blob.valueOf(username + ':' + password);

        String authorizationHeader =
            EncodingUtil.urlEncode('Basic', 'UTF-8') + ' ' +
            EncodingUtil.base64Encode(headerValue);

        req.setHeader('Authorization', authorizationHeader);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
    }
}