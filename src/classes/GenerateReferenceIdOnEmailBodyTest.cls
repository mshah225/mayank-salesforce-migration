@isTest
private class GenerateReferenceIdOnEmailBodyTest {
    private static Case testCase;
    
    private static void createTestData() {
        testCase = new Case(Status = 'New');
        insert testCase;
    }
    
    @isTest
    private static void testReferenceIdOnEmailBody(){
        createTestData();
        
        Test.startTest();
        String emailThreadId = GenerateReferenceIdOnEmailBody.addReferenceIdToEmailBody(testCase.Id, '');
        Test.stopTest();
        
        System.assertEquals(testCase.Id, Cases.getCaseIdFromEmailThreadId(emailThreadId));
    }
    
}