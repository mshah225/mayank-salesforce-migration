@IsTest
private class Test_EmailTemplateService
{
    @testSetup
    static void setup()
    {
        Case_Default_Email_Templates__c templateSettings = new Case_Default_Email_Templates__c();
        templateSettings.Functional_Group__c = 'Test Group';
        templateSettings.Template_Name__c = 'Test_Template';
        templateSettings.Name = 'Test Group Template';

        insert templateSettings;
    }

    @isTest static void testGetEmailTemplatesByAPIName()
    {
        Map<String, EmailTemplate> emailTemplates = new Map<String,
                EmailTemplate>();
        Integer expectedSize = [SELECT count() FROM EmailTemplate];

        Test.startTest();
        emailTemplates = EmailTemplateService.getEmailTemplatesByAPIName();
        Test.stopTest();

        System.assert(emailTemplates.size() == expectedSize, 'EmailTemplateService did not return the expected number of EmailTemplates: ' + emailTemplates.size());
    }

    @isTest static void testGetDefaultEmailTemplateForCaseFeed()
    {
        Id templateFolderId = [SELECT Id FROM Folder WHERE DeveloperName =
                'Public'].Id;
        EmailTemplate testTemplate = new EmailTemplate();
        testTemplate.DeveloperName = 'Test_Template';
        testTemplate.Body = 'Test body';
        testTemplate.Description = 'Test template';
        testTemplate.Subject = 'Test template';
        testTemplate.Name = 'Test template';
        testTemplate.FolderId = templateFolderId;
        testTemplate.TemplateType = 'text';

        insert testTemplate;

        // Get the custom settings
        List<Case_Default_Email_Templates__c> configurations = [
                SELECT Name, Template_Name__c, Functional_Group__c
                FROM Case_Default_Email_Templates__c
        ];

        Test.startTest();
        Map<String, EmailTemplate> emailTemplates = EmailTemplateService.getEmailTemplatesByAPIName();
        EmailTemplate returnedTemplate = EmailTemplateService.getDefaultEmailTemplateForCaseFeed(emailTemplates, configurations, 'Test Group');
        Test.stopTest();

        System.assertEquals(testTemplate.DeveloperName, returnedTemplate.DeveloperName, 'Test template was not returned correctly by EmailTemplateService');
    }

    @isTest static void testNoDefaultEmailTemplates()
    {
        try
        {
            Test.startTest();
            EmailTemplateService.getDefaultEmailTemplateForCaseFeed(null, null, null);
        }
        catch (EmailTemplateService.EmailTemplateServiceException e)
        {
            Test.stopTest();
            System.assert(true);
        }
        catch (Exception e)
        {
            Test.stopTest();
            System.assert(false, 'An unknown exception was thrown by the EmailTemplateService: ' + e.getMessage());
        }
    }

    @isTest static void testDefaultEmailConfiguration()
    {
        Case_Default_Email_Templates__c defaultTemplateSettings = new Case_Default_Email_Templates__c();
        defaultTemplateSettings.Functional_Group__c = 'Default';
        defaultTemplateSettings.Template_Name__c = 'Default_Template';
        defaultTemplateSettings.Name = 'Default';

        insert defaultTemplateSettings;

        // Get the custom settings
        List<Case_Default_Email_Templates__c> configurations = [
                SELECT Name, Template_Name__c, Functional_Group__c
                FROM Case_Default_Email_Templates__c
        ];

        Test.startTest();
        Map<String, EmailTemplate> emailTemplates = EmailTemplateService.getEmailTemplatesByAPIName();
        EmailTemplate returnedTemplate = EmailTemplateService.getDefaultEmailTemplateForCaseFeed(emailTemplates, configurations, 'Dummy_Group');
        Test.stopTest();

        System.assertEquals('Case_Management_Default_Template', returnedTemplate.DeveloperName, 'Default template was not returned correctly by EmailTemplateService');
    }

    @isTest static void testNoEmailConfigurations()
    {
        // Get the custom settings
        List<Case_Default_Email_Templates__c> configurations = [
                SELECT Name, Template_Name__c, Functional_Group__c
                FROM Case_Default_Email_Templates__c
        ];

        try
        {
            Test.startTest();
            Map<String, EmailTemplate> emailTemplates = EmailTemplateService.getEmailTemplatesByAPIName();
            EmailTemplate returnedTemplate = EmailTemplateService.getDefaultEmailTemplateForCaseFeed(emailTemplates, configurations, 'Dummy_Group');
        }
        catch (EmailTemplateService.EmailTemplateServiceException e)
        {
            Test.stopTest();
            System.assert(true);
        }
        catch (Exception e)
        {
            Test.stopTest();
            System.assert(false, 'An unknown exception was thrown by the EmailTemplateService: ' + e.getMessage());
        }
    }
}