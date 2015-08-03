@isTest
private class Test_ServiceCenter
{
    private static User testUser;
    private static User testUserAC;
    private static User testUserB;
    private static Contact testContact;
    private static Contact testContactAC;
    private static Contact testContactB;
    private static Opportunity testOpp;
    private static Opportunity testOppAC;
    private static Opportunity testOppB;
    private static Account testAccount;
    private static Account testAccountAC;
    private static Account testAccountB;
    private static Profile p;
    private static AKBController akb;
    private static ServiceCenter sc;

    private static void getProfileAndTerms()
    {
        p = [SELECT Id FROM Profile WHERE Name='ASU Community'];

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
    }

    private static void setUp()
    {
        getProfileAndTerms();

        testContact = ContactService.createTestContact();
        insert testContact;

        testUser = new User();
        testUser.FirstName = 'Jonny';
        testUser.LastName = 'Test';
        testUser.Username = 'username@test.com';
        testUser.Email = 'test@nomail.com';
        testUser.Alias = testContact.ASURite_ID__c;
        testUser.CommunityNickname = 'jontestComm';
        testUser.TimeZoneSidKey = 'America/Phoenix';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.ProfileId = p.Id;
        testuser.ContactId = testContact.Id;
        insert testUser;

        PageReference serviceCenter = Page.studentSC;
        Test.setCurrentPage(serviceCenter);
    }

    private static void setUpOppNotEnrolled()
    {
        getProfileAndTerms();

        testContact = ContactService.createTestContact();
        insert testContact;

        testAccount = new Account();
        testAccount.Contact__c = testContact.Id;
        testAccount.Name = 'Jonny TestNotEnrolled';
        insert testAccount;

        testOpp = new Opportunity();
        testOpp.AccountId = testAccount.Id;
        testOpp.Name = testContact.FirstName + ' ' + testContact.LastName;
        testOpp.CloseDate = System.Today() + 365;
        testOpp.Contact__c = testContact.Id;
        testOpp.StageName = 'Applicant - Incomplete';
        testOpp.Career__c = 'Undergraduate';
        insert testOpp;

        testUser = new User();
        testUser.FirstName = 'JonnyNotEnrolledOpp';
        testUser.LastName = 'Test';
        testUser.Username = 'usernameOpp@test.com';
        testUser.Email = 'test@nomail.com';
        testUser.Alias = testContact.ASURite_ID__c;
        testUser.CommunityNickname = 'jontest1';
        testUser.TimeZoneSidKey = 'America/Phoenix';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.ProfileId = p.Id;
        testUser.ContactId = testContact.Id;
        insert testUser;

        PageReference serviceCenter = Page.studentSC;
        Test.setCurrentPage(serviceCenter);
    }

    private static void setUpACOpp()
    {
        getProfileAndTerms();

        testContactAC = ContactService.createTestContact();
        insert testContactAC;

        testAccountAC = new Account();
        testAccountAC.Contact__c = testContactAC.Id;
        testAccountAC.Name = 'Jonny TestAC';
        insert testAccountAC;

        testOppAC = new Opportunity();
        testOppAC.AccountId = testAccountAC.Id;
        testOppAC.Name = testContactAC.FirstName + ' ' + testContactAC.LastName;
        testOppAC.CloseDate = System.Today() + 365;
        testOppAC.Contact__c = testContactAC.Id;
        testOppAC.StageName = 'Enrolled';
        testOppAC.Career__c = 'Undergraduate';
        testOppAC.Admitted_Session__c = 'A/C';
        insert testOppAC;

        testUserAC = new User();
        testUserAC.FirstName = 'JonnyACOpp';
        testUserAC.LastName = 'Test';
        testUserAC.Username = 'usernameACOpp@test.com';
        testUserAC.Email = 'test@nomail.com';
        testUserAC.Alias = testContactAC.ASURite_Id__c;
        testUserAC.CommunityNickname = 'jontest1';
        testUserAC.TimeZoneSidKey = 'America/Phoenix';
        testUserAC.LocaleSidKey = 'en_US';
        testUserAC.EmailEncodingKey = 'ISO-8859-1';
        testUserAC.LanguageLocaleKey = 'en_US';
        testUserAC.ProfileId = p.Id;
        testUserAC.ContactId = testContactAC.Id;
        insert testUserAC;

        PageReference serviceCenter = Page.studentSC;
        Test.setCurrentPage(serviceCenter);
    }

