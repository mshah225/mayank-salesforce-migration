public with sharing class AllPublishedArticlesController {
	
	//private string urlPrefix = 'https://utocomm-uto.cs10.force.com/pkb/articles/';
	private string urlPrefix = 'https://asu.secure.force.com/kb/articles/';
	//public List<ArticleInfo> aiList;
	public Map<String, String> articleMap;
		
/*
	public class ArticleInfo {
		string url;
		string title;
	}
*/
	
	public AllPublishedArticlesController() {
		articleMap = new Map<String, String>();
		List<KnowledgeArticleVersion> kavList = new List<KnowledgeArticleVersion>([SELECT id,Title, UrlName, KnowledgeArticleId, PublishStatus, language 
				 																   FROM KnowledgeArticleVersion 
				   																   WHERE PublishStatus='Online'
				   																   AND language ='en_US'
				   																   AND IsVisibleInPkb = true 
				   																   LIMIT 1000]);
		for (KnowledgeArticleVersion kav: kavList) {
			articleMap.put(getArticleUrl(kav), kav.title);
		}
	}
	
	public Map<String, String> getArticleMap() {
		return articleMap;
	}

	
	private string getArticleUrl(KnowledgeArticleVersion kav) {
       	string articleTypeString;
       	string articleIdPrefix = String.valueOf(kav.Id).substring(0,3);
       	if (articleIdPrefix == 'ka1') 
 			articleTypeString = 'FAQ/';
 		else if (articleIdPrefix == 'ka2') 
 			articleTypeString = 'How_To/';
 		else if (articleIdPrefix == 'ka3') 
 			articleTypeString = 'Informational/';
 		else
 			articleTypeString = articleIdPrefix;
 		return urlPrefix + articleTypeString + kav.UrlName;
	}

}