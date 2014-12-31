@isTest
public with sharing class Test_ContactHandler {
	static Id ExtMasteredContactRTId;
	static Id SFMasteredContactRTId;
	static Id ExtMasteredContactAccountRTId;
	static Id SFMasteredContactAccountRTId;
	
	static testMethod void testSFMasteredContacts() {
		Integer recordCount = 200;

		getRecordTypeIDs();
			
		// Set up the Contacts
		Set<Id> testContactIDs = new Set<Id>();
		List<Contact> testContacts = createContacts(recordCount, false);
		
		test.startTest();
		insert testContacts;
		
		for (Integer i=0;i>recordCount;i++) {
			system.assertEquals(testContacts[i].RecordTypeId, SFMasteredContactRTId);
			testContacts[i].EMPLID__c = i.format();
			testContactIDs.add(testContacts[i].Id);
		}

		List<Account> testAccounts1 = new List<Account>([SELECT Id, RecordTypeId FROM Account WHERE Contact__c IN :testContactIDs]);
		for (Account a: testAccounts1) {
			system.assertEquals(a.RecordTypeId, SFMasteredContactAccountRTId);
		}
		
		update testContacts;
		test.stopTest();
		
		List<Account> testAccounts2 = new List<Account>([SELECT Id, RecordTypeId FROM Account WHERE Contact__c IN :testContactIDs]);
		
		for (Integer i=0;i>recordCount;i++) {
			system.assertEquals(testContacts[i].RecordTypeId, ExtMasteredContactRTId);
		}	
		
		for (Account a: testAccounts2) {
			system.assertEquals(a.RecordTypeId, ExtMasteredContactAccountRTId);
		}
		
		// This is not really necessary, but bumps up test coverage for the TriggerFactory class
		delete testContacts;
		
		
	}
	
	static testMethod void testExtMasteredContacts() {
		Integer recordCount = 200;

		getRecordTypeIDs();
			
		// Set up the Contacts
		Set<Id> testContactIDs = new Set<Id>();
		List<Contact> testContacts = createContacts(recordCount, true);
		
		test.startTest();
		insert testContacts;
		
		for (Integer i=0;i>recordCount;i++) {
			system.assertEquals(testContacts[i].RecordTypeId, SFMasteredContactRTId);
			testContacts[i].EMPLID__c = '';
			testContactIDs.add(testContacts[i].Id);
		}

		List<Account> testAccounts1 = new List<Account>([SELECT Id, RecordTypeId FROM Account WHERE Contact__c IN :testContactIDs]);
		for (Account a: testAccounts1) {
			system.assertEquals(a.RecordTypeId, ExtMasteredContactAccountRTId);
		}
		
		update testContacts;
		test.stopTest();
		
		List<Account> testAccounts2 = new List<Account>([SELECT Id, RecordTypeId FROM Account WHERE Contact__c IN :testContactIDs]);
		
		for (Integer i=0;i>recordCount;i++) {
			system.assertEquals(testContacts[i].RecordTypeId, SFMasteredContactRTId);
		}	
		
		for (Account a: testAccounts2) {
			system.assertEquals(a.RecordTypeId, SFMasteredContactAccountRTId);
		}
				
	}

	static List<Contact> createContacts(Integer qty, boolean createEmplId) {
		List<Contact> testContacts = new List<Contact>();
		for (integer i=0; i < qty; i++) {
			Contact c = new Contact(LastName = 'LName'+i, FirstName = 'FName'+i);
			if (createEmplId)
				c.EMPLID__c = i.format();
			testContacts.add(c);
		}
		
		return testContacts;
	}
	
	static void getRecordTypeIDs() {
			List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, sObjectType, DeveloperName FROM RecordType WHERE sObjectType IN ('Account', 'Contact')]);
			for (RecordType rt: recordTypeList) {
				if (rt.SobjectType == 'Contact') {
					if (rt.DeveloperName == 'External_Mastered')
						ExtMasteredContactRTId = rt.Id;
					else if (rt.DeveloperName == 'SF_Mastered')
						SFMasteredContactRTId = rt.Id;
				}
				else if (rt.SobjectType == 'Account') {
					if (rt.DeveloperName == 'External_Mastered_Contact')
						ExtMasteredContactAccountRTId = rt.Id;
					else if (rt.DeveloperName == 'SF_Mastered_Contact')
						SFMasteredContactAccountRTId = rt.Id;
				}
			}
		
	}
}