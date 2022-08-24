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
            '    "empl_id": "1221449333",' +
            '    "checklist_items": [' +
            '        {' +
            '            "seq_3c": 29,' +
            '            "checklist_cd": "FTNOTI",' +
            '            "status": "Initiated",' +
            '            "status_code": "I",' +
            '            "checklist_seq": 100,' +
            '            "checklistitemcd": "FEXDLW",' +
            '            "item_status": "Initiated",' +
            '            "item_status_code": "I",' +
            '            "due_dt": "08/19/2021",' +
            '            "status_dt": "06/02/2022",' +
            '            "asu_fa_status_rsn": null,' +
            '            "strm_code": "2221",' +
            '            "term": "2022 Spring",' +
            '            "description": "Direct Loan Exit Counseling(2021 - 2022)",' +
            '            "institution": "ASU00",' +
            '            "aid_year": "2022",' +
            '            "admin_function": "FINT"' +
            '        }' +
            '    ]' +
            '}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
}