@isTest
public with sharing class Test_OpportunityHandler {
	
	// Build Leads
	
	static List<Lead> createLeads (Integer quantity) {
		List<Lead> leadList = new List<Lead>();
		for (Integer i=0;i<quantity;i++) {
			Lead l = new Lead(LastName='LName'+i, 
							  FirstName='FName'+i,
							  Company='Company', 
							  Email='test'+i+'@test.test', 
							  LeadSource='Email');
			leadList.add(l);
		}
		return leadList;
	}
	
	// Build Lead Interests

	static Id insertProgram(String programName, String programCode) {
		Program__c testProgram = new Program__c(
										Name=programName,
										Program_Code__c = programCode);
		insert testProgram;
		return testProgram.Id;
	}
	
	static Id insertPlan(String planName, String planCode, Id programId) {
		Plan__c testPlan = new Plan__c(
									Name = planName,
									Plan_Code__c = planCode,
									Plan_Status__c = 'Active',
									Plan_Effective_Date__c = Date.today(),
									Program__c = programId);
		insert testPlan;
		return testPlan.Id;		

	}
	
	static List<Lead_Interest__c> createLeadInterests(List<Lead> associatedLeads) {
		List<Lead_Interest__c> liList = new List<Lead_Interest__c>();
        Id program1 = insertProgram('Program1', 'P1');
        Id plan1 = insertPlan('Plan1', 'PL1', program1);
		for (Lead l: associatedLeads) {
			Lead_Interest__c li = new Lead_Interest__c(College__c=program1, Plan__c=plan1, Leads__c=l.Id);
			liList.add(li);
		}
		system.debug('Lead Interests: ' + liList);
		return liList;
	}

//Convert Leads and create Opportunities
	static testMethod void testOpportunityHandler() {
		Integer numberOfLeads = 5;
		Lead[] leadList = createLeads(numberOfLeads);
		insert leadList;
		
		Lead_Interest__c[] liList = createLeadInterests(leadList);
		insert liList;
       
       	Set<Id> leadIds = new Set<Id>();
       
		// Perform Conversion
		for (Lead l: leadList) {
			l.Convert_Perform_Conversion__c = true;
			l.Convert_Create_Opportunity__c = true;
			leadIds.add(l.Id);
		}
		update leadList;
		
		List<Lead> checkLeads = new List<Lead>([SELECT ConvertedContactID FROM Lead WHERE Id IN :leadIds]);
	
		Set<Id> contactIds = new Set<Id>();
		for (Lead l: checkLeads) {
			contactIds.add(l.ConvertedContactId);
		}
 	
 		// Confirm that Opps were created during lead conversion
 		List<Opportunity> oppList = new List<Opportunity>([SELECT Id, contact__c FROM Opportunity WHERE contact__c IN :contactIds]);
		system.assertEquals(opplist.size(), numberOfLeads);
		
		//Lead Interest conversion is not active; commenting this part of the test
		//List<Lead_Interest__c> liListCheck = new List<Lead_Interest__c>([SELECT Id, Contact__c FROM Lead_Interest__c WHERE contact__c IN :contactIds]);		
		//system.debug('GRF LIs:' + liListCheck);
		//List<Lead> convertedLeads = new List<Lead>([SELECT Id FROM Lead WHERE Id IN :leadIds AND IsConverted = true]);
		//system.assertEquals(numberOfLeads, convertedLeads.size());
	}

// Validate that Contacts were updated on Opps (contact__c field)

// Validate that Lead Interest Contacts were updated (contact__c field)

}