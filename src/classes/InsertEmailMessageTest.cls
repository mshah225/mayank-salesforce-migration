@isTest
private class InsertEmailMessageTest {
    private static List<Case> testCases;
    private static Contact testContact;
    private static Email_To_Case_Configuration__c testEmailToCaseConfig;
    private static void createTestData() {
        testContact = ContactService.createTestContact();
        insert testContact;

        testCases = CaseService.createTestCases(1, testContact);
        insert testCases;

        testEmailToCaseConfig = new Email_To_Case_Configuration__c();
        testEmailToCaseConfig.Name = 'Reopen Closed Case Threshold';
        testEmailToCaseConfig.Value__c = '14';
        insert testEmailToCaseConfig;
    }

    @isTest
    private static void emailMessageInsertionSuccess() {
        createTestData();
        String emailBody = 'Test Email Body';
        String parentId = testCases[0].Id;
        String emailSubject = 'Test New Subject';
        String fromName = 'Test Contact';
        String fromEmailAddress = testContact.Email;
        String toEmailAddress = 'test@test.com';

        Test.startTest();
        InsertEmailMessage.createEmailMessage(
            emailBody,
            parentId,
            emailSubject,
            fromName,
            fromEmailAddress,
            toEmailAddress
        );
        Test.stopTest();

        List<EmailMessage> retreiveEmailMessage = [SELECT Id, ParentId, Subject, fromName FROM EmailMessage];
        System.assertEquals(retreiveEmailMessage.size(), 1);
    }

    @isTest
    private static void emailMessageInsertionOnClosedCase() {
        createTestData();
        String emailBody = 'Test Email Body';
        String parentId = testCases[0].Id;
        testCases[0].Status = 'Closed: Resolved';
        update testCases;
        String emailSubject = 'Test New Subject';
        String fromName = 'Test Contact';
        String fromEmailAddress = testContact.Email;
        String toEmailAddress = 'test@test.com';

        Test.startTest();
        RestCallResponse response = InsertEmailMessage.createEmailMessage(
            emailBody,
            parentId,
            emailSubject,
            fromName,
            fromEmailAddress,
            toEmailAddress
        );
        Test.stopTest();
        Case retrievedCase = [SELECT Id, IsClosed, Status FROM Case WHERE Id = :testCases[0].Id];
        System.assertEquals(retrievedCase.IsClosed, false);
        System.assertEquals(retrievedCase.Status, 'Re-Opened');
    }
}
