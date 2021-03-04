@isTest
private class ContactUploadAddFileExtensionTest {
    private static Contact contASURecord;
    private static Contact contWPCRecord;
    private static Contact_Upload__c conUploadRecord;
    private static Profile sysAdminProfile;
    private static User adminUser;
    private static List<Subscription__c> subscriptions;

    private static void setTestData() {
        sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        adminUser = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile.Id AND isActive = TRUE LIMIT 1];

        contASURecord = TestDataFactory.createContact('ASU');
        insert contASURecord;

        contWPCRecord = TestDataFactory.createContact('WPC');
        insert contWPCRecord;

        conUploadRecord = new Contact_Upload__c();
        conUploadRecord.Description__c = 'Test record';
        conUploadRecord.Status__c = 'New';
        insert conUploadRecord;

        subscriptions = TestDataFactory.createTestSubscriptions(1);
        insert subscriptions;

        Attachment attachRecord = TestDataFactory.createAttachment('Test Attachment', conUploadRecord.Id);
        insert attachRecord;
    }

    private static Blob returnCSVBlob(String contactId, String subscribtionId, String campaignId) {
        String header = 'Contact ID,ASURITE,First Name,Last Name,Email Address,Campaign ID,Subscription ID,Date of Birth,Street Address,City,State Code,Postal Code,Country Code,Phone\n\r';
        String body =
            contactId +
            ',,FirstName,LastName,TestBulk2@asu.edu.sid,' +
            campaignId +
            ',' +
            subscribtionId +
            ',2017-04-27,1232 E Lemon St,Tempe,,85281,,111-555-6567\n\r';
        return blob.valueOf(header + body);
    }

    @isTest
    private static void extensionConfirmOneAttachmentPresent() {
        setTestData();

        PageReference pageRef = Page.ContactUploadAddFilePage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);

        Test.startTest();
        ContactUploadAddFileExtension contactUploadExtension = new ContactUploadAddFileExtension(sc);
        Test.stopTest();

        System.assertEquals(1, contactUploadExtension.attachmentList.size());
    }

    @isTest
    private static void checkUploadAttachment() {
        setTestData();
        System.runAs(adminUser) {
            PageReference pageRef = Page.ContactUploadAddFilePage;
            Test.setCurrentPage(pageRef);

            pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);
            ContactUploadAddFileExtension contactUploadExtension = new ContactUploadAddFileExtension(sc);
            System.assertEquals(1, contactUploadExtension.attachmentList.size());

            contactUploadExtension.newAttachment.Name = 'Second Attachment.csv';
            contactUploadExtension.newAttachment.Body = returnCSVBlob(contASURecord.Id, subscriptions.get(0).Id, '');

            Test.startTest();
            contactUploadExtension.upload();
            Test.stopTest();

            Attachment secondAttachment = [
                SELECT Id, IsPrivate, ParentId
                FROM Attachment
                WHERE Name = 'Second Attachment.csv'
            ];
            System.assertEquals(true, secondAttachment.IsPrivate);
            System.assertEquals(conUploadRecord.Id, secondAttachment.ParentId);
            List<Contact_Upload_Detail__c> lstCUD = [SELECT Id FROM Contact_Upload_Detail__c];
            System.assertEquals(1, lstCUD.size());
        }
    }

    @isTest
    private static void associatedSubscriptionInUploadCheckAlreadyExistingContact() {
        Test.startTest();
        setTestData();
        Test.stopTest();

        delete contASURecord;

        System.runAs(adminUser) {
            PageReference pageRef = Page.ContactUploadAddFilePage;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);
            ContactUploadAddFileExtension contactUploadExtension = new ContactUploadAddFileExtension(sc);
            System.assertEquals(1, contactUploadExtension.attachmentList.size());

            contactUploadExtension.newAttachment.Name = 'Second Attachment.csv';
            contactUploadExtension.newAttachment.Body = returnCSVBlob('', subscriptions.get(0).Id, '');

            contactUploadExtension.upload();

            for (Contact_Upload_Detail__c cud : [
                SELECT Id, Processing_Notes__c, Contact__c
                FROM Contact_Upload_Detail__c
                WHERE Subscriber__c = :subscriptions.get(0).Id
            ]) {
                System.assert(cud.Processing_Notes__c.contains('Found existing Contact ID: ' + contASURecord.Id));
            }
        }
    }

    @isTest
    private static void associatedSubscriptionNewContactCreatedInUpload() {
        sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        adminUser = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile.Id AND isActive = TRUE LIMIT 1];
        System.runAs(adminUser) {
            setTestData();
            PageReference pageRef = Page.ContactUploadAddFilePage;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);
            ContactUploadAddFileExtension contactUploadExtension = new ContactUploadAddFileExtension(sc);
            contactUploadExtension.newAttachment.Name = 'Second Attachment.csv';
            contactUploadExtension.newAttachment.Body = returnCSVBlob('', subscriptions.get(0).Id, '');

            Test.startTest();
            contactUploadExtension.upload();
            Test.stopTest();

            for (Contact_Upload_Detail__c cud : [
                SELECT Id, Processing_Notes__c, Contact__c
                FROM Contact_Upload_Detail__c
                WHERE Subscriber__c = :subscriptions.get(0).Id
            ]) {
                System.assert(cud.Processing_Notes__c.contains('Created new Contact ID: ' + contWPCRecord.Id));
            }
        }
    }

    @isTest
    private static void noSubscriptionCampaignCheckErrorMessage() {
        setTestData();
        System.runAs(adminUser) {
            PageReference pageRef = Page.ContactUploadAddFilePage;
            Test.setCurrentPage(pageRef);

            pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);
            ContactUploadAddFileExtension contactUploadExtension = new ContactUploadAddFileExtension(sc);
            System.assertEquals(1, contactUploadExtension.attachmentList.size());

            contactUploadExtension.newAttachment.Name = 'Second Attachment.csv';
            String header = 'Contact ID,ASURITE,First Name,Last Name,Email Address,Campaign ID,Subscription ID,Date of Birth,Street Address,City,State Code,Postal Code,Country Code,Phone\n\r';
            String body =
                contASURecord.Id +
                ',,FirstName,LastName,TestBulk2@asu.edu.sid,,,2017-04-27,1232 E Lemon St,Tempe,,85281,,111-555-6567\n\r';
            contactUploadExtension.newAttachment.Body = returnCSVBlob(contASURecord.Id, '', '');

            Test.startTest();
            contactUploadExtension.upload();
            Test.stopTest();

            List<Contact_Upload_Detail__c> cudList = new List<Contact_Upload_Detail__c>(
                [SELECT Id, Processing_Notes__c, Contact__c FROM Contact_Upload_Detail__c]
            );
            for (Contact_Upload_Detail__c cud : cudList) {
                System.assert(cud.Processing_Notes__c.contains('Subscription Id is REQUIRED'));
            }
        }
    }

    @isTest
    private static void incorrectIdCheckErrorMessage() {
        setTestData();
        System.runAs(adminUser) {
            PageReference pageRef = Page.ContactUploadAddFilePage;
            Test.setCurrentPage(pageRef);

            pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);
            ContactUploadAddFileExtension contactUploadExtension = new ContactUploadAddFileExtension(sc);
            System.assertEquals(1, contactUploadExtension.attachmentList.size());

            contactUploadExtension.newAttachment.Name = 'Second Attachment.csv';
            contactUploadExtension.newAttachment.Body = returnCSVBlob(contASURecord.Id, '', '7000000000000');

            Test.startTest();
            contactUploadExtension.upload();
            Test.stopTest();

            List<Contact_Upload_Detail__c> cudList = new List<Contact_Upload_Detail__c>(
                [SELECT Id, Processing_Notes__c, Contact__c FROM Contact_Upload_Detail__c]
            );
            for (Contact_Upload_Detail__c cud : cudList) {
                System.assert(cud.Processing_Notes__c.contains('Subscription Id is REQUIRED'));
            }
        }
    }

    @isTest
    private static void allContactsOptionAvailable() {
        setTestData();
        List<SelectOption> subscriptionOptions = new List<SelectOption>();

        System.runAs(adminUser) {
            PageReference pageRef = Page.ContactUploadAddFilePage;
            Test.setCurrentPage(pageRef);

            pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);
            ContactUploadAddFileExtension contactUploadExtension = new ContactUploadAddFileExtension(sc);

            Test.startTest();
            contactUploadExtension.contactMatcherButton();
            Test.stopTest();

            subscriptionOptions = contactUploadExtension.subscriptionOptions;
        }

        System.assertEquals('--', subscriptionOptions.get(0).getValue());
        System.assertEquals(1, subscriptionOptions.size());
    }
}
