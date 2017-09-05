@isTest(SeeAllData=true)
public class Test_AllPublishedArticlesController {

	public static testMethod void Test_AllPublishedArticlesController() {      
       PageReference pageRef = Page.AllPublishedArticles;
       Test.setCurrentPage(pageRef);
       AllPublishedArticlesController controller = new AllPublishedArticlesController();
       List<Map<String,String>> lstArticleMap = controller.getArticleMap();
       List<KnowledgeArticleVersion> lstFAQKav = [SELECT Id,Title, UrlName, KnowledgeArticleId, PublishStatus, language 
                                   FROM KnowledgeArticleVersion 
                                   WHERE PublishStatus='Online'
                                   AND language ='en_US'
                                   AND IsVisibleInPkb = true];
       Integer noOfListsInArticleMap=(lstFAQKav.size()/1000)+1;
       System.assertEquals(noOfListsInArticleMap,lstArticleMap.size());
	}
}