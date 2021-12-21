@isTest
private class MyASUHelpControllerTest {
    private static final String testUserAliasBase = 'testUsr';

    @TestSetup
    private static void setup() {
        // Insert test contacts
        List<Contact> testContacts = new List<Contact>();
        Integer emplId = 1200000000;
        for (Integer i = 0; i < 5; i++) {
            testContacts.add(
                new Contact(
                    FirstName = 'Test',
                    LastName = 'Contact-' + i,
                    Email = 'test.contact.' + i + '@test.test',
                    EmplId__c = '' + (emplId++)
                )
            );
        }
        testContacts[3].Affiliation_Alumni__c = 'Current';
        insert testContacts;
        // Get AccountIds for each contact
        Map<Id, Contact> testContactIdToAccountIdMap = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact]);
        for (Contact con : testContacts) {
            con.AccountId = testContactIdToAccountIdMap.get(con.Id).AccountId;
        }

        // Insert a community user for each contact
        List<User> testUsers = new List<User>();
        Id asuCommunityProfileId = RecordIdHelper.getProfileId('ASU Community');
        for (Integer i = 0; i < testContacts.size(); i++) {
            Contact testCon = testContacts[i];
            User testUser = new User(
                FirstName = 'Test',
                LastName = 'User-' + i,
                Username = 'test.user.' + i + '@test.test',
                Email = 'test.user.' + i + '@test.test',
                Alias = testUserAliasBase + i,
                CommunityNickname = testUserAliasBase + i,
                TimeZoneSidKey = 'America/Phoenix',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                ProfileId = asuCommunityProfileId,
                LanguageLocaleKey = 'en_US',
                ContactId = testCon.Id
            );
            testUsers.add(testUser);
        }
        insert testUsers;

        // Insert buttons
        List<Live_Agent_Button__c> liveAgentButtonSettings = new List<Live_Agent_Button__c>();
        liveAgentButtonSettings.add(
            new Live_Agent_Button__c(
                Name = 'Finances_Live_Chat',
                Org_Id__c = '00D2D000000DhIo',
                Chat_Deployment__c = '5720W000001UJD8',
                Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat',
                Chat_Button_Id__c = '5730W000001YVMU',
                Display_Name__c = 'Finances'
            )
        );
        liveAgentButtonSettings.add(
            new Live_Agent_Button__c(
                Name = 'ASU_Services_Live_Chat',
                Org_Id__c = '00D2D000000DhIo',
                Chat_Deployment__c = '5720W000001UJD8',
                Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat',
                Chat_Button_Id__c = '5730W000001YVMR',
                Display_Name__c = 'ASU Services'
            )
        );
        liveAgentButtonSettings.add(
            new Live_Agent_Button__c(
                Name = 'Technical_Support_Live_Chat',
                Org_Id__c = '00D2D000000DhIo',
                Chat_Deployment__c = '5720W000001UJD8',
                Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat',
                Chat_Button_Id__c = '5730W000001YVMW',
                Display_Name__c = 'Technical Support'
            )
        );
        insert liveAgentButtonSettings;

        // Insert terms
        List<Term__c> testTerms = new List<Term__c>();
        Date acTermStart = Date.today().adddays(365);
        testTerms.add(
            new Term__c(
                Session_A_C_Start_Date__c = Date.newinstance(
                    acTermStart.year(),
                    acTermStart.month(),
                    acTermStart.day()
                ),
                Year__c = String.valueOf(acTermStart.year())
            )
        );
        Date bTermStart = Date.today().adddays(405);
        testTerms.add(
            new Term__c(
                Session_B_Start_Date__c = Date.newinstance(bTermStart.year(), bTermStart.month(), bTermStart.day()),
                Year__c = String.valueOf(bTermStart.year())
            )
        );
        insert testTerms;

        // Insert a configuration
        Email_To_Case_Configuration__c defaultEmail = new Email_To_Case_Configuration__c(
            Name = 'Default Org Wide Email Address',
            Value__c = 'noEmail@test.com'
        );
        insert defaultEmail;

        // Insert case classifications for cases
        Case_Classification__c testFuncGrp = new Case_Classification__c(
            Name = 'Student Success Innovations',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group'),
            Active__c = true,
            Visible__c = true
        );
        insert testFuncGrp;
        Case_Classification__c testCategory = new Case_Classification__c(
            Name = 'Knowledge',
            Parent__c = testFuncGrp.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Category'),
            Active__c = true,
            Visible__c = true
        );
        insert testCategory;
        Case_Classification__c testSubCategory = new Case_Classification__c(
            Name = 'Test',
            Parent__c = testCategory.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category'),
            Active__c = true,
            Visible__c = true
        );
        insert testSubCategory;

        // Opporunities for contacts in some terms
        List<Opportunity> testOpportunities = new List<Opportunity>();
        Id undergradProspectId = RecordIdHelper.getRecordTypeId('Opportunity', 'Undergraduate_Prospect');
        testOpportunities.add(
            // A/C term opporunity for first contact
            new Opportunity(
                Contact__c = testContacts[0].Id,
                RecordTypeId = undergradProspectId,
                StageName = 'Enrolled',
                CloseDate = System.today().addYears(1),
                Name = 'Test Opportunity',
                AccountId = testContacts[0].AccountId,
                Career__c = 'Undergraduate',
                Admitted_Session__c = 'A/C'
            )
        );
        testOpportunities.add(
            // B term opporunity for second contact
            new Opportunity(
                Contact__c = testContacts[1].Id,
                RecordTypeId = undergradProspectId,
                StageName = 'Enrolled',
                CloseDate = System.today().addYears(1),
                Name = 'Test Opportunity',
                AccountId = testContacts[1].AccountId,
                Career__c = 'Undergraduate',
                Admitted_Session__c = 'B'
            )
        );
        testOpportunities.add(
            // No term opporunity for third contact
            new Opportunity(
                Contact__c = testContacts[2].Id,
                RecordTypeId = undergradProspectId,
                StageName = 'Not Enrolled',
                CloseDate = System.today().addYears(1),
                Name = 'Test Opportunity',
                AccountId = testContacts[2].AccountId,
                Career__c = 'Undergraduate'
            )
        );
        insert testOpportunities;

        // Insert cases for first contact
        List<Case> testCases = new List<Case>();
        testCases.add(
            new Case(
                Subject = 'Open Test Case',
                Description = 'Auto generated test case',
                ContactId = testContacts[0].Id
            )
        );
        for (Integer i = 0; i < 10; i++) {
            testCases.add(
                new Case(
                    Subject = 'Test Case ' + i,
                    Description = 'Auto generated test case',
                    ContactId = testContacts[0].Id,
                    Status = 'Closed: Resolved'
                )
            );
        }
        insert testCases;

        // Insert email messages for the first case
        List<EmailMessage> testEmailMessages = new List<EmailMessage>();
        testEmailMessages.add(
            new EmailMessage(
                FromAddress = 'test0@test.com',
                Incoming = false,
                ToAddress = testContacts[0].Email,
                Subject = 'Test email',
                TextBody = '23456 ',
                ParentId = testCases[0].Id
            )
        );
        insert testEmailMessages;

        // Insert chat message for the first case
        insert new Chat_Message__c(Body__c = 'Test Body Message', Case__c = testCases[0].Id);

        // Insert bomgar details
        List<bomgar__BomgarSession__c> testBomgarSessions = new List<bomgar__BomgarSession__c>();
        testBomgarSessions.add(new bomgar__BomgarSession__c(bomgar__RelatedCase__c = testCases[0].Id));
        insert testBomgarSessions;

        List<bomgar__Event__c> testBomgarEvents = new List<bomgar__Event__c>();
        testBomgarEvents.add(
            new bomgar__Event__c(
                bomgar__BomgarSession__c = testBomgarSessions[0].Id,
                bomgar__DestinationValue__c = 'everyone',
                bomgar__EventDateTime__c = System.now(),
                bomgar__EventType__c = 'representative',
                bomgar__Text__c = 'Test Text'
            )
        );
        insert testBomgarEvents;

        List<FAQ__kav> faqList = new List<FAQ__kav>();
        // Add FAQ articles
        for (Integer i = 0; i < 6; i++) {
            FAQ__kav techFaqArticle = new FAQ__kav(
                Title = 'Testing Tech FAQ Article' + i,
                Summary = 'Test FAQ ' + i,
                Answer__c = 'TEST' + i,
                Language = 'en_US',
                Functional_Group__c = 'Technical Resources',
                IsVisibleInPKB = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                URLName = 'Tech-Testing-FAQ-Article-' + i
            );
            faqList.add(techFaqArticle);

            FAQ__kav finAidFaqArticle = new FAQ__kav(
                Title = 'Testing FinAid FAQ Article' + i,
                Summary = 'Test FAQ ' + i,
                Answer__c = 'TEST' + i,
                Language = 'en_US',
                Functional_Group__c = 'Financial Aid',
                IsVisibleInPKB = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                URLName = 'FinAid-Testing-FAQ-Article-' + i
            );
            faqList.add(finAidFaqArticle);

            FAQ__kav housingFaqArticle = new FAQ__kav(
                Title = 'Testing Housing FAQ Article' + i,
                Summary = 'Test FAQ ' + i,
                Answer__c = 'TEST' + i,
                Language = 'en_US',
                Functional_Group__c = 'Housing',
                IsVisibleInPKB = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                URLName = 'Housing-Testing-FAQ-Article-' + i
            );
            faqList.add(housingFaqArticle);
        }
        insert faqList;
        // And publish all the FAQ articles
        List<Id> faqListIds = new List<Id>();
        for (FAQ__kav faqArticle : faqList) {
            faqListIds.add(faqArticle.Id);
        }
        List<FAQ__kav> faqListWithKnowledgeArticleIds = [
            SELECT Id, KnowledgeArticleId
            FROM FAQ__kav
            WHERE Id IN :faqListIds
        ];
        for (FAQ__kav faqArticle : faqListWithKnowledgeArticleIds) {
            KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);
        }
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

        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];
        List<Opportunity> oppListForTestUser = [
            SELECT Career__c, Term__c, StageName, Admitted_Session__c
            FROM Opportunity
            WHERE Contact__c = :testUser.ContactId
        ];

        PageReference myASUHelp = Page.studentSC;
        myASUHelp.getParameters().put('source', 'viewAllCases');
        Test.setCurrentPage(myASUHelp);

        MyASUHelpController helpTab;
        ViewCaseController vcc;

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
        }
        Test.stopTest();

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

    @isTest
    private static void testStudentSCPageB() {
        Service_Center_Maintenance__c scm = new Service_Center_Maintenance__c(
            Name = 'The Test Message',
            Displayed__c = true,
            Message__c = 'There is maintenance forever'
        );
        insert scm;

        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '1'
        ];
        List<Opportunity> oppListForTestUser = [
            SELECT Career__c, Term__c, StageName, Admitted_Session__c
            FROM Opportunity
            WHERE Contact__c = :testUser.ContactId
        ];

        PageReference myASUHelp = Page.studentSC;
        myASUHelp.getParameters().put('source', 'viewAllCases');
        Test.setCurrentPage(myASUHelp);

        ViewAllCasesController vacc;
        ViewCaseController vcc;
        MyASUHelpController helpTab;

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
        }
        Test.stopTest();

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

    @isTest
    private static void testStudentSCNotEnrolled() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '2'
        ];
        List<Opportunity> oppListForTestUser = [
            SELECT Career__c, Term__c, StageName, Admitted_Session__c
            FROM Opportunity
            WHERE Contact__c = :testUser.ContactId
        ];

        PageReference myASUHelp = Page.studentSC;
        myASUHelp.getParameters().put('source', 'viewAllCases');
        Test.setCurrentPage(myASUHelp);

        ViewCaseController vcc;
        MyASUHelpController helpTab;

        Test.startTest();
        System.runAs(testUser) {
            helpTab = new MyASUHelpController();
            vcc = new ViewCaseController();

            helpTab.oppList = oppListForTestUser;
            vcc.oppList = oppListForTestUser;
            helpTab.oppList = oppListForTestUser;
        }
        Test.stopTest();

        System.assertEquals(true, helpTab.getmyCasesBox());
        System.assertEquals(true, helpTab.getHelpBox());
        System.assertEquals(true, vcc.getHelpBox());
    }

    @isTest
    private static void testStudentSCNoOpp() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '3'
        ];
        List<Opportunity> oppListForTestUser = [
            SELECT Career__c, Term__c, StageName, Admitted_Session__c
            FROM Opportunity
            WHERE Contact__c = :testUser.ContactId
        ];

        PageReference myASUHelp = Page.studentSC;
        Test.setCurrentPage(myASUHelp);

        MyASUHelpController helpTab;

        Test.startTest();
        System.runAs(testUser) {
            helpTab = new MyASUHelpController();

            helpTab.oppList = oppListForTestUser;
        }
        Test.stopTest();

        System.assertEquals(true, helpTab.getMyCasesBox());
        System.assertEquals(true, helpTab.getHelpBox());
    }

    @isTest
    private static void testStudentSCAlumni() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '3'
        ];
        List<Opportunity> oppListForTestUser = [
            SELECT Career__c, Term__c, StageName, Admitted_Session__c
            FROM Opportunity
            WHERE Contact__c = :testUser.ContactId
        ];

        PageReference myASUHelp = Page.studentSC;
        Test.setCurrentPage(myASUHelp);

        MyASUHelpController helpTab;

        Test.startTest();
        System.runAs(testUser) {
            helpTab = new MyASUHelpController();
            helpTab.oppList = oppListForTestUser;
        }
        Test.stopTest();

        System.assertEquals(true, helpTab.getHelpBox());
        System.assertEquals(true, helpTab.getMyCasesBox());
    }

    @isTest
    private static void testSubmitCase() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :'testUsr0'
        ];

        PageReference myASUHelp = Page.studentSC;
        Test.setCurrentPage(myASUHelp);

        MyASUHelpController helpTab;
        PageReference submit;

        Test.startTest();
        System.runAs(testUser) {
            helpTab = new MyASUHelpController();
            helpTab.newCase.Subject = 'Test Subject for SC';
            helpTab.newCase.Description = 'Test Desc';

            submit = helpTab.submitCase();

            helpTab.getClosedCases();
            helpTab.viewCase();
            helpTab.getMyCases();
            helpTab.getMyCasesBox();

            helpTab.viewingAs = true;
            helpTab.masqScopeIdCookie = 'testCookie';
        }
        Test.stopTest();

        System.assertEquals(submit.getURL().contains('/viewcase?'), true);
        System.assertEquals(helpTab.submitCase().getURL().contains('masqScopeIdCookie=testCookie'), true);
    }

    @isTest
    private static void suggestAnArticleReturnsProperUrl() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :'testUsr0'
        ];

        PageReference myASUHelp = Page.studentSC;
        Test.setCurrentPage(myASUHelp);
        PageReference submit;

        String urlReturnedFromSubmit;
        MyASUHelpController helpTab;

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

    @isTest
    private static void testViewAs() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];

        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);

        MyASUHelpController helpTab;
        PageReference stop;

        Test.startTest();
        System.runAs(testUser) {
            helpTab = new MyASUHelpController();
            helpTab.viewingAs = true;
            stop = ApexPages.currentPage();
        }
        Test.stopTest();

        System.assertEquals(stop.getURL(), helpTab.suggestAnArticleSubmit().getURL());
    }

    @isTest
    private static void fetchCaseDetailsWithoutMyASUHelpViewAsService() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];

        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);

        Case checkCase;

        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
            checkCase = vcc.getCaseDetails();

            vcc.viewingAs = true;
            vcc.getCaseDetails();
        }
        Test.stopTest();

        System.assertEquals(checkCase.Id, caseOnTestUser.Id);
    }

    @isTest
    private static void fetchCaseDetailsWithMyASUHelpViewAsService() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];

        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);

        Case checkCase;

        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
            vcc.viewingAs = true;
            checkCase = vcc.getCaseDetails();
        }
        Test.stopTest();

        System.assertEquals(checkCase.Id, caseOnTestUser.Id);
    }

    @isTest
    private static void fetchChatMessages() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [
            SELECT Id, OwnerId
            FROM Case
            WHERE ContactId = :testUser.ContactId AND Subject = 'Open Test Case'
            LIMIT 1
        ];

        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);

        List<ChatMessage> fetchedChatMessages;

        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
            fetchedChatMessages = vcc.getChatMessages();
        }
        Test.stopTest();

        System.assertEquals(fetchedChatMessages.size(), 1);
    }

    @isTest
    private static void correctNumberOfChatMessages() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [
            SELECT Id, OwnerId
            FROM Case
            WHERE ContactId = :testUser.ContactId AND Subject = 'Open Test Case'
            LIMIT 1
        ];

        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);

        List<ChatMessage> fetchedChatMessages;

        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
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
                bomgar__BomgarSession__r.bomgar__relatedcase__c = :caseOnTestUser.Id
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
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];

        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);

        ViewCaseController vcc;

        Test.setMock(HttpCalloutMock.class, new EmailMessageSuccessMock());
        Test.startTest();
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            vcc.replyCaseAttachment.Name = 'Test Name';
            vcc.replyCaseAttachment.Body = Blob.valueOf('Test Attachment Body');
            vcc.caseReply = 'Test Message';

            vcc.submitReply();
        }
        Test.stopTest();

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
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];

        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);

        ViewCaseController vcc;

        Test.setMock(HttpCalloutMock.class, new EmailMessageFailureMock());
        Test.startTest();
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            vcc.replyCaseAttachment.Name = 'Test Name';
            vcc.replyCaseAttachment.Body = Blob.valueOf('Test Attachment Body');
            vcc.caseReply = 'Test Message';

            vcc.submitReply();
        }
        Test.stopTest();

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
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];
        caseOnTestUser.Intended_Recipient__c = 'testEmail@test.com';
        update caseOnTestUser;

        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);

        String jsonEmail;

        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
            jsonEmail = vcc.createJsonEmail();
        }
        Test.stopTest();

        System.assert(jsonEmail.contains('testEmail@test.com'));
    }

    @isTest
    private static void testNoIntendedReplyToEmail() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];

        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);

        String jsonEmail;

        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
            jsonEmail = vcc.createJsonEmail();
        }
        Test.stopTest();
        System.assert(jsonEmail.contains('noEmail@test.com'));
    }

    @isTest
    private static void testCheckForFunctionalGroup() {
        Test.setCurrentPage(Page.StudentSC);
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :'testUsr0'
        ];

        Pagereference pr;

        MyASUHelpController helpTabFinance, helpTabTech, helpTabHousing;

        Test.startTest();
        System.runAs(testUser) {
            pr = ApexPages.currentPage();

            pr.getParameters().put('category', 'finance');
            helpTabFinance = new MyASUHelpController();

            pr.getParameters().put('category', 'technical');
            helpTabTech = new MyASUHelpController();

            pr.getParameters().put('category', 'housing');
            helpTabHousing = new MyASUHelpController();
        }
        Test.stopTest();

        System.assertEquals('Financial Aid', helpTabFinance.functionalGroup);
        System.assertEquals('%Technical Resources%', helpTabTech.functionalGroup);
        System.assertEquals('Housing', helpTabHousing.functionalGroup);
    }

    @isTest
    private static void testGetArticlesAndLinks() {
        Test.setCurrentPage(Page.StudentSC);
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :'testUsr0'
        ];

        MyASUHelpController helpTab;

        Test.startTest();
        System.runAs(testUser) {
            helpTab = new MyASUHelpController();
        }
        Test.stopTest();

        System.assertEquals(6, helptab.getAllFinancialArticles().size());
        System.assertEquals(3, helptab.getTopThreeFinancialArticles().size());
        System.assertEquals(6, helptab.getAllTechnicalArticles().size());
        System.assertEquals(3, helptab.getTopThreeTechnicalArticles().size());
        System.assertEquals(6, helptab.getAllHousingArticles().size());
        System.assertEquals(3, helptab.getTopThreeHousingArticles().size());
        System.assertNotEquals(null, helptab.getViewAllFinancialArticlesLink());
        System.assertNotEquals(null, helptab.getViewAllTechnicalArticlesLink());
        System.assertNotEquals(null, helptab.getViewAllHousingArticlesLink());
    }
}
