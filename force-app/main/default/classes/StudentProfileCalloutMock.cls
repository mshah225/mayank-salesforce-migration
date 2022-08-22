@isTest
global class StudentProfileCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        if (req.getMethod().equals('/service-indicator/serviceindicators')) {
            return getServiceIndicators();
        } else if (req.getEndpoint().contains('/cs_checklist/fin')) {
            return getFinancialAidChecklists();
        }
        return null;
    }

    private HTTPResponse getServiceIndicators() {
        HttpResponse res = new HttpResponse();
        String json =
            '{' +
            '    \"Emplid\": \"1206104779\",' +
            '    \"ServiceIndicators\": [' +
            '        {' +
            '            \"Institution\": \"ASU00\",' +
            '            \"ServiceIndicatorCode\": \"A15\",' +
            '            \"ServiceIndicatorReason\": \"COMPL\",' +
            '            \"ServiceIndicatorActiveTerm\": \"2201\",' +
            '            \"ServiceIndicatorActiveDate\": \"01/01/2020\",' +
            '            \"ServiceIndicatorEndTerm\": null,' +
            '            \"ServiceIndicatorEndDate\": null,' +
            '            \"PositiveServiceIndicator\": \"Y\",' +
            '            \"Comments\": null,' +
            '            \"ServiceIndicatorDateTime\": \"09/16/2015 02:15:31 AM\",' +
            '            \"ServiceIndicatorCodeDescr\": \"File Complete\",' +
            '            \"DisplayInSS\": \"N\",' +
            '            \"ServiceIndReasonCodeDescr\": \"File is complete\",' +
            '            \"ServiceIndReasonCodeDescrLong\": null,' +
            '            \"ServiceImpacts\": [' +
            '                {' +
            '                    \"ServiceImpactCode\": \"INFOR\",' +
            '                    \"ServiceImpactDescription\": null' +
            '                }' +
            '            ]' +
            '        }' +
            '    ]' +
            '}';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getFinancialAidChecklists() {
        HttpResponse res = new HttpResponse();
        String json =
            '{' +
            '    \"empl_id\": \"1221449333\",' +
            '    \"checklist_items\": [' +
            '        {' +
            '            \"seq_3c\": 29,' +
            '            \"checklist_cd\": \"FTNOTI\",' +
            '            \"status\": \"Initiated\",' +
            '            \"status_code\": \"I\",' +
            '            \"checklist_seq\": 100,' +
            '            \"checklistitemcd\": \"FEXDLW\",' +
            '            \"item_status\": \"Initiated\",' +
            '            \"item_status_code\": \"I\",' +
            '            \"due_dt\": \"2021-08-19T00:00:00\",' +
            '            \"status_dt\": \"2022-06-02T00:00:00\",' +
            '            \"initialize_dt\": null,' +
            '            \"asu_fa_status_rsn\": null,' +
            '            \"strm\": \"2221\",' +
            '            \"descrption\": \"Direct Loan Exit Counseling(2021 - 2022)\",' +
            '            \"institution\": \"ASU00\",' +
            '            \"aid_year\": \"2022\",' +
            '            \"admin_function\": \"FINT\"' +
            '        },' +
            '        {' +
            '            \"seq_3c\": 28,' +
            '            \"checklist_cd\": \"FTNOTI\",' +
            '            \"status\": \"Initiated\",' +
            '            \"status_code\": \"I\",' +
            '            \"checklist_seq\": 100,' +
            '            \"checklistitemcd\": \"FEXDLW\",' +
            '            \"item_status\": \"Initiated\",' +
            '            \"item_status_code\": \"I\",' +
            '            \"due_dt\": \"2021-08-19T00:00:00\",' +
            '            \"status_dt\": \"2022-06-02T00:00:00\",' +
            '            \"initialize_dt\": null,' +
            '            \"asu_fa_status_rsn\": null,' +
            '            \"strm\": \"2217\",' +
            '            \"descrption\": \"Direct Loan Exit Counseling(2021 - 2022)\",' +
            '            \"institution\": \"ASU00\",' +
            '            \"aid_year\": \"2022\",' +
            '            \"admin_function\": \"FINT\"' +
            '        },' +
            '        {' +
            '            \"seq_3c\": 27,' +
            '            \"checklist_cd\": \"FNOTIF\",' +
            '            \"status\": \"Completed\",' +
            '            \"status_code\": \"C\",' +
            '            \"checklist_seq\": 200,' +
            '            \"checklistitemcd\": \"FSAPR2\",' +
            '            \"item_status\": \"Completed\",' +
            '            \"item_status_code\": \"C\",' +
            '            \"due_dt\": \"2022-05-13T00:00:00\",' +
            '            \"status_dt\": \"2022-05-13T00:00:00\",' +
            '            \"initialize_dt\": \"2022-05-23T00:00:00\",' +
            '            \"asu_fa_status_rsn\": \" \",' +
            '            \"strm\": null,' +
            '            \"descrption\": \"Submit SAP Review PC(All Aid Years)\",' +
            '            \"institution\": null,' +
            '            \"aid_year\": \"9999\",' +
            '            \"admin_function\": \"FINA\"' +
            '        },' +
            '        {' +
            '            \"seq_3c\": 26,' +
            '            \"checklist_cd\": \"FTNOTI\",' +
            '            \"status\": \"Completed\",' +
            '            \"status_code\": \"C\",' +
            '            \"checklist_seq\": 100,' +
            '            \"checklistitemcd\": \"FEXDLW\",' +
            '            \"item_status\": \"Completed\",' +
            '            \"item_status_code\": \"C\",' +
            '            \"due_dt\": \"2021-08-19T00:00:00\",' +
            '            \"status_dt\": \"2022-04-08T00:00:00\",' +
            '            \"initialize_dt\": null,' +
            '            \"asu_fa_status_rsn\": null,' +
            '            \"strm\": \"2221\",' +
            '            \"descrption\": \"Direct Loan Exit Counseling(2021 - 2022)\",' +
            '            \"institution\": \"ASU00\",' +
            '            \"aid_year\": \"2022\",' +
            '            \"admin_function\": \"FINT\"' +
            '        },' +
            '        {' +
            '            \"seq_3c\": 24,' +
            '            \"checklist_cd\": \"FPKGEX\",' +
            '            \"status\": \"Completed\",' +
            '            \"status_code\": \"C\",' +
            '            \"checklist_seq\": 200,' +
            '            \"checklistitemcd\": \"FISEPV\",' +
            '            \"item_status\": \"Completed\",' +
            '            \"item_status_code\": \"C\",' +
            '            \"due_dt\": \"2021-12-29T00:00:00\",' +
            '            \"status_dt\": \"2022-03-31T00:00:00\",' +
            '            \"initialize_dt\": \"2022-04-01T00:00:00\",' +
            '            \"asu_fa_status_rsn\": \" \",' +
            '            \"strm\": null,' +
            '            \"descrption\": \"ID/Educational Purpose Verif.(2022 - 2023)\",' +
            '            \"institution\": null,' +
            '            \"aid_year\": \"2023\",' +
            '            \"admin_function\": \"FINA\"' +
            '        },' +
            '        {' +
            '            \"seq_3c\": 26,' +
            '            \"checklist_cd\": \"FTNOTI\",' +
            '            \"status\": \"Completed\",' +
            '            \"status_code\": \"C\",' +
            '            \"checklist_seq\": 200,' +
            '            \"checklistitemcd\": \"FR2T4\",' +
            '            \"item_status\": \"Completed\",' +
            '            \"item_status_code\": \"C\",' +
            '            \"due_dt\": \"2022-01-10T00:00:00\",' +
            '            \"status_dt\": \"2022-03-02T00:00:00\",' +
            '            \"initialize_dt\": \"2022-03-10T00:00:00\",' +
            '            \"asu_fa_status_rsn\": \" \",' +
            '            \"strm\": \"2221\",' +
            '            \"descrption\": \"Confirm Enroll - Aid Bill Back(2021 - 2022)\",' +
            '            \"institution\": \"ASU00\",' +
            '            \"aid_year\": \"2022\",' +
            '            \"admin_function\": \"FINT\"' +
            '        },' +
            '        {' +
            '            \"seq_3c\": 25,' +
            '            \"checklist_cd\": \"FNOTIF\",' +
            '            \"status\": \"Completed\",' +
            '            \"status_code\": \"C\",' +
            '            \"checklist_seq\": 100,' +
            '            \"checklistitemcd\": \"FEXDLW\",' +
            '            \"item_status\": \"Waived\",' +
            '            \"item_status_code\": \"W\",' +
            '            \"due_dt\": \"2021-08-19T00:00:00\",' +
            '            \"status_dt\": \"2022-02-04T00:00:00\",' +
            '            \"initialize_dt\": null,' +
            '            \"asu_fa_status_rsn\": null,' +
            '            \"strm\": \"2221\",' +
            '            \"descrption\": \"Direct Loan Exit Counseling(2021 - 2022)\",' +
            '            \"institution\": \"ASU00\",' +
            '            \"aid_year\": \"2022\",' +
            '            \"admin_function\": \"FINT\"' +
            '        },' +
            '    ]' +
            '}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
}