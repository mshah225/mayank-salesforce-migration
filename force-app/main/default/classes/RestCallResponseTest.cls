@isTest
public class RestCallResponseTest {
    @isTest
    private static void restCallResponseSuccess() {
        String testStatus = 'success';
        String testMessage = 'mockId';

        Test.startTest();
        RestCallResponse response = new RestCallResponse(testStatus, testMessage);
        Boolean responseSuccess = response.isSuccessfull();
        String responseMessage = response.getMessage();
        Test.stopTest();

        System.assertEquals(true, responseSuccess);
        System.assertEquals(testMessage, responseMessage);
    }

    @isTest
    private static void restCallResponseFailure() {
        String testStatus = 'failure';
        String testMessage = 'Exception Message';

        Test.startTest();
        RestCallResponse response = new RestCallResponse(testStatus, testMessage);
        Boolean responseSuccess = response.isSuccessfull();
        String responseMessage = response.getMessage();
        Test.stopTest();

        System.assertEquals(false, responseSuccess);
        System.assertEquals(testMessage, responseMessage);
    }
}
