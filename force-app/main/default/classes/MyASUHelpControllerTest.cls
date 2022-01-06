@isTest
private class MyASUHelpControllerTest {
    private static MyASUHelpController helpTab;
    private static ViewCaseController vcc;
    private static ViewAllCasesController vacc;
    private static Case caseOnTestUser;
    private static User testUser;
    private static Contact contactRelatedToTestUser;
    private static List<Opportunity> oppListForTestUser;

    @testSetup
    private static void setTestData() {
        setLiveAgentSettings();

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

    private static void setLiveAgentSettings() {
        List<Live_Agent_Button__c> liveAgentButtonSettings = new List<Live_Agent_Button__c>();
        Live_Agent_Button__c financeChatLAB = new Live_Agent_Button__c();
        financeChatLAB.Name = 'Finances_Live_Chat';
        financeChatLAB.Org_Id__c = '00D2D000000DhIo';
        financeChatLAB.Chat_Deployment__c = '5720W000001UJD8';
        financeChatLAB.Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat';
        financeChatLAB.Chat_Button_Id__c = '5730W000001YVMU';
        financeChatLAB.Display_Name__c = 'Finances';
        liveAgentButtonSettings.add(financeChatLAB);

        Live_Agent_Button__c studentServicesChatLAB = new Live_Agent_Button__c();
        studentServicesChatLAB.Name = 'ASU_Services_Live_Chat';
        studentServicesChatLAB.Org_Id__c = '00D2D000000DhIo';
        studentServicesChatLAB.Chat_Deployment__c = '5720W000001UJD8';
        studentServicesChatLAB.Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat';
        studentServicesChatLAB.Chat_Button_Id__c = '5730W000001YVMR';
        studentServicesChatLAB.Display_Name__c = 'ASU Services';
        liveAgentButtonSettings.add(studentServicesChatLAB);

        Live_Agent_Button__c technicalSupportChatLAB = new Live_Agent_Button__c();
        technicalSupportChatLAB.Name = 'Technical_Support_Live_Chat';
        technicalSupportChatLAB.Org_Id__c = '00D2D000000DhIo';
        technicalSupportChatLAB.Chat_Deployment__c = '5720W000001UJD8';
        technicalSupportChatLAB.Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat';
        technicalSupportChatLAB.Chat_Button_Id__c = '5730W000001YVMW';
        technicalSupportChatLAB.Display_Name__c = 'Technical Support';
        liveAgentButtonSettings.add(technicalSupportChatLAB);
        insert liveAgentButtonSettings;
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
        Datetime now = System.now();
        Service_Center_Maintenance__c scm = new Service_Center_Maintenance__c(
            Name = 'The Test Message',
            Displayed__c = true,
            Message__c = 'There is maintenance',
            Start_Time__c = now.addDays(-20),
            End_Time__c = now.addDays(20)
        );
        insert scm;

        loadTestDataWithUserByLastName('User0');

        PageReference myASUHelp = Page.studentSC;
        myASUHelp.getParameters().put('source', 'viewAllCases');
        Test.setCurrentPage(myASUHelp);

        Test.startTest();

        System.runAs(testUser) {
            helpTab = new MyASUHelpController();
            vcc = new ViewCaseController();

            helpTab.oppList = oppListForTestUser;
            vcc.oppList = oppListForTestUser;
            helpTab.getMyCasesBox();

            helpTab.stopViewAsUrl = 'www.giphy.com/search/shrek-is-love';
            vcc.stopViewAsUrl = 'www.giphy.com/search/shrek-is-love';
            helpTab.viewAsUrl = 'www.hankhillgifs.com';
            vcc.viewAsUrl = 'www.hankhillgifs.com';

            helpTab.getSource();
            vcc.getSource();

            Boolean found = false;
            for (CustomAlert c : helpTab.alertHandler.alerts) {
                if (c.message == 'There is maintenance') {
                    found = true;
                    break;
                }
            }
            System.assert(found, 'Did not add proper maintenance message');
            System.assertEquals(false, helpTab.getHelpBox());
            System.assertEquals(true, helpTab.getNormalPhone());
            System.assertEquals(false, helpTab.getRoverPhone());

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

            helpTab = new MyASUHelpController();
            helpTab.oppList = oppListForTestUser;
            vcc.oppList = oppListForTestUser;
            helpTab.oppList = oppListForTestUser;

            vacc.getMyCases();
            vacc.getAllClosedCases();
            vacc.getSource();
            vacc.viewCase();

            vacc.viewingAs = true;
            vacc.getMyCases();
            vacc.getAllClosedCases();
            vacc.getSource();
            vacc.viewCase();

            helpTab.stopViewAsUrl = 'www.giphy.com/search/shrek-is-love';
            helpTab.viewAsUrl = 'www.hankhillgifs.com';
            helpTab.getmyCasesBox();
            System.assertEquals(false, helpTab.getHelpBox());
            System.assertEquals(false, vcc.getHelpBox());
            Boolean found = false;
            for (CustomAlert c : helpTab.alertHandler.alerts) {
                if (c.message == 'There is maintenance forever') {
                    found = true;
                    break;
                }
            }
            System.assert(found, 'Did not add proper maintenance message');
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
            helpTab = new MyASUHelpController();
            vcc = new ViewCaseController();

            helpTab.oppList = oppListForTestUser;
            vcc.oppList = oppListForTestUser;
            helpTab.oppList = oppListForTestUser;

            System.assertEquals(true, helpTab.getmyCasesBox());
            System.assertEquals(true, helpTab.getHelpBox());
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
            helpTab = new MyASUHelpController();

            helpTab.oppList = oppListForTestUser;

            System.assertEquals(true, helpTab.getMyCasesBox());
            System.assertEquals(true, helpTab.getHelpBox());
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
            helpTab = new MyASUHelpController();
            System.assertEquals(true, helpTab.getHelpBox());

            helpTab.oppList = oppListForTestUser;

            System.assertEquals(true, helpTab.getMyCasesBox());
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
            helpTab = new MyASUHelpController();
            helpTab.newCase.Subject = 'Test Subject for SC';
            helpTab.newCase.Description = 'Test Desc';

            PageReference submit = helpTab.submitCase();
            System.assertEquals(submit.getURL().contains('/viewcase?'), true);

            helpTab.getClosedCases();
            helpTab.viewCase();
            helpTab.getMyCases();
            helpTab.getMyCasesBox();

            helpTab.viewingAs = true;
            helpTab.masqScopeIdCookie = 'testCookie';
            System.assertEquals(helpTab.submitCase().getURL().contains('masqScopeIdCookie=testCookie'), true);
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
            helpTab = new MyASUHelpController();
            helpTab.suggestAnArticle.Description = 'Description';
            submit = ApexPages.currentPage();
            submit.getParameters().put('Suggest', 'yes');

            Test.startTest();
            urlReturnedFromSubmit = helpTab.suggestAnArticleSubmit().getURL();
            Test.stopTest();
        }

        System.assertEquals('/viewAllArticles', helpTab.getViewAllArticlesLink());
        System.assertEquals(submit.getURL(), urlReturnedFromSubmit);
        System.assertEquals('Description', helpTab.suggestAnArticle.Description);
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
            helpTab = new MyASUHelpController();
            helpTab.viewingAs = true;
            PageReference stop = ApexPages.currentPage();

            System.assertEquals(stop.getURL(), helpTab.suggestAnArticleSubmit().getURL());
        }

        Test.stopTest();
    }

