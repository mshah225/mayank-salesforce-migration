public class EmailMessageService {
    private static boolean debug = false;

    /*
     * All email messages look up to a case. This method returns a map of Id to case containing
     * all of the parent cases for the email. Can be accessed in trigger by result.get(EmailMessage.parentId).
     */
    public static void updateCasesFromEmailMessages(Map<Id, EmailMessage> messages) {
        Map<Id, Case> casesToUpdate;
        Set<Id> caseIds = new Set<Id>();

        try {
            if (messages == null) {
                throw new EmailMessageServiceException('Messages parameter is null');
            }

            for (EmailMessage em : messages.values()) {
                if (em.status == '3') {
                    caseIds.add(em.ParentId);
                }
            }

            casesToUpdate = new Map<Id, Case>([SELECT Status, recordTypeId FROM Case WHERE Id IN :caseIds]);
        } catch (Exception ex) {
            List<String> vars = new List<String>();

            vars.add(ErrorLogger.convertMapToJSON('messages', messages));
            vars.add(ErrorLogger.convertSetToJSON('caseIds', caseIds));
            vars.add(ErrorLogger.convertMapToJSON('casesToUpdate', casesToUpdate));

            ErrorLogger.log(ex, vars, debug);
        }

        if (casesToUpdate != null && casesToUpdate.size() > 0) {
            casesToUpdate = setAdvisorCaseStatus(casesToUpdate);
            if (casesToUpdate.size() > 0) {
                update casesToUpdate.values();
            }
        }
    }

    @TestVisible
    private static Map<Id, Case> setAdvisorCaseStatus(Map<Id, Case> casesToCheck) {
        Id advisorRTID;
        Map<Id, Case> casesToUpdate = new Map<Id, Case>();

        try {
            if (casesToCheck == null) {
                throw new EmailMessageServiceException('CasesToCheck parameter is null');
            }

            advisorRTID = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
            for (Case c : casesToCheck.values()) {
                if (c.recordTypeId == advisorRTID) {
                    c.status = 'Email Sent';
                    casesToUpdate.put(c.Id, c);
                }
            }
        } catch (Exception ex) {
            List<String> vars = new List<String>();

            vars.add(ErrorLogger.convertMapToJSON('casesToCheck', casesToCheck));
            vars.add(ErrorLogger.convertIdToJSON('advisorRTID', advisorRTID));
            vars.add(ErrorLogger.convertMapToJSON('casesToUpdate', casesToUpdate));

            ErrorLogger.log(ex, vars, debug);
        }

        return casesToUpdate;
    }

    private class EmailMessageServiceException extends exception {
    }
}
