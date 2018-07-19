public without sharing class MyAsuViewAs {
    private final String SECRET_KEY = '543d32e1eer10c3360X0916b16d4098q9ebc93d4';
    private final String GET_EFFECTIVE_IDENTITY_SERVICE_NAME = 'getEffIdent';
    private Map<String, String> response;
    public Boolean hasViewAsRights;

    public MyASUViewAs(String idCookie, String asurite) {
        response = getCalloutResponseContents(idCookie, asurite);
        checkViewAsRights(response, asurite);
    }
    
    public String getResponseValueFromMap(String specificResponse) {
        return String.valueOf(response.get(specificResponse));
    }
    
    private Map<String, String> getCalloutResponseContents(String idCookie, String asurite) {
        String requestUrl = createRequestUrl(idCookie, asurite);
        String xmlResponse = makeCallout(requestUrl);
        return createMapForHttpResponse(xmlResponse);
    }
    
    private String createRequestUrl(String idCookie, String asurite) {
        String myAsuUrl = [SELECT MyAsuUrl__c FROM View_As_Url__c WHERE Name = 'URL' LIMIT 1].MyAsuUrl__c;

        String scopeIdCookie = idCookie;
        if (scopeIdCookie == null) {
            scopeIdCookie = '';
        }

        String signatureTime = String.valueOf(System.currentTimeMillis()/1000);
        String stringToSign = 'service=' + GET_EFFECTIVE_IDENTITY_SERVICE_NAME;
        stringToSign += '&appid=salesforce_app';
        stringToSign += '&signaturetime=' + signatureTime;
        stringToSign += '&real-asurite=' + asurite;
        stringToSign += '&scopeid-cookie=' + scopeIdCookie;

        Blob sigBlob = Crypto.generateMac('hmacSHA256', Blob.valueOf(stringToSign), Blob.valueOf(SECRET_KEY));
        String signature = EncodingUtil.convertToHex(sigBlob);

        String requestUrl = myAsuUrl;
        requestUrl += '/ws/' + GET_EFFECTIVE_IDENTITY_SERVICE_NAME;
        requestUrl += '?appid=salesforce_app';
        requestUrl += '&signaturetime=' + signatureTime;
        requestUrl += '&real-asurite=' + EncodingUtil.urlEncode(asurite, 'UTF-8');
        requestUrl += '&scopeid-cookie=' + EncodingUtil.urlEncode(scopeIdCookie, 'UTF-8');
        requestUrl += '&signature=' + EncodingUtil.urlEncode(signature, 'UTF-8');
        
        return requestUrl;
    } 
    
    private String makeCallout(String requestUrl) {
        Http httpObject = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestUrl);
        request.setMethod('GET');
        HttpResponse response = httpObject.send(request);
        return response.getBody();
    }
    
    private Map<String, String> createMapForHttpResponse(String xmlResponse) {
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
    
    private void checkViewAsRights(Map<String, String> viewAsMap, String userAsurite) {
        hasViewAsRights = !viewAsMap.isEmpty()
                && viewAsMap.get('authorizedToViewAs') == 'true'
                && viewAsMap.get('isViewingAs') == 'true'
                && userAsurite != viewAsMap.get('effectiveAsurite');
    }
    
    public Contact getContact(String asurite) {
        if (hasViewAsRights) {
            return MyAsuViewAsWithoutSharing.getContact(asurite);
        } else {
            return MyAsuViewAsWithSharing.getContact(asurite);
        }
    }

    public Case getCaseDetails(Id caseId) {
        if (hasViewAsRights) {
            return MyAsuViewAsWithoutSharing.getCaseDetails(caseId);
        } else {
            return MyAsuViewAsWithSharing.getCaseDetails(caseId);
        }
    }
    
    public Map<Id, List<Case>> getOpenCases(List<Contact> contacts) {
        if (hasViewAsRights) {
            return MyAsuViewAsWithoutSharing.getOpenCases(contacts);
        } else {
            return MyAsuViewAsWithSharing.getOpenCases(contacts);
        }
    }

    public Map<Id, List<Case>> getClosedCases(List<Contact> contacts) {
        if (hasViewAsRights) {
            return MyAsuViewAsWithoutSharing.getClosedCases(contacts);
        } else {
            return MyAsuViewAsWithSharing.getClosedCases(contacts);
        }
    }

    public List<EmailMessage> getCaseEmails(Date launchDate, Id caseId, List<String> contactEmails) {
        if (hasViewAsRights) {
            return MyAsuViewAsWithoutSharing.getCaseEmails(launchDate, caseId, contactEmails);
        } else {
            return MyAsuViewAsWithSharing.getCaseEmails(launchDate, caseId, contactEmails);
        }
    }
        
    private with sharing class MyAsuViewAsWithSharing extends MyAsuViewAsSharingService{}
    
    private without sharing class MyAsuViewAsWithoutSharing extends MyAsuViewAsSharingService{}
}