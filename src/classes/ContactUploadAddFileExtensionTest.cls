@isTest
private with sharing class ContactUploadAddFileExtensionTest {
    
    private static Contact contASURecord;
    private static Contact contWPCRecord;
    private static Contact_Upload__c conUploadRecord;
    private static Profile sysAdminProfile;
    private static User adminUser;
    private static List<Subscription__c> subscriptions;
    
    static void setTestData(){
        
        sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        adminUser = TestDataFactory.createUser('Sidhant', sysAdminProfile.Id);
        
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
    
    @isTest private static void checkQueryAttachment() {
        setTestData();
        Test.startTest();
        PageReference pageRef = Page.ContactUploadAddFilePage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);
    	ContactUploadAddFileExtension testAccPlan = new ContactUploadAddFileExtension(sc);
		system.assertEquals(1, testAccPlan.attachmentList.size());
    	Test.stopTest();
    }
    
    @isTest private static void checkUploadAttachment() {
        Test.startTest();
        setTestData();
        System.runAs(adminUser) {
            PageReference pageRef = Page.ContactUploadAddFilePage;
            Test.setCurrentPage(pageRef);
            
            pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);
            ContactUploadAddFileExtension testAccPlan = new ContactUploadAddFileExtension(sc);
            system.assertEquals(1, testAccPlan.attachmentList.size());
            
            testAccPlan.newAttachment.Name = 'Second Attachment.csv';
            string header = 'Contact ID,ASURITE,First Name,Last Name,Email Address,Campaign ID,Subscription ID,Date of Birth,Street Address,City,State Code,Postal Code,Country Code,Phone\n\r';
			header += contASURecord.Id+',,FirstName,LastName,TestBulk2@asu.edu.sid,,'+subscriptions.get(0).Id+' ,2017-04-27,1232 E Lemon St,Tempe,AZ,85281,US ,111-555-6567\n\r';
            testAccPlan.newAttachment.Body = blob.valueOf(header);
            testAccPlan.upload();
            
            Attachment secondAttachment = [SELECT Id, IsPrivate, ParentId FROM Attachment WHERE Name = 'Second Attachment.csv'];
            system.assertEquals(true, secondAttachment.IsPrivate);
            system.assertEquals(conUploadRecord.Id, secondAttachment.ParentId);
            
        }
        
    	Test.stopTest();
        // assert #1
        List<Contact_Upload_Detail__c> lstCUD = [SELECT ID FROM Contact_Upload_Detail__c];
        system.assertEquals(1, lstCUD.size());
    }
    
    @isTest private static void checkCalloutNoContact() {   
        
        Test.startTest();
        setTestData();
        Test.stopTest();
        delete contASURecord;
        System.runAs(adminUser) {
            PageReference pageRef = Page.ContactUploadAddFilePage;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);
            ContactUploadAddFileExtension testAccPlan = new ContactUploadAddFileExtension(sc);
            system.assertEquals(1, testAccPlan.attachmentList.size());
            
            testAccPlan.newAttachment.Name = 'Second Attachment.csv';
            string header = 'Contact ID,ASURITE,First Name,Last Name,Email Address,Campaign ID,Subscription ID,Date of Birth,Street Address,City,State Code,Postal Code,Country Code,Phone\n\r';
			header += ',,FirstName,LastName,TestBulk2@asu.edu.sid,,'+subscriptions.get(0).Id+' ,2017-04-27,1232 E Lemon St,Tempe,AZ,85281,US ,111-555-6567\n\r';
            testAccPlan.newAttachment.Body = blob.valueOf(header);            
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGen_EnterpriseContact());
            testAccPlan.upload();
            // assert #1
            Attachment secondAttachment = [SELECT Id, IsPrivate, ParentId FROM Attachment WHERE Name = 'Second Attachment.csv'];
            system.assertEquals(true, secondAttachment.IsPrivate);
            system.assertEquals(conUploadRecord.Id, secondAttachment.ParentId);
        }
        
    }
    
    @isTest private static void checkCalloutWithContact() {   
        setTestData();
        System.runAs(adminUser) {
            PageReference pageRef = Page.ContactUploadAddFilePage;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);
            ContactUploadAddFileExtension testAccPlan = new ContactUploadAddFileExtension(sc);
            system.assertEquals(1, testAccPlan.attachmentList.size());
            
            testAccPlan.newAttachment.Name = 'Second Attachment.csv';
            string header = 'Contact ID,ASURITE,First Name,Last Name,Email Address,Campaign ID,Subscription ID,Date of Birth,Street Address,City,State Code,Postal Code,Country Code,Phone\n\r';
			header += ',,FirstName,LastName,TestBulk2@asu.edu.sid,,'+subscriptions.get(0).Id+' ,2017-04-27,1232 E Lemon St,Tempe,AZ,85281,US ,111-555-6567\n\r';
            testAccPlan.newAttachment.Body = blob.valueOf(header);            
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGen_EnterpriseContact());
                testAccPlan.upload();
            Test.stopTest();
            // assert #1
            Attachment secondAttachment = [SELECT Id, IsPrivate, ParentId FROM Attachment WHERE Name = 'Second Attachment.csv'];
            system.assertEquals(true, secondAttachment.IsPrivate);
            system.assertEquals(conUploadRecord.Id, secondAttachment.ParentId);
            // assert #2
            List<Contact_Upload_Detail__c> cudList = new List<Contact_Upload_Detail__c>([SELECT Id, Processing_Notes__c, Contact__c FROM Contact_Upload_Detail__c]);
            for (Contact_Upload_Detail__c cud : cudList) {
                system.assert(cud.Processing_Notes__c.contains('Found existing Contact ID: '+contASURecord.Id));
            }
        }
    }
    
    @isTest private static void checkNoSubscriptionCampaign() {
        Test.startTest();
        setTestData();
        System.runAs(adminUser) {
            PageReference pageRef = Page.ContactUploadAddFilePage;
            Test.setCurrentPage(pageRef);
            
            pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);
            ContactUploadAddFileExtension testAccPlan = new ContactUploadAddFileExtension(sc);
            system.assertEquals(1, testAccPlan.attachmentList.size());
            
            testAccPlan.newAttachment.Name = 'Second Attachment.csv';
            string header = 'Contact ID,ASURITE,First Name,Last Name,Email Address,Campaign ID,Subscription ID,Date of Birth,Street Address,City,State Code,Postal Code,Country Code,Phone\n\r';
			header += contASURecord.Id+',,FirstName,LastName,TestBulk2@asu.edu.sid,,,2017-04-27,1232 E Lemon St,Tempe,AZ,85281,US ,111-555-6567\n\r';
            testAccPlan.newAttachment.Body = blob.valueOf(header);
            testAccPlan.upload();
            
            Attachment secondAttachment = [SELECT Id, IsPrivate, ParentId FROM Attachment WHERE Name = 'Second Attachment.csv'];
            system.assertEquals(true, secondAttachment.IsPrivate);
            system.assertEquals(conUploadRecord.Id, secondAttachment.ParentId);
            
            List<Contact_Upload_Detail__c> cudList = new List<Contact_Upload_Detail__c>([SELECT Id, Processing_Notes__c, Contact__c FROM Contact_Upload_Detail__c]);
            for (Contact_Upload_Detail__c cud : cudList) {
                system.assert(cud.Processing_Notes__c.equals('Either Subscription or Campaign must be specified'));
            }
        }
        
    	Test.stopTest();
    }
    
    @isTest private static void checkCampaignRelatedCode() {
        Test.startTest();
        setTestData();
        System.runAs(adminUser) {
            PageReference pageRef = Page.ContactUploadAddFilePage;
            Test.setCurrentPage(pageRef);
            
            pageRef.getParameters().put('Id', String.valueOf(conUploadRecord.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(conUploadRecord);
            ContactUploadAddFileExtension testAccPlan = new ContactUploadAddFileExtension(sc);
            system.assertEquals(1, testAccPlan.attachmentList.size());
            
            testAccPlan.newAttachment.Name = 'Second Attachment.csv';
            string header = 'Contact ID,ASURITE,First Name,Last Name,Email Address,Campaign ID,Subscription ID,Date of Birth,Street Address,City,State Code,Postal Code,Country Code,Phone\n\r';
			header += contASURecord.Id+',,FirstName,LastName,TestBulk2@asu.edu.sid,7000000000000,,2017-04-27,1232 E Lemon St,Tempe,AZ,85281,US ,111-555-6567\n\r';
            testAccPlan.newAttachment.Body = blob.valueOf(header);
            testAccPlan.upload();
            
            Attachment secondAttachment = [SELECT Id, IsPrivate, ParentId FROM Attachment WHERE Name = 'Second Attachment.csv'];
            system.assertEquals(true, secondAttachment.IsPrivate);
            system.assertEquals(conUploadRecord.Id, secondAttachment.ParentId);
            
            List<Contact_Upload_Detail__c> cudList = new List<Contact_Upload_Detail__c>([SELECT Id, Processing_Notes__c, Contact__c FROM Contact_Upload_Detail__c]);
            for (Contact_Upload_Detail__c cud : cudList) {
                system.assertEquals(cud.Processing_Notes__c, 'Either Subscription or Campaign must be specified');
                system.assert(cud.Processing_Notes__c.equals('Either Subscription or Campaign must be specified'));
            }
        }
        
    	Test.stopTest();
    }
}