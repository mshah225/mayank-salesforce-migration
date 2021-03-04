public class HTTPRestService_MarketingCloud {
    private McAuthResult authResult = new McAuthResult();
    public static JSONParser parser;

    /*
     * Sample payload for queueMO mobile opt-in with Salesforce Contact ID Subscriber Key
     * {"subscribers":[{"subscriberkey":"003d000003J6FNEAA3","mobilenumber":"14807663728"}],"shortCode":"61086","messageText":"FRESHMAN"}
     */
    public String queueMO(
        String subscriberKeyParm,
        String mobilenumberParm,
        String shortCodeParm,
        String messageTextParm
    ) {
        QueueMoDetail qmd = new QueueMoDetail(subscriberKeyParm, mobilenumberParm, shortCodeParm, messageTextParm);
        if (!getAuthorization()) {
            return '';
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Marketing_Cloud/queueMO/');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + authResult.accessToken);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(qmd));
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res.getBody();
    }

    /**
     * Method to call MC REST API's non-standard authorization method
     */
    private Boolean getAuthorization() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Marketing_Cloud/requestToken');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"clientId":"{!$Credential.Username}","clientSecret":"{!$Credential.Password}"}');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            authResult = (McAuthResult) JSON.deserialize(res.getBody(), McAuthResult.class);
            return true;
        }
        return false;
    }

    /**
     * Inner classes used for JSON interaction
     */
    public class SubscriberDetail {
        public String subscriberkey { get; set; }
        public String mobilenumber { get; set; }
    }

    public class QueueMoDetail {
        public List<SubscriberDetail> subscribers { get; set; }
        public String shortCode { get; set; }
        public String messageText { get; set; }

        public QueueMoDetail(
            String subscriberKeyParm,
            String mobilenumberParm,
            String shortCodeParm,
            String messageTextParm
        ) {
            SubscriberDetail sd = new SubscriberDetail();
            sd.subscriberkey = subscriberKeyParm;
            sd.mobilenumber = mobilenumberParm;

            subscribers = new List<SubscriberDetail>{ sd };
            shortCode = shortCodeParm;
            messageText = messageTextParm;
        }
    }

    public class McAuthResult {
        public String accessToken { get; set; }
        public Integer expiresIn { get; set; }
    }
}
