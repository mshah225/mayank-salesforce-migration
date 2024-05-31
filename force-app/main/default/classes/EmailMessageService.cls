public class EmailMessageService {
    private static boolean debug = false;

    /**
     * Mapping of all email message status from nice name to integer string
     */
    @TestVisible
    private static Map<String, String> emailMessageStatusMap {
        get {
            if (emailMessageStatusMap == null) {
                emailMessageStatusMap = new Map<String, String>();
                for (Schema.PicklistEntry picklistItem : EmailMessage.Status.getDescribe().getPicklistValues())
                    emailMessageStatusMap.put(picklistItem.getLabel(), picklistItem.getValue());
            }
            return emailMessageStatusMap;
        }
        set;
    }

    /* Mapping from case record type to (changed) email message status to (desired) case status
     * When a Email Message's status is changed to the specified status, if the case record type is as limited,
     * then the case status should corresponding be updated
     * {
     *      "ASU_Advisor_Outreach": {
     *          "Sent": "Email Sent",
     *          "Replied": "Customer Replied"
     *      },
     *      "ASU_Graduate_Advisor_Portal": {
     *          "Sent": "Email Sent"
     *      }
     * }
     */
    private static Map<String, Map<String, String>> caseStatusMdt {
        get {
            if (caseStatusMdt == null) {
                caseStatusMdt = new Map<String, Map<String, String>>();
                List<Email_Message_Case_Status__mdt> metadata = statusMetadataRecords;

                for (Email_Message_Case_Status__mdt metadatum : metadata) {
                    if (!caseStatusMdt.containsKey(metadatum.Case_Record_Type__c))
                        caseStatusMdt.put(metadatum.Case_Record_Type__c, new Map<String, String>());
                    caseStatusMdt.get(metadatum.Case_Record_Type__c)
                        .put(emailMessageStatusMap.get(metadatum.Email_Message_Status__c), metadatum.Case_Status__c);
                }
            }

            return caseStatusMdt;
        }
        set;
    }

    // We define this using getter and setter so we can easily override the metadata returned in our test class
    @TestVisible
    private static List<Email_Message_Case_Status__mdt> statusMetadataRecords {
        get {
            if (statusMetadataRecords == null) {
                statusMetadataRecords = [
                    SELECT Case_Record_Type__c, Email_Message_Status__c, Case_Status__c
                    FROM Email_Message_Case_Status__mdt
                    WHERE Enabled__c = TRUE
                ];
            }
            return statusMetadataRecords;
        }
        set;
    }

    /*
     * All email messages look up to a case. This method returns a map of Id to case containing
     * all of the parent cases for the email. Can be accessed in trigger by result.get(EmailMessage.parentId).
     */
    public static void updateCasesFromEmailMessages(List<EmailMessage> newEmails, Map<Id, EmailMessage> oldEmailMap) {
        List<String> vars = new List<String>();
        vars.add(ErrorLogger.convertListToJSON('newEmails', newEmails));
        vars.add(ErrorLogger.convertMapToJSON('oldEmailMap', oldEmailMap));
        vars.add(ErrorLogger.convertListToJSON('statusMetadataRecords', statusMetadataRecords));

        try {
            Validator caseValidator = new Validator(Case.getSObjectType());
            Map<Id, EmailMessage> caseIdToEmailMessage = new Map<Id, EmailMessage>();

            // Get all the EmailMessage for Cases
            for (EmailMessage em : newEmails)
                if (caseValidator.validId(em.ParentId))
                    caseIdToEmailMessage.put(em.ParentId, em);

            vars.add(ErrorLogger.convertMapToJSON('caseIdToEmailMessage', caseIdToEmailMessage));
            if (!caseIdToEmailMessage.isEmpty()) {
                List<Case> updatedCases = new List<Case>();

                // Get all the cases for those EmailMessages
                for (Case c : [
                    SELECT Status, RecordType.DeveloperName
                    FROM Case
                    WHERE Id IN :caseIdToEmailMessage.keySet()
                ]) {
                    EmailMessage em = caseIdToEmailMessage.get(c.Id);
                    EmailMessage oldEm = oldEmailMap?.get(c.Id);

                    // And update them if needed
                    Case updatedCase = getUpdatedCase(em, oldEm, c);
                    if (updatedCase != null)
                        updatedCases.add(updatedCase);
                }

                if (!updatedCases.isEmpty())
                    update updatedCases;
            }
        } catch (Exception ex) {
            System.debug('ERROR');
            System.debug(ex);
            ErrorLogger.log(ex, vars, debug);
        }
    }

    /**
     * If the case needs to have status updated, return a new Case record with the updated status.
     * If it doesn't need to be updated, return null

     * @param {EmailMessage} The new EmailMessage record
     * @param {EmailMessage} The old EmailMessage record
     * @param {Case} The Case record associated with the EmailMessage
     * @return Case record with updated status or null if status does not need to be changed
     */
    private static Case getUpdatedCase(EmailMessage newRecord, EmailMessage oldRecord, Case correspondingCase) {
        // EmailMessage's status has changed,
        // and there are rules for this case's record type,
        // and there are rules for the email message's new status
        if (
            RecordHelper.hasNewOrChangedField(newRecord, oldRecord, EmailMessage.Status) &&
            caseStatusMdt.containsKey(correspondingCase.RecordType.DeveloperName) &&
            caseStatusMdt.get(correspondingCase.RecordType.DeveloperName).containsKey(newRecord.Status)
        ) {
            return new Case(
                Id = correspondingCase.Id,
                Status = caseStatusMdt.get(correspondingCase.RecordType.DeveloperName).get(newRecord.Status)
            );
        }

        return null;
    }

    private class EmailMessageServiceException extends exception {
    }
}
