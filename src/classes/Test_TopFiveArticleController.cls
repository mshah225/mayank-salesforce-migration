@isTest
public with sharing class Test_TopFiveArticleController
{
	// Create FAQ
	public static void createFAQArticles(Integer howMany)
	{
	    for (Integer i = 0; i < howMany; i++)
	    {
	        FAQ__kav faqArticle = new FAQ__kav(
	            Title = 'Testing FAQ Article' + i,
	            Summary = 'Test FAQ From Apex' + i,
	            Answer__c = 'TEST' + i,
	            Question__c = 'TEST' + i,
	            Language = 'en_US',
	            IsVisibleInPKB = true,
	            IsVisibleInCsp = true,
	            IsVisibleInPrm = true,
	            URLName = 'Top5-Testing-FAQ-Article-' + i);
	        insert faqArticle;

	        // Publish the FAQ Articles
	        faqArticle = [SELECT KnowledgeArticleId
	                    FROM FAQ__kav
	                    WHERE Id = :faqArticle.id];
	        KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);
	    }
	}

	// Create HowTo
	public static void createHowToArticles(Integer howMany)
	{
	    for (Integer i = 0; i < howMany; i++)
	    {
	        How_To__kav howArticle = new How_To__kav(
	            Title = 'Testing HowTo Article' + i,
	            Summary = 'Testing HowTo From Apex' + i,
	            Content__c = 'Test' + i,
	            Language = 'en_US',
	            IsVisibleInPKB = true,
	            IsVisibleInCsp = true,
	            IsVisibleInPrm = true,
	            URLName = 'Top5-Testing-HowTo-Article' + i);
	        insert howArticle;

	        // Publish the How To Articles
	        howArticle = [SELECT KnowledgeArticleId
	                      FROM How_To__kav
	                      WHERE Id = :howArticle.id];
	        KbManagement.PublishingService.publishArticle(howArticle.KnowledgeArticleId, true);
	    }
	}

	// Create Informational
	public static void createInfoArticles(Integer howMany)
	{
	    for (Integer i = 0; i < howMany; i++)
	    {
	        Informational__kav infoArticle = new Informational__kav(
	            Title = 'Testing Informational Article' + i,
	            Summary = 'Testing From Apex' + i,
	            Information__c = 'test from apex',
	            Language = 'en_US',
	            IsVisibleInPKB = true,
	            IsVisibleInCsp = true,
	            IsVisibleInPrm = true,
	            URLName = 'Top5-Testing-Informational-Article' + i);
	        insert infoArticle;

	        // Publish the Informational Articles
	        infoArticle = [SELECT KnowledgeArticleId
	                       FROM Informational__kav
	                       WHERE Id = :infoArticle.id];
	        KbManagement.PublishingService.publishArticle(infoArticle.KnowledgeArticleId, true);
	    }
	}

	@testSetup static void setUp()
	{
		// Input the number of each type of Article you'd like to create
		createFAQArticles(10);
		createHowToArticles(10);
		createInfoArticles(10);
    }
	
	static testMethod void testDoGet()
	{
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
	    system.debug(postResults6);
	    System.assert(postResults6.size() == 5);
  }
}