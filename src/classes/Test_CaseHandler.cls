@isTest
public with sharing class Test_CaseHandler {

	private static List<Contact> createContacts(Integer qty) {
		List<Contact> contactList = new List<Contact>();
		for (Integer i=0; i<qty; i++) {
		    Contact con = new Contact();
		    con.FirstName = 'FName' + i;
		    con.LastName = 'LName' + i;
		    contactList.add(con);
		}

		return contactList;
	} 

	private static List<Opportunity> createOpportunities(List<Contact> contactList) {
		List<Opportunity> oppList = new List<Opportunity>();

		for (Contact c: contactList) {
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opp';
		    opp.Contact__c = c.Id;
		    opp.AccountId = c.AccountId;
		    opp.StageName = 'Prospect';
		    opp.CloseDate = date.today() + 365;
		    opp.Type = 'First Time Freshman';
		    oppList.add(opp);
		}

		return oppList;
	}

	private static Case createCase(Id queue_id)
    {
        Case newCase = new Case(
            Subject = 'Test Subject%ASURITE:9999999999%Queue:' + queue_id,
            Description = 'Test Description',
            Status = 'Processing'
        );
        
        insert newCase;
        return newCase;
    }
    
    private static Contact createContact()
    {
        Contact newContact = new Contact(
            LastName = 'Contact',
            EMPLID__c = '9999999999'
        );
        
        insert newContact;
        return newContact;
    }

	private static testMethod void testAdmissionsCaseOpportunityAssociation() {
		List<Contact> contactList = createContacts(1);
		insert contactList;

		Set<Id> contactIds = new Set<Id>();
		for (Contact c: contactList) {
			contactIds.add(c.Id);
		}

		// Re-select Contacts to get AccountId values
		contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

		List<Opportunity> oppList = createOpportunities(contactList);
		insert oppList;

		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
		Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

		List<Case> caseList = new List<Case>();
		for (Contact c: contactList) {
			Case ca = new Case(ContactId = c.Id,
							   RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
							   Associate_Case_to_Active_Opportunity__c = true,
							   Subject='Test Subject', 
							   Description='Test Desc', 
							   Status='In Progress');
			caseList.add(ca);
		}

		Test.startTest();
		insert caseList;
		Test.stopTest();

		//List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
		List<Case> newCaseList = new List<Case>([SELECT Id, Opportunity__c FROM Case WHERE ContactId IN :contactIds]);
		for (Case ca: newCaseList) {
			system.assert(ca.Opportunity__c != null, 'Case was not associated with Opportunity');
		}

	}

	private static testMethod void testAdmissionsCaseTerritoryManagerAssignment() {
	    Profile saProfile = [select id from profile where name='System Administrator'];
		
		User TMUser = new User();
	    TMUser.FirstName = 'Test';
	    TMUser.LastName = 'Name';
	    TMUser.CompanyName = 'Test Company';
	    TMUser.MobilePhone = '123-456-7890';
	    TMUser.Username = 'testUser-Inactive@test.test';
	    TMUser.Email = 'testUser-Inactive@test.test';
	    TMUser.Alias = 'testXX';
	    TMUser.CommunityNickname = 'test1';
	    TMUser.TimeZoneSidKey = 'America/New_York';
	    TMUser.LocaleSidKey = 'en_US';
	    TMUser.EmailEncodingKey = 'UTF-8';
	    TMUser.ProfileId = saProfile.Id;
	    TMUser.LanguageLocaleKey = 'en_US';
	    TMUser.IsActive = true;
	    insert TMUser; 

		List<Contact> contactList = createContacts(1);
		insert contactList;

		Set<Id> contactIds = new Set<Id>();
		for (Contact c: contactList) {
			contactIds.add(c.Id);
		}

		// Re-select Contacts to get AccountId values
		contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

		List<Opportunity> oppList = createOpportunities(contactList);
		for (Opportunity o: oppList) {
			o.OwnerId = TMUser.Id;

		}
		insert oppList;

		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
		Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

		List<Case> caseList = new List<Case>();
		for (Contact c: contactList) {
			Case ca = new Case(ContactId = c.Id,
							   RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
							   Associate_Case_to_Active_Opportunity__c = true,
							   Type_of_Additional_Assignment_Needed__c = 'Territory Manager',
							   Subject='Test Subject', 
							   Description='Test Desc', 
							   Status='In Progress');
			caseList.add(ca);
		}

		Test.startTest();
		insert caseList;
		Test.stopTest();

		//List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
		List<Case> newCaseList = new List<Case>([SELECT Id, OwnerId FROM Case WHERE ContactId IN :contactIds]);
		for (Case ca: newCaseList) {
			system.assert(ca.OwnerId == TMUser.Id, 'Case owner was not assigned to Opportunity owner (Territory Manager)');
		}

	}	

	private static testMethod void testAdmissionsCaseEnrollmentCoachAssignment() {
	    Profile saProfile = [select id from profile where name='System Administrator'];
		
		User TMUser = new User();
	    TMUser.FirstName = 'Test';
	    TMUser.LastName = 'Name';
	    TMUser.CompanyName = 'Test Company';
	    TMUser.MobilePhone = '123-456-7890';
	    TMUser.Username = 'testUser-Inactive@test.test';
	    TMUser.Email = 'testUser-Inactive@test.test';
	    TMUser.Alias = 'testXX';
	    TMUser.CommunityNickname = 'test1';
	    TMUser.TimeZoneSidKey = 'America/New_York';
	    TMUser.LocaleSidKey = 'en_US';
	    TMUser.EmailEncodingKey = 'UTF-8';
	    TMUser.ProfileId = saProfile.Id;
	    TMUser.LanguageLocaleKey = 'en_US';
	    TMUser.IsActive = true;
	    insert TMUser; 

		List<Contact> contactList = createContacts(1);
		insert contactList;

		Set<Id> contactIds = new Set<Id>();
		for (Contact c: contactList) {
			contactIds.add(c.Id);
		}

		// Re-select Contacts to get AccountId values
		contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

		List<Opportunity> oppList = createOpportunities(contactList);
		for (Opportunity o: oppList) {
			o.Enrollment_Coach__c = TMUser.Id;
		}
		insert oppList;

		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
		Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

		List<Case> caseList = new List<Case>();
		for (Contact c: contactList) {
			Case ca = new Case(ContactId = c.Id,
							   RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
							   Associate_Case_to_Active_Opportunity__c = true,
							   Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach',
							   Subject='Test Subject', 
							   Description='Test Desc', 
							   Status='In Progress');
			caseList.add(ca);
		}

		Test.startTest();
		insert caseList;
		Test.stopTest();

		//List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
		List<Case> newCaseList = new List<Case>([SELECT Id, OwnerId FROM Case WHERE ContactId IN :contactIds]);
		for (Case ca: newCaseList) {
			system.assert(ca.OwnerId == TMUser.Id, 'Case owner was not assigned to Opportunity Enrollment Coach');
		}

	}	


	private static testMethod void testAdmissionsCaseWebformCARAssignment() {
	    Profile saProfile = [select id from profile where name='System Administrator'];
		
		User APIUser = new User();
	    APIUser.FirstName = 'API';
	    APIUser.LastName = 'LName';
	    APIUser.CompanyName = 'Test Company';
	    APIUser.MobilePhone = '123-456-7890';
	    APIUser.Username = 'testUser-Inactive@test.test';
	    APIUser.Email = 'testUser-Inactive@test.test';
	    APIUser.Alias = 'testXX';
	    APIUser.CommunityNickname = 'test1';
	    APIUser.TimeZoneSidKey = 'America/New_York';
	    APIUser.LocaleSidKey = 'en_US';
	    APIUser.EmailEncodingKey = 'UTF-8';
	    APIUser.ProfileId = saProfile.Id;
	    APIUser.LanguageLocaleKey = 'en_US';
	    APIUser.IsActive = true;
	    insert APIUser; 

		User TMUser = new User();
	    TMUser.FirstName = 'FName';
	    TMUser.LastName = 'LName';
	    TMUser.CompanyName = 'Test Company';
	    TMUser.MobilePhone = '123-456-7890';
	    TMUser.Username = 'testUser-Inactive2@test.test';
	    TMUser.Email = 'testUser-Inactive2@test.test';
	    TMUser.Alias = 'testXX2';
	    TMUser.CommunityNickname = 'test2';
	    TMUser.TimeZoneSidKey = 'America/New_York';
	    TMUser.LocaleSidKey = 'en_US';
	    TMUser.EmailEncodingKey = 'UTF-8';
	    TMUser.ProfileId = saProfile.Id;
	    TMUser.LanguageLocaleKey = 'en_US';
	    TMUser.IsActive = true;
	    insert TMUser; 	

		// Set up Case Assignment Rules
		Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' and AccessType = 'Public' LIMIT 1];
		
		EmailTemplate e;
		QueueSobject testQueue;
		Group testGroup;
		System.runAs(new User(Id = Userinfo.getUserId())) {
			e = new EmailTemplate (developerName = 'test', TemplateType= 'Text', Name = 'test', FolderId = f.Id, isActive=true); 
			insert e;

			testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
			insert testGroup;
			
			testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
	    	insert testQueue;
		}
		


	    string queueId = String.valueOf(testGroup.Id).substring(0,15);
	    string templateId = String.valueOf(e.Id).substring(0,15);
	    
	    Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(Email_Address__c='service@test.test', 
	    														  customer_notice_email_from_name__c = 'Test Service',
	    														  email_template_id__c = templateId,
	    														  queue_id__c = String.valueOf(TMUser.Id).subString(0,15),
	    														  origin__c = 'Test Origin',
	    														  functional_group__c = 'Admission Services',
	    														  category__c = 'Test Category',
	    														  sub_category__c = 'Test Subcategory',
	    														  priority__c = 99);
	    insert car;

	    Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(Email_Address__c='admissions@asu.edu', 
	    														  customer_notice_email_from_name__c = 'Default Test Service',
	    														  email_template_id__c = templateId,
	    														  queue_id__c = String.valueOf(TMUser.Id).subString(0,15),
	    														  origin__c = 'Test Origin',
	    														  functional_group__c = 'Admission Services',
	    														  category__c = 'Test Category',
	    														  sub_category__c = 'Test Subcategory',
	    														  priority__c = 999);
	    insert carDefault;

		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign; 
		Map<String,Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
	    
	    Campaign camp = new Campaign(Name = 'C Test',
									 Type = 'Web',
									 RecordTypeId = CampaignRecordTypeInfo.get('Other Source').getRecordTypeId(),
									 Case_Assignment_Rule__c = car.Id,
                            		 IsActive = TRUE);            
        insert camp;    

		List<Contact> contactList = createContacts(1);
		insert contactList;

		Set<Id> contactIds = new Set<Id>();
		for (Contact c: contactList) {
			contactIds.add(c.Id);
		}

		// Re-select Contacts to get AccountId values
		contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

		List<Opportunity> oppList = createOpportunities(contactList);
		for (Opportunity o: oppList) {
//			o.Enrollment_Coach__c = TMUser.Id;
		}
		insert oppList;

		Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case; 
		Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

		List<Case> caseList = new List<Case>();
		for (Contact c: contactList) {
			Case ca = new Case(ContactId = c.Id,
							   RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
							   Case_Source__c = camp.Id,
							   Associate_Case_to_Active_Opportunity__c = false,
							   Subject='Test Subject', 
							   Description='Test Desc', 
							   Status='In Progress');
			caseList.add(ca);
		}

		Test.startTest();
		System.runAs(APIUser) {
			insert caseList;
		}
		Test.stopTest();

		//List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
		List<Case> newCaseList = new List<Case>([SELECT Id, Category__c, OwnerId FROM Case WHERE ContactId IN :contactIds]);
		for (Case ca: newCaseList) {
			system.assert(ca.OwnerId == TMUser.Id, 'Case owner was not assigned to CAR Queue/User');
			system.assert(ca.Category__c == 'Test Category', 'Case Category was not assigned to CAR Category');
		}
	}	

	private static testMethod void testAdmissionsCaseWebformECAssignment() {
	    Profile saProfile = [select id from profile where name='System Administrator'];
		
		User APIUser = new User();
	    APIUser.FirstName = 'API';
	    APIUser.LastName = 'LName';
	    APIUser.CompanyName = 'Test Company';
	    APIUser.MobilePhone = '123-456-7890';
	    APIUser.Username = 'testUser-Inactive@test.test';
	    APIUser.Email = 'testUser-Inactive@test.test';
	    APIUser.Alias = 'testXX';
	    APIUser.CommunityNickname = 'test1';
	    APIUser.TimeZoneSidKey = 'America/New_York';
	    APIUser.LocaleSidKey = 'en_US';
	    APIUser.EmailEncodingKey = 'UTF-8';
	    APIUser.ProfileId = saProfile.Id;
	    APIUser.LanguageLocaleKey = 'en_US';
	    APIUser.IsActive = true;
	    insert APIUser; 

		User TMUser = new User();
	    TMUser.FirstName = 'FName';
	    TMUser.LastName = 'LName';
	    TMUser.CompanyName = 'Test Company';
	    TMUser.MobilePhone = '123-456-7890';
	    TMUser.Username = 'testUser-Inactive2@test.test';
	    TMUser.Email = 'testUser-Inactive2@test.test';
	    TMUser.Alias = 'testXX2';
	    TMUser.CommunityNickname = 'test2';
	    TMUser.TimeZoneSidKey = 'America/New_York';
	    TMUser.LocaleSidKey = 'en_US';
	    TMUser.EmailEncodingKey = 'UTF-8';
	    TMUser.ProfileId = saProfile.Id;
	    TMUser.LanguageLocaleKey = 'en_US';
	    TMUser.IsActive = true;
	    insert TMUser; 	

		User ECUser = new User();
	    ECUser.FirstName = 'FName';
	    ECUser.LastName = 'LName';
	    ECUser.CompanyName = 'Test Company';
	    ECUser.MobilePhone = '123-456-7890';
	    ECUser.Username = 'testUser-Inactive3@test.test';
	    ECUser.Email = 'testUser-Inactive3@test.test';
	    ECUser.Alias = 'testXX2';
	    ECUser.CommunityNickname = 'test3';
	    ECUser.TimeZoneSidKey = 'America/New_York';
	    ECUser.LocaleSidKey = 'en_US';
	    ECUser.EmailEncodingKey = 'UTF-8';
	    ECUser.ProfileId = saProfile.Id;
	    ECUser.LanguageLocaleKey = 'en_US';
	    ECUser.IsActive = true;
	    insert ECUser;	    

		// Set up Case Assignment Rules
		Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' and AccessType = 'Public' LIMIT 1];
		
		EmailTemplate e;
		QueueSobject testQueue;
		Group testGroup;
		System.runAs(new User(Id = Userinfo.getUserId())) {
			e = new EmailTemplate (developerName = 'test', TemplateType= 'Text', Name = 'test', FolderId = f.Id, isActive=true); 
			insert e;

			testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
			insert testGroup;
			
			testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
	    	insert testQueue;
		}
		


	    string queueId = String.valueOf(testGroup.Id).substring(0,15);
	    string templateId = String.valueOf(e.Id).substring(0,15);
	    
	    Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(Email_Address__c='service@test.test', 
	    														  customer_notice_email_from_name__c = 'Test Service',
	    														  email_template_id__c = templateId,
	    														  queue_id__c = String.valueOf(TMUser.Id).subString(0,15),
	    														  origin__c = 'Test Origin',
	    														  functional_group__c = 'Admission Services - Undergraduate',
	    														  category__c = 'Test Category',
	    														  sub_category__c = 'Test Subcategory',
	    														  Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach',
	    														  priority__c = 99);
	    insert car;

	    Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(Email_Address__c='admissions@asu.edu', 
	    														  customer_notice_email_from_name__c = 'Default Test Service',
	    														  email_template_id__c = templateId,
	    														  queue_id__c = String.valueOf(TMUser.Id).subString(0,15),
	    														  origin__c = 'Test Origin',
	    														  functional_group__c = 'Admission Services - Undergraduate',
	    														  category__c = 'Test Category',
	    														  sub_category__c = 'Test Subcategory',
	    														  priority__c = 999);
	    insert carDefault;

		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign; 
		Map<String,Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
	    
	    Campaign camp = new Campaign(Name = 'C Test',
									 Type = 'Web',
									 RecordTypeId = CampaignRecordTypeInfo.get('Other Source').getRecordTypeId(),
									 Case_Assignment_Rule__c = car.Id,
                            		 IsActive = TRUE);            
        insert camp;    

		List<Contact> contactList = createContacts(1);
		insert contactList;

		Set<Id> contactIds = new Set<Id>();
		for (Contact c: contactList) {
			contactIds.add(c.Id);
		}

		// Re-select Contacts to get AccountId values
		contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

		List<Opportunity> oppList = createOpportunities(contactList);
		for (Opportunity o: oppList) {
			o.Enrollment_Coach__c = ECUser.Id;
			o.OwnerId = TMUser.Id;
		}
		insert oppList;

		Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case; 
		Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

		List<Case> caseList = new List<Case>();
		for (Contact c: contactList) {
			Case ca = new Case(ContactId = c.Id,
							   RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
							   Case_Source__c = camp.Id,
							   Associate_Case_to_Active_Opportunity__c = false,
							   Subject='Test Subject', 
							   Description='Test Desc', 
							   Status='In Progress');
			caseList.add(ca);
		}

		Test.startTest();
		System.runAs(APIUser) {
			insert caseList;
		}
		Test.stopTest();

		//List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
		List<Case> newCaseList = new List<Case>([SELECT Id, Category__c, OwnerId FROM Case WHERE ContactId IN :contactIds]);
		for (Case ca: newCaseList) {
			system.assert(ca.OwnerId == ECUser.Id, 'Case owner was not assigned to Enrollment Coach');
		}
	}	


	private static testMethod void testAdmissionsCaseWebformCARFunctionalGroup() {
	    Profile saProfile = [select id from profile where name='System Administrator'];
		
		User APIUser = new User();
	    APIUser.FirstName = 'API';
	    APIUser.LastName = 'LName';
	    APIUser.CompanyName = 'Test Company';
	    APIUser.MobilePhone = '123-456-7890';
	    APIUser.Username = 'testUser-Inactive@test.test';
	    APIUser.Email = 'testUser-Inactive@test.test';
	    APIUser.Alias = 'testXX';
	    APIUser.CommunityNickname = 'test1';
	    APIUser.TimeZoneSidKey = 'America/New_York';
	    APIUser.LocaleSidKey = 'en_US';
	    APIUser.EmailEncodingKey = 'UTF-8';
	    APIUser.ProfileId = saProfile.Id;
	    APIUser.LanguageLocaleKey = 'en_US';
	    APIUser.IsActive = true;
	    insert APIUser; 

		User TMUser = new User();
	    TMUser.FirstName = 'FName';
	    TMUser.LastName = 'LName';
	    TMUser.CompanyName = 'Test Company';
	    TMUser.MobilePhone = '123-456-7890';
	    TMUser.Username = 'testUser-Inactive2@test.test';
	    TMUser.Email = 'testUser-Inactive2@test.test';
	    TMUser.Alias = 'testXX2';
	    TMUser.CommunityNickname = 'test2';
	    TMUser.TimeZoneSidKey = 'America/New_York';
	    TMUser.LocaleSidKey = 'en_US';
	    TMUser.EmailEncodingKey = 'UTF-8';
	    TMUser.ProfileId = saProfile.Id;
	    TMUser.LanguageLocaleKey = 'en_US';
	    TMUser.IsActive = true;
	    insert TMUser; 	

		// Set up Case Assignment Rules
		Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' and AccessType = 'Public' LIMIT 1];
		
		EmailTemplate e;
		QueueSobject testQueue;
		Group testGroup;
		System.runAs(new User(Id = Userinfo.getUserId())) {
			e = new EmailTemplate (developerName = 'test', TemplateType= 'Text', Name = 'test', FolderId = f.Id, isActive=true); 
			insert e;

			testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
			insert testGroup;
			
			testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
	    	insert testQueue;
		}
		


	    string queueId = String.valueOf(testGroup.Id).substring(0,15);
	    string templateId = String.valueOf(e.Id).substring(0,15);
	    
	    Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(Email_Address__c='service@test.test', 
	    														  customer_notice_email_from_name__c = 'Test Service',
	    														  email_template_id__c = templateId,
	    														  queue_id__c = String.valueOf(TMUser.Id).subString(0,15),
	    														  //origin__c = 'Test Origin',
	    														  functional_group__c = 'Admission Services - Undergraduate',
	    														  category__c = 'Test Category',
	    														  sub_category__c = 'Test Subcategory',
	    														  priority__c = 99);
	    insert car;

	    Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(Email_Address__c='admissions@asu.edu', 
	    														  customer_notice_email_from_name__c = 'Default Test Service',
	    														  email_template_id__c = templateId,
	    														  queue_id__c = String.valueOf(TMUser.Id).subString(0,15),
	    														  origin__c = 'Test Origin',
	    														  functional_group__c = 'Admission Services - Undergraduate',
	    														  category__c = 'Test Category',
	    														  sub_category__c = 'Test Subcategory',
	    														  priority__c = 999);
	    insert carDefault;

		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign; 
		Map<String,Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
	    
	    Campaign camp = new Campaign(Name = 'C Test',
									 Type = 'Web',
									 RecordTypeId = CampaignRecordTypeInfo.get('Other Source').getRecordTypeId(),
									 Case_Assignment_Rule__c = car.Id,
                            		 IsActive = TRUE);            
        insert camp;    

		List<Contact> contactList = createContacts(1);
		insert contactList;

		Set<Id> contactIds = new Set<Id>();
		for (Contact c: contactList) {
			contactIds.add(c.Id);
		}

		// Re-select Contacts to get AccountId values
		contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

		List<Opportunity> oppList = createOpportunities(contactList);
		for (Opportunity o: oppList) {
//			o.Enrollment_Coach__c = TMUser.Id;
		}
		insert oppList;

		Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case; 
		Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

		List<Case> caseList = new List<Case>();
		for (Contact c: contactList) {
			Case ca = new Case(ContactId = c.Id,
							   RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
							   Case_Source__c = camp.Id,
							   Associate_Case_to_Active_Opportunity__c = false,
							   Subject='Test Subject', 
							   Description='Test Desc', 
							   Status='In Progress');
			caseList.add(ca);
		}

		Test.startTest();
		System.runAs(APIUser) {
			insert caseList;
		}
		Test.stopTest();

		//List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
		List<Case> newCaseList = new List<Case>([SELECT Id, functional_group__c, OwnerId FROM Case WHERE ContactId IN :contactIds]);
		for (Case ca: newCaseList) {
			system.assert(ca.OwnerId == TMUser.Id, 'Case owner was not assigned to CAR Queue/User');
			system.assert(ca.functional_group__c == 'Admission Services - Undergraduate', 'Case Functional Group was not assigned to CAR Functional Group');
		}
	}	


	
	private static testMethod void testAdmissionsCaseWebformDefaultCARAssignment() {
	    Profile saProfile = [select id from profile where name='System Administrator'];
		
		User APIUser = new User();
	    APIUser.FirstName = 'API';
	    APIUser.LastName = 'LName';
	    APIUser.CompanyName = 'Test Company';
	    APIUser.MobilePhone = '123-456-7890';
	    APIUser.Username = 'testUser-Inactive@test.test';
	    APIUser.Email = 'testUser-Inactive@test.test';
	    APIUser.Alias = 'testXX';
	    APIUser.CommunityNickname = 'test1';
	    APIUser.TimeZoneSidKey = 'America/New_York';
	    APIUser.LocaleSidKey = 'en_US';
	    APIUser.EmailEncodingKey = 'UTF-8';
	    APIUser.ProfileId = saProfile.Id;
	    APIUser.LanguageLocaleKey = 'en_US';
	    APIUser.IsActive = true;
	    insert APIUser; 

		User TMUser = new User();
	    TMUser.FirstName = 'FName';
	    TMUser.LastName = 'LName';
	    TMUser.CompanyName = 'Test Company';
	    TMUser.MobilePhone = '123-456-7890';
	    TMUser.Username = 'testUser-Inactive2@test.test';
	    TMUser.Email = 'testUser-Inactive2@test.test';
	    TMUser.Alias = 'testXX2';
	    TMUser.CommunityNickname = 'test2';
	    TMUser.TimeZoneSidKey = 'America/New_York';
	    TMUser.LocaleSidKey = 'en_US';
	    TMUser.EmailEncodingKey = 'UTF-8';
	    TMUser.ProfileId = saProfile.Id;
	    TMUser.LanguageLocaleKey = 'en_US';
	    TMUser.IsActive = true;
	    insert TMUser; 	

		// Set up Case Assignment Rules
		Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' and AccessType = 'Public' LIMIT 1];
		
		EmailTemplate e;
		QueueSobject testQueue;
		Group testGroup;
		System.runAs(new User(Id = Userinfo.getUserId())) {
			e = new EmailTemplate (developerName = 'test', TemplateType= 'Text', Name = 'test', FolderId = f.Id, isActive=true); 
			insert e;

			testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
			insert testGroup;
			
			testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Lead');
	    	insert testQueue;
		}
		


	    string queueId = String.valueOf(testGroup.Id).substring(0,15);
	    string templateId = String.valueOf(e.Id).substring(0,15);
	    
	    Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(Email_Address__c='service@test.test', 
	    														  customer_notice_email_from_name__c = 'Test Service',
	    														  email_template_id__c = templateId,
	    														  queue_id__c = String.valueOf(APIUser.Id).substring(0,15),
	    														  origin__c = 'Test Origin',
	    														  functional_group__c = 'Admission Services - Undergraduate',
	    														  category__c = 'Test Category',
	    														  sub_category__c = 'Test Subcategory',
	    														  priority__c = 99);
	    insert car;

	    Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(Email_Address__c='admissions@asu.edu', 
	    														  customer_notice_email_from_name__c = 'Default Test Service',
	    														  email_template_id__c = templateId,
	    														  queue_id__c = String.valueOf(APIUser.Id).substring(0,15),
	    														  origin__c = 'Test Origin',
	    														  functional_group__c = 'Admission Services - Undergraduate',
	    														  category__c = 'Test Category',
	    														  sub_category__c = 'Test Subcategory',
	    														  priority__c = 999);
	    insert carDefault;


		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign; 
		Map<String,Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
	    
	    Campaign camp = new Campaign(Name = 'C Test',
									 Type = 'Web',
									 RecordTypeId = CampaignRecordTypeInfo.get('Other Source').getRecordTypeId(),
                            		 IsActive = TRUE);            
        insert camp; 
 

		List<Contact> contactList = createContacts(1);
		insert contactList;

		Set<Id> contactIds = new Set<Id>();
		for (Contact c: contactList) {
			contactIds.add(c.Id);
		}

		// Re-select Contacts to get AccountId values
		contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

		List<Opportunity> oppList = createOpportunities(contactList);
		for (Opportunity o: oppList) {
			o.CloseDate = Date.today();
			o.OwnerId = TMUser.Id;
		}
		insert oppList;
		
		TMUser.IsActive = false;
		System.runAs(new User(Id = Userinfo.getUserId())) {
			update TMUser;
		}

		Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case; 
		Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

		List<Case> caseList = new List<Case>();
		for (Contact c: contactList) {
			Case ca = new Case(ContactId = c.Id,
							   RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
							   Case_Source__c = camp.Id,
							   Associate_Case_to_Active_Opportunity__c = false,
							   Subject='Test Subject', 
							   Description='Test Desc', 
							   Status='In Progress');
			caseList.add(ca);
		}

		Test.startTest();
		System.runAs(APIUser) {
			insert caseList;
		}
		Test.stopTest();

		//List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
		List<Case> newCaseList = new List<Case>([SELECT Id, OwnerId FROM Case WHERE ContactId IN :contactIds]);
		for (Case ca: newCaseList) {
			system.assert(ca.OwnerId == APIUser.Id, 'Case owner was not assigned to Default CAR Queue/User');
		}
	}	

	private static testMethod void testAdmissionsCaseWebformDefaultCAR_ECAssignment() {
	    Profile saProfile = [select id from profile where name='System Administrator'];
		
		User APIUser = new User();
	    APIUser.FirstName = 'API';
	    APIUser.LastName = 'LName';
	    APIUser.CompanyName = 'Test Company';
	    APIUser.MobilePhone = '123-456-7890';
	    APIUser.Username = 'testUser-Inactive@test.test';
	    APIUser.Email = 'testUser-Inactive@test.test';
	    APIUser.Alias = 'testXX';
	    APIUser.CommunityNickname = 'test1';
	    APIUser.TimeZoneSidKey = 'America/New_York';
	    APIUser.LocaleSidKey = 'en_US';
	    APIUser.EmailEncodingKey = 'UTF-8';
	    APIUser.ProfileId = saProfile.Id;
	    APIUser.LanguageLocaleKey = 'en_US';
	    APIUser.IsActive = true;
	    insert APIUser; 

		User TMUser = new User();
	    TMUser.FirstName = 'FName';
	    TMUser.LastName = 'LName';
	    TMUser.CompanyName = 'Test Company';
	    TMUser.MobilePhone = '123-456-7890';
	    TMUser.Username = 'testUser-Inactive2@test.test';
	    TMUser.Email = 'testUser-Inactive2@test.test';
	    TMUser.Alias = 'testXX2';
	    TMUser.CommunityNickname = 'test2';
	    TMUser.TimeZoneSidKey = 'America/New_York';
	    TMUser.LocaleSidKey = 'en_US';
	    TMUser.EmailEncodingKey = 'UTF-8';
	    TMUser.ProfileId = saProfile.Id;
	    TMUser.LanguageLocaleKey = 'en_US';
	    TMUser.IsActive = true;
	    insert TMUser; 	

		User ECUser = new User();
	    ECUser.FirstName = 'FName';
	    ECUser.LastName = 'LName';
	    ECUser.CompanyName = 'Test Company';
	    ECUser.MobilePhone = '123-456-7890';
	    ECUser.Username = 'testUser-Inactive3@test.test';
	    ECUser.Email = 'testUser-Inactive3@test.test';
	    ECUser.Alias = 'testXX2';
	    ECUser.CommunityNickname = 'test3';
	    ECUser.TimeZoneSidKey = 'America/New_York';
	    ECUser.LocaleSidKey = 'en_US';
	    ECUser.EmailEncodingKey = 'UTF-8';
	    ECUser.ProfileId = saProfile.Id;
	    ECUser.LanguageLocaleKey = 'en_US';
	    ECUser.IsActive = true;
	    insert ECUser;

		// Set up Case Assignment Rules
		Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' and AccessType = 'Public' LIMIT 1];
		
		EmailTemplate e;
		QueueSobject testQueue;
		Group testGroup;
		System.runAs(new User(Id = Userinfo.getUserId())) {
			e = new EmailTemplate (developerName = 'test', TemplateType= 'Text', Name = 'test', FolderId = f.Id, isActive=true); 
			insert e;

			testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
			insert testGroup;
			
			testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Lead');
	    	insert testQueue;
		}
		


	    string queueId = String.valueOf(testGroup.Id).substring(0,15);
	    string templateId = String.valueOf(e.Id).substring(0,15);
	    
	    Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(Email_Address__c='service@test.test', 
	    														  customer_notice_email_from_name__c = 'Test Service',
	    														  email_template_id__c = templateId,
	    														  queue_id__c = String.valueOf(APIUser.Id).substring(0,15),
	    														  origin__c = 'Test Origin',
	    														  functional_group__c = 'Admission Services - Undergraduate',
	    														  category__c = 'Test Category',
	    														  sub_category__c = 'Test Subcategory',
	    														  priority__c = 99);
	    insert car;

	    Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(Email_Address__c='admissions@asu.edu', 
	    														  customer_notice_email_from_name__c = 'Default Test Service',
	    														  email_template_id__c = templateId,
	    														  queue_id__c = String.valueOf(APIUser.Id).substring(0,15),
	    														  origin__c = 'Test Origin',
	    														  functional_group__c = 'Admission Services - Undergraduate',
	    														  category__c = 'Test Category',
	    														  sub_category__c = 'Test Subcategory',
	    														  Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach',
	    														  priority__c = 999);
	    insert carDefault;


		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign; 
		Map<String,Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
	    
	    Campaign camp = new Campaign(Name = 'C Test',
									 Type = 'Web',
									 RecordTypeId = CampaignRecordTypeInfo.get('Other Source').getRecordTypeId(),
                            		 IsActive = TRUE);            
        insert camp; 
 

		List<Contact> contactList = createContacts(1);
		insert contactList;

		Set<Id> contactIds = new Set<Id>();
		for (Contact c: contactList) {
			contactIds.add(c.Id);
		}

		// Re-select Contacts to get AccountId values
		contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

		List<Opportunity> oppList = createOpportunities(contactList);
		for (Opportunity o: oppList) {
			o.CloseDate = Date.today();
			o.OwnerId = TMUser.Id;
			o.Enrollment_Coach__c = ECUser.Id;
		}
		insert oppList;
		
		TMUser.IsActive = false;
		System.runAs(new User(Id = Userinfo.getUserId())) {
			update TMUser;
		}

		Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case; 
		Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

		List<Case> caseList = new List<Case>();
		for (Contact c: contactList) {
			Case ca = new Case(ContactId = c.Id,
							   RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
							   Case_Source__c = camp.Id,
							   Associate_Case_to_Active_Opportunity__c = false,
							   Subject='Test Subject', 
							   Description='Test Desc', 
							   Status='In Progress');
			caseList.add(ca);
		}

		Test.startTest();
		System.runAs(APIUser) {
			insert caseList;
		}
		Test.stopTest();

		//List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
		List<Case> newCaseList = new List<Case>([SELECT Id, OwnerId FROM Case WHERE ContactId IN :contactIds]);
		for (Case ca: newCaseList) {
			system.assert(ca.OwnerId == ECUser.Id, 'Case owner was not assigned to Enrollment Coach User as specified by Default CAR');
		}
	}	

	
/*
	static void createCaseAssignmentRule() {
		Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' and AccessType = 'Public' LIMIT 1];
		
		EmailTemplate e;
		QueueSobject testQueue;
		Group testGroup;
		System.runAs(new User(Id = Userinfo.getUserId())) {
			e = new EmailTemplate (developerName = 'test', TemplateType= 'Text', Name = 'test', FolderId = f.Id, isActive=true); 
			insert e;

			testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
			insert testGroup;
			
			testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Lead');
	    	insert testQueue;
		}
		


	    string queueId = String.valueOf(testQueue.Id).substring(0,15);
	    string templateId = String.valueOf(e.Id).substring(0,15);
	    
	    Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(Email_Address__c='service@test.test', 
	    														  customer_notice_email_from_name__c = 'Test Service',
	    														  email_template_id__c = templateId,
	    														  queue_id__c = queueId,
	    														  origin__c = 'Test Origin',
	    														  functional_group__c = 'Admission Services - Undergraduate',
	    														  category__c = 'Test Category',
	    														  sub_category__c = 'Test Subcategory',
	    														  priority__c = 99);
	    insert car;

	    Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(Email_Address__c='admissions@asu.edu', 
	    														  customer_notice_email_from_name__c = 'Default Test Service',
	    														  email_template_id__c = templateId,
	    														  origin__c = 'Test Origin',
	    														  queue_id__c = queueId,
	    														  functional_group__c = 'Admission Services - Undergraduate',
	    														  category__c = 'Test Category',
	    														  sub_category__c = 'Test Subcategory',
	    														  priority__c = 999);
	    insert carDefault;
	}
*/


    
    static testmethod void TestFAChangeStateWithSufficientLinks()
    {
        Id fa_id = [
                SELECT Id
                FROM Group
                WHERE Name = 'Financial Aid (Case)'
                AND Type = 'Queue' LIMIT 1
        ].Id;

        Contact con = createContact();
        Case c = createCase(fa_id);
        c.Deep_Links__c = 'field_1:<a href="http://www.google.com">Click Here</a><br />field_2:<a href="http://www.google.com">Click Here</a><br />field_3:<a href="http://www.google.com">Click Here</a><br />';
        c.Number_of_Files__c = '3';
        Test.startTest();
        update c;
        Test.stopTest();
        Case stat = [
            SELECT Status, Visible_by_Contact__c
            FROM Case
            WHERE Id = :c.Id LIMIT 1
        ];

        System.assert(stat.Status == 'Closed: Resolved');
        System.assert(stat.Visible_by_Contact__c == FALSE);
    }

    static testmethod void TestRegChangeStateWithSufficientLinks()
    {
        Id reg_id = [
                SELECT Id
                FROM Group
                WHERE Name = 'University Registrar Services (Case)'
                AND Type = 'Queue' LIMIT 1
        ].Id;

        Contact con = createContact();
        Case c = createCase(reg_id);
        c.Deep_Links__c = 'field_1:<a href="http://www.google.com">Click Here</a><br />field_2:<a href="http://www.google.com">Click Here</a><br />field_3:<a href="http://www.google.com">Click Here</a><br />';
        c.Number_of_Files__c = '3';
        Test.startTest();
        update c;
        Test.stopTest();
        Case stat = [
            SELECT Status, Visible_by_Contact__c
            FROM Case
            WHERE Id = :c.Id LIMIT 1
        ];

        System.assert(stat.Status == 'New');
        System.assert(stat.Visible_by_Contact__c == TRUE);
    }
    
    static testmethod void TestChangeStateWithoutSufficientLinks()
    {
        Id reg_id = [
                SELECT Id
                FROM Group
                WHERE Name = 'University Registrar Services (Case)'
                AND Type = 'Queue' LIMIT 1
        ].Id;

        Contact con = createContact();
        Case c = createCase(reg_id);
        c.Deep_Links__c = 'field_1:<a href="http://www.google.com">Click Here</a><br />field_2:<a href="http://www.google.com">Click Here</a><br />field_3:<a href="http://www.google.com">Click Here</a><br />';
        c.Number_of_Files__c = '5';
        Test.startTest();
        update c;
        Test.stopTest();
        Case stat = [SELECT Status FROM Case WHERE Id = :c.Id LIMIT 1];
        System.assert(stat.Status == 'Processing');
    }
}