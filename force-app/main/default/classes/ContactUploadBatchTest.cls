@isTest
private class ContactUploadBatchTest {
    
    private static Id createTestContentVersion(String csvContent) {
        ContentVersion cv = new ContentVersion(
            Title = 'Test CSV',
            PathOnClient = 'TestCSV.csv',
            VersionData = Blob.valueOf(csvContent),
            IsMajorVersion = true
        );
        insert cv;
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        Contact_Upload__c contactUpload = new Contact_Upload__c();
        contactUpload.Description__c = 'test';
        insert contactUpload;
        
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = contactUpload.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert link;
        return cv.Id;
    }
    
    @isTest
    static void testBatchStartExecuteFinish() {
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', EMPLID__c = 'EMP123');
        insert testContact;
        
        Contact_Upload__c contactUpload = new Contact_Upload__c();
        contactUpload.Description__c = 'test';
        insert contactUpload;
        
        Contact_Upload_Detail__c detail = new Contact_Upload_Detail__c(
            Contact_Upload__c = contactUpload.Id
        );
        insert detail;
        
        Subscription__c subscription = new Subscription__c(
            Name = 'Test Subscription',
            Subscriber_Private_in_Salesforce__c = false
        );
        insert subscription;
        
        String csvContent = 'First_Name__c,Last_Name__c,Email__c,EMPLID__c\rAlice,Test,alice@example.com,EMP123';
        Id contentVersionId = createTestContentVersion(csvContent);
        
        Test.startTest();
        ContactUploadBatch batch = new ContactUploadBatch(contentVersionId, subscription.Id, 'Subscribed');
        ID batchId = Database.executeBatch(batch, 2);
        Test.stopTest();
        
        List<Contact_Upload_Detail__c> details = [SELECT Id, Status__c, Subscriber__c FROM Contact_Upload_Detail__c];
    }
    
    @isTest
    static void testNoErroredRecords_True() {
        Contact_Upload__c contactUpload = new Contact_Upload__c();
        contactUpload.Description__c = 'test';
        insert contactUpload;
        
        Contact_Upload_Detail__c detail = new Contact_Upload_Detail__c(
            Contact_Upload__c = contactUpload.Id,
            Status__c = 'Success'
        );
        insert detail;
        
        Test.startTest();
        ContactUploadBatch batch = new ContactUploadBatch(null, null, null);
        
        System.assertEquals(true, batch.noErroredRecords(), 'Should return true when no errored records exist');
        Test.stopTest();
    }
}