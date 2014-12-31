@RestResource(urlMapping='/TopFiveArticles/*')
global class TopFiveArticleController {
	
	global class ArticleInfo {
		string url;
		string title;
		integer rank;
	}

    @HttpGet
    global static List<ArticleInfo> getTopFiveArticles() {
       	string urlPrefix = 'http://utocomm-uto.cs10.force.com/pkb/articles/FAQ/';
       	//string urlPrefix = 'http://asu.secure.force.com/kb/articles/FAQ/';
       	//string urlPrefix = getPkbSiteUrl();
        List<KnowledgeArticleViewStat> articleViewStatList = [SELECT Id, ParentId FROM KnowledgeArticleViewStat ORDER BY ViewCount DESC LIMIT 5];
        Set<Id> articleIds = new Set<Id>();
        system.debug('GRF1: ' + articleIds);
        List<ArticleInfo> articles = new List<ArticleInfo>();
        integer articleRank = 0;
        if (articleViewStatList.size() > 0) {
        	for (KnowledgeArticleViewStat kavs: [SELECT Id, ParentId FROM KnowledgeArticleViewStat WHERE Channel = 'AllChannels' ORDER BY ViewCount DESC LIMIT 5]) {
        		articleIds.add(kavs.ParentId);
        	}
        	for (KnowledgeArticleVersion kav: [SELECT id,Title, UrlName, KnowledgeArticleId, PublishStatus, language 
											   FROM KnowledgeArticleVersion 
											   WHERE PublishStatus='Online'
											   AND language ='en_US' 
											   AND KnowledgeArticleId IN :articleIds]) {
				articleRank++;							   	
        		ArticleInfo ai = new ArticleInfo();
        		ai.rank = articleRank;
        		ai.title = kav.Title;
        		ai.url = urlPrefix + kav.UrlName;
        		articles.add(ai);
			}
        }
        system.debug('GRF2: ' + articles);
        return articles;
    }
    
    @HttpPost
    global static List<ArticleInfo> getTopFiveArticles2(String listName) {
       	//string urlPrefix = getPkbSiteUrl();
        List<ArticleInfo> articles = new List<ArticleInfo>();
        integer articleRank = 0;
    	Set<Id> kavIds = new Set<Id>();
    	Set<Id> articleIds = new Set<Id>();
    	/*
    	List<KnowledgeArticleVersion> kavList = new List<KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus='Online'
										   																		    AND language ='en_US'
										   																		    AND isVisibleInPkb = true
										   																		    WITH DATA CATEGORY Finances__c ABOVE_OR_BELOW All__c]);
		*/
		string kavQuery = 'SELECT Id, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus=\'Online\' AND language =\'en_US\' AND isVisibleInPkb = true';
		string dataCategory = '';
		string dcGroup;
		system.debug('GRF listname: ' + listName);
		if (listName.indexOf('\\') > 0 && listName.indexOf('\\') < listName.length()) {
			Integer slashPosition = listName.indexOf('\\');
			dcGroup = listName.substring(0, slashPosition);
			dataCategory = listName.substring(slashPosition + 1);
			system.debug('GRF backslash found: ' + dcGroup + ' \\ ' + dataCategory);	
		}
		else if (listName == 'Classes') {
			dcGroup = 'Academics__c';
			dataCategory = 'My_ASU_Classes__c';
		}
		else if (listName == 'Programs and eAdvisor') {
			dcGroup = 'Academics__c';
			dataCategory = 'My_ASU_Programs_and__c';
		}
		else if (listName == 'Application Status') {
			dcGroup = 'Academics__c';
			dataCategory= 'My_ASU_Application__c';
		}
		else if (listName == 'Devil2Devil') {
			dcGroup = 'Campus_Services__c';
			dataCategory = 'My_ASU_Devil2Devil__c';
		}
		else if (listName == 'Account Charges') {
			dcGroup = 'Finances__c';
			dataCategory = 'My_ASU_Account_Charges__c';
		}
		else if (listName == 'Financial Aid and Scholarships') {
			dcGroup = 'Finances__c';
			dataCategory = 'My_ASU_Financial_Aid__c';
		}
		if (dataCategory != '')
			kavQuery += ' WITH DATA CATEGORY ' + dcGroup + ' AT ' + dataCategory;
			
		List<Sobject> kavList = new List<Sobject>(database.query(kavQuery));
		system.debug('GRF3: ' + kavList);
		for (Sobject so: kavList) {
			KnowledgeArticleVersion kav = (KnowledgeArticleVersion)so;
			kavIds.add(kav.KnowledgeArticleId);	
		}											   																		    
    	for (KnowledgeArticleViewStat kavs: [SELECT Id, ParentId FROM KnowledgeArticleViewStat WHERE ParentId IN :kavIds AND Channel = 'PKB' ORDER BY ViewCount DESC LIMIT 5]) {
    		articleIds.add(kavs.ParentId);
    	}
    	for (KnowledgeArticleVersion kav: [SELECT id,Title, UrlName, KnowledgeArticleId, PublishStatus, language 
										   FROM KnowledgeArticleVersion 
										   WHERE PublishStatus='Online'
										   AND language ='en_US' 
										   AND KnowledgeArticleId IN :articleIds]) {
			articleRank++;							   	
    		ArticleInfo ai = new ArticleInfo();
    		ai.rank = articleRank;
    		ai.title = kav.Title;
    		ai.url = getArticleUrl(kav);
    		articles.add(ai);
		}
		//ArticleInfo ai = new ArticleInfo();
		//ai.rank = 0;
		//ai.title = 'More Articles';
		//ai.url = getMoreArticlesUrl(dcGroup, dataCategory);
		//articles.add(ai);
        system.debug('GRF2: ' + articles);
        system.debug('GRF 3:' + System.URL.getSalesforceBaseURL().getHost());
        return articles;
    }    

/*
	global static string getPkbSiteUrl() {
		// Copy/pasta'd this code from a blog; it's nice except that it DOES NOT WORK. Doh.
		Site s = [SELECT s.Subdomain FROM Site s WHERE Name = 'PKB' LIMIT 1 ];
		if (s == null)
			return '';
		String urlCode = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());
		String [] cuts = urlCode.split('[.]');
		urlCode = '';
		for(Integer i = 1; i < cuts.size(); i++){
		    if(!cuts[i].contains('visual')){
		        urlCode += cuts[i] + '.';
		    }
		}     
		urlCode = urlCode.substring(0, urlCode.length()-1);  
		urlCode = 'http://'+s.Subdomain+'.'+urlCode+'/';
		return urlCode;	
	}
*/
	
	global static string getArticleUrl(KnowledgeArticleVersion kav) {
       	string urlPrefix;
       	if (isSandbox())
       		urlPrefix = 'http://utocomm-uto.cs10.force.com/pkb/articles/';
 		else
 			urlPrefix = 'https://asu.secure.force.com/kb/articles/';
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
	
	global static string getMoreArticlesUrl(string dcGroup, string dataCategory) {
		string url;
		if (isSandbox())
			url = 'http://utocomm-uto.cs10.force.com/pkb/pkb_Home?l=en_US&c=';
		else
			url = 'https://asu.secure.force.com/kb/pkb_Home?l=en_US&c=';
			
       	url += dcGroup.replace('__c', '') + '%3A' + dataCategory.replace('__c','');
       	return url;
	}
	
	global static Boolean isSandbox() {
    	String host = URL.getSalesforceBaseUrl().getHost();
        String server = host.substring(0,host.indexOf('.'));

        // It's easiest to check for 'my domain' sandboxes first 
        // even though that will be rare
        if(server.contains('--'))
            return true;

        // tapp0 is a unique "non-cs" server so we check it now
        if(server == 'tapp0')
            return true;

        // If server is 'cs' followed by a number it's a sandbox
        if(server.length()>2){
            if(server.substring(0,2)=='cs'){
                try{
                    Integer.valueOf(server.substring(2,server.length()));
                }
                catch(exception e){
                    //started with cs, but not followed by a number
                    return false;
                }

                //cs followed by a number, that's a hit
                return true;
            }
        }

        // If we made it here it's a production box
        return false;
    }
	
}