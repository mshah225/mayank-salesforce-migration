@isTest
global class StudentProfileCalloutMock implements HttpCalloutMock {
    public Boolean transferWorkApiRunning = true;
    public Boolean transferWorkApiPermission = true;
    public Boolean checklistApiRunning = true;
    public Boolean checklistApiPermission = true;
    public Boolean dplRunning = true;
    public Boolean dplPermission = true;

    global HTTPResponse respond(HTTPRequest req) {
        if (req.getEndpoint().contains('/serviceindicators')) {
            return getServiceIndicators();
        } else if (req.getEndpoint().contains('callout:Student_Checklists/fin')) {
            return getFinancialAidChecklists();
        } else if (req.getEndPoint().contains('callout:Financial_Aid')) {
            if (req.getEndPoint().contains('/students/') && req.getEndpoint().contains('/awards-status'))
                return getFinancialAidAwardStatus();
            else if (
                req.getEndPoint().contains('/students/') && req.getEndpoint().contains('/fa-messages?messagetype=E')
            )
                return getFinancialAidEditMessages();
            else if (req.getEndPoint().contains('/students/') && req.getEndpoint().contains('/renewable-aid'))
                return getRenewableAid();
            else if (req.getEndPoint().contains('/students/') && req.getEndpoint().contains('/ebpo'))
                return getBookPayment();
            else if (req.getEndPoint().contains('/students/') && req.getEndpoint().contains('/tuition-residency'))
                return getTuitionResidency();
            else if (req.getEndPoint().contains('/students/') && req.getEndpoint().contains('sap-summary'))
                return getSapSummary();
        } else if (req.getEndPoint().contains('callout:Student_Checklists/comments')) {
            // error paths
            if (!checklistApiRunning)
                return getMuleNotRunning();
            if (!checklistApiPermission)
                return getMuleNoPerms();
            // happy path
            if (req.getEndPoint().contains('mode=ferpa'))
                return getFerpaComments();
            else if (req.getEndPoint().contains('mode=gradNotes'))
                return getGradComments();
            else
                return getComments();
        } else if (req.getEndPoint().contains('/account/charges')) {
            return getFinancialAidChargeHistory();
        } else if (req.getEndPoint().contains('/account/balance')) {
            return getFinancialAidAccountBalance();
        } else if (req.getEndPoint().contains('/account/recent-refunds')) {
            return getFinancialAidRefunds();
        } else if (req.getEndPoint().contains('/account/deposit-status')) {
            return getDepositStatus();
        } else if (req.getEndPoint().contains('callout:DPL')) {
            // error paths
            if (!dplRunning)
                return getDplNotRunning();
            if (!dplPermission)
                return getDplNoPerms();
            // happy path
            if (req.getEndPoint().contains('/enrollment/emplid/'))
                return getEnrollmentData();
            else if (req.getEndPoint().contains('/academic-status-report/emplid/'))
                return getASRs();
            else if (req.getEndPoint().contains('/guest-access/student/emplid/'))
                return getGuestAccess();
            else if (req.getEndPoint().contains('/student-career-term/emplid/'))
                return getStudentCareerTerm();
            else if (req.getEndPoint().contains('/course/'))
                return getCourses(req);
            else if (req.getEndPoint().contains('/advising-note/emplid/'))
                return getAdvisingNotes();
        } else if (req.getEndPoint().contains('callout:Transfer_Work/')) {
            // error paths
            if (!transferWorkApiRunning)
                return getMuleNotRunning();
            if (!transferWorkApiPermission)
                return getMuleNoPerms();
            // happy path
            return getTransferWork();
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

    private HTTPResponse getGradComments() {
        HttpResponse res = new HttpResponse();

        String json =
            '[\n' +
            '    {\n' +
            '        "ACAD_PLAN": "ESCSEIMCS",\n' +
            '        "ACAD_PROGRAM": "GRES",\n' +
            '        "CMNT_CATEGORY": "GRPOS",\n' +
            '        "CMNT_ID": "1216520071",\n' +
            '        "COMMENT_DTTM": "2022-02-06T12:31:08Z",\n' +
            '        "COMMENTS": "GRAD COMMENT 1"\n' +
            '    },\n' +
            '    {\n' +
            '        "ACAD_PLAN": "ESCSEBS",\n' +
            '        "ACAD_PROGRAM": "UGES",\n' +
            '        "CMNT_CATEGORY": "GRGCPS",\n' +
            '        "CMNT_ID": "1216520071",\n' +
            '        "COMMENT_DTTM": "2022-02-05T12:31:08Z",\n' +
            '        "COMMENTS": "GRAD COMMENT 2"\n' +
            '    },\n' +
            '    {\n' +
            '        "ACAD_PLAN": " ",\n' +
            '        "ACAD_PROGRAM": " ",\n' +
            '        "CMNT_CATEGORY": "GRGCPS",\n' +
            '        "CMNT_ID": "0000000000",\n' +
            '        "COMMENT_DTTM": "2022-02-04T12:31:08Z",\n' +
            '        "COMMENTS": "GRAD COMMENT 3"\n' +
            '    }\n' +
            ']';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getFerpaComments() {
        HttpResponse res = new HttpResponse();

        String json =
            '[\n' +
            '    {\n' +
            '        "ACAD_PLAN": " ",\n' +
            '        "ACAD_PROGRAM": " ",\n' +
            '        "CMNT_CATEGORY": "FERPA",\n' +
            '        "CMNT_ID": "1228223297",\n' +
            '        "COMMENT_DTTM": "2022-02-07T12:31:08Z",\n' +
            '        "COMMENTS": "FERPA COMMENT 1"\n' +
            '    },\n' +
            '    {\n' +
            '        "ACAD_PLAN": "ESCSEBS",\n' +
            '        "ACAD_PROGRAM": "UGES",\n' +
            '        "CMNT_CATEGORY": "GRGCPS",\n' +
            '        "CMNT_ID": " ",\n' +
            '        "COMMENT_DTTM": "2022-02-06T12:31:08Z",\n' +
            '        "COMMENTS": "FERPA COMMENT 2"\n' +
            '    },\n' +
            '    {\n' +
            '        "ACAD_PLAN": " ",\n' +
            '        "ACAD_PROGRAM": " ",\n' +
            '        "CMNT_CATEGORY": "GRGCPS",\n' +
            '        "CMNT_ID": "0000000000",\n' +
            '        "COMMENT_DTTM": "2022-02-05T12:31:08Z",\n' +
            '        "COMMENTS": "FERPA COMMENT 3"\n' +
            '    }\n' +
            ']';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getComments() {
        HttpResponse res = new HttpResponse();

        String json =
            '[\n' +
            '    {\n' +
            '        "CMNT_CATEGORY": "FCNSL",\n' +
            '        "CMNT_ID": "1000948362",\n' +
            '        "COMMENT_DTTM": "2018-08-13T16:52:17Z",\n' +
            '        "COMMENTS": "COMMENT 1"\n' +
            '    },\n' +
            '    {\n' +
            '        "CMNT_CATEGORY": "FSCHL",\n' +
            '        "CMNT_ID": "1001466226",\n' +
            '        "COMMENT_DTTM": "2018-08-14T13:16:33Z",\n' +
            '        "COMMENTS": "COMMENT 2"\n' +
            '    },\n' +
            '    {\n' +
            '        "CMNT_CATEGORY": "FGNRL",\n' +
            '        "CMNT_ID": "0000000000",\n' + // invalid EMPLID
            '        "COMMENT_DTTM": "2021-02-08T15:48:04Z",\n' +
            '        "COMMENTS": "COMMENT 3"\n' +
            '    }\n' +
            ']';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getFinancialAidAwardStatus() {
        HttpResponse res = new HttpResponse();
        String json =
            '{' +
            '    "aid_years": [' +
            '        {' +
            '            "financial_year": "2013-2014",' +
            '            "term_awards": [' +
            '                {' +
            '                    "term_description": "2013 Fall",' +
            '                    "total_current_amount": 5000,' +
            '                    "total_accepted_amount": 5000,' +
            '                    "total_disbursed_amount": 5000,' +
            '                    "award_details": [' +
            '                        {' +
            '                            "award_name": "NAmU - President",' +
            '                            "current_offer": 4750,' +
            '                            "accept_balance": 4750,' +
            '                            "disbursed_balance": 4750,' +
            '                            "disbursement_status": "Applied to Account",' +
            '                            "category_description": "Scholarship",' +
            '                            "aid_year": "2014",' +
            '                            "item_type": "920303519344"' +
            '                        },' +
            '                        {' +
            '                            "award_name": "Combs HS Booster Club Coyotes",' +
            '                            "current_offer": 250,' +
            '                            "accept_balance": 250,' +
            '                            "disbursed_balance": 250,' +
            '                            "disbursement_status": "Applied to Account",' +
            '                            "category_description": "Scholarship",' +
            '                            "aid_year": "2014",' +
            '                            "item_type": "920705299992"' +
            '                        }' +
            '                    ]' +
            '                },' +
            '                {' +
            '                    "term_description": "2014 Spring",' +
            '                    "total_current_amount": 4750,' +
            '                    "total_accepted_amount": 4750,' +
            '                    "total_disbursed_amount": 4750,' +
            '                    "award_details": [' +
            '                        {' +
            '                            "award_name": "NAmU - President",' +
            '                            "current_offer": 4750,' +
            '                            "accept_balance": 4750,' +
            '                            "disbursed_balance": 4750,' +
            '                            "disbursement_status": "Applied to Account",' +
            '                            "category_description": "Scholarship",' +
            '                            "aid_year": "2014",' +
            '                            "item_type": "920303519344"' +
            '                        }' +
            '                    ]' +
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

    private HTTPResponse getFinancialAidEditMessages() {
        HttpResponse res = new HttpResponse();
        String json =
            '{' +
            '    "emplid": "1206104779",' +
            '    "edit_messages": [' +
            '        {' +
            '            "academic_year": "2022 - 2023",' +
            '            "aid_year": "2023",' +
            '            "message_details": [' +
            '                {' +
            '                    "term": "2227",' +
            '                    "action_description": "Action Pending",' +
            '                    "description": "Insufficient Bananes",' +
            '                    "item_type": "970542099901",' +
            '                    "edit_message_type": "E"' +
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

    private HTTPResponse getFinancialAidChargeHistory() {
        HttpResponse res = new HttpResponse();
        String json =
            '{' +
            '    "charges": [' +
            '        {' +
            '            "term_name": "2022 Spring",' +
            '            "term_code": "2221",' +
            '            "total_charges": 10011,' +
            '            "total_payment": 10011,' +
            '            "total_balance": 0,' +
            '            "charge_details": [' +
            '                {' +
            '                    "description": "FA Trust ASUOnline B",' +
            '                    "charge": 27,' +
            '                    "payment": 27,' +
            '                    "balance": 0' +
            '                },' +
            '                {' +
            '                    "description": "Undergraduate College Fee 4-B",' +
            '                    "charge": 720,' +
            '                    "payment": 720,' +
            '                    "balance": 0' +
            '                },' +
            '                {' +
            '                    "description": "Tuition UG NonRes Online - B",' +
            '                    "charge": 3246,' +
            '                    "payment": 3246,' +
            '                    "balance": 0' +
            '                }' +
            '            ]' +
            '        },' +
            '        {' +
            '            "term_name": "2023 Spring",' +
            '            "term_code": "2231",' +
            '            "total_charges": 6587,' +
            '            "total_payment": 6587,' +
            '            "total_balance": 0,' +
            '            "charge_details": [' +
            '                {' +
            '                    "description": "Undergraduate College Fee 4-B",' +
            '                    "charge": 60,' +
            '                    "payment": 60,' +
            '                    "balance": 0' +
            '                },' +
            '                {' +
            '                    "description": "FA Trust ASUOnline B",' +
            '                    "charge": 27,' +
            '                    "payment": 27,' +
            '                    "balance": 0' +
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

    private HTTPResponse getFinancialAidAccountBalance() {
        HttpResponse res = new HttpResponse();
        String json =
            '{' +
            '    "emplid": "1206104779",' +
            '    "balances": {' +
            '        "due_amount": 0,' +
            '        "balance_amount": 0,' +
            '        "total_amount": 0' +
            '    }' +
            '}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getFinancialAidRefunds() {
        HttpResponse res = new HttpResponse();
        String json =
            '{' +
            '    "emplid": "1206104779",' +
            '    "refunds": [' +
            '        {' +
            '            "refund_date": "2023-01-13",' +
            '            "id": 3514350,' +
            '            "applied_amount": 2164,' +
            '            "refund_format": "P",' +
            '            "refund_type": "Paper Check"' +
            '        }' +
            '    ],' +
            '    "total_refunds": 2164' +
            '}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getDepositStatus() {
        HttpResponse res = new HttpResponse();
        String json =
            '{' +
            '    "emplid": "1206104779",' +
            '    "deposits": [' +
            '        {' +
            '            "last_update_date": "2021-06-26",' +
            '            "pre_notification_code": "C",' +
            '            "pre_notification_date": "2021-06-26",' +
            '            "campus_id": "995888422",' +
            '            "pre_notification_status": "Completed",' +
            '            "deposit_status": "Active",' +
            '            "days_since_prenote_date": 584' +
            '        },' +
            '        {' +
            '            "last_update_date": "2021-06-26",' +
            '            "pre_notification_code": "C",' +
            '            "pre_notification_date": "2021-06-26",' +
            '            "campus_id": "995888422",' +
            '            "pre_notification_status": "Completed",' +
            '            "deposit_status": "Active",' +
            '            "days_since_prenote_date": 584' +
            '        }' +
            '    ]' +
            '}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getRenewableAid() {
        HttpResponse res = new HttpResponse();

        String json =
            '{' +
            '    "emplid": "1206104779",' +
            '    "aid_years": [' +
            '        {' +
            '            "aid_year": "2017",' +
            '            "name": "ARIZONA GRADUATE SCHOLAR AWARD",' +
            '            "terms_used": "0 of 4 terms",' +
            '            "current_award": "2000",' +
            '            "awards_description": "Funds for this program may be comprised of one or more named awards</br></br>",' +
            '            "renewal_status": "New Award (100%)",' +
            '            "measurement_description": "Measurement as of 06/06/2018:</br></br>",' +
            '            "max_amount": "2000"' +
            '        }' +
            '    ]' +
            '}';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getBookPayment() {
        HttpResponse res = new HttpResponse();

        String json =
            '{' +
            '    "emplid": "1206104779",' +
            '    "aid_years": [' +
            '        {' +
            '            "aid_year": "2023",' +
            '            "term": "2227",' +
            '            "term_description": "2022 Fall",' +
            '            "amount": 150,' +
            '            "begin_date": "2022-09-21",' +
            '            "end_date": "2022-10-26",' +
            '            "description": "Pacific Dental students use your book scholarship at the ASU Bookstore"' +
            '        }' +
            '    ]' +
            '}';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getTuitionResidency() {
        HttpResponse res = new HttpResponse();

        String json =
            '{\n' +
            '    "emplid": "1215721572",\n' +
            '    "tuition_residency": [\n' +
            '        {\n' +
            '            "acad_career": "GRAD",\n' +
            '            "institution": "ASU00",\n' +
            '            "effective_term": "2207",\n' +
            '            "residency_dt": "2020-06-26",\n' +
            '            "residency": "Non-Resident"\n' +
            '        }\n' +
            '    ]\n' +
            '}';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getSapSummary() {
        HttpResponse res = new HttpResponse();

        String json =
            '{\n' +
            '    "emplid": "1215721572",\n' +
            '    "academic_year": [\n' +
            '        {\n' +
            '            "aid_year": "1999",\n' +
            '            "sap": [\n' +
            '                {\n' +
            '                    "processTerm": "1981",\n' +
            '                    "term": "1987",\n' +
            '                    "sapDescription": "Meeting",\n' +
            '                    "paceRateDescription": "Meeting",\n' +
            '                    "maximumHourDescription": "Meeting",\n' +
            '                    "minimumGpaDescription": "Meeting"\n' +
            '                },\n' +
            '                {\n' +
            '                    "processTerm": "1981",\n' +
            '                    "term": "1991",\n' +
            '                    "sapDescription": "Meeting",\n' +
            '                    "paceRateDescription": "Meeting",\n' +
            '                    "maximumHourDescription": "Meeting",\n' +
            '                    "minimumGpaDescription": "Meeting"\n' +
            '                },\n' +
            '                {\n' +
            '                    "processTerm": "1981",\n' +
            '                    "term": "1994",\n' +
            '                    "sapDescription": "Meeting",\n' +
            '                    "paceRateDescription": "Meeting",\n' +
            '                    "maximumHourDescription": "Meeting",\n' +
            '                    "minimumGpaDescription": "Meeting"\n' +
            '                }\n' +
            '            ]\n' +
            '        },\n' +
            '        {\n' +
            '            "aid_year": "2000",\n' +
            '            "sap": [\n' +
            '                {\n' +
            '                    "processTerm": "1991",\n' +
            '                    "term": "1997",\n' +
            '                    "sapDescription": "Meeting",\n' +
            '                    "paceRateDescription": "Meeting",\n' +
            '                    "maximumHourDescription": "Meeting",\n' +
            '                    "minimumGpaDescription": "Meeting"\n' +
            '                },\n' +
            '                {\n' +
            '                    "processTerm": "1991",\n' +
            '                    "term": "2001",\n' +
            '                    "sapDescription": "Meeting",\n' +
            '                    "paceRateDescription": "Meeting",\n' +
            '                    "maximumHourDescription": "Meeting",\n' +
            '                    "minimumGpaDescription": "Meeting"\n' +
            '                },\n' +
            '                {\n' +
            '                    "processTerm": "1991",\n' +
            '                    "term": "2004",\n' +
            '                    "sapDescription": "Meeting",\n' +
            '                    "paceRateDescription": "Meeting",\n' +
            '                    "maximumHourDescription": "Meeting",\n' +
            '                    "minimumGpaDescription": "Meeting"\n' +
            '                }\n' +
            '            ]\n' +
            '        },\n' +
            '        {\n' +
            '            "aid_year": "2001",\n' +
            '            "sap": []\n' +
            '        }\n' +
            '    ]\n' +
            '}';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getEnrollmentData() {
        HttpResponse res = new HttpResponse();

        String json =
            '{\n' +
            '    "2247": [\n' +
            '        {\n' +
            '            "strm": "2247",\n' +
            '            "strmDescription": "Fall 2024",\n' +
            '            "classNumber": "70860",\n' +
            '            "sessionCode": "C",\n' +
            '            "acadCareer": "UGRD",\n' +
            '            "acadCareerDescription": "Undergraduate",\n' +
            '            "enrollmentStatusReason": "DROP",\n' +
            '            "enrollmentStatus": "D",\n' +
            '            "unitsTaken": 3.0,\n' +
            '            "officialGrade": null,\n' +
            '            "academicIntegrityGrade": null,\n' +
            '            "faConfirmationOfParticipation": null,\n' +
            '            "classDetail": {\n' +
            '                "subject": "ENG",\n' +
            '                "catalogNumber": "101",\n' +
            '                "description": "First-Year Composition",\n' +
            '                "courseTopicTitle": null,\n' +
            '                "locationCode": "TEMPE",\n' +
            '                "locationDescription": "Tempe",\n' +
            '                "meetings": [\n' +
            '                    {\n' +
            '                        "instructors": [\n' +
            '                            {\n' +
            '                                "firstName": "Joel",\n' +
            '                                "lastName": "Salcido"\n' +
            '                            }\n' +
            '                        ],\n' +
            '                        "meetDays": ["TUESDAY", "THURSDAY"],\n' +
            '                        "startTime": 52200000,\n' +
            '                        "endTime": 56700000,\n' +
            '                        "startDate": 1534402800000,\n' +
            '                        "endDate": 1543561200000,\n' +
            '                        "facilityLocationCode": "TEMPE"\n' +
            '                    }\n' +
            '                ]\n' +
            '            }\n' +
            '        }\n' +
            '    ],\n' +
            '    "2251": [\n' +
            '        {\n' +
            '            "strm": "2251",\n' +
            '            "strmDescription": "Spring 2025",\n' +
            '            "classNumber": "27873",\n' +
            '            "sessionCode": "C",\n' +
            '            "acadCareer": "UGRD",\n' +
            '            "acadCareerDescription": "Undergraduate",\n' +
            '            "enrollmentStatusReason": "ENRL",\n' +
            '            "enrollmentStatus": "E",\n' +
            '            "unitsTaken": 3.0,\n' +
            '            "officialGrade": "A+",\n' +
            '            "academicIntegrityGrade": null,\n' +
            '            "faConfirmationOfParticipation": true,\n' +
            '            "classDetail": {\n' +
            '                "subject": "CSE",\n' +
            '                "catalogNumber": "548",\n' +
            '                "description": "Adv Computer Network Security",\n' +
            '                "courseTopicTitle": null,\n' +
            '                "locationCode": "TEMPE",\n' +
            '                "locationDescription": "Tempe",\n' +
            '                "meetings": [\n' +
            '                    {\n' +
            '                        "instructors": [\n' +
            '                            {\n' +
            '                                "firstName": "Abdulhakim",\n' +
            '                                "lastName": "Sabur"\n' +
            '                            }\n' +
            '                        ],\n' +
            '                        "meetDays": ["WEDNESDAY"],\n' +
            '                        "startTime": 63000000,\n' +
            '                        "endTime": 67500000,\n' +
            '                        "startDate": 1641798000000,\n' +
            '                        "endDate": 1651215600000,\n' +
            '                        "facilityLocationCode": "TEMPE"\n' +
            '                    },\n' +
            '                    {\n' +
            '                        "instructors": [\n' +
            '                            {\n' +
            '                                "firstName": "Ronald",\n' +
            '                                "lastName": "Dorn"\n' +
            '                            }\n' +
            '                        ],\n' +
            '                        "meetDays": [],\n' +
            '                        "startTime": null,\n' +
            '                        "endTime": null,\n' +
            '                        "startDate": 1641798000000,\n' +
            '                        "endDate": 1651215600000,\n' +
            '                        "facilityLocationCode": "ONLINE"\n' +
            '                    }\n' +
            '                ]\n' +
            '            }\n' +
            '        },\n' +
            '        {\n' +
            '            "strm": "2251",\n' +
            '            "strmDescription": "Spring 2025",\n' +
            '            "classNumber": "79386",\n' +
            '            "sessionCode": "C",\n' +
            '            "acadCareer": "UGRD",\n' +
            '            "acadCareerDescription": "Undergraduate",\n' +
            '            "enrollmentStatusReason": "ENRL",\n' +
            '            "enrollmentStatus": "E",\n' +
            '            "unitsTaken": 3.0,\n' +
            '            "officialGrade": "E",\n' +
            '            "academicIntegrityGrade": "XE",\n' +
            '            "faConfirmationOfParticipation": false,\n' +
            '            "classDetail": {\n' +
            '                "subject": "CSE",\n' +
            '                "catalogNumber": "515",\n' +
            '                "description": "Multimedia and Web Databases",\n' +
            '                "courseTopicTitle": "Simple Clips",\n' +
            '                "locationCode": "TEMPE",\n' +
            '                "locationDescription": "Tempe",\n' +
            '                "meetings": [\n' +
            '                    {\n' +
            '                        "instructors": [\n' +
            '                            {\n' +
            '                                "firstName": "K. Selcuk",\n' +
            '                                "lastName": "Candan"\n' +
            '                            },\n' +
            '                            {\n' +
            '                                "firstName": "Sruthi",\n' +
            '                                "lastName": "Sathyamoorthy"\n' +
            '                            }\n' +
            '                        ],\n' +
            '                        "meetDays": ["TUESDAY", "THURSDAY"],\n' +
            '                        "startTime": 63000000,\n' +
            '                        "endTime": 67500000,\n' +
            '                        "startDate": 1641798000000,\n' +
            '                        "endDate": 1651215600000,\n' +
            '                        "facilityLocationCode": "TEMPE"\n' +
            '                    }\n' +
            '                ]\n' +
            '            }\n' +
            '        }\n' +
            '    ]\n' +
            '}';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getASRs() {
        HttpResponse res = new HttpResponse();

        String json =
            '[\n' +
            '    {\n' +
            '        "strm": "2251",' +
            '        "classNumber": "79386",\n' +
            '        "asrPeriodCode": "3",\n' +
            '        "grade": "D",\n' +
            '        "commentText": null,\n' +
            '        "actions": [\n' +
            '            {\n' +
            '                "gradeActionDescription": "Contact instructor"\n' +
            '            },\n' +
            '            {\n' +
            '                "gradeActionDescription": "Seek tutoring for this course"\n' +
            '            },\n' +
            '            {\n' +
            '                "gradeActionDescription": "Meet with advisor"\n' +
            '            }\n' +
            '        ],\n' +
            '        "reasons": [\n' +
            '            {\n' +
            '                "gradeReasonDescription": "Low quiz and/or exam score(s)"\n' +
            '            }\n' +
            '        ]\n' +
            '    }\n' +
            ']';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getStudentCareerTerm() {
        HttpResponse res = new HttpResponse();

        String json =
            '[\n' +
            '    {\n' +
            '        "strm": "2247",\n' +
            '        "unitsTakenTowardGpaForDisplay": "15.000",\n' +
            '        "totalTakenTowardGpaForDisplay": "15.000",\n' +
            '        "termGpaForDisplay": "3.84",\n' +
            '        "cumulativeGpaForDisplay": "3.84"\n' +
            '    },\n' +
            '    {\n' +
            '        "strm": "2251",\n' +
            '        "unitsTakenTowardGpaForDisplay": "9.000",\n' +
            '        "totalTakenTowardGpaForDisplay": "18.000",\n' +
            '        "termGpaForDisplay": "4.22",\n' +
            '        "cumulativeGpaForDisplay": "4.00"\n' +
            '    }\n' +
            ']';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getGuestAccess() {
        HttpResponse res = new HttpResponse();

        String json =
            '[\n' +
            '    {\n' +
            '        "recordAddedBy": "ASU_MYASU",\n' +
            '        "effectiveDate": 1660806000000,\n' +
            '        "statusCode": "AC",\n' +
            '        "onlineAccess": true,\n' +
            '        "permissionCodes": ["ACAD", "ADMS", "FAID", "GRAD"],\n' +
            '        "provisionalGuestName": "Rob"\n' +
            '    },\n' +
            '    {\n' +
            '        "recordAddedBy": "ASU_MYASU",\n' +
            '        "effectiveDate": 1660804000000,\n' +
            '        "statusCode": "AC",\n' +
            '        "onlineAccess": true,\n' +
            '        "permissionCodes": ["HOUS", "OTHR", "PERS", "PPLS", "TASK"],\n' +
            '        "guestEmplid": "1228223297"\n' +
            '    },\n' +
            '    {\n' +
            '        "recordAddedBy": "ASU_MYASU",\n' +
            '        "effectiveDate": 1660802000000,\n' +
            '        "statusCode": "AC",\n' +
            '        "onlineAccess": true,\n' +
            '        "permissionCodes": ["HOUS"],\n' +
            '        "externalOrganizationName": "Arizona State University"\n' +
            '    },\n' +
            '    {\n' +
            '        "recordAddedBy": "aguardi",\n' +
            '        "effectiveDate": 1660800000000,\n' +
            '        "statusCode": "AC",\n' +
            '        "onlineAccess": true,\n' +
            '        "permissionCodes": ["HOUS"],\n' +
            '        "relationshipDescription": "Father"\n' +
            '    },\n' +
            '    {\n' +
            '        "recordAddedBy": "ASU_MYASU",\n' +
            '        "effectiveDate": 1660898000000,\n' +
            '        "statusCode": "AC",\n' +
            '        "onlineAccess": false,\n' +
            '        "permissionCodes": ["HOUS"]\n' +
            '    },\n' +
            '    {\n' +
            '        "recordAddedBy": "ASU_MYASU",\n' +
            '        "effectiveDate": 1660898000000,\n' +
            '        "statusCode": "AC",\n' +
            '        "onlineAccess": true,\n' +
            '        "permissionCodes": []\n' +
            '    },\n' +
            '    {\n' +
            '        "recordAddedBy": "ASU_MYASU",\n' +
            '        "effectiveDate": 1660898000000,\n' +
            '        "statusCode": "DE",\n' +
            '        "onlineAccess": true,\n' +
            '        "permissionCodes": ["HOUS"]\n' +
            '    }\n' +
            ']';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getAdvisingNotes() {
        HttpResponse res = new HttpResponse();

        String json =
            '[\n' +
            '    {\n' +
            '        "acadProgramCode": "GRES",\n' +
            '        "acadPlanCode": "ESCSEIMCS",\n' +
            '        "createdByOprid": "wlgibson",\n' +
            '        "createdAt": 1615405105000,\n' +
            '        "advisingNoteText": "DESCRIPTION 1"\n' +
            '    },\n' +
            '    {\n' +
            '        "acadProgramCode": "UGES",\n' +
            '        "acadPlanCode": "ESCSEBS",\n' +
            '        "createdByOprid": "rudspr",\n' +
            '        "createdAt": 1531945565000,\n' +
            '        "advisingNoteText": "DESCRIPTION 2"\n' +
            '    },\n' +
            '    {\n' +
            '        "acadProgramCode": " ",\n' +
            '        "acadPlanCode": " ",\n' +
            '        "createdByOprid": "testnoname",\n' +
            '        "createdAt": 1532984786000,\n' +
            '        "advisingNoteText": "DESCRIPTION 3"\n' +
            '    }\n' +
            ']';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HttpResponse getCourses(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        List<String> requestPathComponents = req.getEndPoint().split('[/?]+');

        if (requestPathComponents[2] == '2184') {
            String json =
                '[\n' +
                '    {\n' +
                '        "strm": "2184",\n' +
                '        "courseId": "100049",\n' +
                '        "courseOfferNumber": "1",\n' +
                '        "subject": "HST",\n' +
                '        "catalogNumber": "110",\n' +
                '        "description": "United States Since 1865"\n' +
                '    },\n' +
                '    {\n' +
                '        "strm": "2184",\n' +
                '        "courseId": "103766",\n' +
                '        "courseOfferNumber": "1",\n' +
                '        "subject": "CHM",\n' +
                '        "catalogNumber": "113",\n' +
                '        "description": "General Chemistry I"\n' +
                '    },\n' +
                '    {\n' +
                '        "strm": "2184",\n' +
                '        "courseId": "104173",\n' +
                '        "courseOfferNumber": "1",\n' +
                '        "subject": "CSE",\n' +
                '        "catalogNumber": "110",\n' +
                '        "description": "Principles of Programming"\n' +
                '    },\n' +
                '    {\n' +
                '        "strm": "2184",\n' +
                '        "courseId": "101533",\n' +
                '        "courseOfferNumber": "1",\n' +
                '        "subject": "HST",\n' +
                '        "catalogNumber": "108",\n' +
                '        "description": "United States to 1865"\n' +
                '    },\n' +
                '    {\n' +
                '        "strm": "2184",\n' +
                '        "courseId": "101533",\n' +
                '        "courseOfferNumber": "2",\n' +
                '        "subject": "HST",\n' +
                '        "catalogNumber": "109",\n' +
                '        "description": "United States to 1865"\n' +
                '    }\n' +
                ']';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(json);
            res.setStatusCode(200);
        } else if (requestPathComponents[2] == '2194') {
            String json =
                '[\n' +
                '    {\n' +
                '        "strm": "2194",\n' +
                '        "courseId": "103769",\n' +
                '        "courseOfferNumber": "1",\n' +
                '        "subject": "CHM",\n' +
                '        "catalogNumber": "116",\n' +
                '        "description": "General Chemistry II"\n' +
                '    }\n' +
                ']';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(json);
            res.setStatusCode(200);
        } else {
            String json = '{ "error" : "no mock data implemented for term ' + requestPathComponents[2] + '" }';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(json);
            res.setStatusCode(400);
        }

        return res;
    }

    private HTTPResponse getTransferWork() {
        HttpResponse res = new HttpResponse();

        String json =
            '{\n' +
            '    "external_exam_data": [\n' +
            '        {\n' +
            '            "test_id": "AP",\n' +
            '            "test_descr": " ",\n' +
            '            "exam_data": [\n' +
            '                {\n' +
            '                    "articulation_term": "2184",\n' +
            '                    "score": 4,\n' +
            '                    "unit_transfer": 3,\n' +
            '                    "course_Id": "100049",\n' +
            '                    "course_offer_nbr": 1\n' +
            '                },\n' +
            '                {\n' +
            '                    "articulation_term": "2184",\n' +
            '                    "score": 5,\n' +
            '                    "unit_transfer": 3,\n' +
            '                    "course_Id": "103766",\n' +
            '                    "course_offer_nbr": 1\n' +
            '                },\n' +
            '                {\n' +
            '                    "articulation_term": "2184",\n' +
            '                    "score": 5,\n' +
            '                    "unit_transfer": 3,\n' +
            '                    "course_Id": "104173",\n' +
            '                    "course_offer_nbr": 1\n' +
            '                }\n' +
            '            ]\n' +
            '        },\n' +
            '        {\n' +
            '            "test_id": " ",\n' +
            '            "test_descr": " ",\n' +
            '            "exam_data": [\n' +
            '                {\n' +
            '                    "articulation_term": "2184",\n' +
            '                    "score": 0,\n' +
            '                    "unit_transfer": 3,\n' +
            '                    "course_Id": "101533",\n' +
            '                    "course_offer_nbr": 2\n' +
            '                },\n' +
            '                {\n' +
            '                    "articulation_term": "2184",\n' +
            '                    "score": 0,\n' +
            '                    "unit_transfer": 3,\n' +
            '                    "course_Id": "103766",\n' +
            '                    "course_offer_nbr": 1\n' +
            '                },\n' +
            '                {\n' +
            '                    "articulation_term": "2194",\n' +
            '                    "score": 0,\n' +
            '                    "unit_transfer": 3,\n' +
            '                    "course_Id": "103769",\n' +
            '                    "course_offer_nbr": 1\n' +
            '                }\n' +
            '            ]\n' +
            '        },\n' +
            '        {\n' +
            '            "test_id": "ALEKSMATHPL",\n' +
            '            "test_descr": " ",\n' +
            '            "exam_data": [\n' +
            '                {\n' +
            '                    "articulation_term": "2184",\n' +
            '                    "score": 0,\n' +
            '                    "unit_transfer": 0,\n' +
            '                    "course_Id": " ",\n' +
            '                    "course_offer_nbr": 0\n' +
            '                }\n' +
            '            ]\n' +
            '        }\n' +
            '    ]\n' +
            '}';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getMuleNotRunning() {
        HttpResponse res = new HttpResponse();

        String html = '<html><body><h1>503 Service Unavailable</h1>No server is available to handle this request.</body></html>';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(html);
        res.setStatusCode(503);
        return res;
    }
    private HTTPResponse getMuleNoPerms() {
        HttpResponse res = new HttpResponse();

        String json = '{ "error": "Invalid Client" }';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(401);
        return res;
    }

    private HTTPResponse getDplNotRunning() {
        HttpResponse res = new HttpResponse();

        String json = '{ "error": "Not Found" }';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(404);
        return res;
    }
    private HTTPResponse getDplNoPerms() {
        HttpResponse res = new HttpResponse();

        String json = '{ "error": "unauthorized" }';

        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(401);
        return res;
    }
}
