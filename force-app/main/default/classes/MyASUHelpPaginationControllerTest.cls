@isTest
private class MyASUHelpPaginationControllerTest {
    /**
     * Helper method to publish articles
     * @param articleIds List of article IDs to be published
     */
    private static void publishArticles(List<Id> articleIds) {
        for (FAQ__kav faqArticle : [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id IN :articleIds]) {
            KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);
        }
    }

    /**
     * Test setup method to create and publish test FAQ articles
     */
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
        publishArticles(faqArticleIds);
    }

    /**
     * Set fixed search results for testing
     */
    private static void setFixedSearchResults() {
        List<FAQ__kav> allKAVs = [SELECT Id FROM FAQ__kav WHERE PublishStatus = 'Online'];
        List<Id> fixedResultIds = new List<Id>();
        for (FAQ__kav kav : allKAVs) {
            fixedResultIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fixedResultIds);
    }

    /**
     * Test to verify autofill search text functionality
     */
    @isTest
    private static void testAutofillSearchText() {
        MyASUHelpPaginationController.isTestMode = true;
        setFixedSearchResults();
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Test');

        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        Test.stopTest();

        System.assertEquals('Test', vf.textToSearch);
        System.assertEquals(1, vf.currentPage);
        System.assertEquals(30, vf.resultCount);
    }

    /**
     * Test to verify next and previous page functionality
     */
    @isTest
    private static void testNextPrevPage() {
        MyASUHelpPaginationController.isTestMode = true;
        setFixedSearchResults();
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Test');

        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        Integer pageNum1 = vf.currentPage;
        vf.next();
        Integer pageNum2 = vf.currentPage;
        vf.next();
        Integer pageNum3 = vf.currentPage;
        vf.next();
        Integer pageNum4 = vf.currentPage;
        vf.previous();
        Integer pageNum5 = vf.currentPage;
        Test.stopTest();

        System.assertEquals(10, vf.pageSize, 'These tests expect the page size to be 10');
        System.assertEquals(3, vf.lastPage, '30 results / 10 per page means we should have 3 pages');
        System.assertEquals(1, pageNum1);
        System.assertEquals(2, pageNum2);
        System.assertEquals(3, pageNum3);
        System.assertEquals(3, pageNum4);
        System.assertEquals(2, pageNum5);
    }

    /**
     * Test to verify behavior when only one page of results is present
     */
    @isTest
    private static void testWhenOnlyOnePage() {
        MyASUHelpPaginationController.isTestMode = true;
        List<FAQ__kav> allKAVs = [SELECT Id FROM FAQ__kav WHERE PublishStatus = 'Online' LIMIT 5];
        List<Id> fixedResultIds = new List<Id>();
        for (FAQ__kav kav : allKAVs) {
            fixedResultIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fixedResultIds);
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Test');

        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        Test.stopTest();

        System.assertEquals(true, vf.onFirstPage);
        System.assertEquals(true, vf.onLastPage);
    }

    /**
     * Test to verify behavior when no search term is provided
     */
    @isTest
    private static void testNoSearchTerm() {
        MyASUHelpPaginationController.isTestMode = true;
        setFixedSearchResults();
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', '');

        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        Test.stopTest();

        System.assertEquals('', vf.textToSearch);
        System.assertEquals(true, vf.onFirstPage);
        System.assertEquals(true, vf.onLastPage);
    }

    /**
     * Test to verify behavior when the search term is changed
     */
    @isTest
    private static void testChangeSearchTerm() {
        MyASUHelpPaginationController.isTestMode = true;
        setFixedSearchResults();
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Cats');

        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        vf.textToSearch = 'Test';
        vf.getRefreshPagination();
        Test.stopTest();

        System.assertEquals('Test', vf.textToSearch);
        System.assertEquals(30, vf.resultCount);
    }

    /**
     * Test to verify view all results reference functionality
     */
    @isTest
    private static void testViewAllResultsRef() {
        MyASUHelpPaginationController.isTestMode = true;
        setFixedSearchResults();
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Test');

        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        String actualPageRefUrl = vf.viewAllResults().getUrl();
        Test.stopTest();

        System.assertEquals('/viewAllArticles?q=Test', actualPageRefUrl);
    }

    /**
     * Test to verify MyASUHelpController constructor functionality
     */
    @isTest
    private static void testMyASUHelpControllerConstructor() {
        MyASUHelpPaginationController.isTestMode = true;

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
        Date dTac = System.today().addDays(365);
        Date dTb = System.today().addDays(405);
        Term__c termAC = new Term__c(
            Session_A_C_Start_Date__c = date.newInstance(dTac.year(), dTac.month(), dTac.day()),
            Year__c = String.valueOf(dTac.year())
        );
        Term__c termB = new Term__c(
            Session_B_Start_Date__c = date.newInstance(dTb.year(), dTb.month(), dTb.day()),
            Year__c = String.valueOf(dTb.year())
        );
        insert new List<Term__c>{ termAC, termB };

        setFixedSearchResults();
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Test');

        MyASUHelpPaginationController vf;
        System.runAs(testUser) {
            Test.startTest();
            vf = new MyASUHelpPaginationController(new MyASUHelpController());
            Test.stopTest();
        }

        System.assertEquals('Test', vf.textToSearch);
        System.assertEquals(1, vf.currentPage);
        System.assertEquals(30, vf.resultCount);
    }
}