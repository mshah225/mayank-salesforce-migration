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
        //string urlPrefix = getPkbSiteUrl();
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

        System.debug('KAV QUERY ' + kavQuery);

        List<Sobject> kavList = new List<Sobject>(database.query(kavQuery));
        System.debug('KAV LIST ' + kavList);

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

        System.debug('ARTICLE IDS ' + articleIds);

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

        ArticleInfo allArticleLink = new ArticleInfo();
        allArticleLink.rank = 0;
        allArticleLink.title = 'More Articles';
        allArticleLink.url = getMoreArticlesUrl(dcGroup, dataCategory);
        allArticleLink.id = 'noId';
        articles.add(allArticleLink);

        return articles;
    }

    global static string getArticleUrl(KnowledgeArticleVersion kav) {
        return getUrlPrefix() + 'authkb?id=' + kav.KnowledgeArticleId;
    }

    global static string getMoreArticlesUrl(string dcGroup, string dataCategory) {
        String baseUrl = getUrlPrefix() + 'viewAllArticles?q=';
        String dcgroupFix = dcGroup.replace('__c', '');
        String dataCategoryGroupFix = dataCategory.replace('__c', '');
        baseUrl += dcgroupFix.replace('_', '+') + '+' + dataCategoryGroupFix.replace('_', '+');

        return baseUrl;
    }

    global static string getUrlPrefix() {
        String urlPrefix = 'https://myasu.force.com/';

        if (isSandbox()) {
            List<String> tokens = URL.getSalesforceBaseUrl().getHost().split('\\.');
            List<String> tokens2 = tokens[0].split('--');
            urlPrefix = 'https://' + tokens2[1] + '-myasu.' + tokens[1] + '.force.com/';
        }

        return urlPrefix;
    }

    global static Boolean isSandbox() {
        String host = URL.getSalesforceBaseUrl().getHost();
        String server = host.substring(0, host.indexOf('.'));

        // It's easiest to check for 'my domain' sandboxes first
        // even though that will be rare
        if (server.contains('--')) {
            return true;
        }

        // tapp0 is a unique "non-cs" server so we check it now
        if (server == 'tapp0') {
            return true;
        }

        // If server is 'cs' followed by a number it's a sandbox
        if (server.length() > 2) {
            if (server.substring(0, 2) == 'cs') {
                try {
                    Integer.valueOf(server.substring(2, server.length()));
                } catch (exception e) {
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
