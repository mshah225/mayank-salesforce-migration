@isTest
private class AllPublishedArticlesControllerTest {
    @testSetup
    private static void createArticles() {
        KnowledgeArticleFactory.FAQKnowledgeArticle faq = new KnowledgeArticleFactory.FAQKnowledgeArticle();
        List<FAQ__kav> faqList = faq.create(1);
        insert faqList;

        FAQ__kav insertedTestFaq = [
            SELECT Title, PublishStatus, KnowledgeArticleId
            FROM FAQ__kav
            WHERE ID = :faqList[0].Id
        ];
        KbManagement.PublishingService.publishArticle(insertedTestFaq.KnowledgeArticleId, true);
    }

    @isTest
    private static void numberOfListsInMap() {
        PageReference pageRef = Page.AllPublishedArticles;
        Test.setCurrentPage(pageRef);
        AllPublishedArticlesController controller = new AllPublishedArticlesController();
        List<AllPublishedArticlesController.KnowledgeArticleWrapper> completeListOfArticles = controller.completeListOfArticles;

        System.assertEquals(1, completeListOfArticles.size());

        String expectedURL = 'https://asu.secure.force.com/kb/articles/FAQ/FAQURL0';
        System.assertEquals(expectedURL, completeListOfArticles[0].url);
    }
}
