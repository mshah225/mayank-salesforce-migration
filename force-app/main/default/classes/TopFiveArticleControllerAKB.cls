@RestResource(urlMapping='/TopFiveArticlesAKB/*')
global class TopFiveArticleControllerAKB {
    global class ArticleInfo {
        public string id;
        public string url;
        public string title;
        public integer rank;
    }

    @HttpPost
    global static List<ArticleInfo> getTopFiveArticles2(String listName) {
        List<ArticleInfo> articles = new List<ArticleInfo>();
        integer articleRank = 0;
        List<Id> kavIds = new List<Id>();
        List<Id> articleIds = new List<Id>();

        string kavQuery =
            'SELECT Id, KnowledgeArticleId ' +
            'FROM KnowledgeArticleVersion ' +
            'WHERE PublishStatus=\'Online\' ' +
            'AND language =\'en_US\' ' +
            'AND isVisibleInPkb = true';
        string dataCategory = '';
        string dcGroup;

        if (listName.indexOf('\\') > 0 && listName.indexOf('\\') < listName.length()) {
            Integer slashPosition = listName.indexOf('\\');
            dcGroup = listName.substring(0, slashPosition);
            dataCategory = listName.substring(slashPosition + 1);
        } else if (listName == 'Classes') {
            dcGroup = 'Academics__c';
            dataCategory = 'My_ASU_Classes__c';
        } else if (listName == 'Programs and eAdvisor') {
            dcGroup = 'Academics__c';
            dataCategory = 'My_ASU_Programs_and__c';
        } else if (listName == 'Application Status') {
            dcGroup = 'Academics__c';
            dataCategory = 'My_ASU_Application__c';
        } else if (listName == 'Devil2Devil') {
            dcGroup = 'Campus_Services__c';
            dataCategory = 'My_ASU_Devil2Devil__c';
        } else if (listName == 'Account Charges') {
            dcGroup = 'Finances__c';
            dataCategory = 'My_ASU_Account_Charges__c';
        } else if (listName == 'Financial Aid and Scholarships') {
            dcGroup = 'Finances__c';
            dataCategory = 'My_ASU_Financial_Aid__c';
        }

        if (dataCategory != '') {
            kavQuery += ' WITH DATA CATEGORY ' + dcGroup + ' AT ' + dataCategory;
        }

        List<Sobject> kavList = new List<Sobject>(database.query(kavQuery));

        for (Sobject so : kavList) {
            KnowledgeArticleVersion kav = (KnowledgeArticleVersion) so;
            kavIds.add(kav.KnowledgeArticleId);
        }

        for (KnowledgeArticleViewStat kavs : [
            SELECT Id, ParentId
            FROM KnowledgeArticleViewStat
            WHERE ParentId IN :kavIds AND Channel = 'PKB'
            ORDER BY ViewCount DESC
            LIMIT 5
        ]) {
            articleIds.add(kavs.ParentId);
        }
        //We need this to deal with the case where none of these articles have been viewed (i.e. in testing)
        if (articleIds.size() == 0) {
            for (Integer x = 0; x < Math.min(kavIds.size(), 5); x++) {
                articleIds.add(kavIds.get(x));
            }
        }

        for (KnowledgeArticleVersion kav : [
            SELECT id, Title, UrlName, KnowledgeArticleId, PublishStatus, language
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND language = 'en_US' AND KnowledgeArticleId IN :articleIds
        ]) {
            articleRank++;
            ArticleInfo ai = new ArticleInfo();
            ai.rank = articleRank;
            ai.title = kav.Title;
            ai.url = getArticleUrl(kav);
            ai.id = kav.KnowledgeArticleId;
            articles.add(ai);
        }
        return articles;
    }

    global static string getArticleUrl(KnowledgeArticleVersion kav) {
        return getUrlPrefix() + '/authkb?id=' + kav.KnowledgeArticleId;
    }

    global static string getUrlPrefix() {
        String baseURL = System.URL.getOrgDomainUrl().toExternalForm();
        baseURL = baseURL.replace('salesforce.com', 'site.com');

        return baseURL;
    }

    global static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].isSandbox;
    }
}