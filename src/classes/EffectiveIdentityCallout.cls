public class EffectiveIdentityCallout {
    private static final String SECRET_KEY = '543d32e1eer10c3360X0916b16d4098q9ebc93d4';
    private static final String GET_EFFECTIVE_IDENTITY_SERVICE_NAME = 'getEffIdent';

    public static Map<String, String> getCalloutResponseContents(String idCookie, String asurite) {
        String requestUrl = createRequestUrl(idCookie, asurite);
        String xmlResponse = makeCallout(requestUrl);
        return createMapForHttpResponse(xmlResponse);
    }

    private static String createRequestUrl(String idCookie, String asurite) {
        String myAsuUrl = View_As_Url__c.getInstance('URL').MyAsuUrl__c;
        String signatureTime = String.valueOf(System.currentTimeMillis() / 1000);
        String scopeIdCookie = idCookie;
        if (scopeIdCookie == null) {
            scopeIdCookie = '';
        }

        String signature = createRequestSignature(scopeIdCookie, asurite, signatureTime);

        String requestUrl = myAsuUrl;
        requestUrl += '/ws/' + GET_EFFECTIVE_IDENTITY_SERVICE_NAME;
        requestUrl += '?appid=salesforce_app';
        requestUrl += '&signaturetime=' + signatureTime;
        requestUrl += '&real-asurite=' + EncodingUtil.urlEncode(asurite, 'UTF-8');
        requestUrl += '&scopeid-cookie=' + EncodingUtil.urlEncode(scopeIdCookie, 'UTF-8');
        requestUrl += '&signature=' + EncodingUtil.urlEncode(signature, 'UTF-8');

        return requestUrl;
    }

    private static String createRequestSignature(String scopeIdCookie, String asurite, String signatureTime) {
        String stringToSign = 'service=' + GET_EFFECTIVE_IDENTITY_SERVICE_NAME;
        stringToSign += '&appid=salesforce_app';
        stringToSign += '&signaturetime=' + signatureTime;
        stringToSign += '&real-asurite=' + asurite;
        stringToSign += '&scopeid-cookie=' + scopeIdCookie;

        Blob sigBlob = Crypto.generateMac('hmacSHA256', Blob.valueOf(stringToSign), Blob.valueOf(SECRET_KEY));
        return EncodingUtil.convertToHex(sigBlob);
    }

    private static String makeCallout(String requestUrl) {
        Http httpObject = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestUrl);
        request.setMethod('GET');
        HttpResponse response = httpObject.send(request);
        return response.getBody();
    }

    private static Map<String, String> createMapForHttpResponse(String xmlResponse) {
        Dom.Document doc = new Dom.Document();
        doc.load(xmlResponse);
        Dom.XMLNode response = doc.getRootElement();

        Map<String, String> viewAsValues = new Map<String, String>();
        viewAsValues.put('authorizedToViewAs', response.getChildElement('authorizedToViewAs', null).getText());
        viewAsValues.put('isViewingAs', response.getChildElement('isViewingAs', null).getText());
        viewAsValues.put('effectiveAsurite', response.getChildElement('effectiveAsurite', null).getText());
        viewAsValues.put('signoutUrl', response.getChildElement('signoutUrl', null).getText());
        viewAsValues.put('viewAsUrl', response.getChildElement('viewAsUrl', null).getText());
        viewAsValues.put('stopViewAsUrl', response.getChildElement('stopViewAsUrl', null).getText());

        return viewAsValues;
    }
}
