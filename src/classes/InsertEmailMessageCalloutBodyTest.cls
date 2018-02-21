@isTest
private class InsertEmailMessageCalloutBodyTest {
    private static String testEmailBody;
    private static String testParentId;
    private static String testEmailSubject;
    private static Boolean testIsIncoming;
    private static String testFromName;
    private static String testFromAddress;
    private Static String testToAddress;
    private Static String testStatus;
    
    private static void initTestData() {
        testEmailBody = 'Test Email Body';
        testParentId = 'Mock Id';
        testEmailSubject = 'Test Subject';
        testIsIncoming = true;
        testFromName = 'Test Name';
        testFromAddress = 'testfrom@test.com';
        testToAddress = 'testto@test.com';
        testStatus = '2';
    }
    
    @isTest
    private static void testEmailMessageCalloutBody() {
        initTestData();
        
        Test.startTest();
        InsertEmailMessageCalloutBody testCalloutBody = new InsertEmailMessageCalloutBody(testEmailBody, testParentId,
                                                                testEmailSubject, testIsIncoming, testFromName,
                                                                testFromAddress, testToAddress, testStatus);
        Test.stopTest();
        System.assertEquals(testCalloutBody.getEmailTextBody(), 'Test Email Body');
        System.assertEquals(testCalloutBody.getParentId(), 'Mock Id');
        System.assertEquals(testCalloutBody.getEmailSubject(), 'Test Subject');
        System.assertEquals(testCalloutBody.getIsIncoming(), true);
        System.assertEquals(testCalloutBody.getFromName(), 'Test Name');
        System.assertEquals(testCalloutBody.getFromAddress(), 'testfrom@test.com');
        System.assertEquals(testCalloutBody.getToAddress(), 'testto@test.com');
        System.assertEquals(testCalloutBody.getStatus(), '2');
    }
}