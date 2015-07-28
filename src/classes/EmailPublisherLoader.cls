global class EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global EmailPublisherLoader() {}

    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;

        // Check if the quick action is the standard Case Feed send email action
        for (Integer j = 0; j < defaults.size(); j++)
        {
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults &&
               defaults.get(j).getTargetSObject().getSObjectType() ==
                   EmailMessage.sObjectType &&
               defaults.get(j).getActionName().equals('Case.Email') &&
               defaults.get(j).getActionType().equals('Email'))
            {
                   sendEmailDefaults =
                       (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                   break;
            }
        }

        // Preload the Case Feed with the correct information for sending an Email
        if (sendEmailDefaults != null)
        {
            Case currentCase = CaseService.getCaseInformation(sendEmailDefaults.getContextId());

            // Set the email information correctly
            EmailMessage caseEmailToSend = (EmailMessage)sendEmailDefaults.getTargetSObject();
            Contact caseContact = ContactService.getContactInformation(currentCase.ContactId);
            OrgWideEmailAddress oweaToUse = OrgWideEmailAddressService.getOrgWideEmailAddress(currentCase.Most_Recent_Sent_To_Email__c);
            caseEmailToSend.ToAddress = caseContact.Email;
            caseEmailToSend.FromAddress = oweaToUse.Address;
            caseEmailToSend.FromName = oweaToUse.DisplayName;

            // Load the default email template configurations
            List<Case_Default_Email_Templates__c> defaultEmailTempConf = 
            [SELECT Template_Name__c, Functional_Group__c, Name 
             FROM Case_Default_Email_Templates__c];

            // Get a map of all the EmailTemplates in this org
            Map<String, EmailTemplate> emailTemplates = EmailTemplateService.getEmailTemplatesByAPIName();

            // Set the default template
            EmailTemplate emailTemplateToUse = EmailTemplateService.getDefaultEmailTemplateForCaseFeed(emailTemplates, defaultEmailTempConf, currentCase.Functional_Group__c);
            sendEmailDefaults.setInsertTemplateBody(true);
            sendEmailDefaults.setTemplateId(emailTemplateToUse.Id);
        }
    }
}