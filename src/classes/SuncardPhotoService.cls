/*
 * Borrowed from surjikal (c) 2014
 * Github Gist 7539745
 * @author meruff
 */

public without sharing class SuncardPhotoService {
    private static String baseURLString;
    private static String finalSig;

    public static String getSunCardPhotoURL(String asurite, String emplId) {
        HttpRequest req = new HttpRequest();

        List<Suncard_Photo__c> sunList = [SELECT Name, URL__c, Consumer_Key__c, Secret_Key__c FROM Suncard_Photo__c];

        String photoUrl;
        String consumerKey;
        String secretKey;

        for (Suncard_Photo__c sun : sunList) {
            photoUrl = sun.URL__c;
            consumerKey = sun.Consumer_Key__c;
            secretKey = sun.Secret_Key__c;
        }

        req.setEndpoint(photoUrl);
        req.setMethod('GET');

        Map<String, String> extraParams = new Map<String, String>();
        extraParams.put('asurite', asurite);
        extraParams.put('affiliate', emplId);

        Http h = new Http();

        HttpRequest reqToSend = signRequest(req, consumerKey, secretKey, extraParams);
        HttpResponse res = h.send(reqToSend);

        String suncardPhotoURL = baseURLString + '&' + finalSig;

        return suncardPhotoURL;
    }

    public static HttpRequest signRequest(
        HttpRequest req,
        String consumerKey,
        String consumerSecret,
        Map<String, String> customParams
    ) {
        String nonce = String.valueOf(Crypto.getRandomLong());
        String timestamp = String.valueOf(DateTime.now().getTime() / 1000);

        Map<String, String> params = new Map<String, String>();
        params.put('oauth_signature_method', 'HMAC-SHA1');
        params.put('oauth_consumer_key', consumerKey);
        params.put('oauth_timestamp', timestamp);
        params.put('oauth_nonce', nonce);

        if (customParams.size() > 0) {
            for (String key : customParams.keySet()) {
                params.put(key, customParams.get(key));
            }
        }

        String signature = generateSignature(req, consumerSecret, params);
        String header = generateHeader(signature, params);
        req.setHeader('Authorization', header);

        return req;
    }

    private static String generateHeader(String signature, Map<String, String> parameters) {
        String header = 'OAuth ';

        for (String key : parameters.keySet()) {
            header = header + key + '="' + parameters.get(key) + '", ';
        }

        finalSig = 'oauth_signature=' + signature;

        return header + 'oauth_signature="' + signature + '"';
    }

    private static String generateSignature(HttpRequest req, String consumerSecret, Map<String, String> parameters) {
        String s = createBaseString(req, parameters);

        Blob sig = Crypto.generateMac('HmacSHA1', Blob.valueOf(s), Blob.valueOf(consumerSecret + '&'));

        return EncodingUtil.URLEncode(EncodingUtil.base64encode(sig), 'UTF-8');
    }

    private static String createBaseString(HttpRequest req, Map<String, String> parameters) {
        Map<String, String> p = parameters.clone();

        if (
            req.getMethod().equalsIgnoreCase('post') &&
            req.getBody() != null &&
            req.getHeader('Content-Type') == 'application/x-www-form-URLEncoded'
        ) {
            p.putAll(getURLParams(req.getBody()));
        }

        String host = req.getEndpoint();
        Integer n = host.indexOf('?');

        if (n > -1) {
            p.putAll(getURLParams(host.substring(n + 1)));
            host = host.substring(0, n);
        }

        List<String> keys = new List<String>();
        keys.addAll(p.keySet());
        keys.sort();
        String s = keys.get(0) + '=' + p.get(keys.get(0));

        for (Integer i = 1; i < keys.size(); i++) {
            s = s + '&' + keys.get(i) + '=' + p.get(keys.get(i));
        }

        baseURLString = host + '?' + s;

        return req.getMethod().toUpperCase() +
            '&' +
            EncodingUtil.URLEncode(host, 'UTF-8') +
            '&' +
            EncodingUtil.URLEncode(s, 'UTF-8');
    }

    private static Map<String, String> getURLParams(String value) {
        Map<String, String> res = new Map<String, String>();

        if (value == null || value == '') {
            return res;
        }

        for (String s : value.split('&')) {
            List<String> kv = s.split('=');

            if (kv.size() > 1) {
                res.put(kv[0], kv[1]);
            }
        }

        return res;
    }
}
