@isTest
private class MyASUViewAsTest {
    
    private User userToUse;
    
    private void setUpUser() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile profileSettings = [SELECT Id FROM Profile WHERE Name='ASU Chatter User'];
        userToUse = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = profileSettings.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
    }
    
    private void setUpWithoutSharing() {
        
    }
    
    @isTest
    private static void getContactWithSharing() {

    }

    @isTest
    private static void getContactWithoutSharing() {

    }
    
    @isTest
    private static void getCaseDetailsWithSharing() {

    }
    
    @isTest
    private static void getCaseDetailsWithoutSharing() {

    }
    
    @isTest
    private static void getOpenCasesWithSharing() {

    }

    @isTest
    private static void getOpenCasesWithoutSharing() {

    }

    @isTest
    private static void getClosedCasesWithSharing() {

    }

    @isTest
    private static void getClosedCasesWithoutSharing() {

    }

    @isTest
    private static void getCaseEmailsWithSharing() {

    }
    
    @isTest
    private static void getCaseEmailsWithoutSharing() {

    }
}