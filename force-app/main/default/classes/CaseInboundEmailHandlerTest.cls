@IsTest
public with sharing class CaseInboundEmailHandlerTest {
    @testSetup
    static void initialize() {
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e1;
        QueueSobject testQueue, caseQueue;
        Group testGroup, caseGroup;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            e1 = new EmailTemplate(
                developerName = 'test',
                TemplateType = 'Text',
                Name = 'test',
                FolderId = f.Id,
                isActive = true
            );
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

        String queueId = String.valueOf(caseGroup.Id).substring(0, 15);
        String fallbackQueueId = String.valueOf(caseGroup.Id).substring(0, 15);
        String templateId = String.valueOf(e1.Id).substring(0, 15);

        TestDataFactory.createFunctionalGroupWithCategory('Test Group', 'Test Category', 'Test Subcategory');
        TestDataFactory.createFunctionalGroupWithCategory(
            'Test RMM Group 1',
            'Test RMM Category 1',
            'Test RMM Subcategory 1'
        );
        TestDataFactory.createFunctionalGroupWithCategory(
            'Test RMM Group 2',
            'Test RMM Category 2',
            'Test RMM Subcategory 2'
        );
        TestDataFactory.createFunctionalGroupWithCategory('Test Group 2', 'Test Category 2', 'Test Subcategory 2');

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c();
        car.Email_Address__c = 'service12345123451234512345@test.test';
        car.Customer_notice_email_from_name__c = 'Test Service';
        car.Email_template_id__c = templateId;
        car.Queue_id__c = queueId;
        car.Fallback_Queue_Id__c = fallbackQueueId;
        car.Origin__c = 'Test Origin';
        car.CC_Functional_Group__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Test Group'
            LIMIT 1
        ]
        .Id;
        car.CC_Category__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Category' AND Active__c = TRUE AND Name = 'Test Category'
            LIMIT 1
        ]
        .Id;
        car.CC_Sub_Category__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Sub Category' AND Active__c = TRUE AND Name = 'Test Subcategory'
            LIMIT 1
        ]
        .Id;
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
        rmmCar1.CC_Functional_Group__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Test RMM Group 1'
            LIMIT 1
        ]
        .Id;
        rmmCar1.CC_Category__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Category' AND Active__c = TRUE AND Name = 'Test RMM Category 1'
            LIMIT 1
        ]
        .Id;
        rmmCar1.CC_Sub_Category__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Sub Category' AND Active__c = TRUE AND Name = 'Test RMM Subcategory 1'
            LIMIT 1
        ]
        .Id;
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
        rmmCar2.CC_Functional_Group__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Test RMM Group 2'
            LIMIT 1
        ]
        .Id;
        rmmCar2.CC_Category__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Category' AND Active__c = TRUE AND Name = 'Test RMM Category 2'
            LIMIT 1
        ]
        .Id;
        rmmCar2.CC_Sub_Category__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Sub Category' AND Active__c = TRUE AND Name = 'Test RMM Subcategory 2'
            LIMIT 1
        ]
        .Id;
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
        carDefault.CC_Functional_Group__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Test Group 2'
            LIMIT 1
        ]
        .Id;
        carDefault.CC_Category__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Category' AND Active__c = TRUE AND Name = 'Test Category 2'
            LIMIT 1
        ]
        .Id;
        carDefault.CC_Sub_Category__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Sub Category' AND Active__c = TRUE AND Name = 'Test Subcategory 2'
            LIMIT 1
        ]
        .Id;
        carDefault.Functional_Group__c = 'Test Group 2';
        carDefault.Category__c = 'Test Category 2';
        carDefault.Sub_Category__c = 'Test Subcategory 2';
        carDefault.Priority__c = 999;

        insert carDefault;

        Email_To_Case_Filter__c etcf1 = new Email_To_Case_Filter__c(Name = 'Test Filter');
        Email_To_Case_Filter__c etcf2 = new Email_To_Case_Filter__c(Name = 'blockme@test.test');
        insert etcf1;
        insert etcf2;

        EmailTemplate e2;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            String htmlBody = 'Body in HTML: {!Contact.Preferred_First_Name__c}, {!Contact.LastName}, {!Case.Thread_Id}, {!failedAttachmentsList}';
            String textBody = 'Body in text: {!Contact.Preferred_First_Name__c}, {!Contact.LastName}, {!Case.Thread_Id}, {!failedAttachmentsList}';
            e2 = new EmailTemplate(
                developerName = 'test2',
                TemplateType = 'Text',
                Name = 'test2',
                Subject = 'Rejected Attachment Case-{}',
                HtmlValue = htmlBody,
                Body = textBody,
                FolderId = f.Id,
                IsActive = true
            );
            insert e2;
        }

        Email_To_Case_Configuration__c etcc1 = new Email_To_Case_Configuration__c(
            Name = 'Rejected Attachment Email Template ID',
            Value__c = e2.Id
        );
        Email_To_Case_Configuration__c etcc2 = new Email_To_Case_Configuration__c(
            Name = 'Reopen Closed Case Threshold',
            Value__c = '14'
        );
        Email_To_Case_Configuration__c etcc3 = new Email_To_Case_Configuration__c(
            Name = 'Valid Attachment Types',
            Value__c = 'doc,pdf,png,docx,jpeg,jpg,gif,xls,xlsx,txt'
        );
        Email_To_Case_Configuration__c etcc4 = new Email_To_Case_Configuration__c(
            Name = 'Default Org Wide Email Address',
            Value__c = 'default@test.test'
        );

        insert etcc1;
        insert etcc2;
        insert etcc3;
        insert etcc4;

        Email_Logging__c logging = new Email_Logging__c(
            Name = 'Current_Settings',
            Spam_Logging__c = true,
            Attachment_Logging__c = true
        );
        insert logging;
    }

    @isTest
    static void newContact() {
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

        email.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{ inAtt };

        Messaging.InboundEmail.TextAttachment tattachment = new Messaging.InboundEmail.TextAttachment();
        String csv = 'this is just a test';
        tattachment.body = csv;
        tattachment.fileName = 'data.txt';
        tattachment.mimeTypeSubType = 'text/plain';

        email.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{ tattachment };

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);

        Contact createdContact = [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 1];

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

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void newContactLongName() {
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

        email.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{ inAtt };

        Messaging.InboundEmail.TextAttachment tattachment = new Messaging.InboundEmail.TextAttachment();
        String csv = 'this is just a test';
        tattachment.body = csv;
        tattachment.fileName = 'data.txt';
        tattachment.mimeTypeSubType = 'text/plain';

        email.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{ tattachment };

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);

        Contact createdContact = [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 1];

        System.assert(createdContact != null);
        System.assertEquals('0123456789012345678901234567890123456789', createdContact.FirstName);
        System.assertEquals(
            '01234567890123456789012345678901234567890123456789012345678901234567890123456789',
            createdContact.LastName
        );
        System.assertEquals('user@acme.com.test', createdContact.Email);

        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :createdContact.Id
            LIMIT 1
        ];

        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void existingContact() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
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
        emailServiceObj.handleInboundEmail(email, env);

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, CC_Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Test Group'
        ];
        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        System.assertEquals(fg.Id, createdCase.CC_Functional_Group__c);
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void existingContactCcOnly() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
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
        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Test Group'
        ];

        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        System.assertEquals(fg.Id, createdCase.CC_Functional_Group__c);

        Test.stopTest();

        lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void multipleExistingContacts() {
        Test.startTest();
        Contact c1 = new Contact(FirstName = 'First', LastName = 'Last', Email = 'user@acme.com.test');
        Contact c2 = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@work.com.test',
            ASU_Gmail__c = 'user@acme.com.test'
        );
        insert new List<Contact>{ c1, c2 };

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
        emailServiceObj.handleInboundEmail(email, env);

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId IN (:c1.Id, :c2.Id)
            LIMIT 1
        ];

        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        System.assert(
            createdCase.Description.contains('Note: there is more than one Contact with this email address.')
        );
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void multipleExistingContactsOnlyOneExactMatch() {
        Test.startTest();
        Contact c1 = new Contact(FirstName = 'First', LastName = 'Last', Email = 'user@acme.com.test');
        Contact c2 = new Contact(
            FirstName = 'First',
            LastName = 'Last2',
            Email = 'user@work.com.test',
            ASU_Gmail__c = 'user@acme.com.test'
        );
        insert new List<Contact>{ c1, c2 };

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
        emailServiceObj.handleInboundEmail(email, env);

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c1.Id
            LIMIT 1
        ];

        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        System.assert(
            createdCase.Description.contains('Note: there is more than one Contact with this email address.')
        );
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void existingContactDefaultRule() {
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
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
        emailServiceObj.handleInboundEmail(email, env);
        email.subject = 'Test 2';
        Test.startTest();
        emailServiceObj.handleInboundEmail(email, env);
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void createLostEmail() {
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
            SELECT
                Sender__c,
                Subject__c,
                PlainTextBody__c,
                HtmlTextBody__c,
                Recipient__c,
                RejectedAttachments__c,
                Cause__c
            FROM LostEmail__c
            LIMIT 1
        ];

        System.assertEquals(
            expectedLostEmail.Sender__c,
            actualLostEmail.Sender__c,
            'Unexpected differences in the LostEmails'
        );
        System.assertEquals(
            expectedLostEmail.Subject__c,
            actualLostEmail.Subject__c,
            'Unexpected differences in the LostEmails'
        );
        System.assertEquals(
            expectedLostEmail.Recipient__c,
            actualLostEmail.Recipient__c,
            'Unexpected differences in the LostEmails'
        );
        System.assertEquals(
            expectedLostEmail.RejectedAttachments__c,
            actualLostEmail.RejectedAttachments__c,
            'Unexpected differences in the LostEmails'
        );
        System.assertEquals(
            expectedLostEmail.Cause__c,
            actualLostEmail.Cause__c,
            'Unexpected differences in the LostEmails'
        );
    }

    @isTest
    static void createLostEmailWithAttachment() {
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

        email.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{ inAtt };

        Messaging.InboundEmail.TextAttachment tattachment = new Messaging.InboundEmail.TextAttachment();
        String csv = 'this is just a test';
        tattachment.body = csv;
        tattachment.fileName = 'data.txt';
        tattachment.mimeTypeSubType = 'text/plain';

        email.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{ tattachment };

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
            SELECT
                Sender__c,
                Subject__c,
                PlainTextBody__c,
                HtmlTextBody__c,
                Recipient__c,
                RejectedAttachments__c,
                Cause__c
            FROM LostEmail__c
            LIMIT 1
        ];

        System.assertEquals(
            expectedLostEmail.Sender__c,
            actualLostEmail.Sender__c,
            'Unexpected differences in the LostEmails'
        );
        System.assertEquals(
            expectedLostEmail.Subject__c,
            actualLostEmail.Subject__c,
            'Unexpected differences in the LostEmails'
        );
        System.assertEquals(
            expectedLostEmail.Recipient__c,
            actualLostEmail.Recipient__c,
            'Unexpected differences in the LostEmails'
        );
        System.assertEquals(
            expectedLostEmail.RejectedAttachments__c,
            actualLostEmail.RejectedAttachments__c,
            'Unexpected differences in the LostEmails'
        );
        System.assertEquals(
            expectedLostEmail.Cause__c,
            actualLostEmail.Cause__c,
            'Unexpected differences in the LostEmails'
        );

        List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :actualLostEmail.Id];

        //
        System.assert(attachments.size() == 2, 'Unexpected number of Attachments for this LostEmail');
    }

    @isTest
    static void reopenACaseFromEmail() {
        Contact c = new Contact(FirstName = 'First', LastName = 'Last', Email = 'user@acme.com.test');
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
        email.plainTextBody =
            'Test Body' +
            '\n\n' +
            GenerateReferenceIdOnEmailBody.addReferenceIdToEmailBody(createdCase.Id);
        email.fromAddress = 'user@acme.com.test';

        Test.startTest();
        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);
        Test.stopTest();

        // Verify that the case status was updated
        createdCase = [SELECT Status, CC_Functional_Group__c FROM Case WHERE Id = :createdCase.Id];

        System.assertEquals(
            CFG,
            createdCase.CC_Functional_Group__c,
            'External Unit case was not re-opened to most recent functional group'
        );
        System.assertEquals('Re-Opened', createdCase.Status, 'Case was not reopened correctly');

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void createACaseWithEmptySubject() {
        Contact c = new Contact(FirstName = 'First', LastName = 'Last', Email = 'user@acme.com.test');
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
        Case createdCase = [SELECT Status, Functional_Group__c FROM Case WHERE ContactId = :c.Id LIMIT 1];

        System.assertEquals('New', createdCase.Status);

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testRMMPartialMatchExact() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
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
        emailServiceObj.handleInboundEmail(email, env);

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, CC_Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];
        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Test RMM Group 1'
        ];
        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        System.assertEquals(fg.Id, createdCase.CC_Functional_Group__c);
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testRMMPartialMatchPartial() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
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
        emailServiceObj.handleInboundEmail(email, env);

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, CC_Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];
        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Test RMM Group 2'
        ];

        System.assertEquals('test', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        System.assertEquals(fg.Id, createdCase.CC_Functional_Group__c);

        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testBothBodiesPopulated() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
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
        emailServiceObj.handleInboundEmail(email, env);

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        System.assert(createdCase.Description == 'This is a plaintext body');

        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testHTMLBodyPopulated() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
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
        emailServiceObj.handleInboundEmail(email, env);

        // Verify that the case status was updated
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        System.assert(
            createdCase.Description ==
            'Note: This description was reformatted from the original email body. Please view the case feed to see the original email body.\n\nThis is a HTML body'
        );

        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testNoBodiesPopulatedNoAttachment() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
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
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        System.assert(createdCase.Description != null);
        System.assert(createdCase.Description.contains('without email body or attachment'));
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testNoBodiesPopulatedBinaryAttachment() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        // set the body of the attachment
        inAtt.body = blob.valueOf('test');
        inAtt.fileName = 'attach.pdf';
        inAtt.mimeTypeSubType = 'plain/txt';
        email.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{ inAtt };

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
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        System.assert(createdCase.Description != null);
        System.assert(createdCase.Description.contains('Attachment received at'));
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testNoBodiesPopulatedTextAttachment() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
        insert c;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        Messaging.InboundEmail.TextAttachment tattachment = new Messaging.InboundEmail.TextAttachment();
        String csv = 'this is just a test';
        tattachment.body = csv;
        tattachment.fileName = 'data.txt';
        tattachment.mimeTypeSubType = 'text/plain';

        email.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{ tattachment };

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
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c.Id
            LIMIT 1
        ];

        System.assert(createdCase.Description != null);
        System.assert(createdCase.Description.contains('Attachment received at'));
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testOriginalEmailPresent() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
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

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testOriginalEmailNotPresent1() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
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

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testOriginalEmailNotPresent2() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
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

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @IsTest
    private static void transformedEmailDontUpdateContact() {
        AccountFactory.DefaultAccount accountFactory = new AccountFactory.DefaultAccount();
        Account[] testAccount = accountFactory.create();
        insert testAccount;
        ContactFactory.AllEmailsFilled contactFactory = new ContactFactory.AllEmailsFilled(testAccount[0].Id);
        Contact[] testContact = contactFactory.create();
        insert testContact;
        update testContact[0];

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        List<string> toAddresses = new List<string>();
        toAddresses.add('asusf@asu.edu');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'test.test.com@reply.asu.edu';
        email.fromName = 'Last, First';
        email.plainTextBody = null;
        email.htmlBody = null;
        env.fromAddress = email.fromAddress;

        Test.startTest();
        CaseInboundEmailHandler handler = new CaseInboundEmailHandler();
        handler.handleInboundEmail(email, env);
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');

        Contact contactAfterTest = [SELECT Email, Last_Case_Email_Used__c FROM Contact WHERE Id = :testContact[0].Id];

        System.assertNotEquals(email.toAddresses[0], contactAfterTest.Email);
        System.assertNotEquals(email.toAddresses[0], contactAfterTest.Last_Case_Email_Used__c);
        System.assertEquals(testContact[0].Email, contactAfterTest.Email);
        // System.assertNotEquals(testContact[0].Last_Case_Email_Used__c, contactAfterTest.Last_Case_Email_Used__c);
        System.assertNotEquals(email.fromAddress, contactAfterTest.Last_Case_Email_Used__c);
        System.assertEquals(testContact[0].Email, contactAfterTest.Last_Case_Email_Used__c);
    }

    @IsTest
    private static void transfrormedEmailOnNewContact() {
        AccountFactory.DefaultAccount accountFactory = new AccountFactory.DefaultAccount();
        Account[] testAccount = accountFactory.create();
        insert testAccount;
        ContactFactory.AllEmailsFilled contactFactory = new ContactFactory.AllEmailsFilled(testAccount[0].Id);
        Contact[] testContact = contactFactory.create();

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        List<string> toAddresses = new List<string>();
        toAddresses.add('asusf@asu.edu');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'test.test.com@reply.asu.edu';
        email.fromName = 'Last, First';
        email.plainTextBody = null;
        email.htmlBody = null;
        env.fromAddress = email.fromAddress;

        Test.startTest();
        CaseInboundEmailHandler handler = new CaseInboundEmailHandler();
        handler.handleInboundEmail(email, env);
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');

        Contact contactAfterTest = [SELECT Email, Last_Case_Email_Used__c FROM Contact];

        System.assertNotEquals(email.toAddresses[0], contactAfterTest.Email);
        System.assertEquals(testContact[0].Email, contactAfterTest.Email);
        System.assertEquals(null, contactAfterTest.Last_Case_Email_Used__c);
    }

    @isTest
    private static void filterOnBody() {
        CaseInboundEmailHandler emailHandler = new CaseInboundEmailHandler();

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        List<Email_To_Case_Filter__c> filtersToAdd = new List<Email_To_Case_Filter__c>();
        filtersToAdd.add(new Email_To_Case_Filter__c(Name = 'banana', Filter_Email_Body__c = true));
        insert filtersToAdd;

        List<string> toAddresses = new List<string>();
        toAddresses.add('asusf@asu.edu');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'test.test.com@reply.asu.edu';
        email.fromName = 'Last, First';
        email.plainTextBody = 'The Safe Word is Banana';
        email.htmlBody = 'The Safe Word is Banana';
        env.fromAddress = email.fromAddress;

        Test.startTest();
        CaseInboundEmailHandler handler = new CaseInboundEmailHandler();
        handler.handleInboundEmail(email, env);
        Test.stopTest();

        List<LostEmail__c> rejectedMessages = [SELECT Id FROM LostEmail__c];

        System.assertEquals(1, rejectedMessages.size());
    }

    @isTest
    private static void filterInBodyButNotActive() {
        CaseInboundEmailHandler emailHandler = new CaseInboundEmailHandler();

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        List<Email_To_Case_Filter__c> filtersToAdd = new List<Email_To_Case_Filter__c>();
        filtersToAdd.add(new Email_To_Case_Filter__c(Name = 'banana', Filter_Email_Body__c = false));
        insert filtersToAdd;

        List<string> toAddresses = new List<string>();
        toAddresses.add('asusf@asu.edu');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = 'test.test.com@reply.asu.edu';
        email.fromName = 'Last, First';
        email.plainTextBody = 'The Safe Word is Banana';
        email.htmlBody = 'The Safe Word is Banana';
        env.fromAddress = email.fromAddress;

        Test.startTest();
        CaseInboundEmailHandler handler = new CaseInboundEmailHandler();
        handler.handleInboundEmail(email, env);
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    private static void emailWithAttachmentAndNewContactNoError() {
        ContactFactory factory = new ContactFactory(ContactFactory.DEFAULT_CONTACT);
        Contact sender = factory.createOne();

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        // set the body of the attachment
        inAtt.body = Blob.valueOf('test');
        inAtt.fileName = 'attach.txt';
        inAtt.mimeTypeSubType = 'plain/txt';
        email.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{ inAtt };

        List<String> toAddresses = new List<String>();
        toAddresses.add('service12345123451234512345@test.test');
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = sender.Email;
        email.fromName = sender.LastName + ', ' + sender.FirstName;
        email.plainTextBody = 'Test Body';
        email.htmlBody = 'Test Body';
        env.fromAddress = sender.Personal_Email__c;

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        Test.startTest();
        emailServiceObj.handleInboundEmail(email, env);
        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');

        Case createdCase = [SELECT Id FROM Case LIMIT 1];

        Attachment attachment = [SELECT Name, Body, ParentId FROM Attachment LIMIT 1];
        System.assertEquals(inAtt.fileName, attachment.Name);
        System.assertEquals(inAtt.body.toString(), attachment.Body.toString());
        System.assertEquals(createdCase.Id, attachment.ParentId);
    }

    @isTest
    private static void emailWithBadAttachmentAndNewContactCausesError() {
        ContactFactory factory = new ContactFactory(ContactFactory.DEFAULT_CONTACT);
        Contact sender = factory.createOne();

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        // set the body of the attachment
        inAtt.body = Blob.valueOf('test');
        inAtt.fileName = 'attach.txt' + 'BAD';
        inAtt.mimeTypeSubType = 'plain/txt';
        email.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{ inAtt };

        String sendTo = 'service12345123451234512345@test.test';
        List<String> toAddresses = new List<String>();
        toAddresses.add(sendTo);
        email.toAddresses = toAddresses;
        email.subject = 'test';
        email.fromAddress = sender.Email;
        email.fromName = sender.LastName + ', ' + sender.FirstName;
        email.plainTextBody = 'Test Body';
        email.htmlBody = 'Test Body';
        env.fromAddress = sender.Personal_Email__c;

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        Test.startTest();
        emailServiceObj.handleInboundEmail(email, env);
        Test.stopTest();

        List<LostEmail__c> lostEmails = [
            SELECT
                Sender__c,
                Subject__c,
                PlainTextBody__c,
                HtmlTextBody__c,
                Cause__c,
                Recipient__c,
                CarbonCopies__c,
                RejectedAttachments__c
            FROM LostEmail__c
        ];
        System.assert(!lostEmails.isEmpty(), 'No lost email generated.');

        LostEmail__c lostEmail = lostEmails[0];
        System.assertEquals(email.fromAddress, lostEmail.Sender__c);
        System.assertEquals(email.subject, lostEmail.Subject__c);
        System.assert(lostEmail.PlainTextBody__c.contains(email.plainTextBody));
        System.assertEquals(email.htmlBody, lostEmail.HtmlTextBody__c);
        System.assertEquals('Attachment is invalid', lostEmail.Cause__c);
        System.assertEquals(sendTo, lostEmail.Recipient__c);
        System.assertEquals(null, lostEmail.CarbonCopies__c);
        System.assertEquals(true, lostEmail.RejectedAttachments__c);
    }

    @isTest
    static void testEmptyBodyFromOutlook() {
        Test.startTest();
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'user@acme.com.test',
            Personal_Email__c = 'user2@acme.com.test'
        );
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
        // 'Empty' in Outlook still leaves some head information
        email.htmlBody = '<html>\n<head>\n<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=\n1">\n<style type=3D"text/css" style=3D"display:none;"> P {margin-top:0;margin-bo=\nttom:0;} </style>\n</head>\n<body dir=3D"ltr">\n<div style=3D"font-family: Calibri, Arial, Helvetica, sans-serif; font-size=\n: 12pt; color: rgb(0, 0, 0);">\n<br>\n</div>\n</body>\n</html>\n';
        env.fromAddress = 'user@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);

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

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testFirstNameLastNameFromNameMatches1() {
        Test.startTest();
        Contact c1 = new Contact(FirstName = 'John', LastName = 'Smith', Email = 'john.smith@acme.com.test');
        Contact c2 = new Contact(FirstName = '', LastName = 'Smith', Email = 'john.smith@acme.com.test');
        Contact c3 = new Contact(FirstName = '', LastName = 'Smithers', Email = 'john.smith@acme.com.test');
        insert new List<Contact>{ c1, c2, c3 };

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.toAddresses = toAddresses;
        email.subject = 'Should associate with c1';
        email.fromAddress = 'john.smith@acme.com.test';
        email.fromName = 'Smith, John';
        env.fromAddress = 'john.smith@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);

        // Associated with contact 1
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c1.Id
            LIMIT 1
        ];
        System.assertEquals('Should associate with c1', createdCase.Subject);

        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testFirstNameLastNameFromNameMatches2() {
        Test.startTest();
        Contact c1 = new Contact(FirstName = 'John', LastName = 'Smith', Email = 'john.smith@acme.com.test');
        Contact c2 = new Contact(FirstName = '', LastName = 'Smith', Email = 'john.smith@acme.com.test');
        Contact c3 = new Contact(FirstName = '', LastName = 'Smithers', Email = 'john.smith@acme.com.test');
        insert new List<Contact>{ c1, c2, c3 };

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.toAddresses = toAddresses;
        email.subject = 'Should associate with c2';
        email.fromAddress = 'john.smith@acme.com.test';
        email.fromName = 'Smith';
        env.fromAddress = 'john.smith@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);

        // Associated with contact 2
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c2.Id
            LIMIT 1
        ];
        System.assertEquals('Should associate with c2', createdCase.Subject);

        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }

    @isTest
    static void testFirstNameLastNameFromNameMatches3() {
        Test.startTest();
        Contact c1 = new Contact(FirstName = 'John', LastName = 'Smith', Email = 'john.smith@acme.com.test');
        Contact c2 = new Contact(FirstName = '', LastName = 'Smith', Email = 'john.smith@acme.com.test');
        Contact c3 = new Contact(FirstName = '', LastName = 'Smithers', Email = 'john.smith@acme.com.test');
        insert new List<Contact>{ c1, c2, c3 };

        List<string> toAddresses = new List<string>();
        toAddresses.add('service12345123451234512345@test.test');

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.toAddresses = toAddresses;
        email.subject = 'Should associate with c3';
        email.fromAddress = 'john.smith@acme.com.test';
        email.fromName = 'Smithers';
        env.fromAddress = 'john.smith@acme.com.test';

        // call the class and test it with the data in the testMethod
        CaseInboundEmailHandler emailServiceObj = new CaseInboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env);

        // Associated with contact 3
        Case createdCase = [
            SELECT Id, Subject, Description, Status, Functional_Group__c
            FROM Case
            WHERE ContactId = :c3.Id
            LIMIT 1
        ];
        System.assertEquals('Should associate with c3', createdCase.Subject);

        Test.stopTest();

        List<LostEmail__c> lostEmails = [SELECT Id FROM LostEmail__c];
        System.assert(lostEmails.isEmpty(), 'Incorrectly generated lost email.');
    }
}