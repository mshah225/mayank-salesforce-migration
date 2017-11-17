public with sharing class AllPublishedArticlesController {
	
	private string urlPrefix = 'https://asu.secure.force.com/kb/articles/';
	
	
	public List<Map<String,String>> lstArticleMap {get;set;}	

	
	public AllPublishedArticlesController() {
		lstArticleMap = new List<Map<String,String>>();
		lstArticleMap.add(new Map<String,String>());
		Integer lstSize=lstArticleMap.size();
		for(KnowledgeArticleVersion kav: [SELECT id,Title, UrlName, KnowledgeArticleId, PublishStatus, language 
				 						  FROM KnowledgeArticleVersion 
				   						  WHERE PublishStatus='Online'
				   						  AND language ='en_US'
				   						  AND IsVisibleInPkb = true ]) {
			lstArticleMap[lstSize-1].put(getArticleUrl(kav), kav.title);
			if(lstArticleMap[lstSize-1].size()==1000) {
				lstArticleMap.add(new Map<String,String>());
				lstSize++;
				
			}
				   																   	
		}

	}
	
	public List<Map<String, String>> getArticleMap() {
		return lstArticleMap;
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