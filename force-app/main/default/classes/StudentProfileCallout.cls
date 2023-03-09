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

    global static FinancialAidChargeHistoryWrapper getChargeHistory(String emplid) {
        FinancialAidChargeHistoryWrapper chargeHistoryForStudent;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Student_Finances/students/' + emplid + '/account/charges');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            chargeHistoryForStudent = FinancialAidChargeHistoryWrapper.parse(responseBody);
        }

        return chargeHistoryForStudent;
    }

    global static FinancialAidBalanceWrapper getAccountBalance(String emplid) {
        FinancialAidBalanceWrapper accountBalanceForStudent;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Student_Finances/students/' + emplid + '/account/balance');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            accountBalanceForStudent = FinancialAidBalanceWrapper.parse(responseBody);
        }

        return accountBalanceForStudent;
    }

    global static FinancialAidRefundWrapper getRefunds(String emplid) {
        FinancialAidRefundWrapper refundsForStudent;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Student_Finances/students/' + emplid + '/account/recent-refunds');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            refundsForStudent = FinancialAidRefundWrapper.parse(responseBody);
        }

        return refundsForStudent;
    }

    global static DepositStatusWrapper getDepositStatus(String emplid) {
        DepositStatusWrapper depositsForStudent;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Student_Finances/students/' + emplid + '/account/deposit-status');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            depositsForStudent = DepositStatusWrapper.parse(responseBody);
        }

        return depositsForStudent;
    }

    global static RenewableAidWrapper getRenewableAid(String emplid) {
        RenewableAidWrapper renewableAidForStudent;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Financial_Aid/students/' + emplid + '/renewable-aid');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            renewableAidForStudent = RenewableAidWrapper.parse(responseBody);
        }

        return renewableAidForStudent;
    }

    global static BookPaymentWrapper getBookPayments(String emplid) {
        BookPaymentWrapper bookPaymentsForStudent;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Financial_Aid/students/' + emplid + '/ebpo');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            bookPaymentsForStudent = BookPaymentWrapper.parse(responseBody);
        }

        return bookPaymentsForStudent;
    }

    global static TuitionResidencyWrapper getTuitionResidencyStatus(String emplid) {
        TuitionResidencyWrapper tuitionResidencyForStudent;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Financial_Aid/students/' + emplid + '/tuition-residency');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            tuitionResidencyForStudent = TuitionResidencyWrapper.parse(responseBody);
        }

        return tuitionResidencyForStudent;
    }

    global static SAPWrapper getAcademicProgress(String emplid) {
        SAPWrapper academicProgressForStudent;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Financial_Aid/students/' + emplid + '/sap');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            academicProgressForStudent = SAPWrapper.parse(responseBody);
        }

        return academicProgressForStudent;
    }
}