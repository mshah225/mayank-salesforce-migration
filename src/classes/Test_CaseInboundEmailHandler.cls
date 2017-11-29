@IsTest
public with sharing class Test_CaseInboundEmailHandler {


    @testSetup static void initialize()
    {
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' and AccessType = 'Public' LIMIT 1];

        EmailTemplate e1;
        QueueSobject testQueue, caseQueue;
        Group testGroup, caseGroup;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            e1 = new EmailTemplate (developerName = 'test', TemplateType= 'Text', Name = 'test', FolderId = f.Id, isActive=true);
            insert e1;

            testGroup = new Group(Name = 'TestGroup', Type = 'Queue');
            insert testGroup;

            caseGroup = new Group(Name = 'CaseGroup', Type = 'Queue');
            insert caseGroup;

            testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Lead');
            insert testQueue;

            caseQueue = new QueueSObject(QueueId = caseGroup.Id, SobjectType = 'Case');
            insert caseQueue;
        }

        String queueId = String.valueOf(caseGroup.Id).substring(0,15);
        String fallbackQueueId = String.valueOf(caseGroup.Id).substring(0,15);
        String templateId = String.valueOf(e1.Id).substring(0,15);


		TestDataFactory.createFunctionalGroupWithCategory('Test Group', 'Test Category', 'Test Subcategory');
		TestDataFactory.createFunctionalGroupWithCategory('Test RMM Group 1', 'Test RMM Category 1', 'Test RMM Subcategory 1');
		TestDataFactory.createFunctionalGroupWithCategory('Test RMM Group 2', 'Test RMM Category 2', 'Test RMM Subcategory 2');
		TestDataFactory.createFunctionalGroupWithCategory('Test Group 2', 'Test Category 2', 'Test Subcategory 2');

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c();
        car.Email_Address__c = 'service12345123451234512345@test.test';
        car.Customer_notice_email_from_name__c = 'Test Service';
        car.Email_template_id__c = templateId;
        car.Queue_id__c = queueId;
        car.Fallback_Queue_Id__c = fallbackQueueId;
        car.Origin__c = 'Test Origin';
        car.CC_Functional_Group__c = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Functional Group' AND Active__c = true AND Name = 'Test Group' LIMIT 1].Id;
        car.CC_Category__c = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Category' AND Active__c = true AND Name = 'Test Category' LIMIT 1].Id;
        car.CC_Sub_Category__c = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Sub Category' AND Active__c = true AND Name = 'Test Subcategory' LIMIT 1].Id;
        car.Functional_Group__c = 'Test Group';
        car.Category__c = 'Test Category';
        car.Sub_Category__c = 'Test Subcategory';
        car.Priority__c = 99;

        insert car;

        Case_Assignment_Rule__c rmmCar1 = new Case_Assignment_Rule__c();
        rmmCar1.Email_Address__c = 'reply-fec817737361077e-10607_html-31250844-7204971-0@e.asu.edu';
        rmmCar1.Customer_notice_email_from_name__c = 'Test RMM Service 1';
        rmmCar1.Email_template_id__c = templateId;
        rmmCar1.Queue_id__c = queueId;
        rmmCar1.Fallback_Queue_Id__c = fallbackQueueId;
        rmmCar1.Origin__c = 'Test RMM Origin 1';
        rmmCar1.CC_Functional_Group__c = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Functional Group' AND Active__c = true AND Name = 'Test RMM Group 1' LIMIT 1].Id;
        rmmCar1.CC_Category__c = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Category' AND Active__c = true AND Name = 'Test RMM Category 1' LIMIT 1].Id;
        rmmCar1.CC_Sub_Category__c = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Sub Category' AND Active__c = true AND Name = 'Test RMM Subcategory 1' LIMIT 1].Id;
        rmmCar1.Functional_Group__c = 'Test RMM Group 1';
        rmmCar1.Category__c = 'Test RMM Category 1';
        rmmCar1.Sub_Category__c = 'Test RMM Subcategory 1';
        rmmCar1.Priority__c = 998;

        insert rmmCar1;

        Case_Assignment_Rule__c rmmCar2 = new Case_Assignment_Rule__c();
        rmmCar2.Email_Address__c = 'reply-fdf1234-9999_html-foobar12345-1234567-0@e.asu.edu';
        rmmCar2.Customer_notice_email_from_name__c = 'Test RMM Service 2';
        rmmCar2.Email_template_id__c = templateId;
        rmmCar2.Queue_id__c = queueId;
        rmmCar2.Fallback_Queue_Id__c = fallbackQueueId;
        rmmCar2.Origin__c = 'Test RMM Origin 2';
        rmmCar2.CC_Functional_Group__c = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Functional Group' AND Active__c = true AND Name = 'Test RMM Group 2' LIMIT 1].Id;
        rmmCar2.CC_Category__c = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Category' AND Active__c = true AND Name = 'Test RMM Category 2' LIMIT 1].Id;
        rmmCar2.CC_Sub_Category__c = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Sub Category' AND Active__c = true AND Name = 'Test RMM Subcategory 2' LIMIT 1].Id;
        rmmCar2.Functional_Group__c = 'Test RMM Group 2';
        rmmCar2.Category__c = 'Test RMM Category 2';
        rmmCar2.Sub_Category__c = 'Test RMM Subcategory 2';
        rmmCar2.Priority__c = 997;

        insert rmmCar2;

        Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c();
        carDefault.Email_Address__c = 'default@test.test';
        carDefault.Customer_notice_email_from_name__c = 'Default Test Service';
        carDefault.Email_template_id__c = templateId;
        carDefault.Queue_Id__c = queueId;
        carDefault.Fallback_Queue_Id__c = fallbackQueueId;
        carDefault.Origin__c = 'Test Origin 2';
        carDefault.CC_Functional_Group__c = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Functional Group' AND Active__c = true AND Name = 'Test Group 2' LIMIT 1].Id;
        carDefault.CC_Category__c = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Category' AND Active__c = true AND Name = 'Test Category 2' LIMIT 1].Id;
        carDefault.CC_Sub_Category__c = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Sub Category' AND Active__c = true AND Name = 'Test Subcategory 2' LIMIT 1].Id;
        carDefault.Functional_Group__c = 'Test Group 2';
        carDefault.Category__c = 'Test Category 2';
        carDefault.Sub_Category__c = 'Test Subcategory 2';
        carDefault.Priority__c = 999;

        insert carDefault;

        Email_To_Case_Filter__c etcf1 = new Email_To_Case_Filter__c(Name='Test Filter');
        Email_To_Case_Filter__c etcf2 = new Email_To_Case_Filter__c(Name='blockme@test.test');
        insert etcf1;
        insert etcf2;

        EmailTemplate e2;
        System.runAs(new User(Id = Userinfo.getUserId()))
        {
            e2 = new EmailTemplate (developerName = 'test2', TemplateType= 'Text', Name = 'test2', FolderId = f.Id, IsActive=true);
            insert e2;
        }

        Email_To_Case_Configuration__c etcc1 = new Email_To_Case_Configuration__c(Name='Rejected Attachment Email Template ID', Value__c=e2.Id);
        Email_To_Case_Configuration__c etcc2 = new Email_To_Case_Configuration__c(Name='Reopen Closed Case Threshold', Value__c='14');
        Email_To_Case_Configuration__c etcc3 = new Email_To_Case_Configuration__c(Name='Valid Attachment Types', Value__c='doc,pdf,png,docx,jpeg,jpg,gif,xls,xlsx,txt');
        Email_To_Case_Configuration__c etcc4 = new Email_To_Case_Configuration__c(Name='Default Org Wide Email Address', Value__c='default@test.test');

        insert etcc1;
        insert etcc2;
        insert etcc3;
        insert etcc4;
    }

    @isTest static void newContact()
    {
        Test.startTest();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
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

        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { inAtt };

        Messaging.InboundEmail.TextAttachment tattachment = new Messaging.InboundEmail.TextAttachment();
        String csv = 'this is just a test';
        tattachment.body = csv;
        tattachment.fileName = 'data.txt';
        tattachment.mimeTypeSubType = 'text/plain';

        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { tattachment };

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env );

        Contact createdContact = [
            SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 1
        ];

        System.assert(createdContact != null);
        System.assert(createdContact.FirstName == 'First');
        System.assert(createdContact.LastName == 'Last');
        System.assert(createdContact.Email == 'user@acme.com.test');

        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :createdContact.Id
            LIMIT 1
        ];

        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        Test.stopTest();
    }

    @isTest static void newContactLongName()
    {
        Test.startTest();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        toAddresses.add('default@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user@acme.com.test';
        email.fromName = '0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789, 01234567890123456789012345678901234567890123456789';
        env.fromAddress = 'user@acme.com.test';

        // set the body of the attachment
        inAtt.body = blob.valueOf('test');
        inAtt.fileName = 'attach.pdf';
        inAtt.mimeTypeSubType = 'plain/txt';

        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { inAtt };

        Messaging.InboundEmail.TextAttachment tattachment = new Messaging.InboundEmail.TextAttachment();
        String csv = 'this is just a test';
        tattachment.body = csv;
        tattachment.fileName = 'data.txt';
        tattachment.mimeTypeSubType = 'text/plain';

        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { tattachment };

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env );

        Contact createdContact = [
            SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 1
        ];

        System.assert(createdContact != null);
        System.assert(createdContact.FirstName == '012345678901234567890123456789012345678');
        System.assert(createdContact.LastName == '01234567890123456789012345678901234567890123456789012345678901234567890123456789');
        System.assert(createdContact.Email == 'user@acme.com.test');

        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :createdContact.Id
            LIMIT 1
        ];

        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        Test.stopTest();
    }

    @isTest static void existingContact()
    {
        Test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user2@acme.com.test';
        email.fromName = 'Last, First';
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env );

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, CC_Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        Case_Classification__c fg = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Functional Group' AND Active__c = true AND Name = 'Test Group'];
        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        System.assertEquals(fg.Id, createdCase.CC_Functional_Group__c);
        Test.stopTest();
   }

    @isTest static void existingContactCcOnly()
    {
        Test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        List<string> ccAddresses = new List<string>();
        ccAddresses.add('service12345123451234512345@test.test');
        email.ccAddresses = ccAddresses;
        email.subject = 'test';
        email.fromAddress = 'user2@acme.com.test';
        email.fromName = 'Last, First';
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);

        List<LostEmail__c> lostEmails = [SELECT Recipient__c, Cause__c, Sender__c, Subject__c FROM LostEmail__c];
        System.debug('LOST EMAIL: ' + lostEmails.size());
        System.debug('LOST EMAIL: ' + lostEmails);

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, CC_Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];
        Case_Classification__c fg = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Functional Group' AND Active__c = true AND Name = 'Test Group'];

        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        System.assertEquals(fg.Id, createdCase.CC_Functional_Group__c);

        Test.stopTest();
    }


    @isTest static void multipleExistingContacts()
    {
        Test.startTest();
        Contact c1 = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test');
        Contact c2 = new Contact(FirstName='First', LastName='Last', Email='user@work.com.test', ASU_Gmail__c='user@acme.com.test');
        insert c1;
        insert c2;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user@acme.com.test';
        email.fromName = 'Last, First';
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env );


        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c1.Id
            LIMIT 1
        ];

        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        Test.stopTest();
    }

    @isTest static void existingContactDefaultRule()
    {
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
        Test.startTest();
        emailServiceObj.handleInboundEmail(email, env );
        Test.stopTest();

    }

    @isTest static void createLostEmail()
    {
        Contact testContact = ContactService.createTestContact();

        insert testContact;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        List<String> toAddresses = new List<String>();
        toAddresses.add('example@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'LostEmailTest';
        email.fromAddress = testContact.Email;
        email.fromName = testContact.FirstName + ' ' + testContact.LastName;
        env.fromAddress = testContact.Email;

        String testError = 'Test error';
        Test.startTest();
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.generateLostEmail(email, new Case(), testError);
        Test.stopTest();

        LostEmail__c expectedLostEmail = new LostEmail__c();
        expectedLostEmail.Sender__c = email.fromAddress;
        expectedLostEmail.Subject__c = email.subject;
        expectedLostEmail.Recipient__c = 'example@test.test';
        expectedLostEmail.RejectedAttachments__c = false;
        expectedLostEmail.Cause__c = testError;

        LostEmail__c actualLostEmail = [
                SELECT Sender__c, Subject__c, PlainTextBody__c, HtmlTextBody__c, Recipient__c, RejectedAttachments__c, Cause__c
                FROM LostEmail__c
                LIMIT 1
        ];

        System.assertEquals(expectedLostEmail.Sender__c, actualLostEmail.Sender__c, 'Unexpected differences in the LostEmails');
        System.assertEquals(expectedLostEmail.Subject__c, actualLostEmail.Subject__c, 'Unexpected differences in the LostEmails');
        System.assertEquals(expectedLostEmail.Recipient__c, actualLostEmail.Recipient__c, 'Unexpected differences in the LostEmails');
        System.assertEquals(expectedLostEmail.RejectedAttachments__c, actualLostEmail.RejectedAttachments__c, 'Unexpected differences in the LostEmails');
        System.assertEquals(expectedLostEmail.Cause__c, actualLostEmail.Cause__c, 'Unexpected differences in the LostEmails');

    }

    @isTest static void createLostEmailWithAttachment()
    {
        Contact testContact = ContactService.createTestContact();

        insert testContact;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        List<String> toAddresses = new List<String>();
        toAddresses.add('example@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'LostEmailTest';
        email.fromAddress = testContact.Email;
        email.fromName = testContact.FirstName + ' ' + testContact.LastName;
        env.fromAddress = testContact.Email;

        // Create some attachments
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
        // set the body of the attachment
        inAtt.body = blob.valueOf('test');
        inAtt.fileName = 'attach.pdf';
        inAtt.mimeTypeSubType = 'plain/txt';

        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { inAtt };

        Messaging.InboundEmail.TextAttachment tattachment = new Messaging.InboundEmail.TextAttachment();
        String csv = 'this is just a test';
        tattachment.body = csv;
        tattachment.fileName = 'data.txt';
        tattachment.mimeTypeSubType = 'text/plain';

        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { tattachment };

        String testError = 'Test error';
        Test.startTest();
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.generateLostEmail(email, new Case(), testError);
        Test.stopTest();

        LostEmail__c expectedLostEmail = new LostEmail__c();
        expectedLostEmail.Sender__c = email.fromAddress;
        expectedLostEmail.Subject__c = email.subject;
        expectedLostEmail.Recipient__c = 'example@test.test';
        expectedLostEmail.RejectedAttachments__c = false;
        expectedLostEmail.Cause__c = testError;

        LostEmail__c actualLostEmail = [
                SELECT Sender__c, Subject__c, PlainTextBody__c, HtmlTextBody__c, Recipient__c, RejectedAttachments__c, Cause__c
                FROM LostEmail__c
                LIMIT 1
        ];

        System.assertEquals(expectedLostEmail.Sender__c, actualLostEmail.Sender__c, 'Unexpected differences in the LostEmails');
        System.assertEquals(expectedLostEmail.Subject__c, actualLostEmail.Subject__c, 'Unexpected differences in the LostEmails');
        System.assertEquals(expectedLostEmail.Recipient__c, actualLostEmail.Recipient__c, 'Unexpected differences in the LostEmails');
        System.assertEquals(expectedLostEmail.RejectedAttachments__c, actualLostEmail.RejectedAttachments__c, 'Unexpected differences in the LostEmails');
        System.assertEquals(expectedLostEmail.Cause__c, actualLostEmail.Cause__c, 'Unexpected differences in the LostEmails');

        List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :actualLostEmail.Id];

        //
        System.assert(attachments.size() == 2, 'Unexpected number of Attachments for this LostEmail');

    }

    @isTest static void reopenACaseFromEmail()
    {
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test');
        insert c;

        // Create a test case with our contact
        List<Case> testCases = CaseService.createTestCases(1, c);
        Case createdCase = testCases.get(0);
        createdCase.Status = 'Closed: Resolved';
        Id CFG = TestDataFactory.createFunctionalGroup('CaseFuncGroup').Id;
        Id EU = TestDataFactory.createFunctionalGroup('External Unit').Id;
        createdCase.Most_Recent_Queue__c = 'CaseQueue';
        createdCase.CC_Most_Recent_Functional_Group__c = CFG;
        createdCase.CC_Functional_Group__c = EU;

        insert createdCase;

        // Reopen the case via email
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test email';
        email.fromName = 'Last, First';
        email.plainTextBody = 'ref:' + createdCase.Id + ':ref';
        email.fromAddress = 'user@acme.com.test';

        Test.startTest();
        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);
        Test.stopTest();

        // Verify that the case status was updated
        createdCase = [
                SELECT Status, CC_Functional_Group__c
                FROM Case
                WHERE Id = :createdCase.Id
        ];

        //System.assertEquals(EU, createdCase.CC_Functional_Group__c, 'External Unit case was not re-opened to most recent functional group');
        System.assertEquals('Re-Opened', createdCase.Status, 'Case was not reopened correctly');
    }

    @isTest static void createACaseWithEmptySubject()
    {
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test');
        insert c;

        // Reopen the case via email
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.fromName = 'Last, First';
        email.fromAddress = 'user@acme.com.test';

        Test.startTest();
        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);
        Test.stopTest();

        // Verify that the case status was updated
        Case createdCase = [
                SELECT Status, Functional_Group__c
                FROM Case
                WHERE ContactId = :c.Id
                LIMIT 1
        ];

        System.assertEquals('New', createdCase.Status);
    }

    @isTest static void testDebugLog()
    {
        Id id = null;
        List<String> strings = new List<String>();
        List<Long> longs = new List<Long>();
        Long num = 0;

        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        Test.startTest();
        LostEmail__c result = emailServiceObj.logDebugLostEmail(id, strings, num, strings, longs, strings, strings);
        Test.stopTest();

        System.assertNotEquals(result.Id, null, 'An error occurred when logging the failure');
    }

    @isTest static void testRMMPartialMatchExact()
    {
        Test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        List<string> toAddresses = new List<string>();
        toAddresses.add('reply-fec817737361077e-10607_html-31250844-7204971-0@e.asu.edu');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user2@acme.com.test';
        email.fromName = 'Last, First';
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env );

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, CC_Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];
        Case_Classification__c fg = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Functional Group' AND Active__c = true AND Name = 'Test RMM Group 1'];
        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        System.assertEquals(fg.Id, createdCase.CC_Functional_Group__c);
        Test.stopTest();
   }

    @isTest static void testRMMPartialMatchPartial()
    {
        Test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        List<string> toAddresses = new List<string>();
        toAddresses.add('reply-fec817737361077e-10607_html-31250844-1234567-0@e.asu.edu');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user2@acme.com.test';
        email.fromName = 'Last, First';
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env );

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, CC_Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];
        Case_Classification__c fg = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Functional Group' AND Active__c = true AND Name = 'Test RMM Group 2'];

        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        System.assertEquals(fg.Id, createdCase.CC_Functional_Group__c);

        Test.stopTest();
   }

  @isTest static void testBothBodiesPopulated()
   {
        Test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user2@acme.com.test';
        email.fromName = 'Last, First';
        email.plainTextBody = 'This is a plaintext body';
        email.htmlBody = '<span>This is a <b>HTML</b> body</span>';
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env );

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        System.assert(createdCase.Description == 'This is a plaintext body');

        Test.stopTest();
   }

   @isTest static void testHTMLBodyPopulated()
   {
        Test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user2@acme.com.test';
        email.fromName = 'Last, First';
        email.plainTextBody = null;
        email.htmlBody = '<span>This is a <b>HTML</b> body</span>';
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env );

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        System.assert(createdCase.Description == 'Note: This description was reformatted from the original email body. Please view the case feed to see the original email body.\n\nThis is a HTML body');

        Test.stopTest();
   }

   @isTest static void testNoBodiesPopulatedNoAttachment()
   {
        Test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user2@acme.com.test';
        email.fromName = 'Last, First';
        email.plainTextBody = null;
        email.htmlBody = null;
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env );

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

		System.assert(createdCase.Description != null);
        System.assert(createdCase.Description.contains('without email body or attachment'));
        Test.stopTest();
   }

   @isTest static void testNoBodiesPopulatedBinaryAttachment()
   {
        Test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        // set the body of the attachment
        inAtt.body = blob.valueOf('test');
        inAtt.fileName = 'attach.pdf';
        inAtt.mimeTypeSubType = 'plain/txt';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { inAtt };


        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user2@acme.com.test';
        email.fromName = 'Last, First';
        email.plainTextBody = null;
        email.htmlBody = null;
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env );

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        System.assert(createdCase.Description != null);
        System.assert(createdCase.Description.contains('Attachment received at'));
        Test.stopTest();
   }

   @isTest static void testNoBodiesPopulatedTextAttachment()
   {
        Test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        Messaging.InboundEmail.TextAttachment tattachment = new Messaging.InboundEmail.TextAttachment();
        String csv = 'this is just a test';
        tattachment.body = csv;
        tattachment.fileName = 'data.txt';
        tattachment.mimeTypeSubType = 'text/plain';

        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { tattachment };


        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user2@acme.com.test';
        email.fromName = 'Last, First';
        email.plainTextBody = null;
        email.htmlBody = null;
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env );

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        System.assert(createdCase.Description != null);
        System.assert(createdCase.Description.contains('Attachment received at'));
        Test.stopTest();
   }

   @isTest static void testOriginalEmailPresent()
   {
        Test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        Messaging.InboundEmail.Header header2 = new Messaging.InboundEmail.Header();
        Messaging.InboundEmail.Header header3 = new Messaging.InboundEmail.Header();

        header.name = 'Test 12345';
        header.value = 'Test value 55555';
        header2.name = 'Received';
        header2.value = 'from [209.85.223.170] ([209.85.223.170:35832] helo=mail-io0-f170.google.com) by mx3-was3.mta.salesforce.com (for <gwgmer@gmail.com>) (ecelerity 3.6.17.52090 r(Core:3.6.17.0)) with ESMTPS (cipher=AES128-GCM-SHA256 subject="/C=US/ST=California/L=Mountain View/O=Google Inc/CN=smtp.gmail.com")  id 12/B8-14396-D28B3275; Fri, 29 Apr 2016 19:38:21 +0000';
        header3.name = 'Received';
        header3.value = 'from [209.85.223.170] ([209.85.223.170:35832] helo=mail-io0-f170.google.com) by mx3-was3.mta.salesforce.com (for <foobar@gmail.com>) (ecelerity 3.6.17.52090 r(Core:3.6.17.0)) with ESMTPS (cipher=AES128-GCM-SHA256 subject="/C=US/ST=California/L=Mountain View/O=Google Inc/CN=smtp.gmail.com")  id 12/B8-14396-D28B3275; Fri, 29 Apr 2016 19:38:21 +0000';

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user2@acme.com.test';
        email.fromName = 'Last, First';
        email.plainTextBody = null;
        email.htmlBody = null;
        email.headers = new List<Messaging.InboundEmail.Header>();
        email.headers.add(header);
        email.headers.add(header2);
        email.headers.add(header3);
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c, Intended_Recipient__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        System.assert(createdCase.Intended_Recipient__c == 'gwgmer@gmail.com');

        Test.stopTest();
   }

   @isTest static void testOriginalEmailNotPresent1()
   {

        Test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        Messaging.InboundEmail.Header header2 = new Messaging.InboundEmail.Header();
        Messaging.InboundEmail.Header header3 = new Messaging.InboundEmail.Header();

        header.name = 'Test 12345';
        header2.name = 'Received';
        header2.value = 'Test value 55555';
        header3.name = 'Received';
        header3.value = 'Test value 55555';

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user2@acme.com.test';
        email.fromName = 'Last, First';
        email.plainTextBody = null;
        email.htmlBody = null;
        email.headers = new List<Messaging.InboundEmail.Header>();
        email.headers.add(header);
        email.headers.add(header2);
        email.headers.add(header3);
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c, Intended_Recipient__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        System.assert(createdCase.Intended_Recipient__c == null);
        Test.stopTest();
   }

   @isTest static void testOriginalEmailNotPresent2()
   {
        Test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='user@acme.com.test', Personal_Email__c='user2@acme.com.test');
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'user2@acme.com.test';
        email.fromName = 'Last, First';
        email.plainTextBody = null;
        email.htmlBody = null;
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c, Intended_Recipient__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        System.assert(createdCase.Intended_Recipient__c == null);
        Test.stopTest();
   }

}
