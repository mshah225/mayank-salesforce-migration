global class UserRequestAccess
{
    @InvocableMethod
    global static List<String> callMuleSoft()
    {
        MuleSoft_BB_Courses__c mule = MuleSoft_BB_Courses__c.getValues('MuleSoft Dev');

        if (mule != null)
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(mule.URL__c);
            req.setMethod('POST');

            Blob headerValue = Blob.valueOf(mule.Username__c + ':' + mule.Password__c);

            String authorizationHeader =
                EncodingUtil.urlEncode('Basic', 'UTF-8') + ' ' +
                    EncodingUtil.base64Encode(headerValue);

            req.setHeader('Authorization', authorizationHeader);

            Http http = new Http();
            HttpResponse res = http.send(req);

            List<String> strList = new List<String>();

            strList.add(res.getBody());

            return strList;
        }

        return null;
    }
}