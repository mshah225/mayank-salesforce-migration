@isTest()
public class Test_NewLeadEntryController {
    
    public static Id insertProgram(String programName, String programCode) {
        Program__c testProgram = new Program__c(
                                        Name=programName,
                                        Program_Code__c = programCode);
        insert testProgram;
        return testProgram.Id;
    }
    
    public static Id insertPlan(String planName, String planCode, Id programId) {
        Plan__c testPlan = new Plan__c(
                                    Name = planName,
                                    Plan_Code__c = planCode,
                                    Plan_Effective_Date__c = Date.today(),
                                    Program__c = programId);
                                    //Plan_Status__c = true);
        insert testPlan;
        return testPlan.Id;     
    }

    public static testMethod void testNewLeadEntryController() {
       
       PageReference pageRef = Page.NewLeadEntry;
       Test.setCurrentPage(pageRef);
       NewLeadEntryController controller = new NewLeadEntryController();

       Lead testLead = new Lead();
       Lead_Interest__c testLeadInterest = new Lead_Interest__c();
       Task testTask = new Task();
       
       testLead.FirstName = 'FirstName';
       testLead.LastName = 'LastName';
       testLead.Company = 'Arizona State University';
       testLead.Email = 'test@email.com';
       testLead.LeadSource = 'Advertisement';
       testLead.Lead_Source_Subtype__c = 'USA Today';
      // testLead.Enrollment_Term__c = 'Spring 2017';
       
       Id program1 = insertProgram('Program1', 'P1');
       Id program2 = insertProgram('Program2', 'P2');
       Id plan1 = insertPlan('Plan1', 'PL1', program1);
       
       // This is an invalid Program/Plan Combo
       testLeadInterest.College__c = program2;
       testLeadInterest.Plan__c = plan1;
       
       controller.setExtlead(testLead);
       controller.setLeadInterest(testLeadInterest);
       controller.setLeadTask(testTask);
       
       // We should get an invalid College/Plan exception here
       PageReference pageRefResult = controller.extSave();
       List<Apexpages.Message> msgs = ApexPages.getMessages();
       boolean b = false;
       for(Apexpages.Message msg:msgs){
          if (msg.getDetail().contains('The specfied College & Plan combination is not valid')) b = true;
       }
       system.assert(b);
       
       //This is a valid Program/Plan Combo
       testLeadInterest.College__c = program1;
       controller.setLeadInterest(testLeadInterest);
       controller.extSaveAndNew();
       
       //Make sure our inserts happened       
       List<Lead> insertedLeads = new List<Lead>([SELECT Id FROM Lead WHERE Id = :testLead.Id]);
       List<Lead_Interest__c> insertedLeadInterests = new List<Lead_Interest__c>([SELECT Id FROM Lead_Interest__c WHERE Id = :testLeadInterest.Id]);       
       System.Assert(insertedLeads.size() > 0);
       System.Assert(insertedLeadInterests.size() > 0);
       
   }

}