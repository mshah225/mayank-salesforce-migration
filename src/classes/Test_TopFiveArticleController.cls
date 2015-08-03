@isTest(SeeAllData=true)
public with sharing class Test_TopFiveArticleController {
	static {
    // setup test data	
    List<FAQ__kav> faqList = new List<FAQ__kav>();
    for (Integer i=0; i<=4; i++) {
//    	FAQ__kav faq = new FAQ__kav(Title='TestFaq' + i, UrlName = 'TestFaq1' + i, PublishStatus='Online');
    	FAQ__kav faq = new FAQ__kav(Title='TestFaq' + i, UrlName = 'TestFaq1' + i);
    	faqList.add(faq);
    }
    insert faqList;
    
    List<FAQ__DataCategorySelection> faqDCSList = new List<FAQ__DataCategorySelection>();
    for (FAQ__kav faq: faqList) {
    	FAQ__DataCategorySelection faqDCS = new FAQ__DataCategorySelection(ParentId=faq.Id, DataCategoryGroupName='Finances', DataCategoryName='My_ASU_Financial_Aid');
    	faqDCSList.add(faqDCS);
    }
    insert faqDCSList;
    
//    How_To__kav ht1 = new How_To__kav(Title='TestHT1', UrlName = 'TestHT1', PublishStatus='Online');
    How_To__kav ht1 = new How_To__kav(Title='TestHT1', UrlName = 'TestHT1');
    insert ht1;

//    Informational__kav inf1 = new Informational__kav(Title='TestInf1', UrlName = 'TestInf1', PublishStatus='Online');
    Informational__kav inf1 = new Informational__kav(Title='TestInf1', UrlName = 'TestInf1');
    insert inf1;
    
    }
	
	static testMethod void testDoGet() {
  	    
	    RestRequest req = new RestRequest(); 
	    RestResponse res = new RestResponse();
			 
	    // req.requestURI = 'https://cs9.salesforce.com/services/apexrest/v.9/member/me/results/today';  
	    req.requestURI = System.URL.getSalesforceBaseUrl() + '/services/apexrest/TopFiveArticles';
	    req.httpMethod = 'GET';
	    RestContext.request = req;
	    RestContext.response = res;
	 
	    List<TopFiveArticleController.ArticleInfo> getResults = TopFiveArticleController.getTopFiveArticles();
	    List<TopFiveArticleController.ArticleInfo> postResults1 = TopFiveArticleController.getTopFiveArticles2('Classes');
	    List<TopFiveArticleController.ArticleInfo> postResults2 = TopFiveArticleController.getTopFiveArticles2('Programs and eAdvisor');
	    List<TopFiveArticleController.ArticleInfo> postResults3 = TopFiveArticleController.getTopFiveArticles2('Application Status');
	    List<TopFiveArticleController.ArticleInfo> postResults4 = TopFiveArticleController.getTopFiveArticles2('Devil2Devil');
	    List<TopFiveArticleController.ArticleInfo> postResults5 = TopFiveArticleController.getTopFiveArticles2('Account Charges');
	    List<TopFiveArticleController.ArticleInfo> postResults6 = TopFiveArticleController.getTopFiveArticles2('Financial Aid and Scholarships');
	    
	    //System.assertEquals('true', results.success);
	    //System.assertEquals(10, results.records.size());
	    //System.assertEquals('Query executed successfully.', results.message);
 
  }
  

}