global class CaseDefaultEmailTemplateLoader implements Support.EmailTemplateSelector
{
	global CaseDefaultEmailTemplateLoader() {}

	global Id getDefaultEmailTemplateId(Id caseId) 
	{
		Case c = [SELECT Functional_Group__c 
				  FROM Case
				  WHERE Id = :caseId];

	    //Find the appropriate configuration
	    List<Case_Default_Email_Templates__c> configurations = null;
	    configurations = [SELECT Template_Name__c FROM Case_Default_Email_Templates__c WHERE Functional_Group__c = :c.Functional_Group__c];

	    Case_Default_Email_Templates__c confToUse = null;

	    if (!configurations.isEmpty())
	    {
	    	confToUse = configurations[0];
	    	System.debug('Found default case email template ' + confToUse.Template_Name__c);
	    }
	    else
	    {
	    	System.debug('No templates found, using the default one.');
	    	configurations = [SELECT Template_Name__c FROM Case_Default_Email_Templates__c WHERE Functional_Group__c = ''];

	   		if(!configurations.isEmpty())
	   		{
	   			confToUse = configurations[0];
	   			System.debug('Using default case email template ' + confToUse.Template_Name__c);
	   		}
	    }

	    if (configurations == null)
	    {
	    	System.debug('!!!WARNING!!!: No case default email templates found.');
	    }

	    //Get the template ID
	    List<EmailTemplate> emailTemplates = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :confToUse.Template_Name__c];

	 	if (!emailTemplates.isEmpty())
	 	{
	 		EmailTemplate templateToLoad = emailTemplates[0];
	 		System.debug('Template: ' + confToUse.Template_Name__c + ' --  id: ' + templateToLoad.Id);
	 		return templateToLoad.Id;
	 	}
	 	System.debug('!!!WARNING!!!: No template with the name: ' + confToUse.Template_Name__c);

		return null;
	}
}