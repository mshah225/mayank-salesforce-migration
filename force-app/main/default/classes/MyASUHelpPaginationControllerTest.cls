@isTest
private class MyASUHelpPaginationControllerTest {
    /**
     * Helper method to publish articles
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
            faqArticles.add(new FAQ__kav(
                Title = 'Testing FAQ Article' + i,
                Summary = 'Test FAQ From Apex' + i,
                Answer__c = 'Test' + i,
                Language = 'en_US',
                IsVisibleInPKB = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                URLName = 'MyASUHelpPaginationController-Test-Article-' + i
            ));
        }
        insert faqArticles;
    
        List<Id> faqArticleIds = new List<Id>();
        for (FAQ__kav faq : faqArticles) {
            faqArticleIds.add(faq.Id);
        }
    
        publishArticles(faqArticleIds);
    }


    /**
     * Sets fixed search results based on published FAQ__kav records
     */
    private static void setFixedSearchResults() {
        List<FAQ__kav> published = [SELECT Id FROM FAQ__kav WHERE PublishStatus = 'Online'];
        List<Id> ids = new List<Id>();
        for (FAQ__kav article : published) {
            ids.add(article.Id);
        }
        Test.setFixedSearchResults(ids);
    }

    @isTest private static void testAutofillSearchText() {
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

    @isTest private static void testNextPrevPage() {
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

        System.assertEquals(10, vf.pageSize);
        System.assertEquals(3, vf.lastPage);
        System.assertEquals(1, pageNum1);
        System.assertEquals(2, pageNum2);
        System.assertEquals(3, pageNum3);
        System.assertEquals(3, pageNum4);
        System.assertEquals(2, pageNum5);
    }

    @isTest private static void testWhenOnlyOnePage() {
        MyASUHelpPaginationController.isTestMode = true;
        List<FAQ__kav> fewArticles = [SELECT Id FROM FAQ__kav WHERE PublishStatus = 'Online' LIMIT 5];
        List<Id> fewIds = new List<Id>();
        for (FAQ__kav kav : fewArticles) {
            fewIds.add(kav.Id);
        }
        Test.setFixedSearchResults(fewIds);
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Test');

        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        Test.stopTest();

        System.assert(vf.onFirstPage);
        System.assert(vf.onLastPage);
    }

    @isTest private static void testNoSearchTerm() {
        MyASUHelpPaginationController.isTestMode = true;
        setFixedSearchResults();
        Test.setCurrentPage(Page.viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', '');

        Test.startTest();
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();
        Test.stopTest();

        System.assertEquals('', vf.textToSearch);
        System.assert(vf.onFirstPage);
        System.assert(vf.onLastPage);
    }

    @isTest private static void testChangeSearchTerm() {
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

    @isTest private static void testViewAllResultsRef() {
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

    @isTest private static void testMyASUHelpControllerConstructor() {
        MyASUHelpPaginationController.isTestMode = true;

        Contact testContact = new Contact(FirstName = 'John', LastName = 'McTesterson');
        insert testContact;

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

        Date dTac = System.today().addDays(365);
        Date dTb = System.today().addDays(405);
        insert new List<Term__c>{
            new Term__c(Session_A_C_Start_Date__c = dTac, Year__c = String.valueOf(dTac.year())),
            new Term__c(Session_B_Start_Date__c = dTb, Year__c = String.valueOf(dTb.year()))
        };

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