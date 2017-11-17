public class PortalEmailService {
    /*
     * Splits the email records by record type and passes Id lists
     * to future methods for processing in bulk.
     */
    public static void setFromAddress(Map<Id, Portal_Email__c> emailsToUpdate) {
        Id advisorRTID = RTIDHelper.getRTID('Portal_Email__c', 'Advisor');
        Id coachRTID = RTIDHelper.getRTID('Portal_Email__c', 'Coach');
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
    private static void enqueueAdvisor(Set<Id> emailIds) {
        Map<Id, String> studentPrimaryEmailMap = new Map<Id, String>();
        Map<Id, String> ownedByQueueEmailMap = new Map<Id, String>();
        Map<String, String> mostRecentQueueEmailMap = new Map<String, String>();
        
        Map<Id, Portal_Email__c> emailsToUpdate = new Map<Id, Portal_Email__c>(
        	[
                SELECT Primary_Owner_Id__c, Case_Most_Recent_Queue__c, RecordTypeId, From_Address__c, Success_Student__c
                FROM Portal_Email__c
                WHERE Id IN :emailIds
            ]
        );
        
        // Prep the validator
        Validator.setPrefix(Group.Class);
        
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
            for (Success_Student__c ss : [SELECT Success_Pod__r.Primary_Email__c
                FROM Success_Student__c
                WHERE Id IN :studentPrimaryEmailMap.keySet()]) {
                studentPrimaryEmailMap.put(ss.Id, ss.Success_Pod__r.Primary_Email__c);
            }
            
            for (Portal_Email__c pe : emailsToUpdate.values()) {
                pe.From_Address__c = studentPrimaryEmailMap.get(pe.Success_Student__c);
            }
        }
        
        // For cases, we need to get a queue Id and use it to query for the pod
        // The queue Id could be the owner OR the most recent queue
        // Most recent queue is the Name of the queue so we need to query the group object
        // to get it's ID
        // I use 2 maps with different keys to simplify referencing the queue from the pe
        // record
        if (ownedByQueueEmailMap.size() > 0) {
            for (Success_Pod__c sp : [SELECT Primary_Email__c, ownerId
                FROM Success_Pod__c
                WHERE ownerId IN : ownedByQueueEmailMap.keySet()]) {
                ownedByQueueEmailMap.put(sp.OwnerId, sp.Primary_Email__c);
            }
        }
        
        if (mostRecentQueueEmailMap.size() > 0) {
            for (Success_Pod__c sp : [SELECT Primary_Email__c, Owner_Name__c
                FROM Success_Pod__c
                WHERE Owner_Name__c IN :mostRecentQueueEmailMap.keySet()]) {
                mostRecentQueueEmailMap.put(sp.Owner_Name__c, sp.Primary_Email__c);
            }
        }
        
        for (Portal_Email__c pe : emailsToUpdate.values()) {
            if (Validator.validateId(pe.Primary_Owner_Id__c)) {
                pe.From_Address__c = ownedByQueueEmailMap.get(pe.Primary_Owner_Id__c);
            } else if (pe.Success_Student__c == null) {
                pe.From_Address__c = mostRecentQueueEmailMap.get(pe.Case_Most_Recent_Queue__c);
            }
        }
        
        update emailsToUpdate.values();
        
        // Now that we inserted and updated the from address, finish by creating a viewable record
        createEmailMessage(emailsToUpdate.keySet());
    }
    
    @future
    private static void enqueueCoach(Set<Id> emailIds) {
        Map<Id, Portal_Email__c> emailsToUpdate = new Map<Id, Portal_Email__c>(
        	[
                SELECT From_Address__c, CreatedBy.Recruiter_Email__c
                FROM Portal_Email__c
                WHERE Id IN :emailIds
            ]
        );
        
        for (Portal_Email__c pe : emailsToUpdate.values()) {
            pe.From_Address__c = pe.createdBy.Recruiter_Email__c;
        }
        
        update emailsToUpdate.values();
        
        createEmailMessage(emailsToUpdate.keySet());
    }
    
    private static void createEmailMessage(Set<Id> emailIds) {
        List<EmailMessage> newMessages = new List<EmailMessage>();
        
        for (Portal_Email__c pe : [SELECT From_Address__c, Contact_Email__c, Additional_Message_Text__c, Case__c, From_Name__c,
                Email_Template_Name__c
            FROM Portal_Email__c
            WHERE Id IN :emailIds]) {
            if (pe.Case__c != null) {
                newMessages.add(new EmailMessage(
                    FromAddress = pe.From_Address__c,
                    FromName = pe.From_Name__c,
                    ToAddress = pe.Contact_Email__c,
                    parentId = pe.Case__c,
                    Subject = pe.Email_Template_Name__c,
                    HTMLBody = pe.Additional_Message_Text__c,
                    TextBody = pe.Additional_Message_Text__c
                ));
            }
            
        }
        
        if (newMessages.size() > 0) {
            insert newMessages;
        }
    }
}