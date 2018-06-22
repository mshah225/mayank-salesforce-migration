@isTest
private class MyASUViewAsTest {
    
    private static User userToUse;
    private static MyASUViewAs viewAsService;
    
    private static void setUpUser() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGen_MyAsuViewAs());       
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile profileSettings = [SELECT Id FROM Profile WHERE Name='ASU Chatter User'];
        userToUse = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = profileSettings.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        
        ContactFactory.DefaultContact contactCreator = new ContactFactory.DefaultContact();
        Contact contactToInsert = (Contact)contactCreator.create(1)[0];
        contactToInsert.ASURite_ID__c = 'ASUTestID';
        insert contactToInsert;
        
        View_As_URL__c urlToInsert = new View_As_URL__c(Name = 'URL', MyASUURL__c = 'https://webapp4.asu.edu/myasu');
        insert urlToInsert;
        Test.startTest();
        viewAsService = new MyASUViewAs(null, 'Tester');
        Test.stopTest();
    }
    
    @isTest
    private static void getContact() {
        MyASUViewAsTest.setUpUser();
        System.runAs(userToUse) {
            viewAsService.hasViewAsRights = true;
            Contact contactAssociatedWithAsurite = viewAsService.getContact('ASUTestID');
            Contact expectedResult = [Select Id FROM Contact WHERE ASURite_ID__c = 'ASUTestID'];
            System.assertEquals(expectedResult.Id, contactAssociatedWithAsurite.Id);
        }
    }

    @isTest
    private static void getCaseDetails() {

    }
    
    @isTest
    private static void getOpenCasesWithSharing() {

    }

    @isTest
    private static void getClosedCasesWithSharing() {

    }

    @isTest
    private static void getCaseEmailsWithSharing() {

    }
}