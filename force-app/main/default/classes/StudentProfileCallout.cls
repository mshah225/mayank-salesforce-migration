public with sharing class StudentProfileCallout {
    public static List<ServiceIndicatorWrapper.ServiceIndicators> getServiceIndicators(String emplid) {
        ServiceIndicatorWrapper dataWrapper;
        List<ServiceIndicatorWrapper.ServiceIndicators> serviceIndicatorsForStudent = new List<ServiceIndicatorWrapper.ServiceIndicators>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Service_Indicator/serviceindicators?emplid=' + emplid);
        req.setHeader('x-asu-ps-app-id', 'ASU_SF_STDNT_PROFILE');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            dataWrapper = ServiceIndicatorWrapper.parse(responseBody);
        }

        if (dataWrapper.ServiceIndicators == null) {
            return serviceIndicatorsForStudent;
        }

        for (ServiceIndicatorWrapper.ServiceIndicators siw : dataWrapper.ServiceIndicators) {
            serviceIndicatorsForStudent.add(siw);
        }

        serviceIndicatorsForStudent.sort();

        return serviceIndicatorsForStudent;
    }
}