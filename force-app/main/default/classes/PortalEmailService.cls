public class PortalEmailService {
    private static boolean debug = false;
    /*
     * Splits the email records by record type and passes Id lists
     * to future methods for processing in bulk.
     */
    public static void setFromAddress(Map<Id, Portal_Email__c> emailsToUpdate) {
        Id advisorRTID = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Advisor');
        Id coachRTID = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Coach');
        Set<Id> advisorEmails = new Set<Id>();
        Set<Id> coachEmails = new Set<Id>();

        for (Portal_Email__c pe : emailsToUpdate.values()) {
            if (pe.RecordTypeId == advisorRTID) {
                advisorEmails.add(pe.Id);
            } else if (pe.RecordTypeId == coachRTID) {
                coachEmails.add(pe.Id);
            }
        }

        if (advisorEmails.size() > 0) {
            enqueueAdvisor(advisorEmails);
        }

        if (coachEmails.size() > 0) {
            enqueueCoach(coachEmails);
        }
    }

    @future
    @TestVisible
    private static void enqueueAdvisor(Set<Id> emailIds) {
        Map<Id, String> studentPrimaryEmailMap = new Map<Id, String>();
        Map<Id, String> studentPrimaryEmailTemplateMap = new Map<Id, String>();
        Map<Id, String> ownedByQueueEmailMap = new Map<Id, String>();
        Map<String, String> mostRecentQueueEmailMap = new Map<String, String>();
        Map<Id, String> ownedByQueueEmailTemplateMap = new Map<Id, String>();
        Map<String, String> mostRecentQueueEmailTemplateMap = new Map<String, String>();
        Map<Id, Portal_Email__c> emailsToUpdate;
        List<String> vars = new List<String>();
        try {
            if (emailIds == null) {
                throw new PortalEmailServiceException('EmailIds parameter is null');
            }

            emailsToUpdate = new Map<Id, Portal_Email__c>(
                [
                    SELECT
                        Primary_Owner_Id__c,
                        Case_Most_Recent_Queue__c,
                        RecordTypeId,
                        From_Address__c,
                        Success_Student__c,
                        Email_Template_Name__c,
                        Contact__r.FirstName
                    FROM Portal_Email__c
                    WHERE Id IN :emailIds
                ]
            );

            // Prep the validator
            Validator.setPrefix(Group.class);

            for (Portal_Email__c pe : emailsToUpdate.values()) {
                if (pe.Success_Student__c != null) {
                    studentPrimaryEmailMap.put(pe.Success_Student__c, null);
                } else {
                    if (Validator.validateId(pe.Primary_Owner_Id__c)) {
                        ownedByQueueEmailMap.put(pe.Primary_Owner_Id__c, null);
                    } else {
                        mostRecentQueueEmailMap.put(pe.Case_Most_Recent_Queue__c, null);
                    }
                }
            }

            // For students, they should have a look up to the pod that can be abused
            if (studentPrimaryEmailMap.size() > 0) {
                for (Success_Student__c ss : [
                    SELECT Success_Pod__r.Primary_Email__c, Success_Pod__r.Email_Template__c
                    FROM Success_Student__c
                    WHERE Id IN :studentPrimaryEmailMap.keySet()
                ]) {
                    studentPrimaryEmailMap.put(ss.Id, ss.Success_Pod__r.Primary_Email__c);
                    studentPrimaryEmailTemplateMap.put(ss.Id, ss.Success_Pod__r.Email_Template__c);
                }

                for (Portal_Email__c pe : emailsToUpdate.values()) {
                    pe.From_Address__c = studentPrimaryEmailMap.get(pe.Success_Student__c);
                    pe.Email_Template_Name__c = studentPrimaryEmailTemplateMap.get(pe.Success_Student__c);
                    system.debug(pe.Email_Template_Name__c);
                }
            }

            // For cases, we need to get a queue Id and use it to query for the pod
            // The queue Id could be the owner OR the most recent queue
            // Most recent queue is the Name of the queue so we need to query the group object
            // to get it's ID
            // I use 2 maps with different keys to simplify referencing the queue from the pe
            // record
            if (ownedByQueueEmailMap.size() > 0) {
                for (Success_Pod__c sp : [
                    SELECT Primary_Email__c, Email_Template__c, ownerId
                    FROM Success_Pod__c
                    WHERE ownerId IN :ownedByQueueEmailMap.keySet()
                ]) {
                    ownedByQueueEmailMap.put(sp.OwnerId, sp.Primary_Email__c);
                    ownedByQueueEmailTemplateMap.put(sp.OwnerId, sp.Email_Template__c);
                }
            }

            if (mostRecentQueueEmailMap.size() > 0) {
                for (Success_Pod__c sp : [
                    SELECT Primary_Email__c, Email_Template__c, Owner_Name__c
                    FROM Success_Pod__c
                    WHERE Owner_Name__c IN :mostRecentQueueEmailMap.keySet()
                ]) {
                    mostRecentQueueEmailMap.put(sp.Owner_Name__c, sp.Primary_Email__c);
                    mostRecentQueueEmailTemplateMap.put(sp.Owner_Name__c, sp.Email_Template__c);
                }
            }

            for (Portal_Email__c pe : emailsToUpdate.values()) {
                system.debug(pe.Email_Template_Name__c);

                if (Validator.validateId(pe.Primary_Owner_Id__c)) {
                    pe.From_Address__c = ownedByQueueEmailMap.get(pe.Primary_Owner_Id__c);
                    pe.Email_Template_Name__c = ownedByQueueEmailTemplateMap.get(pe.Primary_Owner_Id__c);
                } else if (pe.Success_Student__c == null) {
                    pe.From_Address__c = mostRecentQueueEmailMap.get(pe.Case_Most_Recent_Queue__c);
                    pe.Email_Template_Name__c = mostRecentQueueEmailTemplateMap.get(pe.Case_Most_Recent_Queue__c);
                }
            }

            update emailsToUpdate.values();

            // Now that we inserted and updated the from address, finish by creating a viewable record
            createEmailMessage(emailsToUpdate.keySet());
        } catch (Exception e) {
            vars.add(string.valueOf(emailsToUpdate));
            vars.add(string.valueOf(studentPrimaryEmailMap));
            vars.add(string.valueOf(ownedByQueueEmailMap));
            vars.add(string.valueOf(mostRecentQueueEmailMap));
            ErrorLogger.log(e, vars, debug);
        }
    }

    public static void verifySubject(List<Portal_Email__c> emailsToValidate) {
        for (Portal_Email__c pe : emailsToValidate) {
            if (pe.Subject__c == '' || pe.Subject__c == null) {
                pe.Subject__c = 'A Message from your College and Department';
            }
        }
    }

    public static void verifyMessageText(List<Portal_Email__c> emailsToValidate) {
        for (Portal_Email__c pe : emailsToValidate) {
            if (pe.Additional_Message_Text__c == '' || pe.Additional_Message_Text__c == null) {
                pe.Status__c = 'Cancelled';
            }
        }
    }

    @future
    @TestVisible
    private static void enqueueCoach(Set<Id> emailIds) {
        Map<Id, Portal_Email__c> emailsToUpdate;
        List<String> vars = new List<String>();
        try {
            if (emailIds == null) {
                throw new PortalEmailServiceException('EmailIds parameter is null');
            }

            emailsToUpdate = new Map<Id, Portal_Email__c>(
                [SELECT From_Address__c, CreatedBy.Recruiter_Email__c FROM Portal_Email__c WHERE Id IN :emailIds]
            );
            for (Portal_Email__c pe : emailsToUpdate.values()) {
                pe.From_Address__c = pe.createdBy.Recruiter_Email__c;
            }

            update emailsToUpdate.values();

            createEmailMessage(emailsToUpdate.keySet());
        } catch (Exception e) {
            vars.add(ErrorLogger.convertSetToJSON('emailIds', emailIds));
            vars.add(string.valueOf(emailsToUpdate));
            ErrorLogger.log(e, vars, debug);
        }
    }

    private static void createEmailMessage(Set<Id> emailIds) {
        List<EmailMessage> newMessages = new List<EmailMessage>();
        for (Portal_Email__c pe : [
            SELECT
                From_Address__c,
                Contact_Email__c,
                Subject__c,
                Additional_Message_Text__c,
                Case__c,
                From_Name__c,
                Email_Template_Name__c,
                Contact__r.FirstName,
                CreatedBy.Name,
                Status__c
            FROM Portal_Email__c
            WHERE Id IN :emailIds
        ]) {
            if (pe.Case__c != null && pe.Status__c != 'Cancelled') {
                newMessages.add(
                    new EmailMessage(
                        FromAddress = pe.From_Address__c,
                        FromName = pe.From_Name__c,
                        ToAddress = pe.Contact_Email__c,
                        parentId = pe.Case__c,
                        Subject = pe.Subject__c,
                        HTMLBody = 'Dear ' +
                            pe.Contact__r.FirstName +
                            ',<br/><br/>' +
                            pe.Additional_Message_Text__c +
                            '<br/><br/>Sincerely,<br/>' +
                            pe.CreatedBy.Name,
                        TextBody = 'Dear ' +
                            pe.Contact__r.FirstName +
                            ',\n\n' +
                            pe.Additional_Message_Text__c +
                            '\n\nSincerely,\n' +
                            pe.CreatedBy.Name
                    )
                );
            }
        }

        if (newMessages.size() > 0) {
            insert newMessages;
        }
    }
    private class PortalEmailServiceException extends exception {
    }
}