    private static void setUpBOpp()
    {
        getProfileAndTerms();

        testContactB = ContactService.createTestContact();
        insert testContactB;

        testAccountB = new Account();
        testAccountB.Contact__c = testContactB.Id;
        testAccountB.Name = 'Jonny TestB';
        insert testAccountB;

        testOppB = new Opportunity();
        testOppB.AccountId = testAccountB.Id;
        testOppB.Name = testContactB.FirstName + ' ' + testContactB.LastName;
        testOppB.CloseDate = System.Today() + 365;
        testOppB.Contact__c = testContactB.Id;
        testOppB.StageName = 'Enrolled';
        testOppB.Career__c = 'Undergraduate';
        testOppB.Admitted_Session__c = 'B';
        insert testOppB;

        testUserB = new User();
        testUserB.FirstName = 'JonnyBOpp';
        testUserB.LastName = 'Test';
        testUserB.Username = 'usernameBOpp@test.com';
        testUserB.Email = 'test@nomail.com';
        testUserB.Alias = testContactB.ASURite_ID__c;
        testUserB.CommunityNickname = 'jontest1';
        testUserB.TimeZoneSidKey = 'America/Phoenix';
        testUserB.LocaleSidKey = 'en_US';
        testUserB.EmailEncodingKey = 'ISO-8859-1';
        testUserB.LanguageLocaleKey = 'en_US';
        testUserB.ProfileId = p.Id;
        testUserB.ContactId = testContactB.Id;
        insert testUserB;

        PageReference serviceCenter = Page.studentSC;
        Test.setCurrentPage(serviceCenter);
    }

    @isTest static void submitCaseTest()
    {
        setUp();
        Test.startTest();
        System.runAs(testUser)
        {
            sc = new ServiceCenter();
            Case c = sc.newCase;
            c.ContactId = testUser.Id;
            c.Subject = 'Test case';
            c.Description= 'here\'s my test';
            sc.newCase = c;
            PageReference confirmCaseTest = sc.SubmitCase();
            PageReference confirmCase = new PageReference('/studentSC?Confirm=case');
            sc.SubmitCase();
        }
        Test.stopTest();
    }

    @isTest static void testCases()
    {
        setUp();
        Test.startTest();
        System.runAs(testUser)
        {
            sc = new ServiceCenter();
            Case c = sc.newCase;
            c.Subject = 'Test case';
            c.Description= 'here\'s my test';
            sc.newCase = c;
            sc.SubmitCase();
            sc.getMyCases();
            sc.getClosedCases();
            sc.getMyCases();
            sc.getEmailMessages();
        }
        Test.stopTest();
    }

    @isTest static void testCasesContact()
    {
        setUp();
        System.runAs(testUser)
        {
            sc = new ServiceCenter();
            Case c = sc.newCase;
            c.Subject = 'Test case';
            c.Description= 'here\'s my test';
            c.contact = testContact;
            sc.newCase = c;
            sc.SubmitCase();
            sc.getMyCases();
            sc.getClosedCases();
        }
    }

    @isTest static void getBoxes()
    {
        setUp();
        Test.startTest();
        System.runAs(testUser)
        {
            sc = new ServiceCenter();
            sc.getNormalPhone();
            sc.getRoverPhone();
            sc.getHelpBox();
            sc.getQuestionsBox();
            sc.getMyCasesBox();
        }
        Test.stopTest();
    }

    @isTest static void testPin()
    {
        setUp();
        System.runAs(testUser) {
            sc = new ServiceCenter();
            sc.userContact = testContact;
            sc.getMyPin();
            sc.newPin = 111111;
            sc.changePin();
            sc.newPin = 6758394;
            sc.changePin();
            sc.userContact = null;
        }
    }

    @isTest static void getNotEnrolledOppBoxes()
    {
        setUpOppNotEnrolled();
        System.runAs(testUser)
        {
            sc = new ServiceCenter();
            sc.userContact = testContact;
            sc.oppList.add(testOpp);
            System.Debug('Test user contact getOppBoxes() Not Enrolled: ' + sc.userContact);
            System.Debug('Test user opportunity getOppBoxes() Not Enrolled: ' + sc.oppList);
            sc.getNormalPhone();
            sc.getRoverPhone();
            sc.getHelpBox();
            sc.getQuestionsBox();
            sc.getMyCasesBox();
        }
    }

