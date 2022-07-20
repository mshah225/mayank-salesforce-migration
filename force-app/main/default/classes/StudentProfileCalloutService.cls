public with sharing class StudentProfileCalloutService {
    public StudentProfileCalloutService() {

    }

    public static Map<String, List<ServiceIndicatorWrapper.ServiceIndicators>> getServiceIndicators(String emplid) {
        ServiceIndicatorWrapper dataWrapper;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Service_Indicator/serviceindicators?emplid=' + emplid);
        req.setHeader('x-asu-ps-app-id', 'ASU_SF_STDNT_PROFILE_NP'); // Prod will be ASU_SF_STDNT_PROFILE (handle this in a setting?)
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        
        if (responseBody != null) {
           dataWrapper =  ServiceIndicatorWrapper.parse(responseBody);
        }

        if (dataWrapper.ServiceIndicators == null) {
            return null;
        }

        
        List<ServiceIndicatorWrapper.ServiceIndicators> serviceIndicatorsForStudent = new List<ServiceIndicatorWrapper.ServiceIndicators>();

        for (ServiceIndicatorWrapper.ServiceIndicators siw : dataWrapper.ServiceIndicators) {
            serviceIndicatorsForStudent.add(siw);
        }

        serviceIndicatorsForStudent.sort();

        return serviceIndicatorsForStudent;
    }
}
