@isTest
global class StudentProfileCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        if (req.getEndpoint().contains('/serviceindicators')) {
            return getServiceIndicators();
        } else if (req.getEndpoint().contains('Student_Checklists')) {
            return getFinancialAidChecklists();
        } else if (req.getEndPoint().contains('awards-status')) {
            return getFinancialAidAwardStatus();
        } else if (req.getEndPoint().contains('fa-messages')) {
            return getFinancialAidEditMessages();
        } else if (req.getEndPoint().contains('/account/charges')) {
            return getFinancialAidChargeHistory();
        } else if (req.getEndPoint().contains('/account/balance')) {
            return getFinancialAidAccountBalance();
        } else if (req.getEndPoint().contains('/account/refunds')) {
            return getFinancialAidRefunds();
        } else if (req.getEndPoint().contains('/account/deposit-status')) {
            return getDepositStatus();
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
            '            \"due_dt\": \"08/19/2021\",' +
            '            \"status_dt\": \"06/02/2022\",' +
            '            \"asu_fa_status_rsn\": null,' +
            '            \"strm_code\": \"2221\",' +
            '            \"term\": \"2022 Spring\",' +
            '            \"description\": \"Direct Loan Exit Counseling(2021 - 2022)\",' +
            '            \"institution\": \"ASU00\",' +
            '            \"aid_year\": \"2022\",' +
            '            \"admin_function\": \"FINT\"' +
            '        }' +
            '    ]' +
            '}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getFinancialAidAwardStatus() {
        HttpResponse res = new HttpResponse();
        String json=		'{'+
            '    "aid_years": ['+
            '        {'+
            '            "financial_year": "2013-2014",'+
            '            "term_awards": ['+
            '                {'+
            '                    "term_description": "2013 Fall",'+
            '                    "total_current_amount": 5000,'+
            '                    "total_accepted_amount": 5000,'+
            '                    "total_disbursed_amount": 5000,'+
            '                    "award_details": ['+
            '                        {'+
            '                            "award_name": "NAmU - President",'+
            '                            "current_offer": 4750,'+
            '                            "accept_balance": 4750,'+
            '                            "disbursed_balance": 4750,'+
            '                            "disbursement_status": "Applied to Account",'+
            '                            "category_description": "Scholarship",'+
            '                            "aid_year": "2014",'+
            '                            "item_type": "920303519344"'+
            '                        },'+
            '                        {'+
            '                            "award_name": "Combs HS Booster Club Coyotes",'+
            '                            "current_offer": 250,'+
            '                            "accept_balance": 250,'+
            '                            "disbursed_balance": 250,'+
            '                            "disbursement_status": "Applied to Account",'+
            '                            "category_description": "Scholarship",'+
            '                            "aid_year": "2014",'+
            '                            "item_type": "920705299992"'+
            '                        }'+
            '                    ]'+
            '                },'+
            '                {'+
            '                    "term_description": "2014 Spring",'+
            '                    "total_current_amount": 4750,'+
            '                    "total_accepted_amount": 4750,'+
            '                    "total_disbursed_amount": 4750,'+
            '                    "award_details": ['+
            '                        {'+
            '                            "award_name": "NAmU - President",'+
            '                            "current_offer": 4750,'+
            '                            "accept_balance": 4750,'+
            '                            "disbursed_balance": 4750,'+
            '                            "disbursement_status": "Applied to Account",'+
            '                            "category_description": "Scholarship",'+
            '                            "aid_year": "2014",'+
            '                            "item_type": "920303519344"'+
            '                        }'+
            '                    ]'+
            '                }'+
            '            ]'+
            '        }'+
            '    ]'+
            '}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getFinancialAidEditMessages() {
        HttpResponse res = new HttpResponse();
        String json=		'{'+
		'    "emplid": "1206104779",'+
		'    "edit_messages": ['+
		'        {'+
		'            "academic_year": "2022 - 2023",'+
		'            "aid_year": "2023",'+
		'            "message_details": ['+
		'                {'+
		'                    "term": "2227",'+
		'                    "action_description": "Action Pending",'+
		'                    "description": "Insufficient Bananes",'+
		'                    "item_type": "970542099901",'+
		'                    "edit_message_type": "E"'+
		'                }'+
		'            ]'+
		'        }'+
		'    ]'+
		'}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getFinancialAidChargeHistory() {
        HttpResponse res = new HttpResponse();
        String json=		'{'+
		'    "charges": ['+
		'        {'+
		'            "term_name": "2022 Spring",'+
		'            "term_code": "2221",'+
		'            "total_charges": 10011,'+
		'            "total_payment": 10011,'+
		'            "total_balance": 0,'+
		'            "charge_details": ['+
		'                {'+
		'                    "description": "FA Trust ASUOnline B",'+
		'                    "charge": 27,'+
		'                    "payment": 27,'+
		'                    "balance": 0'+
		'                },'+
		'                {'+
		'                    "description": "Undergraduate College Fee 4-B",'+
		'                    "charge": 720,'+
		'                    "payment": 720,'+
		'                    "balance": 0'+
		'                },'+
		'                {'+
		'                    "description": "Tuition UG NonRes Online - B",'+
		'                    "charge": 3246,'+
		'                    "payment": 3246,'+
		'                    "balance": 0'+
		'                }'+
		'            ]'+
		'        },'+
		'        {'+
		'            "term_name": "2023 Spring",'+
		'            "term_code": "2231",'+
		'            "total_charges": 6587,'+
		'            "total_payment": 6587,'+
		'            "total_balance": 0,'+
		'            "charge_details": ['+
		'                {'+
		'                    "description": "Undergraduate College Fee 4-B",'+
		'                    "charge": 60,'+
		'                    "payment": 60,'+
		'                    "balance": 0'+
		'                },'+
		'                {'+
		'                    "description": "FA Trust ASUOnline B",'+
		'                    "charge": 27,'+
		'                    "payment": 27,'+
		'                    "balance": 0'+
		'                }'+
		'            ]'+
		'        }'+
		'    ]'+
		'}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getFinancialAidAccountBalance() {
        HttpResponse res = new HttpResponse();
        String json=		'{'+
		'    "emplid": "1206104779",'+
		'    "balances": {'+
		'        "due_amount": 0,'+
		'        "balance_amount": 0,'+
		'        "total_amount": 0'+
		'    }'+
		'}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getFinancialAidRefunds() {
        HttpResponse res = new HttpResponse();
        String json=		'{'+
		'    "emplid": "1206104779",'+
		'    "refunds": ['+
		'        {'+
		'            "refund_date": "2023-01-13",'+
		'            "id": 3514350,'+
		'            "applied_amount": 2164,'+
		'            "refund_format": "P",'+
		'            "refund_type": "Paper Check"'+
		'        }'+
		'    ],'+
		'    "total_refunds": 2164'+
		'}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getDepositStatus() {
        HttpResponse res = new HttpResponse();
        String json=		'{'+
		'    "emplid": "1211532150",'+
		'    "deposits": ['+
		'        {'+
		'            "last_update_date": "2021-06-26",'+
		'            "pre_notification_code": "C",'+
		'            "pre_notification_date": "2021-06-26",'+
		'            "campus_id": "995888422",'+
		'            "pre_notification_status": "Completed",'+
		'            "deposit_status": "Active",'+
		'            "days_since_prenote_date": 584'+
		'        },'+
		'        {'+
		'            "last_update_date": "2021-06-26",'+
		'            "pre_notification_code": "C",'+
		'            "pre_notification_date": "2021-06-26",'+
		'            "campus_id": "995888422",'+
		'            "pre_notification_status": "Completed",'+
		'            "deposit_status": "Active",'+
		'            "days_since_prenote_date": 584'+
		'        }'+
		'    ]'+
		'}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
    
}
