public class CaseUtilities {
    public static void forwardCaseAttachments(Id caseId, string forwardToEmail, string forwardToEmailCalc) {

        String dummyContactId;
        String emailTemplateId;
        String recipientEmailAddress;

		if (forwardToEmailCalc != null && forwardToEmailCalc != '') {
			recipientEmailAddress = forwardToEmailCalc;
		}
		else if (forwardToEmail != null && forwardToEmail != '') {
			recipientEmailAddress = forwardToEmail;
		}
		else {
			// Nowhere to send our email
			//
			return;
		} 

		List<Case_Forwarding_Settings__c> settingsList = new List<Case_Forwarding_Settings__c>([SELECT Name, Value__c FROM Case_Forwarding_Settings__c]);
		if (settingsList.size() > 0) {
			for (Case_Forwarding_Settings__c s: settingsList) {
				if (s.Name == 'Dummy Contact ID')
					dummyContactId = s.Value__c;
				else if (s.Name == 'Email Template ID')
					emailTemplateId = s.Value__c;
			}
		} 
		else {
			return;	
		}
		
        List<Attachment> aList = new List<Attachment>();
        Map<Id, SObject> caseEmailMap = new Map<Id, SObject>([SELECT Id FROM EmailMessage WHERE ParentId = :caseId]);
        aList = [SELECT Id, Name, Body, LastModifiedDate, CreatedBy.Name, BodyLength FROM Attachment WHERE (ParentId = :caseId OR ParentId IN :caseEmailMap.keySet()) ORDER BY LastModifiedDate];
        system.debug('GRF aList:' + aList);
        Boolean attachmentsTooLarge = false;
        Messaging.EmailFileAttachment[] attachmentList = new List<Messaging.EmailFileAttachment>();
        
        if (aList.size() > 0) {
            Double sizeCounter = 0;
            for (Attachment a: aList) {
                sizeCounter += a.BodyLength;
                // Check for maximum attachment length; stop here if we will exceed it
                //
                if (sizeCounter > 25000000) {
                    attachmentsTooLarge = true;
                    break;
                }
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(a.Name);
                efa.setBody(a.Body);
                attachmentList.add(efa);
            }
        }
        
		// Workaround for sending a templated email to an external email address from Apex:
		// Create the email using an existing contact, "send it", rollback the transaction,
		// and copy the email contents to another email message that actually is sent
		//
		
		// Pick an existing Contact that will be used to create a dummy email
		// 
		Contact c = [select id, Email from Contact where Id = :dummyContactId];
		
		List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
		
		Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
		if (emailTemplateId != null)
			msg.setTemplateId(emailTemplateId);
		msg.setSaveAsActivity(true);
		msg.setWhatId(caseId);
		msg.setTargetObjectId(c.id);
		msg.setToAddresses(new List<String>{c.Email});
		
		lstMsgs.add(msg);
		
		// Send the emails in a transaction, then roll it back
		Savepoint sp = Database.setSavepoint();
		Messaging.sendEmail(lstMsgs);
		Database.rollback(sp);
		
		// For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
		// contents to a new SingleEmailMessage. Then send those new messages.
		List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
		for (Messaging.SingleEmailMessage email : lstMsgs) {
		Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
		// emailToSend.setToAddresses(email.getToAddresses());
		emailToSend.setToAddresses(new List<String>{recipientEmailAddress});
		emailToSend.setWhatId(caseId);
		emailToSend.setPlainTextBody(email.getPlainTextBody());
		emailToSend.setHTMLBody(email.getHTMLBody());
		emailToSend.setSubject(email.getSubject());
		if (attachmentList.size() > 0)
			emailToSend.setFileAttachments(attachmentList);
		lstMsgsToSend.add(emailToSend);
        createEmailMessage(caseId, emailToSend, recipientEmailAddress);    
		}
        
        try {
            Messaging.reserveSingleEmailCapacity(1); 
            Messaging.sendEmail(lstMsgsToSend);
        }
        catch (Exception e) {
            //Most likely SINGLE_EMAIL_LIMIT_EXCEEDED; catching so the transaction will continue
            //
        }
        
    }

    private static String limitLength(String input, Integer maxLength) {
        String results;
        if(input != null && input.length() > maxLength)
            results = input.substring(0,maxLength);
        else 
            results = input;
        return results;
    }
    
    private static void createEmailMessage(Id caseId, Messaging.SingleEmailMessage email, String toEmailAddress) {
        String value;
        Integer maxlength;
        EmailMessage theEmail = new EmailMessage();
        theEmail.ParentId = caseId;
        theEmail.Incoming = false;
        Schema.DescribeFieldResult F = EmailMessage.HtmlBody.getDescribe();
        maxlength = F.getLength();
        theEmail.Subject = limitLength(email.Subject, EmailMessage.Subject.getDescribe().getLength());
        theEmail.MessageDate = datetime.now();
        theEmail.HtmlBody = limitLength(email.htmlBody,EmailMessage.HtmlBody.getDescribe().getLength());  
        theEmail.TextBody = limitLength(email.plainTextBody,EmailMessage.TextBody.getDescribe().getLength());

        theEmail.ToAddress = toEmailAddress;
         
        theEmail.FromName = email.getSenderDisplayName();

        insert theEmail;
    }


}