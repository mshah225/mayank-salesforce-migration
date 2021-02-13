@isTest
public class RestCallResponseTest {
    private static String testStatus;
    private static String testMessage;

    private static void setTestData(String status, String message) {
        testStatus = status;
        testMessage = message;
    }

    @isTest
    private static void restCallResponseSuccess() {
        setTestData('success', 'mockId');
        Boolean testSuccess = false;
        Test.startTest();
        RestCallResponse response = new RestCallResponse(testStatus, testMessage);
        testSuccess = response.isSuccessfull();
        Test.stopTest();
        System.assertEquals(testSuccess, true);
    }

    @isTest
    private static void restCallResponseFailure() {
        setTestData('failure', 'Exception Message');
        Boolean testSuccess = true;
        Test.startTest();
        RestCallResponse response = new RestCallResponse(testStatus, testMessage);
        testSuccess = response.isSuccessfull();
        Test.stopTest();
        System.assertEquals(testSuccess, false);
    }
}
