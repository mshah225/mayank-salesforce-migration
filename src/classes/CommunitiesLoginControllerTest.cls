/**
 * An apex page controller that exposes the site login functionality
 */
@isTest 
private with sharing class CommunitiesLoginControllerTest {
    @isTest 
    private static void forwardToAuthPageReturnsCorrectUrl () {
        Test.startTest();
     	CommunitiesLoginController controller = new CommunitiesLoginController();
     	Test.stopTest();
     	
     	System.assertEquals(null, controller.forwardToAuthPage());       
    }    
}