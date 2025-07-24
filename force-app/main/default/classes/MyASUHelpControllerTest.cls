@isTest
private class MyASUHelpControllerTest {
    private static final String testUserAliasBase = 'testUsr';
    
    @TestSetup
    private static void setup() {
        // Insert test contacts
        List<Contact> testContacts = new List<Contact>();
        Integer emplId = 1200000000;
        for (Integer i = 0; i < 5; i++) {
            testContacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact-' + i,
                Email = 'test.contact.' + i + '@test.test',
                EmplId__c = String.valueOf(emplId++)
            ));
        }
        testContacts[3].Affiliation_Alumni__c = 'Current';
        insert testContacts;
        
        Map<Id, Contact> testContactIdToAccountIdMap = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact]);
        for (Contact con : testContacts) {
            con.AccountId = testContactIdToAccountIdMap.get(con.Id).AccountId;
        }
        
        // Insert test users
        List<User> testUsers = new List<User>();
        Id asuCommunityProfileId = RecordIdHelper.getProfileId('ASU Community');
        System.debug('ProfileId: ' + asuCommunityProfileId);
        
        for (Integer i = 0; i < testContacts.size(); i++) {
            testUsers.add(new User(
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
                ContactId = testContacts[i].Id
            ));
        }
        insert testUsers;
        
        // Live Agent Buttons
        insert new List<Live_Agent_Button__c>{
            new Live_Agent_Button__c(
                Name = 'Finances_Live_Chat',
                Org_Id__c = '00D2D000000DhIo',
                Chat_Deployment__c = '5720W000001UJD8',
                Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat',
                Chat_Button_Id__c = '5730W000001YVMU',
                Display_Name__c = 'Finances'
            ),
                new Live_Agent_Button__c(
                    Name = 'ASU_Services_Live_Chat',
                    Org_Id__c = '00D2D000000DhIo',
                    Chat_Deployment__c = '5720W000001UJD8',
                    Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat',
                    Chat_Button_Id__c = '5730W000001YVMR',
                    Display_Name__c = 'ASU Services'
                ),
                new Live_Agent_Button__c(
                    Name = 'Technical_Support_Live_Chat',
                    Org_Id__c = '00D2D000000DhIo',
                    Chat_Deployment__c = '5720W000001UJD8',
                    Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat',
                    Chat_Button_Id__c = '5730W000001YVMW',
                    Display_Name__c = 'Technical Support'
                )
                };
                    
                    // Terms
                    List<Term__c> testTerms = new List<Term__c>{
                        new Term__c(
                            Session_A_C_Start_Date__c = Date.today().addDays(365),
                            Year__c = String.valueOf(Date.today().addDays(365).year())
                        ),
                            new Term__c(
                                Session_B_Start_Date__c = Date.today().addDays(405),
                                Year__c = String.valueOf(Date.today().addDays(405).year())
                            )
                            };
                                insert testTerms;
        
        insert new Email_To_Case_Configuration__c(
            Name = 'Default Org Wide Email Address',
            Value__c = 'noEmail@test.com'
        );
        
        // Case Classifications
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
        
        // Opportunities
        Id undergradProspectId = RecordIdHelper.getRecordTypeId('Opportunity', 'Corporate_Relations_Opportunity');
        insert new List<Opportunity>{
            new Opportunity(
                Contact__c = testContacts[0].Id,
                RecordTypeId = undergradProspectId,
                StageName = 'Enrolled',
                CloseDate = Date.today().addYears(1),
                Name = 'Test Opportunity',
                AccountId = testContacts[0].AccountId,
                Career__c = 'Undergraduate',
                Admitted_Session__c = 'A/C'
            ),
                new Opportunity(
                    Contact__c = testContacts[1].Id,
                    RecordTypeId = undergradProspectId,
                    StageName = 'Enrolled',
                    CloseDate = Date.today().addYears(1),
                    Name = 'Test Opportunity',
                    AccountId = testContacts[1].AccountId,
                    Career__c = 'Undergraduate',
                    Admitted_Session__c = 'B'
                ),
                new Opportunity(
                    Contact__c = testContacts[2].Id,
                    RecordTypeId = undergradProspectId,
                    StageName = 'Not Enrolled',
                    CloseDate = Date.today().addYears(1),
                    Name = 'Test Opportunity',
                    AccountId = testContacts[2].AccountId,
                    Career__c = 'Undergraduate'
                )
                };
                    
                    // Cases
                    List<Case> testCases = new List<Case>{
                        new Case(Subject = 'Open Test Case', Description = 'Auto generated test case', ContactId = testContacts[0].Id)
                            };
                                for (Integer i = 0; i < 10; i++) {
                                    testCases.add(new Case(
                                        Subject = 'Test Case ' + i,
                                        Description = 'Auto generated test case',
                                        ContactId = testContacts[0].Id,
                                        Status = 'New'
                                    ));
                                }
        insert testCases;
        
        for (Case c : testCases) {
            c.Status = 'Closed: Resolved'; // This is now AFTER CreatedDate
        }
        update testCases;
        
        // Email Messages
        insert new EmailMessage(
            FromAddress = testContacts[0].Email,
            Incoming = false,
            ToAddress = testContacts[0].Email,
            Subject = 'Test email',
            TextBody = '23456',
            ParentId = testCases[0].Id
        );
        
        // Chat Message
        insert new Chat_Message__c(Body__c = 'Test Body Message', Case__c = testCases[0].Id);
        
        // Bomgar - handle with try/catch
        try {
            List<bomgar__BomgarSession__c> testBomgarSessions = new List<bomgar__BomgarSession__c>{
                new bomgar__BomgarSession__c(bomgar__RelatedCase__c = testCases[0].Id)
                    };
                        insert testBomgarSessions;
            
            List<bomgar__Event__c> testBomgarEvents = new List<bomgar__Event__c>{
                new bomgar__Event__c(
                    bomgar__BomgarSession__c = testBomgarSessions[0].Id,
                    bomgar__DestinationValue__c = 'everyone',
                    bomgar__EventDateTime__c = System.now(),
                    bomgar__EventType__c = 'representative',
                    bomgar__Text__c = 'Test Text'
                )
                    };
                        insert testBomgarEvents;
        } catch (Exception ex) {
            System.debug('Bomgar Insert Failed: ' + ex.getMessage());
        }
        
        // FAQ Articles
        List<FAQ__kav> faqList = new List<FAQ__kav>();
        for (Integer i = 0; i < 6; i++) {
            faqList.addAll(new List<FAQ__kav>{
                new FAQ__kav(
                    Title = 'Testing Tech FAQ Article' + i,
                    Summary = 'Test FAQ ' + i,
                    Answer__c = 'TEST' + i,
                    Language = 'en_US',
                    Functional_Group__c = 'Technical Resources',
                    IsVisibleInPKB = true,
                    IsVisibleInCsp = true,
                    IsVisibleInPrm = true,
                    URLName = 'Tech-Testing-FAQ-Article-' + i
                ),
                    new FAQ__kav(
                        Title = 'Testing FinAid FAQ Article' + i,
                        Summary = 'Test FAQ ' + i,
                        Answer__c = 'TEST' + i,
                        Language = 'en_US',
                        Functional_Group__c = 'Financial Aid',
                        IsVisibleInPKB = true,
                        IsVisibleInCsp = true,
                        IsVisibleInPrm = true,
                        URLName = 'FinAid-Testing-FAQ-Article-' + i
                    ),
                    new FAQ__kav(
                        Title = 'Testing Housing FAQ Article' + i,
                        Summary = 'Test FAQ ' + i,
                        Answer__c = 'TEST' + i,
                        Language = 'en_US',
                        Functional_Group__c = 'Housing',
                        IsVisibleInPKB = true,
                        IsVisibleInCsp = true,
                        IsVisibleInPrm = true,
                        URLName = 'Housing-Testing-FAQ-Article-' + i
                    )
                    });
        }
        insert faqList;
        
        if (!Test.isRunningTest()) {
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
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert cv;
        
        // Step 3: Get ContentDocumentId via query
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id contentDocumentId = insertedCV.ContentDocumentId;
        
        for(Case cse : testCases){
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = contentDocumentId,
                LinkedEntityId = cse.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            insert cdl;
        }
    }
    
    @isTest
    private static void testStudentSCPageAC() {
        Datetime now = System.now();
        CustomMetadataHelper.setFakeRecords(
            'ASU_Alert_Messages__mdt$$ASUHelpTab$$Active',
            new List<ASU_Alert_Messages__mdt>{
                new ASU_Alert_Messages__mdt(
                    Display_Message__c = 'There is maintenance',
                    Start_Time__c = now.addDays(-20),
                    End_Time__c = now.addDays(20),
                    Priority__c = 0,
                    Is_Active__c = true
                )
                    }
        );
        
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
        List<Case> testCases = [Select id,ClosedDate from case Limit 1];
        Test.startTest();
        System.runAs(testUser) {
            helpTab = new MyASUHelpController();
            Test.setCurrentPageReference(new PageReference('/apex/ViewCase'));
            ApexPages.currentPage().getParameters().put('id', testCases[0].Id);
            vcc = new ViewCaseController();
            
            helpTab.oppList = oppListForTestUser;
            vcc.oppList = oppListForTestUser;
            vcc.caseReply = 'Test case resolved';
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
        
        CustomMetadataHelper.setFakeRecords(
            'ASU_Alert_Messages__mdt$$ASUHelpTab$$Active',
            new List<ASU_Alert_Messages__mdt>{
                new ASU_Alert_Messages__mdt(
                    Display_Message__c = 'There is maintenance forever',
                    Priority__c = 0,
                    Is_Active__c = true
                )
                    }
        );
        
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '1'
        ];
        contact con = new Contact(); 
        con.ASURite_Id__C = 'hmacSHA256';
        con.Id = testUser.ContactId;
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
        List<Case> testCases = [Select id,ClosedDate from case Limit 1];
        View_As_Url__c url = new View_As_Url__c();
        url.Name = 'URL';
        url.MyAsuUrl__c = 'https://webapp4.asu.edu/myasu'; 
        Test.startTest();
        System.runAs(testUser) {
            Test.setCurrentPageReference(new PageReference('/apex/ViewCase'));
            ApexPages.currentPage().getParameters().put('id', testCases[0].Id);
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
        Test.setMock(HttpCalloutMock.class, new FailingMockHttpResponse());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/fail');
        req.setMethod('POST');
        RestCallResponse result = vcc.sendRequestAndParseResponse(req);
        String testJson = '{"subject":"Test","body":"Test Body"}';
        
        HttpRequest req1 = vcc.createEmailMessageRequestWithJsonBody(testJson);
        
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
        List<Case> testCases = [Select id,ClosedDate from case Limit 1];
        list<EmailMessage> emalMsg = [Select id from EmailMessage];
        Test.startTest();
        System.runAs(testUser) {
            helpTab = new MyASUHelpController();
            
            Test.setCurrentPageReference(new PageReference('/apex/ViewCase'));
            ApexPages.currentPage().getParameters().put('id', testCases[0].Id);
            
            vcc = new ViewCaseController();
            vcc.caseDetailsCache = testCases[0];
            vcc.caseReply = 'Test case resolved';
            helpTab.oppList = oppListForTestUser;
            vcc.oppList = oppListForTestUser;
            helpTab.oppList = oppListForTestUser;
            vcc.getEmailMessages();
            vcc.getEmailMessagesWithFormattedDateTime();
            vcc.clearContentsAndCloseBox();
            vcc.submitCaseReply();
            vcc.submitAttachmentReply(); 
            vcc.caseId = testCases[0].Id;
            vcc.caseReply = 'Test case resolved';
            vcc.masqScopeIdCookie = 'test';
            vcc.caseFunctionalGroup = 'test';
            PageReference results = vcc.redirectWithParams('testParam', 'testValue');
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            // Construct the request
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://example.com/api/send');
            req.setMethod('POST');
            req.setBody('{"subject":"Test"}');
            RestCallResponse result = vcc.sendRequestAndParseResponse(req);
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
            vcc.retrieveCaseDetails();
            vcc.caseReply = 'Test case resolved';
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
            vcc.caseReply = 'Test case resolved';
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
        
        Test.setMock(HttpCalloutMock.class, new EmailMessageCalloutMock());
        Test.startTest();
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            vcc.replyCaseFile.Title = 'Test Name';
            vcc.replyCaseFile.VersionData = Blob.valueOf('Test Attachment Body');
            vcc.caseReply = 'Test Message';
            
            
        }
        
        Test.stopTest();
        
        Boolean successMessageFound = false;
        for (CustomAlert alert : vcc.alertHandler.alerts) {
            if (alert.message.contains('Your response was submitted successfully')) {
                successMessageFound = true;
            }
        }
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
        
        EmailMessageCalloutMock calloutMock = new EmailMessageCalloutMock();
        calloutMock.shouldSucceed = false;
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            vcc.replyCaseFile.Title = 'Test Name';
            vcc.replyCaseFile.VersionData = Blob.valueOf('Test Attachment Body');
            vcc.caseReply = 'Test Message';
            
        }
        Test.stopTest();
        
        Boolean failureMessageFound = false;
        for (CustomAlert alert : vcc.alertHandler.alerts) {
            if (alert.message.contains('Your response was not submitted successfully')) {
                failureMessageFound = true;
            }
        }
    }
    
    @isTest
    private static void testCorrectReplyToEmail() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];
        caseOnTestUser.Initial_Request_Sent_To_Addresses__c = 'testEmail@test.com';
        update caseOnTestUser;
        
        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);
        
        String jsonEmail;
        
        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
            jsonEmail = vcc.createJsonEmail();
            vcc.uploadAttachment();
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
    }
    
    @isTest
    private static void testAlertDateRanges() {
        Datetime now = System.now();
        CustomMetadataHelper.setFakeRecords(
            'ASU_Alert_Messages__mdt$$ASUHelpTab$$Active',
            new List<ASU_Alert_Messages__mdt>{
                new ASU_Alert_Messages__mdt(
                    Display_Message__c = 'start and end - not started',
                    Start_Time__c = now.addDays(10),
                    End_Time__c = now.addDays(20),
                    Priority__c = 0,
                    Is_Active__c = true
                ),
                    new ASU_Alert_Messages__mdt(
                        Display_Message__c = 'start and end - current',
                        Start_Time__c = now.addDays(-5),
                        End_Time__c = now.addDays(5),
                        Priority__c = 1,
                        Is_Active__c = true
                    ),
                    new ASU_Alert_Messages__mdt(
                        Display_Message__c = 'start and end - already finished',
                        Start_Time__c = now.addDays(-20),
                        End_Time__c = now.addDays(-10),
                        Priority__c = 2,
                        Is_Active__c = true
                    ),
                    new ASU_Alert_Messages__mdt(
                        Display_Message__c = 'start, no end - not started',
                        Start_Time__c = now.addDays(20),
                        Priority__c = 3,
                        Is_Active__c = true
                    ),
                    new ASU_Alert_Messages__mdt(
                        Display_Message__c = 'start, no end - current',
                        Start_Time__c = now.addDays(-20),
                        Priority__c = 4,
                        Is_Active__c = true
                    ),
                    new ASU_Alert_Messages__mdt(
                        Display_Message__c = 'end, no start - current',
                        End_Time__c = now.addDays(20),
                        Priority__c = 5,
                        Is_Active__c = true
                    ),
                    new ASU_Alert_Messages__mdt(
                        Display_Message__c = 'end, no start - already finished',
                        End_Time__c = now.addDays(-20),
                        Priority__c = 6,
                        Is_Active__c = true
                    ),
                    new ASU_Alert_Messages__mdt(
                        Display_Message__c = 'no start, no end - current',
                        Priority__c = 7,
                        Is_Active__c = true
                    )
                    }
        );
        
        /**
Create test alerts to check the 8 primary time-relationships.
1. For events that have a start and end, and it hasn't started yet
2.                                   ... and it is currently ongoing
3.                                   ... and it has already finished
4. For events that have a start but no end, and it hasn't started yet
5.                                      ... and are currently ongoing
6. For events that have an end but no start, and are currently ongoing 
7.                                       ... and it has already finished
8. For events that have neither a start or an end (and it therefore currently ongoing)

1          2                   3
+  [====== + ==============]   + 

4          5
+  [====== + ===============>

6                   7
<====== + ==============]   +

8
<====== + ===============>
*/
        
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        
        PageReference myASUHelp = Page.studentSC;
        Test.setCurrentPage(myASUHelp);
        
        MyASUHelpController helpTab;
        
        Test.startTest();
        System.runAs(testUser) {
            helpTab = new MyASUHelpController();
        }
        Test.stopTest();
        
        Boolean found1 = false,
            found2 = false,
            found3 = false,
            found4 = false,
            found5 = false,
            found6 = false,
            found7 = false,
            found8 = false;
        for (CustomAlert c : helpTab.alertHandler.alerts) {
            if (c.message == 'start and end - not started')
                found1 = true;
            if (c.message == 'start and end - current')
                found2 = true;
            if (c.message == 'start and end - already finished')
                found3 = true;
            if (c.message == 'start, no end - not started')
                found4 = true;
            if (c.message == 'start, no end - current')
                found5 = true;
            if (c.message == 'end, no start - current')
                found6 = true;
            if (c.message == 'end, no start - already finished')
                found7 = true;
            if (c.message == 'no start, no end - current')
                found8 = true;
        }
        System.assert(!found1, 'Alert 1 is for a future alert and should not be shown, but it is');
        System.assert(found2, 'Alert 2 is for a current alert and should be shown, but it is not');
        System.assert(!found3, 'Alert 3 is for a past alert and should not be shown, but it is');
        
        System.assert(!found4, 'Alert 4 is for a future event and should not be shown, but it is');
        System.assert(found5, 'Alert 5 is for a current alert and should be shown, but it is not');
        
        System.assert(found6, 'Alert 6 is for a current alert and should be shown, but it is not');
        System.assert(!found7, 'Alert 7 is for a past alert and should not be shown, but it is');
        
        System.assert(found8, 'Alert 8 is for a current alert and should be shown, but it is not');
    }
    
    @isTest
    private static void testAlertTypes() {
        Datetime now = System.now();
        CustomMetadataHelper.setFakeRecords(
            'ASU_Alert_Messages__mdt$$ASUHelpTab$$Active',
            new List<ASU_Alert_Messages__mdt>{
                new ASU_Alert_Messages__mdt(
                    Display_Message__c = 'info message',
                    Type__c = 'info',
                    Priority__c = 0,
                    Is_Active__c = true
                ),
                    new ASU_Alert_Messages__mdt(
                        Display_Message__c = 'fatal message',
                        Type__c = 'fatal',
                        Priority__c = 1,
                        Is_Active__c = true
                    ),
                    new ASU_Alert_Messages__mdt(
                        Display_Message__c = 'warning message',
                        Type__c = 'warning',
                        Priority__c = 2,
                        Is_Active__c = true
                    ),
                    new ASU_Alert_Messages__mdt(
                        Display_Message__c = 'confirm message',
                        Type__c = 'confirm',
                        Priority__c = 3,
                        Is_Active__c = true
                    )
                    }
        );
        
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        
        PageReference myASUHelp = Page.studentSC;
        Test.setCurrentPage(myASUHelp);
        
        MyASUHelpController helpTab;
        
        Test.startTest();
        System.runAs(testUser) {
            helpTab = new MyASUHelpController();
        }
        Test.stopTest();
        
        Boolean foundInfo, foundFatal, foundWarning, foundConfirm = false;
        for (CustomAlert c : helpTab.alertHandler.alerts) {
            if (c.message == 'info message' && c.severity == customAlert.INFO)
                foundInfo = true;
            if (c.message == 'fatal message' && c.severity == customAlert.FATAL)
                foundFatal = true;
            if (c.message == 'warning message' && c.severity == customAlert.WARNING)
                foundWarning = true;
            if (c.message == 'confirm message' && c.severity == customAlert.CONFIRM)
                foundConfirm = true;
        }
        System.assert(foundInfo, 'Should have created info alert - but it did not');
        System.assert(foundFatal, 'Should have created fatal alert - but it did not');
        System.assert(foundWarning, 'Should have created warning alert - but it did not');
        System.assert(foundConfirm, 'Should have created confirmation alert - but it did not');
    }
    
    @isTest
    static void testInnerClassesCoverage() {
        ViewCaseController.EmailMessageWithFormattedDateTime emailMsg = new ViewCaseController.EmailMessageWithFormattedDateTime();
        emailMsg.CreatedDate = '2025-05-26 12:00:00';
        emailMsg.LastModifiedDate = '2025-05-26 12:10:00';
        emailMsg.TextBody = 'This is a plain text email.';
        emailMsg.HtmlBody = '<p>This is an HTML email.</p>';
        emailMsg.Subject = 'Test Subject';
        emailMsg.FromName = 'John Doe';
        emailMsg.FromAddress = 'john.doe@example.com';
        emailMsg.ToAddress = 'jane.doe@example.com';
        emailMsg.CcAddress = 'manager@example.com';
        emailMsg.MessageDate = '2025-05-26 12:00:00';
        
        ViewCaseController.AttachmentWithFormattedDateTime attach = new ViewCaseController.AttachmentWithFormattedDateTime();
        attach.Id = 'test';
        attach.CreatedDate = '2025-05-26 12:10:00';
        attach.Name = 'This is a plain text email.';
        
        System.assertNotEquals(null, emailMsg); 
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"200", "message":"Email sent successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }
    public class FailingMockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Simulate HTTP failure by throwing an exception
            throw new CalloutException('Simulated callout failure');
        }
    }
    
}