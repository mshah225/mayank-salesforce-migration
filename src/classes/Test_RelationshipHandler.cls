@isTest
private class Test_RelationshipHandler {

	static void createCustomSettings() {
		List<Relationships__c> listRelationshipsSettings = new List<Relationships__c>();
		listRelationshipsSettings.add(new Relationships__c(Name='Parent', Reciprocal__c='Child'));	
		insert listRelationshipsSettings;
	}

	static List<Contact> createContacts(Integer qty) {
		List<Contact> testContacts = new List<Contact>();
		for (integer i=0; i < qty; i++) {
			Contact c = new Contact(LastName = 'LName'+i, FirstName = 'FName'+i);
			testContacts.add(c);
		}
		
		return testContacts;
	}	
	
	static testMethod void testReciprocalCreation() {
            
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Relationship__c' AND DeveloperName = 'Contact_to_Contact']);

		createCustomSettings(); 
        List<Relationships__c> relCustomSettings = Relationships__c.getAll().values();

		Integer qtyToTest = 200;
		List<Contact> listParents = createContacts(qtyToTest);
		List<Contact> listChildren = createContacts(qtyToTest);

		insert listParents;
		insert listChildren;

		List<Relationship__c> listRelationships = new List<Relationship__c>();
		Set<Id> parentContactIds = new Set<Id>();
		for (Integer i=0;i<qtyToTest;i++) {
			Relationship__c rel = new Relationship__c(Contact__c = listParents[i].Id,
													  Related_Contact__c = listChildren[i].Id,
													  Relationship_Type__c = 'Parent',
													  Active_Relationship__c = true,
													  Relationship_Start_Date__c = Date.today(),
													  RecordTypeId = recordTypeList[0].Id);
			listRelationships.add(rel);
			parentContactIds.add(listParents[i].Id);
		}

		Test.startTest();
		insert listRelationships;
		Test.stopTest();

		List<Relationship__c> listRecips = new List<Relationship__c>([SELECT Id FROM Relationship__c WHERE Related_Contact__c IN :parentContactIds]);
		System.assert(listRecips.size() == qtyToTest, 'Expected number of reciprocal relationships was not created: ' + listRecips.size() + ' vs ' + qtyToTest);

	}

	static testMethod void testReciprocalUpdate() {
            
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Relationship__c' AND DeveloperName = 'Contact_to_Contact']);

		createCustomSettings(); 
        List<Relationships__c> relCustomSettings = Relationships__c.getAll().values();

		Integer qtyToTest = 200;
		List<Contact> listParents = createContacts(qtyToTest);
		List<Contact> listChildren = createContacts(qtyToTest);
		List<Contact> listNewParents = createContacts(qtyToTest);

		insert listParents;
		insert listChildren;

		List<Relationship__c> listRelationships = new List<Relationship__c>();
		Set<Id> parentContactIds = new Set<Id>();
		for (Integer i=0;i<qtyToTest;i++) {
			Relationship__c rel = new Relationship__c(Contact__c = listParents[i].Id,
													  Related_Contact__c = listChildren[i].Id,
													  Relationship_Type__c = 'Parent',
													  Active_Relationship__c = true,
													  Relationship_Start_Date__c = Date.today(),
													  RecordTypeId = recordTypeList[0].Id);
			listRelationships.add(rel);
			parentContactIds.add(listParents[i].Id);
		}

		insert listRelationships;

		Integer i = 0;
		Set<Id> newParentContactIds = new Set<Id>();
		for (Relationship__c r: listRelationships) {
			r.Active_Relationship__c = false;
			r.Relationship_Start_Date__c = Date.today().addDays(-7);
			r.Relationship_End_Date__c = Date.today().addDays(7);
			r.Contact__c = listNewParents[i].Id;
			newParentContactIds.add(listNewParents[i].Id);
			i++;
		}

		Test.startTest();
		update listRelationships;
		Test.stopTest();

		List<Relationship__c> listRecips = new List<Relationship__c>([SELECT Id FROM Relationship__c WHERE Related_Contact__c IN :newParentContactIds and Active_Relationship__c = false]);
		System.assert(listRecips.size() == qtyToTest, 'Expected number of reciprocal relationships was not updated: ' + listRecips.size() + ' vs ' + qtyToTest);

	}

	static testMethod void testReciprocalDeletion() {
            
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Relationship__c' AND DeveloperName = 'Contact_to_Contact']);

		createCustomSettings(); 
        List<Relationships__c> relCustomSettings = Relationships__c.getAll().values();

		Integer qtyToTest = 200;
		List<Contact> listParents = createContacts(qtyToTest);
		List<Contact> listChildren = createContacts(qtyToTest);

		insert listParents;
		insert listChildren;

		List<Relationship__c> listRelationships = new List<Relationship__c>();
		Set<Id> parentContactIds = new Set<Id>();
		for (Integer i=0;i<qtyToTest;i++) {
			Relationship__c rel = new Relationship__c(Contact__c = listParents[i].Id,
													  Related_Contact__c = listChildren[i].Id,
													  Relationship_Type__c = 'Parent',
													  Active_Relationship__c = true,
													  Relationship_Start_Date__c = Date.today(),
													  RecordTypeId = recordTypeList[0].Id);
			listRelationships.add(rel);
			parentContactIds.add(listParents[i].Id);
		}

		insert listRelationships;
		List<Relationship__c> listRecips = new List<Relationship__c>([SELECT Id FROM Relationship__c WHERE Related_Contact__c IN :parentContactIds]);
		System.assert(listRecips.size() == qtyToTest, 'Expected number of reciprocal relationships was not created while preparing for deletion test: ' + listRecips.size() + ' vs ' + qtyToTest);

		Test.startTest();
		delete listRelationships;
		Test.stopTest();

		listRecips = new List<Relationship__c>([SELECT Id FROM Relationship__c WHERE Related_Contact__c IN :parentContactIds]);
		System.assert(listRecips.size() == 0, 'Reciprocal relationships were not deleted');

	}


	
}