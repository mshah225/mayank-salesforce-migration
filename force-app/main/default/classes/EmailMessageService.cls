public class EmailMessageService {
    private static boolean debug = false;

    /*
     * All email messages look up to a case. This method returns a map of Id to case containing
     * all of the parent cases for the email. Can be accessed in trigger by result.get(EmailMessage.parentId).
     *
     * <p>
     * Note: this method needs to be updated to contain all of the fields that need to be updated by the trigger.
     * </p>
     *
     * @param Map<Id, EmailMessage> The trigger.newMap
     *
     * @return Map<Id, Case> A map of parent cases for the provided email messages
     */
    public static void getCasesFromEmailMessages(Map<Id, EmailMessage> messages) {
        Map<Id, Case> result;
        Set<Id> caseIds;

        try {
            if (messages == null) {
                throw new EmailMessageServiceException('Messages parameter is null');
            }

            caseIds = new Set<Id>();

            for (EmailMessage em : messages.values()) {
                if (em.status == '3') {
                    caseIds.add(em.ParentId);
                }
            }

            result = new Map<Id, Case>([SELECT Status, recordTypeId FROM Case WHERE Id IN :caseIds]);
        } catch (Exception ex) {
            List<String> vars = new List<String>();

            vars.add(ErrorLogger.convertMapToJSON('messages', messages));
            vars.add(ErrorLogger.convertSetToJSON('caseIds', caseIds));
            vars.add(ErrorLogger.convertMapToJSON('result', result));

            ErrorLogger.log(ex, vars, debug);
        }

        if (result != null && result.size() > 0) {
            setAdvisorCaseStatus(result);
        }
    }

    /*
     * Loops through the provided cases and sets the status of any advisor cases to
     * "Email Sent".
     *
     * @param Map<Id, Case> Map of cases to be updated
     *
     * @return Map<Id, Case> map of updated cases
     */
    public static void setAdvisorCaseStatus(Map<Id, Case> casesToCheck) {
        Id advisorRTID;
        Map<Id, Case> result;

        try {
            if (casesToCheck == null) {
                throw new EmailMessageServiceException('CasesToCheck parameter is null');
            }

            advisorRTID = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
            result = new Map<Id, Case>();

            for (Case c : casesToCheck.values()) {
                if (c.recordTypeId == advisorRTID) {
                    c.status = 'Email Sent';
                    result.put(c.Id, c);
                }
            }
        } catch (Exception ex) {
            List<String> vars = new List<String>();

            vars.add(ErrorLogger.convertMapToJSON('casesToCheck', casesToCheck));
            vars.add(ErrorLogger.convertIdToJSON('advisorRTID', advisorRTID));
            vars.add(ErrorLogger.convertMapToJSON('result', result));

            ErrorLogger.log(ex, vars, debug);
        }

        if (result.size() > 0) {
            update result.values();
        }
    }

    private class EmailMessageServiceException extends exception {
    }
}
