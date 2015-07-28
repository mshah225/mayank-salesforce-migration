public class EmailTemplateService
{
	/**
	* Returns all the fields on EmailTemplate in a String
	* @return A string containing all the EmailTemplate fields
	*/
	public static String emailTemplateFieldsToString()
	{
		return ObjectService.objectFieldsToString('EmailTemplate');
	}

	/**
	 * Returns all the EmailTemplates in an org keyed by the DeveloperName
	 * @return A map of DeveloperName and EmailTemplate
	 */
	public static Map<String, EmailTemplate> getEmailTemplatesByAPIName()
	{
		Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();
		List<EmailTemplate> emailTemplates = new List<EmailTemplate>();

		try
		{
			/**
			 * Do not call the emailTemplateFieldsToString() here. Execution time is too long 
			 * (10s), probably because of the EmailTemplate.Body field.
			 */
			String emailTemplateQuery = 'SELECT DeveloperName FROM EmailTemplate';

			emailTemplates = Database.query(emailTemplateQuery);
		}
		catch (Exception e)
		{
			throw new EmailTemplateServiceException('!!!ERROR!!!: An error occurred trying to get the EmailTemplates for this organization\n' + e.getMessage());
		}

		for (EmailTemplate template : emailTemplates)
		{
			emailTemplateMap.put(template.DeveloperName, template);
		}

		return emailTemplateMap;
	}

	/**
	 * Returns the appropriate Email Template to load in the Case Feed
	 * @param  defaultEmailConf    A List of Case_Default_Email_Templates__c configurations
	 * @param  caseFunctionalGroup A Case Functional Group
	 * @return emailTemplateToUse  An EmailTemplate that is defined for use by the Custom Setting
	 */
	public static EmailTemplate getDefaultEmailTemplateForCaseFeed(Map<String, EmailTemplate> emailTemplates, List<Case_Default_Email_Templates__c> defaultEmailConf, String caseFunctionalGroup)
	{
		Map<String, Case_Default_Email_Templates__c> confsByFunctionalGroup = new Map<String, Case_Default_Email_Templates__c>();
		String emailTemplateAPIName;
		EmailTemplate emailTemplateToUse;

		// Check to make sure we actually have Custom Settings defined
		if (defaultEmailConf == null)
		{
			throw new EmailTemplateServiceException('!!!ERROR!!!: No case default email templates provided');
		}

		// Map the configurations by their Functional_Group__c
		for (Case_Default_Email_Templates__c configuration : defaultEmailConf)
		{
			confsByFunctionalGroup.put(configuration.Functional_Group__c, configuration);
		}

		if (confsByFunctionalGroup.containsKey(caseFunctionalGroup))
		{
			emailTemplateAPIName = confsByFunctionalGroup.get(caseFunctionalGroup).Template_Name__c;
		}
		else
		{
			// Use the default configuration if there is one
			Case_Default_Email_Templates__c defaultFGConf = confsByFunctionalGroup.get('Default');

			if (defaultFGConf == null)
			{
				// Throw an error if there is no default Custom Setting defined in this org
				throw new EmailTemplateServiceException('!!!ERROR!!!: No default Case_Default_Email_Templates__c configuration exists for this org');
			}
			else
			{
				emailTemplateAPIName = defaultFGConf.Template_Name__c;
			}
		}

		// Get the email template that corresponds to this custom setting
		if (emailTemplates.containsKey(emailTemplateAPIName))
		{
			emailTemplateToUse = emailTemplates.get(emailTemplateAPIName);
		}
		else 
		{
			// Use the Case Management Default email template if there is no email template with this API Name
			emailTemplateToUse = emailTemplates.get('Case_Management_Default_Template');

			// Throw an error if there is no Case_Management_Default_Template in this org
			if (emailTemplateToUse == null)
			{
				throw new EmailTemplateServiceException('!!!ERROR!!!: The \'Case_Management_Default_Template\' was not found in this org');
			}
		}

		return emailTemplateToUse;
	}

	public class EmailTemplateServiceException extends Exception {}
}