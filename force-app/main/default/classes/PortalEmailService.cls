public class PortalEmailService {
    private static Boolean debug = false;

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

    public static void setFromAndTemplateForAdvisorEmails(List<Portal_Email__c> portalEmails) {
        List<String> vars = new List<String>();
        vars.add(ErrorLogger.convertListToJSON('portalEmails', portalEmails));

        try {
            Id advisorRTID = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Advisor');

            List<Portal_Email__c> advisorEmails = new List<Portal_Email__c>();

            for (Portal_Email__c pe : portalEmails)
                if (pe.RecordTypeId == advisorRTID)
                    advisorEmails.add(pe);

            vars.add(ErrorLogger.convertListToJSON('advisorEmails', advisorEmails));
            if (!advisorEmails.isEmpty()) {
                Map<String, Success_Pod__c> valueToSuccessPod = new Map<String, Success_Pod__c>();

                Set<Id> successStudentIds = new Set<Id>();
                Set<Id> ownedByQueueIds = new Set<Id>();
                Set<String> mostRecentQueueNames = new Set<String>();

                Validator groupValidator = new Validator(Group.getSObjectType());

                for (Portal_Email__c pe : advisorEmails) {
                    if (pe.Success_Student__c != null)
                        // If success student marked, we will use email on the success pod
                        successStudentIds.add(left15(pe.Success_Student__c));
                    else if (groupValidator.validId(pe.Primary_Owner_Id__c))
                        // If no successs student, but is owned by a queue, then use email from that queue's success pod
                        ownedByQueueIds.add(left15(pe.Primary_Owner_Id__c));
                    else if (pe.Case_Most_Recent_Queue__c != null)
                        // If no success student, and not owned by a Group, then use email from the most revent queue's success pod
                        mostRecentQueueNames.add(pe.Case_Most_Recent_Queue__c);
                }
                vars.add(ErrorLogger.convertSetToJSON('successStudentIds', successStudentIds));
                vars.add(ErrorLogger.convertSetToJSON('ownedByQueueIds', ownedByQueueIds));
                vars.add(ErrorLogger.convertSetToJSON('mostRecentQueueNames', mostRecentQueueNames));

                // For students, they should have a look up to the pod that can be used
                if (successStudentIds.size() > 0) {
                    for (Success_Student__c ss : [
                        SELECT Success_Pod__r.Primary_Email__c, Success_Pod__r.Email_Template__c
                        FROM Success_Student__c
                        WHERE Id IN :successStudentIds
                    ]) {
                        // Map those using succss student's success pod
                        valueToSuccessPod.put(
                            left15(ss.Id),
                            new Success_Pod__c(
                                Primary_Email__c = ss.Success_Pod__r.Primary_Email__c,
                                Email_Template__c = ss.Success_Pod__r.Email_Template__c
                            )
                        );
                    }
                }

                // For cases, we need to get a queue Id and use it to query for the pod
                // The queue Id could be the owner OR the most recent queue
                // Most recent queue is the Name of the queue so we need to query the group object
                // to get it's ID
                if (ownedByQueueIds.size() > 0 || mostRecentQueueNames.size() > 0) {
                    for (Success_Pod__c sp : [
                        SELECT Primary_Email__c, Email_Template__c, OwnerId, Owner_Name__c
                        FROM Success_Pod__c
                        WHERE OwnerId IN :ownedByQueueIds OR Owner_Name__c IN :mostRecentQueueNames
                    ]) {
                        // Map those using ownerid (for those currently owned by a queue)
                        if (ownedByQueueIds.contains(left15(sp.OwnerId))) {
                            valueToSuccessPod.put(left15(sp.OwnerId), sp);
                        }

                        // Map those using owner name (for those using most recent queue name)
                        if (mostRecentQueueNames.contains(sp.Owner_Name__c)) {
                            valueToSuccessPod.put(sp.Owner_Name__c, sp);
                        }
                    }
                }

                // Mark from address and template for each portal email
                for (Portal_Email__c pe : advisorEmails) {
                    if (
                        pe.Success_Student__c != null &&
                        successStudentIds.contains(left15(pe.Success_Student__c)) &&
                        valueToSuccessPod.get(left15(pe.Success_Student__c)) != null
                    ) {
                        // If success student available, use success student's success pod
                        pe.From_Address__c = valueToSuccessPod.get(left15(pe.Success_Student__c)).Primary_Email__c;
                        pe.Email_Template_Name__c = valueToSuccessPod.get(left15(pe.Success_Student__c))
                            .Email_Template__c;
                    } else if (
                        pe.Primary_Owner_Id__c != null &&
                        groupValidator.validId(pe.Primary_Owner_Id__c) &&
                        ownedByQueueIds.contains(left15(pe.Primary_Owner_Id__c)) &&
                        valueToSuccessPod.get(left15(pe.Primary_Owner_Id__c)) != null
                    ) {
                        // otherwise, if owned by a queue, then use queue's success pod
                        pe.From_Address__c = valueToSuccessPod.get(left15(pe.Primary_Owner_Id__c)).Primary_Email__c;
                        pe.Email_Template_Name__c = valueToSuccessPod.get(left15(pe.Primary_Owner_Id__c))
                            .Email_Template__c;
                    } else if (
                        pe.Case_Most_Recent_Queue__c != null &&
                        mostRecentQueueNames.contains(pe.Case_Most_Recent_Queue__c) &&
                        valueToSuccessPod.get(pe.Case_Most_Recent_Queue__c) != null
                    ) {
                        // otherwise, if possible, use most recent queue's success pod
                        pe.From_Address__c = valueToSuccessPod.get(pe.Case_Most_Recent_Queue__c).Primary_Email__c;
                        pe.Email_Template_Name__c = valueToSuccessPod.get(pe.Case_Most_Recent_Queue__c)
                            .Email_Template__c;
                    } else {
                        // finally, default to use the Advisor Ad-hoc template template if no pods matched and it is otherwise unspecified
                        if (pe.Email_Template_Name__c == null)
                            pe.Email_Template_Name__c = 'Advisor Ad-hoc template';
                    }
                }
            }
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
    }

    public static void setFromAddressForCoachEmails(List<Portal_Email__c> portalEmails) {
        List<String> vars = new List<String>();
        vars.add(ErrorLogger.convertListToJSON('portalEmails', portalEmails));

        try {
            Id coachRTID = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Coach');

            List<Portal_Email__c> coachEmails = new List<Portal_Email__c>();

            for (Portal_Email__c pe : portalEmails)
                if (pe.RecordTypeId == coachRTID)
                    coachEmails.add(pe);

            vars.add(ErrorLogger.convertListToJSON('coachEmails', coachEmails));
            if (!coachEmails.isEmpty()) {
                Set<Id> creatorIds = new Set<Id>();

                for (Portal_Email__c pe : coachEmails) {
                    // Use CreatedById if possible - but in some trigger contexts this is not set yet (such as before insert),
                    // in which case we need to use the current user (since they will soon be assigned as the creator)
                    if (pe.CreatedById != null) {
                        creatorIds.add(pe.CreatedById);
                    } else {
                        creatorIds.add(UserInfo.getUserId());
                    }
                }
                vars.add(ErrorLogger.convertSetToJSON('creatorIds', creatorIds));

                Map<Id, User> creators = new Map<Id, User>(
                    [SELECT Id, Recruiter_Email__c FROM User WHERE Id IN :creatorIds]
                );
                vars.add(ErrorLogger.convertMapToJSON('creators', creators));

                for (Portal_Email__c pe : coachEmails)
                    if (pe.CreatedById != null) {
                        if (creators.containsKey(pe.CreatedById))
                            pe.From_Address__c = creators.get(pe.CreatedById).Recruiter_Email__c;
                    } else {
                        if (creators.containsKey(UserInfo.getUserId()))
                            pe.From_Address__c = creators.get(UserInfo.getUserId()).Recruiter_Email__c;
                    }
            }
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
    }

    private static String left15(String s) {
        if (s == null)
            return null;
        if (s.length() < 15)
            return s;
        return s.substring(0, 15);
    }

    public static void createEmailMessages(List<Portal_Email__c> portalEmails) {
        List<String> vars = new List<String>();
        vars.add(ErrorLogger.convertListToJSON('portalEmails', portalEmails));

        try {
            List<Id> emailIds = new List<Id>();
            for (Portal_Email__c pe : portalEmails)
                emailIds.add(pe.Id);
            vars.add(ErrorLogger.convertListToJSON('emailIds', emailIds));

            List<EmailMessage> newMessages = new List<EmailMessage>();

            // Create and EmailMessage record for each
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

            vars.add(ErrorLogger.convertListToJSON('newMessages', newMessages));

            if (newMessages.size() > 0) {
                insert newMessages;
            }
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
    }

    private class PortalEmailServiceException extends exception {
    }
}
