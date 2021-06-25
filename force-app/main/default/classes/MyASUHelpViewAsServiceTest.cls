@isTest
private class MyASUHelpViewAsServiceTest {
    private static User userToUse;
    private static MyASUHelpViewAsService viewAsService;

    private static void setUpUser() {
        Test.setMock(HttpCalloutMock.class, new MyASUHelpViewAsServiceMock());
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile profileSettings = [SELECT Id FROM Profile WHERE Name = 'ASU Chatter User'];
        userToUse = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileSettings.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = uniqueUserName
        );

        ContactFactory.DefaultContact contactCreator = new ContactFactory.DefaultContact();
        Contact contactToInsert = (Contact) contactCreator.create(1)[0];
        contactToInsert.ASURite_ID__c = 'ASUTestID';
        insert contactToInsert;

        CaseFactory.DefaultCase openCaseCreator = new CaseFactory.DefaultCase();
        Case openCaseToInsert = (Case) openCaseCreator.create(1)[0];
        openCaseToInsert.Contact = contactToInsert;
        openCaseToInsert.ContactId = contactToInsert.Id;
        openCaseToInsert.Visible_by_Contact__c = true;
        insert openCaseToInsert;

        View_As_Url__c urlToInsert = new View_As_Url__c(Name = 'URL', MyAsuUrl__c = 'https://webapp4.asu.edu/myasu');
        insert urlToInsert;
        Test.startTest();
        viewAsService = new MyASUHelpViewAsService(null, 'Tester');
        Test.stopTest();
    }

    @isTest
    private static void getContact() {
        MyASUHelpViewAsServiceTest.setUpUser();
        Contact contactAssociatedWithAsurite;
        System.runAs(userToUse) {
            viewAsService.hasViewAsRights = true;
            contactAssociatedWithAsurite = viewAsService.getContact('ASUTestID');
        }

        Contact expectedResult = [SELECT Id FROM Contact WHERE Asurite_ID__c = 'ASUTestID'];
        System.assertEquals(expectedResult.Id, contactAssociatedWithAsurite.Id);
    }

    @isTest
    private static void getCaseDetails() {
        MyASUHelpViewAsServiceTest.setUpUser();
        Case createdCase = [SELECT Id FROM Case LIMIT 1];
        Case caseAssociatedWithAsurite;
        System.runAs(userToUse) {
            viewAsService.hasViewAsRights = true;
            caseAssociatedWithAsurite = viewAsService.getCaseDetails(createdCase.Id);
        }
        System.assertEquals(createdCase.Id, caseAssociatedWithAsurite.Id);
    }

    @isTest
    private static void getOpenCasesWithSharing() {
        MyASUHelpViewAsServiceTest.setUpUser();
        List<Contact> contactsWithCases = [SELECT Id FROM Contact];
        List<Case> allOpenCases = [SELECT Id FROM Case WHERE isClosed = FALSE];
        List<Case> openCases;
        System.runAs(userToUse) {
            viewAsService.hasViewAsRights = true;
            Map<Id, List<Case>> openCasesFromService = viewAsService.getOpenCases(contactsWithCases);
            openCases = openCasesFromService.get(contactsWithCases[0].Id);
        }
        System.assertEquals(allOpenCases.size(), openCases.size());
    }
}
