@isTest
public class ContentDocumentLinkTriggerTest {
    
    @testSetup
    static void setupData() {
        Case testCase = new Case(Subject = 'Dispatcher Trigger Test Case');
        insert testCase;
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test Content')
        );
        insert cv;
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = testCase.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }
    
    @isTest
    static void testDispatcherViaTrigger() {
        Case c = [SELECT Id FROM Case WHERE Subject = 'Dispatcher Trigger Test Case' LIMIT 1];
        ContentDocument cd = [
            SELECT Id FROM ContentDocument 
            WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Test File')
            LIMIT 1
        ];
        
        ContentDocumentLink link = [
            SELECT Id, Visibility 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :c.Id 
            AND ContentDocumentId = :cd.Id 
            LIMIT 1
        ];
        
        link.Visibility = link.Visibility == 'AllUsers' ? 'InternalUsers' : 'AllUsers';
        update link;
        
        delete link;
        
        Case secondCase = new Case(Subject = 'Dispatcher Trigger Test Case 2');
        insert secondCase;
        
        ContentDocumentLink newLink = new ContentDocumentLink(
            ContentDocumentId = cd.Id,
            LinkedEntityId = secondCase.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert newLink;
    }
    
    @isTest
    static void testContentDocumentTriggerDeleteFlow() {
        Case testCase = new Case(Subject = 'Test for ContentDocumentTrigger');
        insert testCase;
        
        ContentVersion cv = new ContentVersion(
            Title = 'TriggerDeleteTestFile',
            PathOnClient = 'TriggerDeleteTestFile.txt',
            VersionData = Blob.valueOf('Trigger test content')
        );
        insert cv;
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id contentDocId = cv.ContentDocumentId;
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = testCase.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
        
        ContentDocument docToDelete = [SELECT Id FROM ContentDocument WHERE Id = :contentDocId];
        delete docToDelete;
        
    }
    
    @isTest
    static void testContentDocumentTriggerWithEmailMessage() {
        Case testCase = new Case(Subject = 'Test for EmailMessage and ContentDocumentTrigger');
        insert testCase;
        
        ContentVersion cv = new ContentVersion(
            Title = 'TestFileWithEmailMessage',
            PathOnClient = 'TestFileWithEmailMessage.txt',
            VersionData = Blob.valueOf('Test content for EmailMessage scenario')
        );
        insert cv;
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id contentDocId = cv.ContentDocumentId;
        
        EmailMessage emailMessage = new EmailMessage(
            Subject = 'Test Email for ContentDocumentLink',
            ToAddress = 'test@example.com',
            FromAddress = 'sender@example.com',
            ParentId = testCase.Id
        );
        insert emailMessage;
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = emailMessage.Id, 
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
        
        delete [SELECT Id FROM ContentDocument WHERE Id = :contentDocId];
        
    }
}