@isTest
public with sharing class ContactUploadAddFileExtensionTest {
    
    private static Contact_Upload__c conUploadRecord;
    private static Profile sysAdminProfile;
    private static User adminUser;
    
    static void setTestData(){
        
        sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        adminUser = TestDataFactory.createUser('Sidhant', sysAdminProfile.Id);
        
        conUploadRecord = new Contact_Upload__c();
        conUploadRecord.Description__c = 'Test record';
        conUploadRecord.Status__c = 'New';
        insert conUploadRecord;
        
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
            string header = 'Contact,ID,ASURITE,First Name,Last Name,Email Address,Campaign ID,Subscription ID,Date of Birth,Street Address,City,State Code,Postal Code,Country Code,Phone\n';
            testAccPlan.newAttachment.Body = blob.valueOf(header);
            testAccPlan.upload();
            
            Attachment secondAttachment = [SELECT Id, IsPrivate, ParentId FROM Attachment WHERE Name = 'Second Attachment.csv'];
            system.assertEquals(true, secondAttachment.IsPrivate);
            system.assertEquals(conUploadRecord.Id, secondAttachment.ParentId);
        }
        
    	Test.stopTest();
    }
}