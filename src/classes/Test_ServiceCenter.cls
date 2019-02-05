@isTest
private class Test_ServiceCenter {
    private static ServiceCenter sc;
    private static ViewCaseController vcc;
    private static ViewAllCasesController vacc;
    private static SCMyCasesBoxController scMyCaseBox;
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

        UserFactory.DefaultUser userFactory = new UserFactory.DefaultUser();
        List<User> testUserList = userFactory.create(4);

        Profile asuCommunity = [SELECT Id FROM Profile WHERE Name = 'ASU Community'];
        for (Integer i = 0; i < testUserList.size(); i++)
        {
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
        Contact testContEnrolledA = [
            SELECT Id, AccountId, Email
            FROM Contact
            WHERE LastName = 'Contact0'
        ];
        
        User userAsCaseOwner = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE LastName = 'User0'
        ];

        Opportunity testOppEnrolledA =
            OpportunityService.createTestUndergraduateProspect(testContEnrolledA);
        testOppEnrolledA.StageName = 'Enrolled';
        testOppEnrolledA.Career__c = 'Undergraduate';
        testOppEnrolledA.Admitted_Session__c = 'A/C';
        insert testOppEnrolledA;

        List<Case> openCases = CaseService.createTestCases(1, testContEnrolledA);
        openCases[0].OwnerId = userAsCaseOwner.Id;
        insert openCases;
        
        EmailMessage emailOnCase = new EmailMessage(FromAddress = 'test0@test.com', Incoming = False, 
                                        ToAddress= testContEnrolledA.Email, Subject = 'Test email', TextBody = '23456 ', ParentId = openCases[0].Id);
        
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
        Contact testContEnrolledB = [
            SELECT Id, AccountId
            FROM Contact
            WHERE LastName = 'Contact1'
        ];

