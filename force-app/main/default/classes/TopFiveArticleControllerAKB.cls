@RestResource(urlMapping='/TopFiveArticlesAKB/*')
global class TopFiveArticleControllerAKB {
    global class ArticleInfo {
        public String id;
        public String url;
        public String title;
        public Integer rank;
    }

    @HttpPost
    global static List<ArticleInfo> getTopFiveArticles(String listName) {
        List<ArticleInfo> articles = new List<ArticleInfo>();
        Integer articleRank = 0;
        List<Id> kavIds = new List<Id>();
        List<Id> articleIds = new List<Id>();

        String kavQuery =
            'SELECT Id, KnowledgeArticleId ' +
            'FROM KnowledgeArticleVersion ' +
            'WHERE PublishStatus=\'Online\' ' +
            'AND Language =\'en_US\' ' +
            'AND IsVisibleInPkb = true';
        String dataCategory;
        String dataCategoryGroup;

        if (listName.indexOf('\\') > 0 && listName.indexOf('\\') < listName.length()) {
            dataCategoryGroup = listName.subString(0, listName.indexOf('\\'));
            dataCategory = listName.subString(listName.indexOf('\\') + 1);
        } else {
            if (String.isNotBlank(listName)) {
                ObjectHelper.DataCategoryWrapper dataCategoryInfo = ObjectHelper.getDataCategoryNameAndGroupByLabel(
                    'KnowledgeArticleVersion',
                    'My ASU ' + listName
                );
                dataCategoryGroup = dataCategoryInfo?.parentGroup;
                dataCategory = dataCategoryInfo?.name;
            }
        }

        if (String.isNotBlank(dataCategory)) {
            kavQuery += ' WITH DATA CATEGORY ' + dataCategoryGroup + ' AT ' + dataCategory;
        }

        List<sObject> kavList = new List<sObject>(Database.query(kavQuery));
        for (sObject so : kavList) {
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

    global static String getArticleUrl(KnowledgeArticleVersion kav) {
        return getUrlPrefix() + '/authkb?id=' + kav.KnowledgeArticleId;
    }

    global static String getUrlPrefix() {
        String baseURL = System.URL.getOrgDomainUrl().toExternalForm();
        baseURL = baseURL.replace('salesforce.com', 'site.com');

        return baseURL;
    }

    global static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].isSandbox;
    }
}