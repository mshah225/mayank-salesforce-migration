@RestResource(urlMapping='/TopFiveArticlesAKB/*')
global class TopFiveArticleControllerAKB
{
	
	global class ArticleInfo
	{
		public string id;
		public string url;
		public string title;
		public integer rank;
	}

    @HttpGet
    global static List<ArticleInfo> getTopFiveArticles()
    {
       	string urlPrefix = 'http://utocomm-uto.cs10.force.com/pkb/articles/FAQ/';
       	//string urlPrefix = 'http://asu.secure.force.com/kb/articles/FAQ/';
       	//string urlPrefix = getPkbSiteUrl();
        List<KnowledgeArticleViewStat> articleViewStatList = [SELECT Id, ParentId FROM KnowledgeArticleViewStat ORDER BY ViewCount DESC LIMIT 5];
        Set<Id> articleIds = new Set<Id>();
        List<ArticleInfo> articles = new List<ArticleInfo>();

        integer articleRank = 0;
    	for (KnowledgeArticleViewStat kavs: [SELECT Id, ParentId FROM KnowledgeArticleViewStat WHERE Channel = 'AllChannels' ORDER BY ViewCount DESC LIMIT 5])
    	{
    		articleIds.add(kavs.ParentId);
    	}

    	for (KnowledgeArticleVersion kav: [SELECT id,Title, UrlName, KnowledgeArticleId, PublishStatus, language 
										   FROM KnowledgeArticleVersion 
										   WHERE PublishStatus='Online'
										   AND language ='en_US' 
										   AND KnowledgeArticleId IN :articleIds]
			)
    	{
			articleRank++;							   	
    		ArticleInfo ai = new ArticleInfo();
    		ai.rank = articleRank;
    		ai.title = kav.Title;
    		ai.url = urlPrefix + kav.UrlName;
    		articles.add(ai);
		}
        return articles;
    }
    
    @HttpPost
    global static List<ArticleInfo> getTopFiveArticles2(String listName)
    {
       	//string urlPrefix = getPkbSiteUrl();
        List<ArticleInfo> articles = new List<ArticleInfo>();
        integer articleRank = 0;
    	List<Id> kavIds = new List<Id>();
    	List<Id> articleIds = new List<Id>();

		string kavQuery = 'SELECT Id, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus=\'Online\' AND language =\'en_US\' AND isVisibleInPkb = true';
		string dataCategory = '';
		string dcGroup;

		if (listName.indexOf('\\') > 0 && listName.indexOf('\\') < listName.length())
		{
			Integer slashPosition = listName.indexOf('\\');
			dcGroup = listName.substring(0, slashPosition);
			dataCategory = listName.substring(slashPosition + 1);
		}
		else if (listName == 'Classes')
		{
			dcGroup = 'Academics__c';
			dataCategory = 'My_ASU_Classes__c';
		}
		else if (listName == 'Programs and eAdvisor')
		{
			dcGroup = 'Academics__c';
			dataCategory = 'My_ASU_Programs_and__c';
		}
		else if (listName == 'Application Status')
		{
			dcGroup = 'Academics__c';
			dataCategory= 'My_ASU_Application__c';
		}
		else if (listName == 'Devil2Devil')
		{
			dcGroup = 'Campus_Services__c';
			dataCategory = 'My_ASU_Devil2Devil__c';
		}
		else if (listName == 'Account Charges')
		{
			dcGroup = 'Finances__c';
			dataCategory = 'My_ASU_Account_Charges__c';
		}
		else if (listName == 'Financial Aid and Scholarships')
		{
			dcGroup = 'Finances__c';
			dataCategory = 'My_ASU_Financial_Aid__c';
		}

		if (dataCategory != '')
		{
			kavQuery += ' WITH DATA CATEGORY ' + dcGroup + ' AT ' + dataCategory;
		}

		System.debug('KAV QUERY ' + kavQuery);
			
		List<Sobject> kavList = new List<Sobject>(database.query(kavQuery));
		System.debug('KAV LIST ' + kavList);

		for (Sobject so : kavList)
		{
			KnowledgeArticleVersion kav = (KnowledgeArticleVersion)so;
			kavIds.add(kav.KnowledgeArticleId);	
		}											   																		    

    	for (KnowledgeArticleViewStat kavs : [SELECT Id, ParentId FROM KnowledgeArticleViewStat WHERE ParentId IN :kavIds AND Channel = 'PKB' ORDER BY ViewCount DESC LIMIT 5]) 
    	{
    		articleIds.add(kavs.ParentId);
    	}
    	//We need this to deal with the case where none of these articles have been viewed (i.e. in testing)
    	if(articleIds.size() == 0)
    	{
    		for(Integer x = 0; x < Math.min(kavIds.size(), 5); x++)
    		{
    			articleIds.add(kavIds.get(x));
    		}
    	}

    	System.debug('ARTICLE IDS ' + articleIds);

    	for (KnowledgeArticleVersion kav: [SELECT id,Title, UrlName, KnowledgeArticleId, PublishStatus, language 
										   FROM KnowledgeArticleVersion 
										   WHERE PublishStatus='Online'
										   AND language ='en_US' 
										   AND KnowledgeArticleId IN :articleIds]
			)
    	{
			articleRank++;							   	
    		ArticleInfo ai = new ArticleInfo();
    		ai.rank = articleRank;
    		ai.title = kav.Title;
    		ai.url = getArticleUrl(kav);
    		ai.id = kav.Id;
    		articles.add(ai);
		}

        return articles;
    }    

	global static string getArticleUrl(KnowledgeArticleVersion kav)
	{
		String urlPrefix = 'https://myasu.force.com/akb';
 		return urlPrefix + '?id=' + kav.Id;
	}
	
	global static string getMoreArticlesUrl(string dcGroup, string dataCategory)
	{
		string url;
		url = 'https://asu.secure.force.com/kb/pkb_Home?l=en_US&c=';
			
       	url += dcGroup.replace('__c', '') + '%3A' + dataCategory.replace('__c','');
       	return url;
	}
}