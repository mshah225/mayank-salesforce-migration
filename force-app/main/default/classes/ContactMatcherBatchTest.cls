@isTest
public class ContactMatcherBatchTest {
    @isTest
    static void testContactMatcherBatch() {
        Subscription__c sub = new Subscription__c(
            Name = 'Test',
            Subscriber_Private_in_Salesforce__c = false
        );
        insert sub;

        Contact_Upload__c upload = new Contact_Upload__c();
        upload.Description__c = 'Test Description';
        
        insert upload;

        String csvData = 'First_Name__c,Last_Name__c,Email__c,EMPLID__c\nJohn,Doe,john.doe@example.com,12345';

        ContentVersion version = new ContentVersion(
            Title = 'ContactUploadCSV',
            PathOnClient = 'ContactUpload.csv',
            VersionData = Blob.valueOf(csvData),
            IsMajorVersion = true
        );
        insert version;

        ContentVersion insertedVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :version.Id];

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = insertedVersion.ContentDocumentId,
            LinkedEntityId = upload.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        Test.startTest();
        ContactMatcherBatch batch = new ContactMatcherBatch(insertedVersion.Id, sub.Id,upload.Id);
        Database.executeBatch(batch, 1);
        Test.stopTest();

        List<Contact_Upload_Detail__c> details = [SELECT Id, Email__c, Status__c FROM Contact_Upload_Detail__c 
                                                  WHERE Contact_Upload__c = :upload.Id];
        
        upload = [SELECT Status__c FROM Contact_Upload__c WHERE Id = :upload.Id];
        System.assert(upload.Status__c.contains('Complete'), 'Upload status should be marked Complete');
    }
}