    @isTest
    private static void fetchCaseDetailsWithoutMyASUHelpViewAsService() {
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
    private static void fetchCaseDetailsWithMyASUHelpViewAsService() {
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
        Boolean successMessageFound = false;
        for (CustomAlert alert : vcc.alertHandler.alerts) {
            if (alert.message.contains('Your response was submitted successfully')) {
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
        Boolean failureMessageFound = false;
        for (CustomAlert alert : vcc.alertHandler.alerts) {
            if (alert.message.contains('Your response was not submitted successfully')) {
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

    @isTest
    private static void testCheckForFunctionalGroup() {
        Test.setCurrentPage(Page.StudentSC);
        loadTestUserByLastName('User0');
        Pagereference pr;

        System.runAs(testUser) {
            Test.startTest();
            pr = ApexPages.currentPage();
            pr.getParameters().put('category', 'finance');
            helpTab = new MyASUHelpController();
            System.assertEquals('Financial Aid', helpTab.functionalGroup);
            pr.getParameters().put('category', 'technical');
            helpTab = new MyASUHelpController();
            System.assertEquals('%Technical Resources%', helpTab.functionalGroup);
            pr.getParameters().put('category', 'housing');
            helpTab = new MyASUHelpController();
            System.assertEquals('Housing', helpTab.functionalGroup);
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetArticlesAndLinks() {
        Test.setCurrentPage(Page.StudentSC);
        loadTestUserByLastName('User0');

        System.runAs(testUser) {
            Test.startTest();
            helpTab = new MyASUHelpController();
            System.assertEquals(0, helptab.getAllFinancialArticles().size());
            System.assertEquals(0, helptab.getTopThreeFinancialArticles().size());
            System.assertEquals(0, helptab.getAllTechnicalArticles().size());
            System.assertEquals(0, helptab.getTopThreeTechnicalArticles().size());
            System.assertEquals(0, helptab.getAllHousingArticles().size());
            System.assertEquals(0, helptab.getTopThreeHousingArticles().size());
            System.assertNotEquals(null, helptab.getViewAllFinancialArticlesLink());
            System.assertNotEquals(null, helptab.getViewAllTechnicalArticlesLink());
            System.assertNotEquals(null, helptab.getViewAllHousingArticlesLink());

            Test.stopTest();
        }
    }
}
