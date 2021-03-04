/**
 * An apex page controller that exposes the site login functionality
 */
@isTest
private with sharing class CommunitiesLoginControllerTest {
    @isTest
    private static void forwardToAuthPageReturnsCorrectUrl() {
        PageReference defaultLoginPage;
        Test.startTest();
        CommunitiesLoginController controller = new CommunitiesLoginController();
        defaultLoginPage = controller.forwardToAuthPage();
        Test.stopTest();

        System.assertEquals(null, defaultLoginPage);
    }
}
