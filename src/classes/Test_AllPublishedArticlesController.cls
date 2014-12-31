@isTest(SeeAllData=true)
public class Test_AllPublishedArticlesController {

	public static testMethod void Test_AllPublishedArticlesController() {      
       PageReference pageRef = Page.AllPublishedArticles;
       Test.setCurrentPage(pageRef);
       AllPublishedArticlesController controller = new AllPublishedArticlesController();
       Map<String, String> articleMap = controller.getArticleMap();
	}
}