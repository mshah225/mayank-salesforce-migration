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
        
        CaseFactory.DefaultCase openCaseCreator = new CaseFactory.DefaultCase();
        Case openCaseToInsert = (Case)openCaseCreator.create(1)[0];
        openCaseToInsert.Contact = contactToInsert;
        openCaseToInsert.ContactId = contactToInsert.Id;
        openCaseToInsert.Visible_by_Contact__c = true;
        insert openCaseToInsert;
        
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
        MyASUViewAsTest.setUpUser();
        System.runAs(userToUse) {
            viewAsService.hasViewAsRights = true;
            Case createdCase = [SELECT Id FROM Case LIMIT 1];
            Case caseAssociatedWithAsurite = viewAsService.getCaseDetails(createdCase.Id);
            System.assertEquals(createdCase.Id, caseAssociatedWithAsurite.Id);
        }
    }
    
    @isTest
    private static void getOpenCasesWithSharing() {
        MyASUViewAsTest.setUpUser();
        List<Contact> contactsWithCases = [SELECT Id FROM Contact];
        System.runAs(userToUse) {
            viewAsService.hasViewAsRights = true;
            List<Case> allOpenCases = [SELECT Id FROM Case WHERE isClosed = false];
            Map<Id, List<Case>> openCasesFromService = viewAsService.getOpenCases(contactsWithCases);
            List<Case> openCases = openCasesFromService.get(contactsWithCases[0].Id);
            System.assertEquals(allOpenCases.size(), openCases.size());
        }
    }
}