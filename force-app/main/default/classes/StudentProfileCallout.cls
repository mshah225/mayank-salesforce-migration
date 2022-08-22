public with sharing class StudentProfileCallout {
    public static List<ServiceIndicatorWrapper.ServiceIndicators> getServiceIndicators(String emplid) {
        ServiceIndicatorWrapper indicatorWrapper;
        List<ServiceIndicatorWrapper.ServiceIndicators> serviceIndicatorsForStudent = new List<ServiceIndicatorWrapper.ServiceIndicators>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Service_Indicator/serviceindicators?emplid=' + emplid);
        req.setHeader('x-asu-ps-app-id', 'ASU_SF_STDNT_PROFILE');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            indicatorWrapper = ServiceIndicatorWrapper.parse(responseBody);
        }

        for (ServiceIndicatorWrapper.ServiceIndicators siw : indicatorWrapper.ServiceIndicators) {
            serviceIndicatorsForStudent.add(siw);
        }

        if (indicatorWrapper.ServiceIndicators != null) {
            serviceIndicatorsForStudent = serviceIndicatorsForStudent.sort();
        }

        return serviceIndicatorsForStudent;
    }

    public static List<FinancialAidChecklistWrapper.FinancialAidChecklists> getFinancialAidChecklists(String emplid) {
        FinancialAidChecklistWrapper checklistWrapper;
        List<FinancialAidChecklistWrapper.FinancialAidChecklists> checklists = new List<FinancialAidChecklistWrapper.FinancialAidChecklists>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Student_Checklists/fin?emplid=' + emplid);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            checklistWrapper = FinancialAidChecklistWrapper.parse(responseBody);
        }

        for (FinancialAidChecklistWrapper.FinancialAidChecklists checklist : checklistWrapper.FinancialAidChecklists) {
            checklists.add(checklist);
        }

        return checklists;
    }
}