@IsTest(SeeAllData=true)
public with sharing class Test_NewProspectController {

	public static Id insertProgram(String programName, String programCode) {
		Program__c testProgram = new Program__c(
										Name=programName,
										Program_Code__c = programCode);
		insert testProgram;
		return testProgram.Id;
	}
	
	public static testMethod void testNewProspectController() {
       
       PageReference pageRef = Page.NewProspect;
       Test.setCurrentPage(pageRef);
       NewProspectController controller = new NewProspectController();
       
       Contact c = new Contact();
       c.FirstName = 'First';
       c.LastName = 'Last';
       c.Email = 'test@test.test';
       
       Id programId = insertProgram('testProgram', 'TST');
       Opportunity o = new Opportunity();
       o.College__c = programId; 
       o.LeadSource = 'Email';
       o.StageName = 'Prospect';
       
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
       
       system.assertNotEquals(cCheck.Id, null);
       system.assertNotEquals(oCheck.Id, null);
       system.assertNotEquals(tCheck.Id, null);
   }
   
	public static testMethod void testNewProspectControllerWithSearch() {
       
       PageReference pageRef = Page.NewProspect;
       Test.setCurrentPage(pageRef);
       NewProspectController controller = new NewProspectController();
       
       Contact c = new Contact();
       c.FirstName = 'First';
       c.LastName = 'Last';
       c.Email = 'test@test.test';
       
       Id programId = insertProgram('testProgram', 'TST');
       Opportunity o = new Opportunity();
       o.College__c = programId; 
       o.LeadSource = 'Email';
       o.StageName = 'Prospect';
       
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

}