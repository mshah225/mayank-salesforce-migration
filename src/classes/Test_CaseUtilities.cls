@isTest
public with sharing class Test_CaseUtilities {

	static void createCustomSettings() {
		Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' and AccessType = 'Public' LIMIT 1];
	
		EmailTemplate e;
		QueueSobject testQueue;
		Group testGroup;
		System.runAs(new User(Id = Userinfo.getUserId())) {
			e = new EmailTemplate (developerName = 'test', TemplateType= 'Text', Name = 'test', FolderId = f.Id, isActive=true); 
			insert e;
		}

		Contact c = new Contact(FirstName='First', LastName='Last', Email='donotsend@acme.com.test', Personal_Email__c='user2@acme.com.test');
		insert c;

		List<Case_Forwarding_Settings__c> cfsList = new List<Case_Forwarding_Settings__c>();
		
		cfsList.add(new Case_Forwarding_Settings__c(Name='Email Template ID', Value__c = String.valueOf(e.Id)));
		cfsList.add(new Case_Forwarding_Settings__c(Name='Dummy Contact ID', Value__c = String.valueOf(c.Id)));
		
		insert cfsList;
		
	}
	
	static Case createCase() {
		Contact co = new Contact(FirstName='FirstCase', LastName='LastCase', Email='send@acme.com.test', Personal_Email__c='user2@acme.com.test');
		insert co;
		
		Case ca = new Case(Subject='Test Subject', Description='Test Desc', Status='In Progress', ContactId=co.Id);
		insert ca;
		
        Attachment a = new Attachment();  
        a.Name = 'TestAttach1';
        a.Body = Blob.valueOf('HELLO');
        a.ParentId = ca.Id;
        insert a;             

		return ca;
	}
	
	static testMethod void forwardCase() {
		createCustomSettings();
		Case c = createCase();
		
		c.Status = 'Closed: Forwarded';
		c.Forward_To_Email__c = 'forward@test.com.test';
		
		Test.startTest();
		update c;
		Test.stopTest();
	}
	

}