@isTest(seeAllData = true)
private class Test_AKBController {

    static testMethod void testAKBControllerFAQ() {
    	List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND Language = 'en_US' AND ArticleType = 'FAQ__kav' LIMIT 1];
    	PageReference akbPage = Page.akb;
  		Test.setCurrentPage(akbPage);
    	ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
    	Test.startTest();
    	AKBController akb = new AKBController();
    	System.AssertEquals(akb.article.KnowledgeArticleId, articleTest[0].KnowledgeArticleId);
    	Test.stopTest();
    }
    
    static testMethod void testAKBControllerInfo() {
    	List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND Language = 'en_US' AND ArticleType = 'Informational__kav' LIMIT 1];
    	PageReference akbPage = Page.akb;
  		Test.setCurrentPage(akbPage);
    	ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
    	Test.startTest();
    	AKBController akb = new AKBController();
    	System.AssertEquals(akb.article.KnowledgeArticleId, articleTest[0].KnowledgeArticleId);
    	Test.stopTest();
    }
    
    static testMethod void testAKBControllerHowTo() {
    	List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND Language = 'en_US' AND ArticleType = 'How_To__kav' LIMIT 1];
    	PageReference akbPage = Page.akb;
  		Test.setCurrentPage(akbPage);
    	ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
    	Test.startTest();
    	AKBController akb = new AKBController();
    	System.AssertEquals(akb.article.KnowledgeArticleId, articleTest[0].KnowledgeArticleId);
    	Test.stopTest();
    }
}