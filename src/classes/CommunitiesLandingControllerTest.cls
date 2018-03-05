/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@isTest 
private with sharing class CommunitiesLandingControllerTest {
    
    @isTest 
    public static void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        Test.startTest();
        
        CommunitiesLandingController communityController = new CommunitiesLandingController();
        PageReference startPage = communityController.forwardToStartPage();
        
        Test.stopTest();
        
        System.assertEquals(startPage.getURL(), '');
    }
}