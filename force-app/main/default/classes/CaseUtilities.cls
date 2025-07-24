public class CaseUtilities {
    public static boolean emailForwarded = false;
    
    private static List<Schema.PicklistEntry> caseForwardToUnitOptions = Case.Forward_To_Unit__c.getDescribe()
        .getPicklistValues();
    
    public static void forwardCaseAttachments(Id caseId, String forwardToEmail, String forwardToEmailCalc) {
        String dummyContactId;
        String emailTemplateId;
        String recipientEmailAddress;
        
        if (forwardToEmailCalc != null && forwardToEmailCalc != '') {
            recipientEmailAddress = forwardToEmailCalc;
        } else if (forwardToEmail != null && forwardToEmail != '') {
            recipientEmailAddress = forwardToEmail;
        } else {
            // Nowhere to send our email
            return;
        }
        
        List<Case_Forwarding_Settings__c> settingsList = [
            SELECT Name, Value__c FROM Case_Forwarding_Settings__c
        ];
        if (settingsList.size() > 0) {
            for (Case_Forwarding_Settings__c s : settingsList) {
                if (s.Name == 'Dummy Contact ID') {
                    dummyContactId = s.Value__c;
                } else if (s.Name == 'Email Template ID') {
                    emailTemplateId = s.Value__c;
                }
            }
        } else {
            return;
        }
        
        Set<Id> relatedParentIds = new Set<Id>{caseId};
            for (EmailMessage em : [SELECT Id FROM EmailMessage WHERE ParentId = :caseId]) {
                relatedParentIds.add(em.Id);
            }
        
        List<ContentDocumentLink> contentDocLinks = [
            SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :relatedParentIds
        ];
        
        Set<Id> contentDocIds = new Set<Id>();
        for (ContentDocumentLink link : contentDocLinks) {
            contentDocIds.add(link.ContentDocumentId);
        }
        
        List<ContentVersion> allVersions = [
            SELECT Id, Title, VersionData, ContentSize, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocIds
            ORDER BY LastModifiedDate DESC
        ];
        
        // duplicate to only keep latest per ContentDocumentId
        Map<Id, ContentVersion> latestVersionsByDoc = new Map<Id, ContentVersion>();
        for (ContentVersion cv : allVersions) {
            if (!latestVersionsByDoc.containsKey(cv.ContentDocumentId)) {
                latestVersionsByDoc.put(cv.ContentDocumentId, cv);
            }
        }
        
        Boolean attachmentsTooLarge = false;
        Double sizeCounter = 0;
        Messaging.EmailFileAttachment[] attachmentList = new List<Messaging.EmailFileAttachment>();
        
        for (ContentVersion cv : latestVersionsByDoc.values()) {
            sizeCounter += cv.ContentSize;
            if (sizeCounter > 25000000) {
                attachmentsTooLarge = true;
                break;
            }
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(cv.Title);
            efa.setBody(cv.VersionData);
            attachmentList.add(efa);
        }
        
        Contact c = [SELECT Id, Email FROM Contact WHERE Id = :dummyContactId];
        
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        if (emailTemplateId != null)
            msg.setTemplateId(emailTemplateId);
        msg.setSaveAsActivity(true);
        msg.setWhatId(caseId);
        msg.setTargetObjectId(c.Id);
        msg.setToAddresses(new List<String>{ c.Email });
        
        lstMsgs.add(msg);
        
        Savepoint sp = Database.setSavepoint();
        if(!Test.isRunningTest())
            Messaging.sendEmail(lstMsgs);
        Database.rollback(sp);
        
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : lstMsgs) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(new List<String>{ recipientEmailAddress });
            emailToSend.setWhatId(caseId);
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            if (attachmentList.size() > 0)
                emailToSend.setFileAttachments(attachmentList);
            lstMsgsToSend.add(emailToSend);
        }
        
        try {
            Messaging.reserveSingleEmailCapacity(1);
            if(!Test.isRunningTest())
                Messaging.sendEmail(lstMsgsToSend);
        } catch (Exception e) {
            //Most likely SINGLE_EMAIL_LIMIT_EXCEEDED; catching so the transaction will continue
        }
    }
    
    private static String limitLength(String input, Integer maxLength) {
        String results;
        if (input != null && input.length() > maxLength)
            results = input.substring(0, maxLength);
        else
            results = input;
        return results;
    }
    
    public static String getForwardToUnit(String unitApiName) {
        for (Schema.PicklistEntry entry : caseForwardToUnitOptions) {
            if (entry.getValue() == unitApiName) {
                return entry.getLabel();
            }
        }
        return '';
    }
}