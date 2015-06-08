@isTest
public with sharing class Test_NewProspectController 
{
    public static Id insertProgram(String programName, String programCode) 
    {
		Program__c testProgram = new Program__c(
			Name=programName,
			Program_Code__c = programCode);
		insert testProgram;
		return testProgram.Id;
	}
	
	@isTest static void testNewProspectController() 
    {
        PageReference pageRef = Page.NewProspect;
        Test.setCurrentPage(pageRef);
        NewProspectController controller = new NewProspectController();
          
        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        c.Lead_Email__c = 'test@test.test';
        c.Phone = '5858585858';
          
        Id programId = insertProgram('testProgram', 'TST');
        Opportunity o = new Opportunity();
        o.College__c = programId; 
        o.LeadSource = 'Email';
        o.StageName = 'Prospect';
        o.Type = 'Masters';
          
        Task t = new Task();
        t.Type = 'Email';
        t.Subject = 'Test Task';
        t.Description = 'Test Task';
          
        controller.setContact(c);
        controller.setOpportunity(o);
        controller.setTask(t);
          
        PageReference pageRefResult = controller.save();
          
        Contact cCheck = controller.getContact();
        Opportunity oCheck = controller.getOpportunity();
        Task tCheck = controller.getTask();
        controller.getOptions();
          
        system.assertNotEquals(cCheck.Id, null);
        system.assertNotEquals(oCheck.Id, null);
        system.assertNotEquals(tCheck.Id, null);
    }

    @isTest static void testNewSaveAndNew() 
    {
        PageReference pageRef = Page.NewProspect;
        Test.setCurrentPage(pageRef);
        NewProspectController controller = new NewProspectController();
              
        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        c.Lead_Email__c = 'test@test.test';
        c.Phone = '5858585858';
              
        Id programId = insertProgram('testProgram', 'TST');
        Opportunity o = new Opportunity();
        o.College__c = programId; 
        o.LeadSource = 'Email';
        o.StageName = 'Prospect';
        o.Type = 'Masters';
              
        Task t = new Task();
        t.Type = 'Email';
        t.Subject = 'Test Task';
        t.Description = 'Test Task';
              
        controller.setContact(c);
        controller.setOpportunity(o);
        controller.setTask(t);
              
        PageReference pageRefResult = controller.saveAndNew();
              
        Contact cCheck = controller.getContact();
        Opportunity oCheck = controller.getOpportunity();
        Task tCheck = controller.getTask();
        controller.getOptions();
              
        system.assertNotEquals(cCheck.Id, null);
        system.assertNotEquals(oCheck.Id, null);
        system.assertNotEquals(tCheck.Id, null);
    }
   
    @isTest static void testNewProspectControllerWithSearch() 
    {
        PageReference pageRef = Page.NewProspect;
        Test.setCurrentPage(pageRef);
        NewProspectController controller = new NewProspectController();
              
        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        c.Lead_Email__c = 'test@test.test';
        c.Phone = '4848484848';
              
        Id programId = insertProgram('testProgram', 'TST');
        Opportunity o = new Opportunity();
        o.College__c = programId; 
        o.LeadSource = 'Email';
        o.StageName = 'Prospect';
        o.Type = 'Masters';
              
        Task t = new Task();
        t.Type = 'Email';
        t.Subject = 'Test Task';
        t.Description = 'Test Task';
              
        controller.setContact(c);
        controller.setOpportunity(o);
        controller.setTask(t);
              
        controller.searchFirstName = 'First';
        controller.searchLastName = 'Last';
        controller.searchLeadEmail = 'test@test.test';
              
        PageReference pageRefResult = controller.save();
              
        Contact cCheck = controller.getContact();
        Opportunity oCheck = controller.getOpportunity();
        Task tCheck = controller.getTask();
              
        system.assertNotEquals(cCheck.Id, null);
        system.assertNotEquals(oCheck.Id, null);
        system.assertNotEquals(tCheck.Id, null);
    }

    @isTest static void testContactValidation() 
    {
        PageReference pageRef = Page.NewProspect;
        Test.setCurrentPage(pageRef);
        NewProspectController controller = new NewProspectController();
              
        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
              
        Id programId = insertProgram('testProgram', 'TST');
        Opportunity o = new Opportunity();
        o.College__c = programId; 
        o.LeadSource = 'Email';
        o.StageName = 'Prospect';
        o.Type = 'Masters';
              
        Task t = new Task();
        t.Type = 'Email';
        t.Subject = 'Test Task';
        t.Description = 'Test Task';
              
        controller.setContact(c);
        controller.setOpportunity(o);
        controller.setTask(t);
              
        controller.searchFirstName = 'First';
        controller.searchLastName = 'Last';
        controller.searchLeadEmail = 'test@test.test';
              
        PageReference pageRefResult = controller.save();
              
        Contact cCheck = controller.getContact();
        Opportunity oCheck = controller.getOpportunity();
        Task tCheck = controller.getTask();
              
        ApexPages.Message[] msgs = ApexPages.getMessages();
        Boolean found = false;
        for (ApexPages.Message msg : msgs)
        {
            if (msg.getSummary() == 'You must fill out at least two of these three fields: Postal Code, Email, or Phone.')
            {
                found = true;
            }
        }
        System.assert(found);

        c.FirstName = 'First';
        c.LastName = 'Last';
        c.Lead_Email__c = 'test@test.test';
        c.Phone = null;
        c.MailingPostalCode = null;
        controller.setContact(c);
        pageRefResult = controller.save();

        msgs = ApexPages.getMessages();
        found = false;
        for (ApexPages.Message msg : msgs)
        {
            if (msg.getSummary() == 'You must fill out at least two of these three fields: Postal Code, Email, or Phone.')
            {
                found = true;
            }
        }
        System.assert(found);

        c.FirstName = 'First';
        c.LastName = 'Last';
        c.Lead_Email__c = null;
        c.Email = null;
        c.Phone = '5858585858';
        c.MailingPostalCode = null;
        controller.setContact(c);
        pageRefResult = controller.save();
 
        msgs = ApexPages.getMessages();
        found = false;
        for (ApexPages.Message msg : msgs)
        {
            if (msg.getSummary() == 'You must fill out at least two of these three fields: Postal Code, Email, or Phone.')
            {
                found = true;
            }
        }
        System.assert(found);

        c.FirstName = 'First';
        c.LastName = 'Last';
        c.Lead_Email__c = null;
        c.Email = null;
        c.Phone = null;
        c.MailingPostalCode = '48484';
        controller.setContact(c);
        pageRefResult = controller.save();

        msgs = ApexPages.getMessages();
        found = false;
        for (ApexPages.Message msg : msgs)
        {
            if (msg.getSummary() == 'You must fill out at least two of these three fields: Postal Code, Email, or Phone.')
            {
                found = true;
            }
        }
        System.assert(found);
    }
}