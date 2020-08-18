@isTest
private class MyASUHelpFAQControllerTest {
    private static MyASUHelpFAQController sc;
    private static ViewCaseController vcc;
    private static ViewAllCasesController vacc;
    private static MyASUHelpMyRequestsController myASUHelpMyRequests;
    private static Case caseOnTestUser;
    private static User testUser;
    private static Contact contactRelatedToTestUser;
    private static List<Opportunity> oppListForTestUser;

    @testSetup
    private static void setTestData() {
        Term__c termAC = new Term__c();
        Date acTermStart = Date.today().adddays(365);
        termAC.Session_A_C_Start_Date__c = date.newinstance(acTermStart.year(), acTermStart.month(), acTermStart.day());
        String ACYear = String.valueOf(acTermStart.year());
        termAC.Year__c = ACYear;
        insert termAC;

        Term__c termB = new Term__c();
        Date bTermStart = Date.today().adddays(405);
        termB.Session_B_Start_Date__c = date.newinstance(bTermStart.year(), bTermStart.month(), bTermStart.day());
        String BYear = String.valueOf(bTermStart.year());
        termB.Year__c = BYear;
        insert termB;

        ContactFactory.DefaultContact contactFactoy = new ContactFactory.DefaultContact();
        List<Contact> testContactList = contactFactoy.create(4);
        testContactList[3].Affiliation_Alumni__c = 'Current';
        insert testContactList;

        Email_To_Case_Configuration__c defaultEmail = new Email_To_Case_Configuration__c(
            Name = 'Default Org Wide Email Address',
            Value__c = 'noEmail@test.com'
        );
        insert defaultEmail;

        UserFactory.DefaultUser userFactory = new UserFactory.DefaultUser();
        List<User> testUserList = userFactory.create(4);

        Profile asuCommunity = [SELECT Id FROM Profile WHERE Name = 'ASU Community'];
        for (Integer i = 0; i < testUserList.size(); i++) {
            testUserList[i].ProfileId = asuCommunity.Id;
            testUserList[i].ContactId = testContactList[i].Id;
        }

        insert testUserList;

        CaseClassificationFactory factory = new CaseClassificationFactory();
        List<Case_Classification__c> classifications = factory.createAndInsertSetOfCaseClassification();
        classifications[0].Name = 'Student Success Innovations';
        classifications[1].Name = 'Knowledge';
        classifications[2].Name = 'Test';
        update classifications;

        setupEnrolledTestSessionA();
        setUpEnrolledTestSessionB();
        setUpNonEnrolled();
    }

    private static void setUpEnrolledTestSessionA() {
        Contact testContEnrolledA = [SELECT Id, AccountId, Email FROM Contact WHERE LastName = 'Contact0'];

        User userAsCaseOwner = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE LastName = 'User0'
        ];

        Opportunity testOppEnrolledA = OpportunityService.createTestUndergraduateProspect(testContEnrolledA);
        testOppEnrolledA.StageName = 'Enrolled';
        testOppEnrolledA.Career__c = 'Undergraduate';
        testOppEnrolledA.Admitted_Session__c = 'A/C';
        insert testOppEnrolledA;

        List<Case> openCases = CaseService.createTestCases(1, testContEnrolledA);
        openCases[0].OwnerId = userAsCaseOwner.Id;
        insert openCases;

        EmailMessage emailOnCase = new EmailMessage(
            FromAddress = 'test0@test.com',
            Incoming = false,
            ToAddress = testContEnrolledA.Email,
            Subject = 'Test email',
            TextBody = '23456 ',
            ParentId = openCases[0].Id
        );

        insert emailonCase;

        List<Case> closedCases = CaseService.createTestCases(10, testContEnrolledA);

        for (Case c : closedCases) {
            c.Status = 'Closed: Resolved';
        }
        insert closedCases;

        bomgar__BomgarSession__c bomgarSession = new bomgar__BomgarSession__c();
        bomgarSession.bomgar__RelatedCase__c = openCases[0].Id;
        insert bomgarSession;

