public with sharing class StudentProfileCalloutService {
    public StudentProfileCalloutService() {

    }

    public static Map<String, List<ServiceIndicatorWrapper.ServiceIndicators>> getServiceIndicators(String emplid) {
        ServiceIndicatorWrapper dataWrapper;
        Map<String, List<ServiceIndicatorWrapper.ServiceIndicators>> serviceIndicatorMap = new Map<String, List<ServiceIndicatorWrapper.ServiceIndicators>>();

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

        
        List<ServiceIndicatorWrapper.ServiceIndicators> wildCardTermIndicators = new List<ServiceIndicatorWrapper.ServiceIndicators>();

        for (ServiceIndicatorWrapper.ServiceIndicators siw : dataWrapper.ServiceIndicators) {
            for (ServiceIndicatorWrapper.ServiceIndicators.ServiceImpacts impact : siw.ServiceImpacts) {
                if (impact.ServiceImpactCode.contains('SF') || impact.ServiceImpactCode.contains('B')) {
                    String term = siw.ServiceIndicatorActiveTerm;
                    if (term == '0000') {
                        wildCardTermIndicators.add(siw);
                    } else {
                        if (serviceIndicatorMap.get(term) == null) {
                            List<ServiceIndicatorWrapper.ServiceIndicators> serviceIndicatorList = new List<ServiceIndicatorWrapper.ServiceIndicators>();
                            serviceIndicatorList.add(siw);
                            serviceIndicatorMap.put(term, serviceIndicatorList);
                        } else {
                            List<ServiceIndicatorWrapper.ServiceIndicators> serviceIndicatorList = serviceIndicatorMap.get(term);
                            serviceIndicatorList.add(siw);
                            serviceIndicatorMap.put(term, serviceIndicatorList);
                        }
                    }                
                }
                break;
            }            
        }

        for (String serviceTerm : serviceIndicatorMap.keySet()) {
            serviceIndicatorMap.get(serviceTerm).addAll(wildCardTermIndicators);
            serviceIndicatorMap.get(serviceTerm).sort();
        }

        System.debug(dataWrapper);
        return serviceIndicatorMap;
    }
}
