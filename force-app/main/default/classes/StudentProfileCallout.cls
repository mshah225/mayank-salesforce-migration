global with sharing class StudentProfileCallout {
    global StudentProfileCallout() {
    }

    global static List<ServiceIndicatorWrapper.ServiceIndicator> getServiceIndicators(String emplid) {
        ServiceIndicatorWrapper dataWrapper;
        List<ServiceIndicatorWrapper.ServiceIndicator> serviceIndicatorsForStudent = new List<ServiceIndicatorWrapper.ServiceIndicator>();

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

        for (ServiceIndicatorWrapper.ServiceIndicator siw : dataWrapper.ServiceIndicators) {
            serviceIndicatorsForStudent.add(siw);
        }

        serviceIndicatorsForStudent.sort();

        return serviceIndicatorsForStudent;
    }

    global static List<FinancialAidChecklistWrapper.FinancialAidChecklist> getFinancialAidChecklists(String emplid) {
        FinancialAidChecklistWrapper checklistWrapper;
        List<FinancialAidChecklistWrapper.FinancialAidChecklist> checklists = new List<FinancialAidChecklistWrapper.FinancialAidChecklist>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Student_Checklists/fin?emplid=' + emplid);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            checklistWrapper = FinancialAidChecklistWrapper.parse(responseBody);
        }

        if (checklistWrapper == null || checklistWrapper.checklist_items == null) {
            return checklists;
        }

        for (FinancialAidChecklistWrapper.FinancialAidChecklist checklist : checklistWrapper.checklist_items) {
            checklists.add(checklist);
        }

        return checklists;
    }

    global static FinancialAidAwardWrapper getAwards(String emplid) {
        FinancialAidAwardWrapper awardsForStudent;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Financial_Aid/students/' + emplid + '/awards-status');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            awardsForStudent = FinancialAidAwardWrapper.parse(responseBody);
        }

        return awardsForStudent;
    }

    global static FinancialEditMessageWrapper getEditMessages(String emplid) {
        FinancialEditMessageWrapper messagesForStudent;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Financial_Aid/students/' + emplid + '/fa-messages?messagetype=E');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            messagesForStudent = FinancialEditMessageWrapper.parse(responseBody);
        }

        return messagesForStudent;
    }
}