    @isTest static void getACOppBoxes()
    {
        setUpACOpp();
        System.runAs(testUserAC)
        {
            sc = new ServiceCenter();
            sc.userContact = testContactAC;
            sc.oppList.add(testOppAC);
            System.Debug('Test user contact getACOppBoxes(): ' + sc.userContact);
            System.Debug('Test user opportunity getACOppBoxes(): ' + sc.oppList);
            sc.getNormalPhone();
            sc.getRoverPhone();
            sc.getHelpBox();
            sc.getQuestionsBox();
            sc.getMyCasesBox();
        }
    }

    @isTest static void getBOppBoxes()
    {
        setUpBOpp();
        System.runAs(testUserB)
        {
            sc = new ServiceCenter();
            sc.userContact = testContactB;
            sc.oppList.add(testOppB);
            System.Debug('Test user contact getBOppBoxes(): ' + sc.userContact);
            System.Debug('Test user opportunity getBOppBoxes(): ' + sc.oppList);
            sc.getNormalPhone();
            sc.getRoverPhone();
            sc.getHelpBox();
            sc.getQuestionsBox();
            sc.getMyCasesBox();
        }
    }

    @isTest static void getNoOppBoxes()
    {
        setUpACOpp();
        System.runAs(testUserAC) {
            sc = new ServiceCenter();
            sc.userContact = testContactAC;
            System.Debug('Test user contact getOppBoxes() Not Enrolled: ' + sc.userContact);
            System.Debug('Test user opportunity getOppBoxes() Not Enrolled: ' + sc.oppList);
            sc.getNormalPhone();
            sc.getRoverPhone();
            sc.getHelpBox();
            sc.getQuestionsBox();
            sc.getMyCasesBox();
        }
    }

    @isTest static void testCaseDetails()
    {
        setUp();
        Test.startTest();
        System.runAs(testUser)
        {
            sc = new ServiceCenter();
            Case c = sc.newCase;
            c.Subject = 'Test case';
            c.Description= 'here\'s my test';
            sc.newCase = c;
            sc.SubmitCase();
            System.currentPageReference().getParameters().put('id', c.Id);
            System.AssertNotEquals(null, sc.getCaseDetails());
        }
        Test.stopTest();
    }

    @isTest static void viewCaseTest()
    {
        setUp();
        String source;
        PageReference viewcase = Page.viewcase;
        Test.setCurrentPage(viewcase);
        System.runAs(testUser)
        {
            sc = new ServiceCenter();
            Case c = sc.newCase;
            c.Subject = 'Test case';
            c.Description= 'here\'s my test';
            sc.newCase = c;
            sc.SubmitCase();
            sc.getMyCases();
            sc.caseId = c.Id;
            sc.viewCase();
            source = sc.getSource();
        }

        System.assertEquals(source, 'studentSC');
    }

    @isTest static void viewCaseFromViewAllTest()
    {
        setUp();
        String source;
        PageReference viewcase = Page.viewcase;
        Test.setCurrentPage(viewcase);
        System.runAs(testUser)
        {
            sc = new ServiceCenter();
            Case c = sc.newCase;
            c.Subject = 'Test case';
            c.Description= 'here\'s my test';
            sc.newCase = c;
            sc.SubmitCase();
            sc.getMyCases();
            sc.caseId = c.Id;
            sc.viewCase();
            viewcase.getParameters().put('source', 'viewAllCases');
            source = sc.getSource();
        }

        System.assertEquals(source, 'viewAllCases?source=studentSC');
    }


    @isTest static void testSuggestAnArticle()
    {
        setUp();
        PageReference viewcase = Page.viewcase;
        Test.setCurrentPage(viewcase);
        Id newCaseId;
        System.runAs(testUser)
        {
            sc = new ServiceCenter();
            sc.suggestAnArticle.Description = 'Test Description';
            PageReference page = sc.suggestAnArticleSubmit();
            PageReference expected = new PageReference('/apex/viewcase?Suggest=yes');
            System.AssertEquals(expected.getUrl(), page.getUrl());
            newCaseId = sc.suggestAnArticle.Id;
        }
        Case newCase = [SELECT Subject, Description FROM Case WHERE Id = :newCaseId];
        System.AssertEquals(newCase.Subject, 'Suggest An Article');
        System.AssertEquals(newCase.Description, 'Test Description');
    }
}
