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

    /**
     * Get all the class enrollment information for a student.
     *
     * This includes classDetails, instructor name and details, and both enrolled and dropped classes
     *
     * @param emplId The EmplId of the student - this is required and throws an error if null
     * @return Mapping of term code to a list of enrollments during that term
     * @throws IllegalArgumentException If emplId is null
     * @throws DataPotluck.DPLException If Data Potluck returns an error
     */
    global static Map<String, List<DataPotluck.DPLEnrollment>> getEnrollmentInfo(String emplId) {
        if (emplId == null)
            throw new IllegalArgumentException('Cannot query enrollment details, emplId should not be null');

        Map<String, List<DataPotluck.DPLEnrollment>> enrollmentWrapper = new Map<String, List<DataPotluck.DPLEnrollment>>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            'callout:DPL/enrollment/emplid/' +
                emplid +
                '?include=classDetail&include=instructor&include=dropped&include=academicIntegrityGrade'
        );
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            if (responseBody != null) {
                enrollmentWrapper = (Map<String, List<DataPotluck.DPLEnrollment>>) (JSON.deserialize(
                    responseBody,
                    Map<String, List<DataPotluck.DPLEnrollment>>.class
                ));
            }
        } else {
            String dplErrorMsg = DataPotluck.parseErrorMessage(responseBody);
            if (dplErrorMsg != null)
                throw new DataPotluck.DPLException(
                    'DPL API threw an error: [' + res.getStatusCode() + '] ' + dplErrorMsg
                );
            else
                throw new DataPotluck.DPLException(
                    'DPL API threw an error: [' + res.getStatusCode() + '] ' + responseBody
                );
        }

        return enrollmentWrapper;
    }

    /**
     * Get all the academic status reports for a student.
     *
     * @param emplId The EmplId of the student - this is required and throws an error if null
     * @return List of DPLAcademicStatusReports
     * @throws IllegalArgumentException If emplId is null
     * @throws DataPotluck.DPLException If Data Potluck returns an error
     */
    global static List<DataPotluck.DPLAcademicStatusReport> getAcademicStatusReports(String emplId) {
        if (emplId == null)
            throw new IllegalArgumentException(
                'Cannot query academic status report details, emplId should not be null'
            );

        List<DataPotluck.DPLAcademicStatusReport> asrWrapper = new List<DataPotluck.DPLAcademicStatusReport>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DPL/academic-status-report/emplid/' + emplid);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            if (responseBody != null) {
                asrWrapper = (List<DataPotluck.DPLAcademicStatusReport>) (JSON.deserialize(
                    responseBody,
                    List<DataPotluck.DPLAcademicStatusReport>.class
                ));
            }
        } else {
            String dplErrorMsg = DataPotluck.parseErrorMessage(responseBody);
            if (dplErrorMsg != null)
                throw new DataPotluck.DPLException(
                    'DPL API threw an error: [' + res.getStatusCode() + '] ' + dplErrorMsg
                );
            else
                throw new DataPotluck.DPLException(
                    'DPL API threw an error: [' + res.getStatusCode() + '] ' + responseBody
                );
        }

        return asrWrapper;
    }

    /**
     * Get all the guest access details for a student.
     *
     * @param emplId The EmplId of the student - this is required and throws an error if null
     * @return List of DPLGuestAccesss
     * @throws IllegalArgumentException If emplId is null
     * @throws DataPotluck.DPLException If Data Potluck returns an error
     */
    global static List<DataPotluck.DPLGuestAccess> getGuestAccess(String emplId) {
        if (emplId == null)
            throw new IllegalArgumentException(
                'Cannot query academic status report details, emplId should not be null'
            );

        List<DataPotluck.DPLGuestAccess> guestAccessWrapper = new List<DataPotluck.DPLGuestAccess>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DPL/guest-access/student/emplid/' + emplid);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            if (responseBody != null) {
                guestAccessWrapper = (List<DataPotluck.DPLGuestAccess>) (JSON.deserialize(
                    responseBody,
                    List<DataPotluck.DPLGuestAccess>.class
                ));
            }
        } else {
            String dplErrorMsg = DataPotluck.parseErrorMessage(responseBody);
            if (dplErrorMsg != null)
                throw new DataPotluck.DPLException(
                    'DPL API threw an error: [' + res.getStatusCode() + '] ' + dplErrorMsg
                );
            else
                throw new DataPotluck.DPLException(
                    'DPL API threw an error: [' + res.getStatusCode() + '] ' + responseBody
                );
        }

        return guestAccessWrapper;
    }

    /**
     * Get all the student career term data for a student.
     *
     * @param emplId The EmplId of the student - this is required and throws an error if null
     * @return Mapping of term code to a list of enrollments during that term
     * @throws IllegalArgumentException If emplId is null
     * @throws DataPotluck.DPLException If Data Potluck returns an error
     */
    global static List<DataPotluck.DPLStudentCareerTerm> getStudentCareerTermData(String emplId) {
        if (emplId == null)
            throw new IllegalArgumentException('Cannot query student career term details, emplId should not be null');

        List<DataPotluck.DPLStudentCareerTerm> careerTermWrapper = new List<DataPotluck.DPLStudentCareerTerm>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DPL/student-career-term/emplid/' + emplid);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            if (responseBody != null) {
                careerTermWrapper = (List<DataPotluck.DPLStudentCareerTerm>) (JSON.deserialize(
                    responseBody,
                    List<DataPotluck.DPLStudentCareerTerm>.class
                ));
            }
        } else {
            String dplErrorMsg = DataPotluck.parseErrorMessage(responseBody);
            if (dplErrorMsg != null)
                throw new DataPotluck.DPLException(
                    'DPL API threw an error: [' + res.getStatusCode() + '] ' + dplErrorMsg
                );
            else
                throw new DataPotluck.DPLException(
                    'DPL API threw an error: [' + res.getStatusCode() + '] ' + responseBody
                );
        }

        return careerTermWrapper;
    }

    /**
     * Get all the classes offered for a specific term
     *
     * @param termCode The term for which we need all the classes
     * @return A list of classes for that term
     * @throws IllegalArgumentException If emplId is null
     * @throws DataPotluck.DPLException If Data Potluck returns an error
     */
    global static List<DataPotluck.DPLCourse> getCourses(String termCode, List<String> courseIds) {
        if (termCode == null)
            throw new IllegalArgumentException('Cannot query course list, termCode should not be null');
        if (courseIds == null)
            throw new IllegalArgumentException('Cannot query course list, courseIds should not be null');
        if (courseIds.isEmpty())
            throw new IllegalArgumentException('Cannot query course list, courseIds should not be empty');

        List<DataPotluck.DPLCourse> courseListWrapper = new List<DataPotluck.DPLCourse>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DPL/course/' + termCode + '?courseId=' + String.join(courseIds, '&courseId='));
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            if (responseBody != null) {
                courseListWrapper = (List<DataPotluck.DPLCourse>) (JSON.deserialize(
                    responseBody,
                    List<DataPotluck.DPLCourse>.class
                ));
            }
        } else {
            String dplErrorMsg = DataPotluck.parseErrorMessage(responseBody);
            if (dplErrorMsg != null)
                throw new DataPotluck.DPLException(
                    'DPL API threw an error: [' + res.getStatusCode() + '] ' + dplErrorMsg
                );
            else
                throw new DataPotluck.DPLException(
                    'DPL API threw an error: [' + res.getStatusCode() + '] ' + responseBody
                );
        }

        return courseListWrapper;
    }

    /**
     * Get all the advising notes for a student.
     *
     * @param emplId The EmplId of the student - this is required and throws an error if null
     * @return A list of
     * @throws IllegalArgumentException If emplId is null
     * @throws DataPotluck.DPLException If Data Potluck returns an error
     */
    global static List<DataPotluck.DPLAdvisingNote> getAdvisingNotes(String emplId) {
        if (emplId == null)
            throw new IllegalArgumentException('Cannot advising notes, emplId should not be null');

        List<DataPotluck.DPLAdvisingNote> advNoteWrapper = new List<DataPotluck.DPLAdvisingNote>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DPL/advising-note/emplid/' + emplId);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            if (responseBody != null) {
                advNoteWrapper = (List<DataPotluck.DPLAdvisingNote>) (JSON.deserialize(
                    responseBody,
                    List<DataPotluck.DPLAdvisingNote>.class
                ));
            }
        } else {
            String dplErrorMsg = DataPotluck.parseErrorMessage(responseBody);
            if (dplErrorMsg != null)
                throw new DataPotluck.DPLException(
                    'DPL API threw an error: [' + res.getStatusCode() + '] ' + dplErrorMsg
                );
            else
                throw new DataPotluck.DPLException(
                    'DPL API threw an error: [' + res.getStatusCode() + '] ' + responseBody
                );
        }

        return advNoteWrapper;
    }

    /**
     * Get all the comments for a student.
     *
     * @param emplId The EmplId of the student - this is required and throws an error if null
     * @return The list of all the students checklist comments
     * @throws IllegalArgumentException If emplId is null
     */
    global static List<StudentProfileChecklistComment> getComments(String emplId) {
        if (emplId == null)
            throw new IllegalArgumentException('Cannot query student comments, emplId should not be null');

        List<StudentProfileChecklistComment> checklistComments = new List<StudentProfileChecklistComment>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Student_Checklists/comments?emplid=' + emplid + '&format=json');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            if (responseBody != null) {
                checklistComments = (List<StudentProfileChecklistComment>) (JSON.deserialize(
                    responseBody,
                    List<StudentProfileChecklistComment>.class
                ));
            }
        } else {
            String muleErrorMsg = StudentProfileChecklistComment.parseErrorMessage(responseBody);
            if (muleErrorMsg != null)
                throw new StudentProfileChecklistComment.ChecklistAPIException(
                    'Checklist API threw an error: [' + res.getStatusCode() + '] ' + muleErrorMsg
                );
            else
                throw new StudentProfileChecklistComment.ChecklistAPIException(
                    'Checklist API threw an error: [' + res.getStatusCode() + '] ' + responseBody
                );
        }

        return checklistComments;
    }

    /**
     * Get all the grad notes for a student.
     *
     * @param emplId The EmplId of the student - this is required and throws an error if null
     * @return The list of all the students checklist comments
     * @throws IllegalArgumentException If emplId is null
     */
    global static List<StudentProfileChecklistComment> getGradComments(String emplId) {
        if (emplId == null)
            throw new IllegalArgumentException('Cannot query student comments, emplId should not be null');

        List<StudentProfileChecklistComment> checklistComments = new List<StudentProfileChecklistComment>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Student_Checklists/comments?emplid=' + emplid + '&mode=gradNotes&format=json');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            if (responseBody != null) {
                checklistComments = (List<StudentProfileChecklistComment>) (JSON.deserialize(
                    responseBody,
                    List<StudentProfileChecklistComment>.class
                ));
            }
        } else {
            String muleErrorMsg = StudentProfileChecklistComment.parseErrorMessage(responseBody);
            if (muleErrorMsg != null)
                throw new StudentProfileChecklistComment.ChecklistAPIException(
                    'Checklist API threw an error: [' + res.getStatusCode() + '] ' + muleErrorMsg
                );
            else
                throw new StudentProfileChecklistComment.ChecklistAPIException(
                    'Checklist API threw an error: [' + res.getStatusCode() + '] ' + responseBody
                );
        }

        return checklistComments;
    }

    /**
     * Get all the ferpa notes for a student.
     *
     * @param emplId The EmplId of the student - this is required and throws an error if null
     * @return The list of all the students ferpa comments
     * @throws IllegalArgumentException If emplId is null
     */
    global static List<StudentProfileChecklistComment> getFerpaComments(String emplId) {
        if (emplId == null)
            throw new IllegalArgumentException('Cannot query student comments, emplId should not be null');

        List<StudentProfileChecklistComment> checklistComments = new List<StudentProfileChecklistComment>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Student_Checklists/comments?emplid=' + emplid + '&mode=ferpa&format=json');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            if (responseBody != null) {
                checklistComments = (List<StudentProfileChecklistComment>) (JSON.deserialize(
                    responseBody,
                    List<StudentProfileChecklistComment>.class
                ));
            }
        } else {
            String muleErrorMsg = StudentProfileChecklistComment.parseErrorMessage(responseBody);
            if (muleErrorMsg != null)
                throw new StudentProfileChecklistComment.ChecklistAPIException(
                    'Checklist API threw an error: [' + res.getStatusCode() + '] ' + muleErrorMsg
                );
            else
                throw new StudentProfileChecklistComment.ChecklistAPIException(
                    'Checklist API threw an error: [' + res.getStatusCode() + '] ' + responseBody
                );
        }

        return checklistComments;
    }

    /**
     * Get the transfer work object for a student.
     * This contains information about the student's transferred courses, their education data at other schools, and external exam data
     *
     * @param emplId The EmplId of the student - this is required and throws an error if null
     * @return The tranfer work record
     * @throws IllegalArgumentException If emplId is null
     */
    global static StudentProfileTransferWork getTransferWork(String emplId) {
        if (emplId == null)
            throw new IllegalArgumentException('Cannot query student comments, emplId should not be null');

        StudentProfileTransferWork transferWork = null;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Transfer_Work/' + emplid + '?format=json');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            if (responseBody != null) {
                transferWork = (StudentProfileTransferWork) (JSON.deserialize(
                    responseBody,
                    StudentProfileTransferWork.class
                ));
            }
        } else {
            String muleErrorMsg = StudentProfileTransferWork.parseErrorMessage(responseBody);
            if (muleErrorMsg != null)
                throw new StudentProfileTransferWork.TrasnferWorkAPIException(
                    'Transfer Work API threw an error: [' + res.getStatusCode() + '] ' + muleErrorMsg
                );
            else
                throw new StudentProfileTransferWork.TrasnferWorkAPIException(
                    'Transfer Work API threw an error: [' + res.getStatusCode() + '] ' + responseBody
                );
        }

        return transferWork;
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
        req.setEndpoint('callout:Financial_Aid/students/' + emplid + '/sap-summary');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();

        if (responseBody != null) {
            academicProgressForStudent = SAPWrapper.parse(responseBody);
        }

        return academicProgressForStudent;
    }

    private class StudentProfileCalloutException extends Exception {
    }
}
