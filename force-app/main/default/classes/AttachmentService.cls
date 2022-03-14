public with sharing class AttachmentService {
    private static final boolean debug = false; // Toggle debug error reporting

    /**
     * Look through attachments to identify any cases that need to be updated
     * <p>
     * SFE-5455: Loop through all attachments in the trigger and Identify any related
     * cases.
     *
     * @param List<Attachment> trigger.new
     * @return Map<Id,Case> a map containing all of the cases that will need updating
     */
    public static void getCasesFromAttachments(List<Attachment> newList) {
        String casePrefix = ObjectService.getKeyPrefix(new Case().getSObjectType()); // Case prefix
        String emailMessagePrefix = ObjectService.getKeyPrefix(new EmailMessage().getSObjectType()); // Email message Prefix
        Set<Id> emailMessages = new Set<Id>(); // List of emails with new attachments
        Map<Id, Case> casesToUpdate = new Map<Id, Case>(); // Map of cases to update
        String parentId; // Stores parent ID of attachments and emails as needed

        try {
            // Look through new attachments to check if any of them are on emails or cases
            for (Attachment attach : newList) {
                parentId = (String) attach.parentId;

                if (parentId.left(3) == casePrefix) {
                    casesToUpdate.put(attach.parentId, null);
                } else if (parentId.left(3) == emailMessagePrefix) {
                    emailMessages.add(attach.parentId);
                }
            }

            // Look through attachments on emails to find if any of them are for cases
            if (!emailMessages.isEmpty()) {
                for (EmailMessage em : [SELECT ParentId FROM EmailMessage WHERE Id IN :emailMessages]) {
                    // EmailMessages can only be children of cases so this check is not required
                    // This check is included in the event that the previous statement becomes false
                    parentId = (string) em.parentId;
                    if (parentId.left(3) == casePrefix) {
                        casesToUpdate.put(em.parentId, null);
                    }
                }
            }

            // Get all cases for updating from the database
            // Make sure to include any fields that might need to be updated later
            if (!casesToUpdate.isEmpty()) {
                for (Case caseUpdate : [
                    SELECT Id, Attachments__c, Description
                    FROM Case
                    WHERE Id IN :casesToUpdate.keySet()
                ]) {
                    if (caseUpdate.Description == null) {
                        caseUpdate.Description = ' Attachment received at ' + Datetime.now().formatLong();
                    }
                    casesToUpdate.Put(caseUpdate.Id, caseUpdate);
                }
                // Verify that all entries have values before returning
                for (Id i : casesToUpdate.keySet()) {
                    if (casesToUpdate.get(i) == null) {
                        casesToUpdate.remove(i);
                    }
                }
            }

            if (casesToUpdate != null && !casesToUpdate.isEmpty()) {
                setCaseNumberOfFiles(casesToUpdate);
            }
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('casePrefix', casePrefix));
            vars.add(ErrorLogger.convertStringToJSON('emailMessagePrefix', casePrefix));
            vars.add(ErrorLogger.convertStringToJSON('parentId', parentId));
            vars.add(ErrorLogger.convertMapToJSON('casesToUpdate', casesToUpdate));
            vars.add(ErrorLogger.convertSetToJSON('emailMessages', emailMessages));
            ErrorLogger.log(ex, vars, debug);
        }
    }

    /**
     * Look through cases to determine if they have any attachments
     * <p>
     * SFE-5455: If a case has no attachments the "has Attachment" box should
     * be set to false
     */
    private static void setCaseNumberOfFiles(Map<Id, Case> casesToUpdate) {
        Set<Id> emailMessageIds = new Set<id>(); // Aggregate of all email message Ids from All cases to update
        Map<Id, Integer> numberOfAttachmentsPerCase = new Map<Id, Integer>(); // Map of case ID to the number of attachments the case has

        try {
            // Pull cases from database and keep track of direct attachments
            for (Case caseUpdate : [
                SELECT Id, (SELECT Id FROM Attachments), (SELECT Id FROM EmailMessages)
                FROM Case
                WHERE Id IN :casesToUpdate.keySet()
            ]) {
                numberOfAttachmentsPerCase.put(caseUpdate.Id, caseUpdate.Attachments.size());

                // Gather email message Ids for bulk query
                for (EmailMessage em : caseUpdate.EmailMessages) {
                    emailMessageIds.Add(em.Id);
                }
            }

            // Pull email messages from database and track case to message count
            for (EmailMessage em : [
                SELECT Id, ParentId, (SELECT Id FROM Attachments)
                FROM EmailMessage
                WHERE Id IN :emailMessageIds
            ]) {
                Integer attachmentCount = numberOfAttachmentsPerCase.get(em.ParentId) + em.Attachments.size();
                numberOfAttachmentsPerCase.put(em.ParentId, attachmentCount);
            }

            // Filter out cases that still have attachments
            for (Id i : numberOfAttachmentsPerCase.keySet()) {
                casesToUpdate.get(i).Attachments__c = numberOfAttachmentsPerCase.get(i);
            }

            update casesToUpdate.values();
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertSetToJSON('emailMessageIds', emailMessageIds));
            vars.add(ErrorLogger.convertMapToJSON('numberOfAttachmentsPerCase', numberOfAttachmentsPerCase));
            vars.add(ErrorLogger.convertMapToJSON('casesToUpdate', casesToUpdate));
            ErrorLogger.log(ex, vars, debug);
        }
    }
}
