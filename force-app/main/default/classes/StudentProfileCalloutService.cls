public with sharing class StudentProfileCalloutService {
    public StudentProfileCalloutService() {

    }

    public static String getServiceIndicators(String emplid) {
        ServiceIndicatorWrapper dataWrapper;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Service_Indicator/serviceindicators?emplid=' + emplid);
        req.setHeader('x-asu-ps-app-id', 'ASU_SF_STDNT_PROFILE_NP'); // Prod will be ASU_SF_STDNT_PROFILE (handle this in a setting?)
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        if (responseBody != null) {
           responseBody = responseBody.replace('Service indicators', 'ServiceIndicators'); 
           System.debug(responseBody);
           dataWrapper =  ServiceIndicatorWrapper.parse(responseBody);
        }

        System.debug(dataWrapper);
        return null;
    }
}
