@isTest
private class FeedbackControllerTest {
    private static Contact testContact;
    private static Case testCase;
    private static User testUser;
    private static FeedbackController fc;
    private static MyASUHelpController sc;

    static void setUp() {
        Term__c termAC = new Term__c();
        Date dTac = Date.today().adddays(365);
        Date dTb = Date.today().adddays(405);
        termAC.Session_A_C_Start_Date__c = date.newinstance(dTac.year(), dTac.month(), dTac.day());
        String ACYear = String.valueOf(dTac.year());
        termAC.Year__c = ACYear;
        insert termAC;

        Term__c termB = new Term__c();
        termB.Session_B_Start_Date__c = date.newinstance(dTb.year(), dTb.month(), dTb.day());
        String BYear = String.valueOf(dTb.year());
        termB.Year__c = BYear;
        insert termB;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'ASU Community'];

        testContact = ContactService.createTestContact();
        insert testContact;

        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        testUser = (User) userCreator.create(1)[0];
        testUser.ProfileId = p.Id;
        testUser.ContactId = testContact.Id;
        insert testUser;

        List<Live_Agent_Button__c> buttonsToInsert = new List<Live_Agent_Button__c>();
        buttonsToInsert.add(
            new Live_Agent_Button__c(
                Name = 'Finances_Live_Chat',
                Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat'
            )
        );
        buttonsToInsert.add(
            new Live_Agent_Button__c(
                Name = 'ASU_Services_Live_Chat',
                Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat'
            )
        );
        buttonsToInsert.add(
            new Live_Agent_Button__c(
                Name = 'Technical_Support_Live_Chat',
                Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat'
            )
        );

        insert buttonsToInsert;
    }

    @isTest
    static void testFeedbackCase() {
        setUp();
        testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0' LIMIT 1];
        PageReference setPage = Page.feedback;
        Test.setCurrentPage(setPage);
        System.runAs(testUser) {
            sc = new MyASUHelpController();
            fc = new FeedbackController(sc);
            fc.comments = 'Test description submission.';

            PageReference submitTest = new PageReference('/studentSC?Confirm=feedback');
            System.assertEquals(fc.submit().getUrl(), submitTest.getUrl());
        }
    }

    @isTest
    static void testViewAsFeedback() {
        setUp();
        testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0' LIMIT 1];
        PageReference setPage = Page.feedback;
        Test.setCurrentPage(setPage);
        System.runAs(testUser) {
            sc = new MyASUHelpController();
            fc = new FeedbackController(sc);
            sc.viewingAs = true;
            fc.comments = 'test should return null PageReference while Viewing As';

            PageReference testURL = new PageReference('/apex/feedback');
            System.assertEquals(fc.submit().getUrl(), testURL.getUrl());
        }
    }
}
