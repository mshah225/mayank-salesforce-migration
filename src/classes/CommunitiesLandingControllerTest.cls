/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@isTest
private with sharing class CommunitiesLandingControllerTest {
    @isTest
    private static void forwardToStartPageReturnsCorrectUrl() {
        CommunitiesLandingController communityController = new CommunitiesLandingController();
        Test.startTest();
        PageReference startPage = communityController.forwardToStartPage();
        Test.stopTest();

        System.assertEquals(startPage.getURL(), '');
    }
}
