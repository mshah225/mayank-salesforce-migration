@isTest
private class AllPublishedArticlesControllerTest {
    @testSetup
    private static void createArticles() {
        FAQ__kav article = new FAQ__kav(
            Title = 'Test Article',
            Summary = 'Testing From Apex',
            Answer__c = 'This is a Test',
            URLName = 'FAQURL0',
            IsVisibleInPkb = true
        );
        insert article;

        article = [
            SELECT Title, PublishStatus, KnowledgeArticleId
            FROM FAQ__kav
            WHERE ID = :article.Id
        ];
        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);
    }

    @isTest
    private static void numberOfListsInMap() {
        PageReference pageRef = Page.AllPublishedArticles;
        Test.setCurrentPage(pageRef);
        AllPublishedArticlesController controller = new AllPublishedArticlesController();
        List<AllPublishedArticlesController.KnowledgeArticleWrapper> completeListOfArticles = controller.completeListOfArticles;

        System.assertEquals(1, completeListOfArticles.size());

        Id knowledgeBaseSiteId = [SELECT Id FROM Site WHERE Name = 'kb']?.Id;
        String expectedURL =
            (knowledgeBaseSiteId != null
                ? [SELECT SecureUrl FROM SiteDetail WHERE DurableId = :knowledgeBaseSiteId]?.SecureUrl + '/articles/'
                : '/') + 'FAQ/FAQURL0';

        System.assertEquals(expectedURL, completeListOfArticles[0].url);
    }
}
