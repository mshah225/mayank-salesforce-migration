@IsTest
private class MyASUHelpPaginationControllerTest {
    @testSetup
    static void setUp() {
        for (Integer i = 0; i < 30; i++) {
            FAQ__kav faqArticle = new FAQ__kav(
                Title = 'Testing FAQ Article' + i,
                Summary = 'Test FAQ From Apex' + i,
                Answer__c = 'TEST' + i,
                Language = 'en_US',
                IsVisibleInPKB = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                URLName = 'MyASUHelpPaginationController-Test-Article-' + i
            );
            insert faqArticle;

            // Publish the FAQ Articles
            faqArticle = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :faqArticle.id];

            KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);
        }
    }

    @isTest
    static void testViewAllArticlesPage() {
        PageReference viewAllArticles = Page.viewAllArticles;
        Test.setCurrentPage(viewAllArticles);
        ApexPages.currentPage().getParameters().put('q', 'Test');
        MyASUHelpPaginationController vf = new MyASUHelpPaginationController();

        vf.getPageSize();
        vf.next();
        vf.previous();
        vf.getCurrentPageNumber();
        vf.viewAllResults();

        System.assertEquals('Test', vf.textToSearch);
        System.assertEquals(1, vf.getCurrentPageNumber());
    }
}
