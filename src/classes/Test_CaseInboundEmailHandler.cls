@IsTest(SeeAllData=false)
public with sharing class Test_CaseInboundEmailHandler {


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
	    													  functional_group__c = 'Test Group',
	    													  category__c = 'Test Category',
	    													  sub_category__c = 'Test Subcategory',
    														  priority__c = 99);
    insert car;

    Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(Email_Address__c='default@test.test', 
    														  customer_notice_email_from_name__c = 'Default Test Service',
    														  email_template_id__c = templateId,
    														  queue_id__c = queueId,
	    													  origin__c = 'Test Origin',
	    													  functional_group__c = 'Test Group',
	    													  category__c = 'Test Category',
	    													  sub_category__c = 'Test Subcategory',
    														  priority__c = 999);
    insert carDefault;
}

static void createCustomSettings() {
	Email_To_Case_Filter__c etcf1 = new Email_To_Case_Filter__c(Name='Test Filter');
	Email_To_Case_Filter__c etcf2 = new Email_To_Case_Filter__c(Name='blockme@test.test');
	insert etcf1;
	insert etcf2;

	Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' and AccessType = 'Public' LIMIT 1];
	
	EmailTemplate e;
	System.runAs(new User(Id = Userinfo.getUserId())) {
		e = new EmailTemplate (developerName = 'test2', TemplateType= 'Text', Name = 'test2', FolderId = f.Id, IsActive=true); 
		insert e;
	}
	
	Email_To_Case_Configuration__c etcc1 = new Email_To_Case_Configuration__c(Name='Rejected Attachment Email Template ID', Value__c=e.Id);
	Email_To_Case_Configuration__c etcc2 = new Email_To_Case_Configuration__c(Name='Reopen Closed Case Threshold', Value__c='14');
	Email_To_Case_Configuration__c etcc3 = new Email_To_Case_Configuration__c(Name='Valid Attachment Types', Value__c='doc,pdf,png,docx,jpeg,jpg,gif,xls,xlsx,txt');
	Email_To_Case_Configuration__c etcc4 = new Email_To_Case_Configuration__c(Name='Default Org Wide Email Address', Value__c='default@test.test');
	
	insert etcc1;
	insert etcc2;
	insert etcc3;
	insert etcc4;
	
}

static testMethod void newContact() {
	
	createCaseAssignmentRule();
	createCustomSettings();

	Messaging.InboundEmail email = new Messaging.InboundEmail();
	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

	List<string> toAddresses = new List<string>();
	toAddresses.add('service@test.test');	
	toAddresses.add('default@test.test');
	email.toAddresses = toAddresses;
	email.subject = 'test';
	email.fromAddress = 'user@acme.com.test';
	email.fromName = 'Last, First';
	env.fromAddress = 'user@acme.com.test';

	// set the body of the attachment
	inAtt.body = blob.valueOf('test');
	inAtt.fileName = 'attach.pdf';
	inAtt.mimeTypeSubType = 'plain/txt';

	email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt }; 
   
	Messaging.InboundEmail.TextAttachment tattachment = new Messaging.InboundEmail.TextAttachment();
	String csv = 'this is just a test';
	tattachment.body = csv;
	tattachment.fileName = 'data.txt';
	tattachment.mimeTypeSubType = 'text/plain';
	  
	email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { tattachment };   

	// call the class and test it with the data in the testMethod
	CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
	emailServiceObj.handleInboundEmail(email, env );  
	
	email.subject = 'Test 2';
	emailServiceObj.handleInboundEmail(email, env );  
	                    
}    

/*
static testMethod void badAttachment() {

	Messaging.InboundEmail email = new Messaging.InboundEmail();
	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

	List<string> toAddresses = new List<string>();
	toAddresses.add('service@test.test');	
	email.toAddresses = toAddresses;
	email.subject = 'test';
	email.fromAddress = 'user@acme.com.test';
	email.fromName = 'Last, First';
	env.fromAddress = 'user@acme.com.test';

	// set the body of the attachment
	inAtt.body = blob.valueOf('test');
	inAtt.fileName = 'attach.exe';
	inAtt.mimeTypeSubType = 'plain/txt';

	email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt }; 
   

	// call the class and test it with the data in the testMethod
	CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
	emailServiceObj.handleInboundEmail(email, env );  
	
	email.subject = 'Test 2';
	emailServiceObj.handleInboundEmail(email, env );  
	                    
}  
*/


static testMethod void existingContact() {
	createCaseAssignmentRule();
	createCustomSettings();
	
	Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
	insert c;

	Messaging.InboundEmail email = new Messaging.InboundEmail();
	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

	List<string> toAddresses = new List<string>();
	toAddresses.add('service@test.test');	
	email.toAddresses = toAddresses;
	email.subject = 'test';
	email.fromAddress = 'user2@acme.com.test';
	email.fromName = 'Last, First';
	env.fromAddress = 'user@acme.com.test';

	// call the class and test it with the data in the testMethod
	CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
	emailServiceObj.handleInboundEmail(email, env );  
	email.subject = 'Test 2';
	emailServiceObj.handleInboundEmail(email, env );  
	                    
}  

static testMethod void existingContactCcOnly() {
	createCaseAssignmentRule();
	createCustomSettings();
	
	Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
	insert c;

	Messaging.InboundEmail email = new Messaging.InboundEmail();
	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

	List<string> ccAddresses = new List<string>();
	ccAddresses.add('service@test.test');	
	email.ccAddresses = ccAddresses;
	email.subject = 'test';
	email.fromAddress = 'user2@acme.com.test';
	email.fromName = 'Last, First';
	env.fromAddress = 'user@acme.com.test';

	// call the class and test it with the data in the testMethod
	CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
	emailServiceObj.handleInboundEmail(email, env );  
	email.subject = 'Test CC Only';
	emailServiceObj.handleInboundEmail(email, env );  
	                    
}  


static testMethod void multipleExistingContacts() {
	createCaseAssignmentRule();
	createCustomSettings();
	
	Contact c1 = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test');
	Contact c2 = new Contact(FirstName='First', LastName='Last', Email='user@work.com.test', ASU_Gmail__c='user@acme.com.test');
	insert c1;
	insert c2;

	Messaging.InboundEmail email = new Messaging.InboundEmail();
	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

	List<string> toAddresses = new List<string>();
	toAddresses.add('service@test.test');	
	email.toAddresses = toAddresses;
	email.subject = 'test';
	email.fromAddress = 'user@acme.com.test';
	email.fromName = 'Last, First';
	env.fromAddress = 'user@acme.com.test';

	// call the class and test it with the data in the testMethod
	CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
	emailServiceObj.handleInboundEmail(email, env );  
	email.subject = 'Test 2';
	emailServiceObj.handleInboundEmail(email, env );  
	                    
}  

static testMethod void existingContactDefaultRule() {
	createCaseAssignmentRule();
	createCustomSettings();
	
	Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
	insert c;

	Messaging.InboundEmail email = new Messaging.InboundEmail();
	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

	List<string> toAddresses = new List<string>();
	toAddresses.add('service_nomatch@test.test');	
	email.toAddresses = toAddresses;
	email.subject = 'test';
	email.fromAddress = 'user2@acme.com.test';
	email.fromName = 'Last, First';
	env.fromAddress = 'user@acme.com.test';

	// call the class and test it with the data in the testMethod
	CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
	emailServiceObj.handleInboundEmail(email, env );  
	email.subject = 'Test 2';
	emailServiceObj.handleInboundEmail(email, env );  
	                    
} 

}