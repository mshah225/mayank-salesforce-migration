@isTest
private class EmailMessageInsertTest {
    
    private static List<Case> testCases;
    private static Contact testContact;
    
    private static void createTestData() {
        testContact = ContactService.createTestContact();
        insert testContact;
        
        testCases = CaseService.createTestCases(1, testContact);
        insert testCases;
        
    }
    
    @isTest
    private static void testEmailMessageInsertionSuccess() {
        createTestData();
        String emailBody = 'Test Email Body'; 
        String  parentId = testCases[0].Id; 
        String emailSubject = 'Test New Subject';
        Boolean isIncoming = true;
        String fromName = 'Test Contact';
        String fromEmailAddress = testContact.Email;
        String toEmailAddress = 'test@test.com';
        String emailStatus = '2';   
        
        Test.startTest();
        EmailMessageInsert.createEmailMessage(emailBody, parentId, emailSubject, isIncoming, fromName, fromEmailAddress, toEmailAddress, emailStatus);
        Test.stopTest();
        
        List<EmailMessage> retrieveEmailMessage = [SELECT Id, ParentId, TextBody, FromAddress FROM EmailMessage LIMIT 1];
        System.assertEquals(retrieveEmailMessage[0].ParentId, testCases[0].Id);
        System.assertEquals(retrieveEmailMessage[0].TextBody, emailBody);
        System.assertEquals(retrieveEmailMessage[0].FromAddress, testContact.Email);
    }
    
    @isTest
    private static void testEmailMessageInsertionFailure() {
        createTestData();
        String emailBody = '';
        String  parentId = testCases[0].Id; 
        String emailSubject = '';
        Boolean isIncoming = true;
        String fromName = '';
        String fromEmailAddress = '';
        String toEmailAddress = '';
        String emailStatus = '-1';   // wrong status code to cover exception block
        
        String returnMessage;
        Test.startTest();
        returnMessage = EmailMessageInsert.createEmailMessage(emailBody, parentId, emailSubject, isIncoming, fromName, fromEmailAddress, toEmailAddress, emailStatus);
        Test.stopTest();
        
        System.assertEquals(returnMessage, 'failure');
    }
}