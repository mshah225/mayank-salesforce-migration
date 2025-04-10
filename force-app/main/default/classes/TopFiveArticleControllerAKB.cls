/**
 * This REST resource class provides an endpoint for retrieving the top five knowledge articles
 * based on view statistics or data category for a given list name. The class includes methods
 * for constructing article URLs and determining the environment type.
 *
 * URL Mapping: /services/apexrest/TopFiveArticlesAKB/*
 */
@RestResource(urlMapping='/TopFiveArticlesAKB/*')
global class TopFiveArticleControllerAKB {
    /**
     * Inner class representing the structure of an article, including its ID, URL, title, and rank.
     */
    global class ArticleInfo {
        public String id;
        public String url;
        public String title;
        public Integer rank;
    }

    /**
     * Retrieves the top five knowledge articles based on view statistics or data category for a given list name.
     *
     * @param listName The name of the list or data category to filter articles.
     * @return A list of the top five articles, each represented by an instance of the ArticleInfo class.
     */
    @HttpPost
    global static List<ArticleInfo> getTopFiveArticles(String listName) {
        List<ArticleInfo> articles = new List<ArticleInfo>();
        Integer articleRank = 0;
        List<Id> kavIds = new List<Id>();
        List<Id> articleIds = new List<Id>();

        String kavQuery =
            'SELECT Id, KnowledgeArticleId ' +
            'FROM FAQ__kav ' +
            'WHERE PublishStatus=\'Online\' ' +
            'AND Language =\'en_US\' ' +
            'AND IsVisibleInPkb = true';
        String dataCategory;
        String dataCategoryGroup;

        // Determine data category and data category group based on listName
        if (listName.indexOf('\\') > 0 && listName.indexOf('\\') < listName.length()) {
            dataCategoryGroup = listName.substring(0, listName.indexOf('\\'));
            dataCategory = listName.substring(listName.indexOf('\\') + 1);
        } else {
            if (String.isNotBlank(listName)) {
                ObjectHelper.DataCategoryWrapper dataCategoryInfo = ObjectHelper.getDataCategoryNameAndGroupByLabel(
                    'FAQ__kav',
                    'My ASU ' + listName
                );
                dataCategoryGroup = dataCategoryInfo?.parentGroup;
                dataCategory = dataCategoryInfo?.name;
            }
        }

        // Append data category to query if available
        if (String.isNotBlank(dataCategory)) {
            kavQuery += ' WITH DATA CATEGORY ' + dataCategoryGroup + ' AT ' + dataCategory;
        }

        // Execute query to retrieve knowledge article versions
        List<SObject> kavList = new List<SObject>(Database.query(kavQuery));
        for (SObject so : kavList) {
            FAQ__kav kav = (FAQ__kav) so;
            kavIds.add(kav.KnowledgeArticleId);
        }

        // Retrieve the top five articles based on view count
        for (FAQ__ViewStat kavs : [
            SELECT Id, ParentId
            FROM FAQ__ViewStat
            WHERE ParentId IN :kavIds AND Channel = 'PKB'
            ORDER BY ViewCount DESC
            LIMIT 5
        ]) {
            articleIds.add(kavs.ParentId);
        }

        // Handle case where no articles have been viewed (e.g., in testing)
        if (articleIds.size() == 0) {
            for (Integer x = 0; x < Math.min(kavIds.size(), 5); x++) {
                articleIds.add(kavIds.get(x));
            }
        }

        // Populate article information and add to articles list
        for (FAQ__kav kav : [
            SELECT Id, Title, UrlName, KnowledgeArticleId, PublishStatus, Language
            FROM FAQ__kav
            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND KnowledgeArticleId IN :articleIds
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

    /**
     * Constructs the URL for a given knowledge article version.
     *
     * @param kav The knowledge article version object.
     * @return The constructed URL as a string.
     */
    global static String getArticleUrl(FAQ__kav kav) {
        return getUrlPrefix() + '/authkb?id=' + kav.KnowledgeArticleId;
    }

    /**
     * Retrieves the base URL for the current organization and modifies it for site-specific use.
     *
     * @return The base URL as a string.
     */
    global static String getUrlPrefix() {
        String baseURL = System.URL.getOrgDomainUrl().toExternalForm();
        baseURL = baseURL.replace('salesforce.com', 'site.com');
        return baseURL;
    }

    /**
     * Determines if the current environment is a sandbox.
     *
     * @return True if the environment is a sandbox, false otherwise.
     */
    global static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}