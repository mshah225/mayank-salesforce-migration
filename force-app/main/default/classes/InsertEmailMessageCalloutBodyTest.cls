@isTest
private class InsertEmailMessageCalloutBodyTest {
    private static String testEmailBody;
    private static String testParentId;
    private static String testEmailSubject;
    private static Boolean testIsIncoming;
    private static String testFromName;
    private static String testFromAddress;
    private static String testToAddress;
    private static String testStatus;

    private static void initTestData() {
        testEmailBody = 'Test Email Body';
        testParentId = 'Mock Id';
        testEmailSubject = 'Test Subject';
        testFromName = 'Test Name';
        testFromAddress = 'testfrom@test.com';
        testToAddress = 'testto@test.com';
    }

    @isTest
    private static void testEmailMessageCalloutBody() {
        initTestData();

        Test.startTest();
        InsertEmailMessageCalloutBody testCalloutBody = new InsertEmailMessageCalloutBody(
            testEmailBody,
            testParentId,
            testEmailSubject,
            testFromName,
            testFromAddress,
            testToAddress
        );
        Test.stopTest();
        System.assertEquals(testCalloutBody.getEmailTextBody(), 'Test Email Body');
        System.assertEquals(testCalloutBody.getParentId(), 'Mock Id');
        System.assertEquals(testCalloutBody.getEmailSubject(), 'Test Subject');
        System.assertEquals(testCalloutBody.getFromName(), 'Test Name');
        System.assertEquals(testCalloutBody.getFromAddress(), 'testfrom@test.com');
        System.assertEquals(testCalloutBody.getToAddress(), 'testto@test.com');
    }
}
