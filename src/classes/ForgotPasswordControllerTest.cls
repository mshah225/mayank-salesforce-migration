@IsTest 
public with sharing class ForgotPasswordControllerTest {
     @IsTest
     public static void testForgotPasswordController() {
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'test@salesforce.com';     	
    
        System.assertEquals(controller.forgotPassword(),null); 
    }
}