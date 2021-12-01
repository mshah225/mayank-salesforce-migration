@isTest
private class MyASUHelpPaginationControllerTest {
    @TestSetup
    private static void setup() {
        List<FAQ__kav> faqArticles = new List<FAQ__kav>();
        for (Integer i = 0; i < 30; i++) {
            FAQ__kav faqArticle = new FAQ__kav(
                Title = 'Testing FAQ Article' + i,
                Summary = 'Test FAQ From Apex' + i,
                Answer__c = 'Test' + i,
                Language = 'en_US',
                IsVisibleInPKB = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                URLName = 'MyASUHelpPaginationController-Test-Article-' + i
            );
            faqArticles.add(faqArticle);
        }
        insert faqArticles;

        List<Id> faqArticleIds = new List<Id>();
        for (FAQ__kav faqArticle : faqArticles) {
            faqArticleIds.add(faqArticle.Id);
        }

        // Publish all test articles
        for (FAQ__kav faqArticle : [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id IN :faqArticleIds]) {
            KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);
        }
    }

    @isTest
    private static void testAutofillSearchText() {
        List<KnowledgeArticleVersion> allKAVs = [SELECT Id FROM KnowledgeArticleVersion];
        List<Id> fixedResultIds = new List<Id>();
        for (KnowledgeArticleVersion kav : allKAVs) {
            fixedResultIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fixedResultIds);
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Test');

        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        Test.stopTest();

        System.assertEquals('Test', vf.textToSearch);
        System.assertEquals(1, vf.getCurrentPageNumber());
        System.assertEquals(30, vf.numberOfResults);
    }

    @isTest
    private static void testNextPrevPage() {
        List<KnowledgeArticleVersion> allKAVs = [SELECT Id FROM KnowledgeArticleVersion];
        List<Id> fixedResultIds = new List<Id>();
        for (KnowledgeArticleVersion kav : allKAVs) {
            fixedResultIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fixedResultIds);
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Test');

        Decimal pageNum1, pageNum2, pageNum3, pageNum4, pageNum5, pageNum6;
        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        pageNum1 = vf.getCurrentPageNumber();
        vf.next();
        pageNum2 = vf.getCurrentPageNumber();
        vf.next();
        pageNum3 = vf.getCurrentPageNumber();
        vf.next();
        pageNum4 = vf.getCurrentPageNumber();
        vf.next();
        pageNum5 = vf.getCurrentPageNumber();
        vf.previous();
        pageNum6 = vf.getCurrentPageNumber();
        Test.stopTest();

        System.assertEquals(10, vf.getPageSize(), 'These tests expect the page size to be 10');
        System.assertEquals(3, vf.lastPage, '30 results / 10 per page means we should have 3 pages');
        System.assertEquals(1, pageNum1);
        System.assertEquals(2, pageNum2);
        System.assertEquals(3, pageNum3);
        System.assertEquals(4, pageNum4);
        System.assertEquals(4, pageNum5);
        System.assertEquals(3, pageNum6);
    }

    @isTest
    private static void testWhenOnlyOnePage() {
        List<KnowledgeArticleVersion> allKAVs = [SELECT Id FROM KnowledgeArticleVersion LIMIT 5];
        List<Id> fixedResultIds = new List<Id>();
        for (KnowledgeArticleVersion kav : allKAVs) {
            fixedResultIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fixedResultIds);
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Test');

        Boolean actualOnFirstPage, actualOnLastPage;
        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        actualOnFirstPage = vf.getOnFirstPage();
        actualOnLastPage = vf.getOnLastPage();
        Test.stopTest();

        System.assertEquals(true, actualOnFirstPage);
        System.assertEquals(true, actualOnLastPage);
    }

    @isTest
    private static void testNoSearchTerm() {
        List<KnowledgeArticleVersion> allKAVs = [SELECT Id FROM KnowledgeArticleVersion];
        List<Id> fixedResultIds = new List<Id>();
        for (KnowledgeArticleVersion kav : allKAVs) {
            fixedResultIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fixedResultIds);
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', '');

        Boolean actualOnFirstPage, actualOnLastPage;
        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        actualOnFirstPage = vf.getOnFirstPage();
        actualOnLastPage = vf.getOnLastPage();
        Test.stopTest();

        System.assertEquals('', vf.textToSearch);
        System.assertEquals(true, actualOnFirstPage);
        System.assertEquals(true, actualOnLastPage);
    }

    @isTest
    private static void testChangeSearchTerm() {
        List<KnowledgeArticleVersion> allKAVs = [SELECT Id FROM KnowledgeArticleVersion];
        List<Id> fixedResultIds = new List<Id>();
        for (KnowledgeArticleVersion kav : allKAVs) {
            fixedResultIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fixedResultIds);
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Cats');

        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        vf.getCurrentPageNumber();
        vf.textToSearch = 'Test';
        vf.getCurrentPageNumber();
        vf.getForceRecalculatePaginationValues();
        Test.stopTest();

        System.assertEquals('Test', vf.textToSearch);
        System.assertEquals(30, vf.numberOfResults);
    }

    @isTest
    private static void testViewAllResultsRef() {
        List<KnowledgeArticleVersion> allKAVs = [SELECT Id FROM KnowledgeArticleVersion];
        List<Id> fixedResultIds = new List<Id>();
        for (KnowledgeArticleVersion kav : allKAVs) {
            fixedResultIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fixedResultIds);
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Test');

        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        String actualPageRefUrl = vf.viewAllResults().getUrl();
        Test.stopTest();

        System.assertEquals('/viewAllArticles?q=Test', actualPageRefUrl);
    }

    @isTest
    private static void testMyASUHelpControllerConstructor() {
        // Need buttons for MyASUHelpController constructor
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
        // Need contact for MyASUHelpController constructor
        Contact testContact = new Contact(FirstName = 'John', LastName = 'McTesterson');
        insert testContact;
        // New user for MyASUHelpController constructor
        User testUser = new User(
            FirstName = 'John',
            LastName = 'McTesterson',
            Username = 'John.McTesterson@test.test',
            Email = 'John.McTesterson@test.test',
            Alias = 'testUsr',
            CommunityNickname = 'testUsr',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ContactId = testContact.Id,
            ProfileId = RecordIdHelper.getProfileId('ASU Community')
        );
        insert testUser;
        // Need terms for MyASUHelpController constructor
        Date dTac = System.today().adddays(365);
        Date dTb = System.today().adddays(405);
        Term__c termAC = new Term__c(
            Session_A_C_Start_Date__c = date.newinstance(dTac.year(), dTac.month(), dTac.day()),
            Year__c = String.valueOf(dTac.year())
        );
        Term__c termB = new Term__c(
            Session_B_Start_Date__c = date.newinstance(dTb.year(), dTb.month(), dTb.day()),
            Year__c = String.valueOf(dTb.year())
        );
        insert new List<Term__c>{ termAC, termB };

        List<KnowledgeArticleVersion> allKAVs = [SELECT Id FROM KnowledgeArticleVersion];
        List<Id> fixedResultIds = new List<Id>();
        for (KnowledgeArticleVersion kav : allKAVs) {
            fixedResultIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fixedResultIds);
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Test');

        MyASUHelpPaginationController vf;
        System.runAs(testUser) {
            Test.startTest();
            vf = new MyASUHelpPaginationController(new MyASUHelpController());
            Test.stopTest();
        }

        System.assertEquals('Test', vf.textToSearch);
        System.assertEquals(1, vf.getCurrentPageNumber());
        System.assertEquals(30, vf.numberOfResults);
    }
}
