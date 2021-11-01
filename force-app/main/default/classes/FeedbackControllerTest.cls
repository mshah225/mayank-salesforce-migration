@isTest
private class FeedbackControllerTest {
    private static final String userAlias = 'testusr';

    @TestSetup
    static void setup() {
        Date dTac = Date.today().addDays(365);
        Date dTb = Date.today().addDays(405);

        Term__c termAC = new Term__c(
            Session_A_C_Start_Date__c = Date.newInstance(dTac.year(), dTac.month(), dTac.day()),
            Year__c = String.valueOf(dTac.year())
        );
        insert termAC;

        Term__c termB = new Term__c(
            Session_B_Start_Date__c = Date.newInstance(dTb.year(), dTb.month(), dTb.day()),
            Year__c = String.valueOf(dTb.year())
        );
        insert termB;

        Contact testContact = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'test.user@test.example.com',
            Personal_Email__c = 'test.user@test.example.com'
        );
        insert testContact;

        insert new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'test.user@test.example.com',
            Email = 'test.user@test.example.com',
            Alias = userAlias,
            CommunityNickname = 'testUsr',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = IDHelper.getProfileId('ASU Community'),
            ContactId = testContact.Id
        );

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

        if ([SELECT Id FROM Group WHERE Name = 'Student Success Innovations (Case)' AND Type = 'Queue'].size() == 0) {
            // Add group if needed
            Group testGroup = new Group(Name = 'Student Success Innovations (Case)', Type = 'Queue');
            insert testGroup;
        }

        // Needed case functional group and category
        Case_Classification__c testFuncGroup = new Case_Classification__c(
            Name = 'Student Success Innovations',
            Active__c = true,
            RecordTypeId = IdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
        );
        insert testFuncGroup;
        Case_Classification__c testClassification = new Case_Classification__c(
            Name = 'Service Center Feedback',
            Active__c = true,
            Parent__c = testFuncGroup.Id,
            RecordTypeId = IdHelper.getRecordTypeId('Case_Classification__c', 'Category')
        );
        insert testClassification;
    }

    @isTest
    static void testFeedbackCase() {
        User testUser = [SELECT Id FROM User WHERE Alias = :userAlias LIMIT 1];

        String feedbackBody = 'Test description submission.';

        MyASUHelpController sc;
        FeedbackController fc;

        Test.setCurrentPage(Page.Feedback);
        System.runAs(testUser) {
            Test.startTest();
            sc = new MyASUHelpController();
            fc = new FeedbackController(sc);
            fc.comments = feedbackBody;
            fc.submit();
            Test.stopTest();
        }

        Case createdCase = [SELECT Id, Subject, Description FROM Case LIMIT 1];
        System.assertEquals(feedbackBody, createdCase.Description);
    }

    @isTest
    static void testFeedbackEmptyCase() {
        User testUser = [SELECT Id FROM User WHERE Alias = :userAlias LIMIT 1];

        String feedbackBody = '';

        PageReference expectedRef = new PageReference('/apex/feedback');
        PageReference recievedRef;
        MyASUHelpController sc;
        FeedbackController fc;

        Test.setCurrentPage(Page.Feedback);
        System.runAs(testUser) {
            Test.startTest();
            sc = new MyASUHelpController();
            fc = new FeedbackController(sc);
            fc.comments = feedbackBody;
            recievedRef = fc.submit();
            Test.stopTest();
        }

        List<Case> createdCases = [SELECT Id, Subject, Description FROM Case LIMIT 1];
        System.assertEquals(0, createdCases.size());
        System.assertEquals(null, recievedRef);
    }

    @isTest
    static void testErrorLogging() {
        User testUser = [SELECT Id FROM User WHERE Alias = :userAlias LIMIT 1];

        // Delete needed category to cause error logger to trigger
        Case_Classification__c testClassification = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IdHelper.getRecordTypeId('Case_Classification__c', 'Category')
        ];
        delete testClassification;

        String feedbackBody = 'This should not get inserted - an error should occur.';

        MyASUHelpController sc;
        FeedbackController fc;

        Test.setCurrentPage(Page.Feedback);
        System.runAs(testUser) {
            Test.startTest();
            sc = new MyASUHelpController();
            fc = new FeedbackController(sc);
            fc.comments = feedbackBody;
            fc.submit();
            Test.stopTest();
        }

        List<Case> createdCases = [SELECT Id, Subject, Description FROM Case];
        System.assert(!createdCases.isEmpty(), 'An error logger case should have been created');
        for (Case c : createdCases) {
            Boolean correct = false;
            if (c.Subject.contains('Apex Exception')) {
                // Yes error logger
                correct = true;
            }
            if (c.Description == feedbackBody) {
                // No feedback case
                correct = false;
            }
            System.assert(correct, 'Incorrect case was inserted');
        }
    }

    @isTest
    static void testFeedbackPageRef() {
        User testUser = [SELECT Id FROM User WHERE Alias = :userAlias LIMIT 1];

        PageReference expectedRef = new PageReference('/studentSC?Confirm=feedback');
        PageReference recievedRef;
        MyASUHelpController sc;
        FeedbackController fc;

        Test.setCurrentPage(Page.Feedback);
        System.runAs(testUser) {
            Test.startTest();
            sc = new MyASUHelpController();
            fc = new FeedbackController(sc);
            fc.comments = 'Test description submission.';
            recievedRef = fc.submit();
            Test.stopTest();
        }

        System.assertEquals(expectedRef.getUrl(), recievedRef.getUrl());
    }

    @isTest
    static void testViewAsPageRef() {
        User testUser = [SELECT Id FROM User WHERE Alias = :userAlias LIMIT 1];

        PageReference expectedRef = new PageReference('/apex/feedback');
        PageReference recievedRef;
        MyASUHelpController sc;
        FeedbackController fc;

        Test.setCurrentPage(Page.Feedback);
        System.runAs(testUser) {
            Test.startTest();
            sc = new MyASUHelpController();
            fc = new FeedbackController(sc);
            sc.viewingAs = true;
            fc.comments = 'test should return PageReference back to current page while Viewing As';
            recievedRef = fc.submit();
            Test.stopTest();
        }

        System.assertEquals(expectedRef.getUrl(), recievedRef.getUrl());
    }
}