        Opportunity testOppEnrolledB =
            OpportunityService.createTestUndergraduateProspect(testContEnrolledB);
        testOppEnrolledB.StageName = 'Enrolled';
        testOppEnrolledB.Career__c = 'Undergraduate';
        testOppEnrolledB.Admitted_Session__c = 'B';
        insert testOppEnrolledB;
    }

    private static void setUpNonEnrolled() {
        Contact testNotEnrolled = [
            SELECT Id, AccountId
            FROM Contact
            WHERE LastName = 'Contact2'
        ];

        Opportunity testOppNotEnrolled =
            OpportunityService.createTestUndergraduateProspect(testNotEnrolled);
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
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c, Contact.Self_Service_PIN__c
            FROM User
            WHERE LastName = :lastName
        ];
    }
    private static void loadContactForTestUser() {
        List<Contact> contactListForTestUser = [
            SELECT Id, Self_Service_PIN__c
            FROM Contact
            WHERE Id = :testUser.ContactId
        ];
        if (!contactListForTestUser.isEmpty())
            contactRelatedToTestUser = contactListForTestUser[0];
    }
    
    private static void loadCaseOnTestUser() {
        List<Case> caseListForTestUser = [
            SELECT Id,OwnerId
            FROM Case
            WHERE ContactId = :testUser.ContactId
            LIMIT 1
        ];
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
        
        PageReference serviceCenter = Page.studentSC;
        serviceCenter.getParameters().put('source', 'viewAllCases');
        Test.setCurrentPage(serviceCenter);

        Test.startTest();

        System.runAs(testUser){
            sc = new ServiceCenter();
            vcc = new viewCaseController();
            scMyCaseBox=new SCMyCasesBoxController();

            sc.oppList = oppListForTestUser;
            vcc.oppList = oppListForTestUser;
            scMyCaseBox.getMyCasesBox();

            sc.stopViewAsUrl = 'www.giphy.com/search/shrek-is-love';
            vcc.stopViewAsUrl = 'www.giphy.com/search/shrek-is-love';
            sc.viewAsUrl = 'www.hankhillgifs.com';
            vcc.viewAsUrl = 'www.hankhillgifs.com';

            sc.getMyPin();
            sc.getSource();
           
            vcc.getMyPin();
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
        PageReference serviceCenter = Page.studentSC;
        serviceCenter.getParameters().put('source', 'viewAllCases');
        Test.setCurrentPage(serviceCenter);

        Test.startTest();

        System.runAs(testUser) {
            vacc = new ViewAllCasesController();
            vcc = new viewCaseController();

            vacc.stopViewAsUrl = 'www.giphy.com/search/shrek-is-love';
            vacc.viewAsUrl = 'www.hankhillgifs.com';

            scMyCaseBox = new SCMyCasesBoxController();
            sc = new ServiceCenter();
            sc.oppList = oppListForTestUser;
            vcc.oppList = oppListForTestUser;
            scMyCaseBox.oppList = oppListForTestUser;

            vacc.getMyCases();
            vacc.getAllClosedCases();
            vacc.getSource();
            vacc.viewCase();

            vacc.viewingAs = true;
            vacc.getMyCases();
            vacc.getAllClosedCases();
            vacc.getSource();
            vacc.viewCase();

            scMyCaseBox.stopViewAsUrl = 'www.giphy.com/search/shrek-is-love';
            scMyCaseBox.viewAsUrl = 'www.hankhillgifs.com';
            scMyCaseBox.getmyCasesBox();
            System.assertEquals(false, sc.getHelpBox());
            System.assertEquals(false, vcc.getHelpBox());
            System.assertEquals('There is maintenance forever', sc.getmMessage());
        }
        Test.stopTest();
    }

    @isTest 
    private static void testStudentSCNotEnrolled() {
        loadTestDataWithUserByLastName('User2');

        PageReference serviceCenter = Page.studentSC;
        serviceCenter.getParameters().put('source', 'viewAllCases');
        Test.setCurrentPage(serviceCenter);

        Test.startTest();

        System.runAs(testUser){
            sc = new ServiceCenter();
            vcc = new viewCaseController();
            scMyCaseBox = new SCMyCasesBoxController();

            sc.oppList = oppListForTestUser;
            vcc.oppList = oppListForTestUser;
            scMyCaseBox.oppList = oppListForTestUser;

            System.assertEquals(true, scMyCaseBox.getmyCasesBox());
            System.assertEquals(true, sc.getHelpBox());
            System.assertEquals(true, vcc.getHelpBox());
        }

        Test.stopTest();
    }

    @isTest 
    private static void testStudentSCNoOpp() {
        loadTestDataWithUserByLastName('User3');
        
        Test.startTest();

        PageReference serviceCenter = Page.studentSC;
        Test.setCurrentPage(serviceCenter);

        System.runAs(testUser) {
            sc = new ServiceCenter();
            scMyCaseBox = new SCMyCasesBoxController();

            scMyCaseBox.oppList = oppListForTestUser;

            System.assertEquals(true, scMyCaseBox.getMyCasesBox());
            System.assertEquals(true, sc.getHelpBox());
        }
        Test.stopTest();
    }

    @isTest 
    private static void testStudentSCAlumni() {
        loadTestDataWithUserByLastName('User3');
        
        PageReference serviceCenter = Page.studentSC;
        Test.setCurrentPage(serviceCenter);

        Test.startTest();

        System.runAs(testUser) {
            sc = new ServiceCenter();
            System.assertEquals(true, sc.getHelpBox());
            scMyCaseBox = new SCMyCasesBoxController();

            scMyCaseBox.oppList = oppListForTestUser;

            System.assertEquals(true, scMyCaseBox.getMyCasesBox());
        }

        Test.stopTest();
    }

    @isTest 
    private static void testSubmitCase() {
        loadTestUserByLastName('User0');

        PageReference serviceCenter = Page.studentSC;
        Test.setCurrentPage(serviceCenter);

        Test.startTest();

        System.runAs(testUser){
            scMyCaseBox = new SCMyCasesBoxController();
            scMyCaseBox.newCase.Subject = 'Test Subject for SC';
            scMyCaseBox.newCase.Description = 'Test Desc';

            PageReference submit = scMyCaseBox.submitCase();
            System.debug(submit);
            System.assertEquals(submit.getURL().contains('/viewcase?'),true);

            scMyCaseBox.getClosedCases();
            scMyCaseBox.viewCase();
            scMyCaseBox.getMyCases();
            scMyCaseBox.getMyCasesBox();

            scMyCaseBox.viewingAs = true;
            scMyCaseBox.masqScopeIdCookie = 'testCookie';
            System.assertEquals(scMyCaseBox.submitCase().getURL().contains('masqScopeIdCookie=testCookie'),true);
        }

        Test.stopTest();
    }

    @isTest 
    private static void suggestAnArticleReturnsProperUrl() {
        loadTestUserByLastName('User0');
        PageReference serviceCenter = Page.studentSC;
        Test.setCurrentPage(serviceCenter);
        PageReference submit;
        String urlReturnedFromSubmit;
        
        System.runAs(testUser){
            sc = new ServiceCenter();
            sc.suggestAnArticle.Description = 'Test submitting a suggestion';
            sc.suggestedArticleDescription = 'Description';
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
    private static void testViewAs(){
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
        
        Test.startTest();

        System.runAs(testUser){
            sc = new ServiceCenter();
            sc.viewingAs = true;
            PageReference stop = ApexPages.currentPage();

            System.assertEquals(stop.getURL(), sc.changePin().getURL());
            System.assertEquals(stop.getURL(), sc.suggestAnArticleSubmit().getURL());
        }

        Test.stopTest();
    }
    
    @isTest 
    private static void originalPinSameAsNewPinError() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
        PageReference currentPage;
        String urlAfterPinChange;
        
        System.runAs(testUser) {   
            vcc = new viewCaseController();
            vcc.newPin = contactRelatedToTestUser.Self_Service_PIN__c;
            currentPage = ApexPages.currentPage();
            currentPage.getParameters().put('PIN', 'error');
            
            Test.startTest();
            urlAfterPinChange = vcc.changePin().getURL();
            Test.stopTest();
        }
        System.assertEquals(currentPage.getURL(), urlAfterpinChange);
    }
       
    
    @isTest 
    private static void repeatingDigitsError() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
        PageReference currentPage;
        String urlAfterPinChange;
        
        System.runAs(testUser) {   
            vcc = new viewCaseController();
            vcc.newPin = 111111;
            
            Test.startTest();
            urlAfterPinChange = vcc.changePin().getURL();
            Test.stopTest();
            
            currentPage = ApexPages.currentPage();
            currentPage.getParameters().put('PIN', 'error');
        }
        System.assertEquals(currentPage.getURL(), urlAfterPinChange);
    }
    
     @isTest 
     private static void testViewCasePinSuccess() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
       
        String urlAfterPinChange;
        System.runAs(testUser) { 
            vcc = new viewCaseController();
            vcc.newPin = 574838;
            
            Test.startTest();
            urlAfterPinChange = vcc.changepin().getURL();
            Test.stopTest();
        }
        
        PageReference submitPage = ApexPages.currentPage();
        submitPage.getParameters().put('PIN', 'success');
        
        Contact retrieveContact = [Select Id, Self_Service_PIN__c, PIN_Lockout__c FROM Contact WHERE Id = :vcc.UserContact.Id];
        
        System.assertEquals(submitPage.getURL(), urlAfterPinChange);
        System.assertEquals(retrieveContact.Self_service_PIN__c, vcc.newPin);
        System.assertEquals(retrieveContact.PIN_Lockout__c, false);
    }
    
    @isTest 
    private static void fetchCaseDetailsWithoutMyASUViewAs() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
        
        Case checkCase;
        
        Test.startTest();
        System.runAs(testUser) {
            vcc = new viewCaseController();
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
            vcc = new viewCaseController();
            vcc.viewingAs = true;
            checkCase = vcc.getCaseDetails();
            
        }
        Test.stopTest();
        System.assertEquals(checkCase.Id, caseOnTestUser.Id);
    }
    
    @isTest 
    private static void testSCExceptionCases(){
        loadTestDataWithUserByLastName('User0');

        System.runAs(testUser){
            sc = new ServiceCenter();
            sc.newPin = testUser.Contact.Self_Service_PIN__c + 1;
            sc.UserContact.LastName = null;
            Test.startTest();
            sc.changePin();
            Test.stopTest();
        }
        
        List<Case> lstCase = [Select Id, Subject, Description from Case where Origin__c = 'Error Logger'];
        System.assertEquals(1, lstCase.size());
    }
    
    @isTest
    private static void fetchEmailMessagesWithoutMyASUViewAs() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
        
        Test.startTest();
        System.runAs(testUser) {
            vcc = new viewCaseController();
            vcc.getEmailMessages();
        }
        Test.stopTest();
        EmailMessage emailMsgWithParentId = [SELECT Id, ParentId FROM EmailMessage WHERE ParentId = :caseOnTestUser.Id];
        System.assertEquals(emailMsgWithParentId.ParentId, caseOnTestUser.Id);
    }
    
    @isTest
    private static void fetchEmailMessagesWithMyASUViewAs() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
        
        Test.startTest();
        System.runAs(testUser) {
            vcc = new viewCaseController();
            vcc.viewingAs = true;
            vcc.getEmailMessages();
        }
        Test.stopTest();
        EmailMessage emailMsgWithParentId = [SELECT Id, ParentId FROM EmailMessage WHERE ParentId = :caseOnTestUser.Id];
        System.assertEquals(emailMsgWithParentId.ParentId, caseOnTestUser.Id);
    }
    
    @isTest
    private static void fetchChatMessages() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
        
        List<bomgar__Event__c> fetchedBomgarEvent;
        Test.startTest();
        System.runAs(testUser) {
            vcc = new viewCaseController();
            fetchedBomgarEvent = vcc.getChatMessages();
        }
        Test.stopTest();
        List<bomgar__Event__c> bomgarForAssert = [SELECT Id, bomgar__BomgarSession__r.bomgar__relatedcase__c from bomgar__Event__c LIMIT 1];
        System.assertEquals(bomgarForAssert[0].bomgar__BomgarSession__r.bomgar__relatedcase__c, caseOnTestUser.Id);
    }
    
    @isTest
    private static void testDisplayReplyBox() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
        
        Test.startTest();
        System.runAs(testUser) {
            vcc = new viewCaseController();
            vcc.showReplyBox = false;
            vcc.showReplyButton = true;
            vcc.displayReplyBox();
        }
        Test.stopTest();
        System.assertEquals(vcc.showReplyBox, true);
        System.assertEquals(vcc.showReplyButton, false);
    }
    
    @isTest
    private static void testCancelFunctionality() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
        
        Test.startTest();
        System.runAs(testUser) {
            vcc = new viewCaseController();
            vcc.showReplyBox = true;
            vcc.caseReply = 'Test Reply';
            vcc.showReplyButton = false;
            vcc.clearContentsAndCloseBox();
        }
        Test.stopTest();
        System.assertEquals(vcc.showReplyBox, false);
        System.assertEquals(vcc.caseReply.length(), 0);
        System.assertEquals(vcc.showReplyButton, true);
    }
    
    @isTest 
    private static void testRestCalloutSuccess(){
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
        
        System.runAs(testUser) {
            vcc = new viewCaseController();
            Test.setMock(HttpCalloutMock.class, new EmailMessageSuccessMock());
            vcc.replyCaseAttachment.Name = 'Test Name';
            vcc.replyCaseAttachment.Body = Blob.valueOf('Test Attachment Body');
            vcc.caseReply = 'Test Message';
            
            Test.startTest();
            vcc.submitReply();  
            Test.stopTest();
        }
        System.assertEquals(vcc.caseReply, 'Test Message');
    }
    
    @isTest 
    private static void testRestCalloutFailure() {
        loadTestDataWithUserByLastName('User0');
        setCurrentPageAsViewCase();
        
        System.runAs(testUser) {
            vcc = new viewCaseController();
            Test.setMock(HttpCalloutMock.class, new EmailMessageFailureMock());
            vcc.replyCaseAttachment.Name = 'Test Name';
            vcc.replyCaseAttachment.Body = Blob.valueOf('Test Attachment Body');
            vcc.caseReply = 'Test Message';
            
            Test.startTest();
            vcc.submitReply();  
            Test.stopTest();
        }
        System.assertEquals(vcc.caseReply, 'Test Message');
    }
    
    @isTest 
    private static void testCorrectReplyToEmail() {
        loadTestDataWithUserByLastName('User0');
        caseOnTestUser.Intended_Recipient__c = 'testEmail@test.com';
        update caseOnTestUser;
        setCurrentPageAsViewCase();
        String jsonEmail;
        System.runAs(testUser) {
            vcc = new viewCaseController();
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
        Email_To_Case_Configuration__c defaultEmail = new Email_To_Case_Configuration__c(Name = 'Default Org Wide Email Address', Value__c = 'noEmail@test.com');
        insert defaultEmail;
        String jsonEmail;
        System.runAs(testUser) {
            vcc = new viewCaseController();
            Test.startTest();
            jsonEmail = vcc.createJsonEmail();
            Test.stopTest();
        }
        System.assert(jsonEmail.contains('noEmail@test.com')); 
    }
}
