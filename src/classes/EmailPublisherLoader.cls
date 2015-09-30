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
            OrgWideEmailAddress oweaToUse;

            Case currentCase = CaseService.getCaseInformation(sendEmailDefaults.getContextId());

            // Set the email information correctly
            EmailMessage caseEmailToSend = (EmailMessage)sendEmailDefaults.getTargetSObject();

            Contact caseContact = ContactService.getContactInformation(currentCase.ContactId);

            // If we have an issue getting the OWEA from the service, catch the exception and use the customerservice@asu.edu one instead.
            try
            {
                oweaToUse = OrgWideEmailAddressService.getOrgWideEmailAddress(currentCase.Case_Feed_Email__c);
            }
            catch (OrgWideEmailAddressService.OrgWideEmailAddressServiceException e)
            {
                oweaToUse = OrgWideEmailAddressService.getOrgWideEmailAddress('customerservice@asu.edu');
            }

            caseEmailToSend.ToAddress = caseContact.Email;
            caseEmailToSend.FromAddress = oweaToUse.Address;
            caseEmailToSend.FromName = oweaToUse.DisplayName;

            sendEmailDefaults.setInsertTemplateBody(true);

            // Null check the Case Feed Email Template Id field on the case. It may not be set for some reason.
            if (currentCase.Case_Feed_Email_Template_Id__c != null)
            {
                sendEmailDefaults.setTemplateId(currentCase.Case_Feed_Email_Template_Id__c);
            }
        }
    }
}