        DateTime bomgarEventTime = DateTime.now();
        bomgar__Event__c bomgarEvent = new bomgar__Event__c();
        bomgarEvent.bomgar__BomgarSession__c = bomgarSession.Id;
        bomgarEvent.bomgar__DestinationValue__c = 'everyone';
        bomgarEvent.bomgar__EventDateTime__c = bomgarEventTime;
        bomgarEvent.bomgar__EventType__c = 'representative';
        bomgarEvent.bomgar__Text__c = 'Test Text';
        insert bomgarEvent;
    }

    private static void setUpEnrolledTestSessionB() {
        Contact testContEnrolledB = [SELECT Id, AccountId FROM Contact WHERE LastName = 'Contact1'];

        Opportunity testOppEnrolledB = OpportunityService.createTestUndergraduateProspect(testContEnrolledB);
        testOppEnrolledB.StageName = 'Enrolled';
        testOppEnrolledB.Career__c = 'Undergraduate';
        testOppEnrolledB.Admitted_Session__c = 'B';
        insert testOppEnrolledB;
    }

    private static void setUpNonEnrolled() {
        Contact testNotEnrolled = [SELECT Id, AccountId FROM Contact WHERE LastName = 'Contact2'];

        Opportunity testOppNotEnrolled = OpportunityService.createTestUndergraduateProspect(testNotEnrolled);
        testOppNotEnrolled.StageName = 'Not Enrolled';
        testOppNotEnrolled.Career__c = 'Undergraduate';
        insert testOppNotEnrolled;
    }

    private static void loadTestDataWithUserByLastName(String userLasName) {
        loadTestUserByLastName(userLasName);
        loadContactForTestUser();
        loadCaseOnTestUser();
        loadTestOpportunityForTestUser();
    }

    private static void loadTestUserByLastName(String lastName) {
        testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE LastName = :lastName
        ];
    }
    private static void loadContactForTestUser() {
        List<Contact> contactListForTestUser = [SELECT Id FROM Contact WHERE Id = :testUser.ContactId];
        if (!contactListForTestUser.isEmpty())
            contactRelatedToTestUser = contactListForTestUser[0];
    }

    private static void loadCaseOnTestUser() {
        List<Case> caseListForTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];
        if (!caseListForTestUser.isEmpty())
            caseOnTestUser = caseListForTestUser[0];
    }

    private static void loadTestOpportunityForTestUser() {
        oppListForTestUser = [
            SELECT Career__c, Term__c, StageName, Admitted_Session__c
            FROM Opportunity
            WHERE Contact__c = :testUser.ContactId
        ];
    }

    private static void insertLiveAgentMessages(Integer num) {
        List<Chat_Message__c> chatMessages = new List<Chat_Message__c>();
        for (Integer i = 0; i < num; i++) {
            chatMessages.add(new Chat_Message__c(Body__c = 'Test Body Message', Case__c = caseOnTestUser.Id));
        }
        insert chatMessages;
    }

    @isTest
    private static void testStudentSCPageAC() {
        Service_Center_Maintenance__c scm = new Service_Center_Maintenance__c(
            Name = 'The Test Message',
            Displayed__c = true,
            Message__c = 'There is maintenance',
            Start_Time__c = System.now(),
            End_Time__c = System.now() + 20
        );
        insert scm;

        loadTestDataWithUserByLastName('User0');

        PageReference myASUHelp = Page.studentSC;
        myASUHelp.getParameters().put('source', 'viewAllCases');
        Test.setCurrentPage(myASUHelp);

        Test.startTest();

        System.runAs(testUser) {
            sc = new MyASUHelpFAQController();
            vcc = new ViewCaseController();
            myASUHelpMyRequests = new MyASUHelpMyRequestsController();

            sc.oppList = oppListForTestUser;
            vcc.oppList = oppListForTestUser;
            myASUHelpMyRequests.getMyCasesBox();

            sc.stopViewAsUrl = 'www.giphy.com/search/shrek-is-love';
            vcc.stopViewAsUrl = 'www.giphy.com/search/shrek-is-love';
            sc.viewAsUrl = 'www.hankhillgifs.com';
            vcc.viewAsUrl = 'www.hankhillgifs.com';

            sc.getSource();
            vcc.getSource();

            System.assertEquals('There is maintenance', sc.getmMessage());
            System.assertEquals(false, sc.getHelpBox());
            System.assertEquals(true, sc.getNormalPhone());
            System.assertEquals(false, sc.getRoverPhone());

            System.assertEquals(false, vcc.getHelpBox());
            System.assertEquals(true, vcc.getNormalPhone());
            System.assertEquals(false, vcc.getRoverPhone());
        }
        Test.stopTest();
    }

    @isTest
    private static void testStudentSCPageB() {
        Service_Center_Maintenance__c scm = new Service_Center_Maintenance__c(
            Name = 'The Test Message',
            Displayed__c = true,
            Message__c = 'There is maintenance forever'
        );
        insert scm;

        loadTestDataWithUserByLastName('User1');
        PageReference myASUHelp = Page.studentSC;
        myASUHelp.getParameters().put('source', 'viewAllCases');
        Test.setCurrentPage(myASUHelp);

        Test.startTest();

        System.runAs(testUser) {
            vacc = new ViewAllCasesController();
            vcc = new ViewCaseController();

            vacc.stopViewAsUrl = 'www.giphy.com/search/shrek-is-love';
            vacc.viewAsUrl = 'www.hankhillgifs.com';

            myASUHelpMyRequests = new MyASUHelpMyRequestsController();
            sc = new MyASUHelpFAQController();
            sc.oppList = oppListForTestUser;
            vcc.oppList = oppListForTestUser;
            myASUHelpMyRequests.oppList = oppListForTestUser;

            vacc.getMyCases();
            vacc.getAllClosedCases();
            vacc.getSource();
            vacc.viewCase();

            vacc.viewingAs = true;
            vacc.getMyCases();
            vacc.getAllClosedCases();
            vacc.getSource();
            vacc.viewCase();

            myASUHelpMyRequests.stopViewAsUrl = 'www.giphy.com/search/shrek-is-love';
            myASUHelpMyRequests.viewAsUrl = 'www.hankhillgifs.com';
            myASUHelpMyRequests.getmyCasesBox();
            System.assertEquals(false, sc.getHelpBox());
            System.assertEquals(false, vcc.getHelpBox());
            System.assertEquals('There is maintenance forever', sc.getmMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testStudentSCNotEnrolled() {
        loadTestDataWithUserByLastName('User2');

        PageReference myASUHelp = Page.studentSC;
        myASUHelp.getParameters().put('source', 'viewAllCases');
        Test.setCurrentPage(myASUHelp);

        Test.startTest();

        System.runAs(testUser) {
            sc = new MyASUHelpFAQController();
            vcc = new ViewCaseController();
            myASUHelpMyRequests = new MyASUHelpMyRequestsController();

            sc.oppList = oppListForTestUser;
            vcc.oppList = oppListForTestUser;
            myASUHelpMyRequests.oppList = oppListForTestUser;

            System.assertEquals(true, myASUHelpMyRequests.getmyCasesBox());
            System.assertEquals(true, sc.getHelpBox());
            System.assertEquals(true, vcc.getHelpBox());
        }

        Test.stopTest();
    }

    @isTest
    private static void testStudentSCNoOpp() {
        loadTestDataWithUserByLastName('User3');

        Test.startTest();

        PageReference myASUHelp = Page.studentSC;
        Test.setCurrentPage(myASUHelp);

        System.runAs(testUser) {
            sc = new MyASUHelpFAQController();
            myASUHelpMyRequests = new MyASUHelpMyRequestsController();

            myASUHelpMyRequests.oppList = oppListForTestUser;

            System.assertEquals(true, myASUHelpMyRequests.getMyCasesBox());
            System.assertEquals(true, sc.getHelpBox());
        }
        Test.stopTest();
    }

    @isTest
    private static void testStudentSCAlumni() {
        loadTestDataWithUserByLastName('User3');

        PageReference myASUHelp = Page.studentSC;
        Test.setCurrentPage(myASUHelp);

        Test.startTest();

        System.runAs(testUser) {
            sc = new MyASUHelpFAQController();
            System.assertEquals(true, sc.getHelpBox());
            myASUHelpMyRequests = new MyASUHelpMyRequestsController();

            myASUHelpMyRequests.oppList = oppListForTestUser;

            System.assertEquals(true, myASUHelpMyRequests.getMyCasesBox());
        }

        Test.stopTest();
    }

    @isTest
    private static void testSubmitCase() {
        loadTestUserByLastName('User0');

        PageReference myASUHelp = Page.studentSC;
        Test.setCurrentPage(myASUHelp);

        Test.startTest();

        System.runAs(testUser) {
            myASUHelpMyRequests = new MyASUHelpMyRequestsController();
            myASUHelpMyRequests.newCase.Subject = 'Test Subject for SC';
            myASUHelpMyRequests.newCase.Description = 'Test Desc';

            PageReference submit = myASUHelpMyRequests.submitCase();
            System.debug(submit);
            System.assertEquals(submit.getURL().contains('/viewcase?'), true);

            myASUHelpMyRequests.getClosedCases();
            myASUHelpMyRequests.viewCase();
            myASUHelpMyRequests.getMyCases();
            myASUHelpMyRequests.getMyCasesBox();

            myASUHelpMyRequests.viewingAs = true;
            myASUHelpMyRequests.masqScopeIdCookie = 'testCookie';
            System.assertEquals(
                myASUHelpMyRequests.submitCase().getURL().contains('masqScopeIdCookie=testCookie'),
                true
            );
        }

        Test.stopTest();
    }

    @isTest
    private static void suggestAnArticleReturnsProperUrl() {
        loadTestUserByLastName('User0');
        PageReference myASUHelp = Page.studentSC;
        Test.setCurrentPage(myASUHelp);
        PageReference submit;
        String urlReturnedFromSubmit;

        System.runAs(testUser) {
            sc = new MyASUHelpFAQController();
            sc.suggestAnArticle.Description = 'Test submitting a suggestion';
            submit = ApexPages.currentPage();
            submit.getParameters().put('Suggest', 'yes');

            Test.startTest();
            urlReturnedFromSubmit = sc.suggestAnArticleSubmit().getURL();
            Test.stopTest();
        }

        System.assertEquals(submit.getURL(), urlReturnedFromSubmit);
        System.assertEquals('Description', sc.suggestAnArticle.Description);
    }

    private static void setCurrentPageAsViewCase() {
        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);
    }

    @isTest
    private static void testViewAs() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();

        Test.startTest();

        System.runAs(testUser) {
            sc = new MyASUHelpFAQController();
            sc.viewingAs = true;
            PageReference stop = ApexPages.currentPage();

            System.assertEquals(stop.getURL(), sc.suggestAnArticleSubmit().getURL());
        }

        Test.stopTest();
    }

    @isTest
    private static void fetchCaseDetailsWithoutMyASUViewAs() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();

        Case checkCase;

        Test.startTest();
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            checkCase = vcc.getCaseDetails();

            vcc.viewingAs = true;
            vcc.getCaseDetails();
        }
        Test.stopTest();
        System.assertEquals(checkCase.Id, caseOnTestUser.Id);
    }

    @isTest
    private static void fetchCaseDetailsWithMyASUViewAs() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();

        Case checkCase;

        Test.startTest();
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            vcc.viewingAs = true;
            checkCase = vcc.getCaseDetails();
        }
        Test.stopTest();
        System.assertEquals(checkCase.Id, caseOnTestUser.Id);
    }

    @isTest
    private static void fetchEmailMessagesWithoutMyASUViewAs() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();

        Test.startTest();
        System.runAs(testUser) {
            vcc = new ViewCaseController();
        }
        Test.stopTest();
        System.assertEquals(vcc.getEmailMessages().size(), 1);
    }

    @isTest
    private static void fetchEmailMessagesWithMyASUViewAs() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();

        Test.startTest();
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            vcc.viewingAs = true;
        }
        Test.stopTest();
        System.assertEquals(vcc.getEmailMessages().size(), 1);
    }

    @isTest
    private static void fetchChatMessages() {
        loadTestDataWithUserByLastName('User0');
        insertLiveAgentMessages(1);
        setCurrentPageAsViewCase();

        List<ChatMessage> fetchedChatMessages;
        Test.startTest();
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            fetchedChatMessages = vcc.getChatMessages();
        }
        Test.stopTest();
        System.assertEquals(fetchedChatMessages.size(), 1);
    }

    @isTest
    private static void correctNumberOfChatMessages() {
        loadTestDataWithUserByLastName('User0');
        insertLiveAgentMessages(1);
        setCurrentPageAsViewCase();

        List<ChatMessage> fetchedChatMessages;
        Test.startTest();
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            fetchedChatMessages = vcc.getChatMessages();
        }
        Test.stopTest();
        List<bomgar__Event__c> bomgarForAssert = [
            SELECT
                bomgar__DestinationValue__c,
                bomgar__EventDateTime__c,
                bomgar__EventType__c,
                bomgar__PerformedByType__c,
                bomgar__PerformedByValue__c,
                bomgar__Text__c,
                Id,
                Name,
                OwnerId
            FROM bomgar__Event__c
            WHERE
                bomgar__BomgarSession__r.bomgar__relatedcase__c = :ApexPages.currentPage().getParameters().get('Id')
                AND (bomgar__PerformedByType__c = 'representative'
                OR bomgar__PerformedByType__c = 'customer')
                AND bomgar__DestinationValue__c = 'everyone'
            ORDER BY bomgar__EventDateTime__c ASC
        ];
        List<Chat_Message__c> chatMessages = [SELECT Body__c FROM Chat_Message__c];
        System.assertEquals(bomgarForAssert.size() + chatMessages.size(), fetchedChatMessages.size());
    }

    @isTest
    private static void testRestCalloutSuccess() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();

        System.runAs(testUser) {
            vcc = new ViewCaseController();
            Test.setMock(HttpCalloutMock.class, new EmailMessageSuccessMock());
            vcc.replyCaseAttachment.Name = 'Test Name';
            vcc.replyCaseAttachment.Body = Blob.valueOf('Test Attachment Body');
            vcc.caseReply = 'Test Message';

            Test.startTest();
            vcc.submitReply();
            Test.stopTest();
        }

        System.assert(String.isEmpty(vcc.caseReply));
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean successMessageFound = false;
        for (Apexpages.Message msg : msgs) {
            if (msg.getDetail().contains('Response to the case was submitted successfully')) {
                successMessageFound = true;
            }
        }
        System.assert(successMessageFound);
    }

    @isTest
    private static void testRestCalloutFailure() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();

        System.runAs(testUser) {
            vcc = new ViewCaseController();
            Test.setMock(HttpCalloutMock.class, new EmailMessageFailureMock());
            vcc.replyCaseAttachment.Name = 'Test Name';
            vcc.replyCaseAttachment.Body = Blob.valueOf('Test Attachment Body');
            vcc.caseReply = 'Test Message';

            Test.startTest();
            vcc.submitReply();
            Test.stopTest();
        }

        System.assert(String.isEmpty(vcc.caseReply));
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean failureMessageFound = false;
        for (Apexpages.Message msg : msgs) {
            if (msg.getDetail().contains('Could not add response to case. Please try again or contact system admin')) {
                failureMessageFound = true;
            }
        }
        System.assert(failureMessageFound);
    }

    @isTest
    private static void testCorrectReplyToEmail() {
        loadTestDataWithUserByLastName('User0');
        caseOnTestUser.Intended_Recipient__c = 'testEmail@test.com';
        update caseOnTestUser;
        setCurrentPageAsViewCase();
        String jsonEmail;
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            Test.startTest();
            jsonEmail = vcc.createJsonEmail();
            Test.stopTest();
        }
        System.assert(jsonEmail.contains('testEmail@test.com'));
    }

    @isTest
    private static void testNoIntendedReplyToEmail() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
        String jsonEmail;
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            Test.startTest();
            jsonEmail = vcc.createJsonEmail();
            Test.stopTest();
        }
        System.assert(jsonEmail.contains('noEmail@test.com'));
    }
}
