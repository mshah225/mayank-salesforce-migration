@IsTest
private with sharing class ForgotPasswordControllerTest {
    @IsTest
    private static void testForgotPasswordController() {
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'test@salesforce.com';

        System.assertEquals(null, controller.forgotPassword());
    }
}
