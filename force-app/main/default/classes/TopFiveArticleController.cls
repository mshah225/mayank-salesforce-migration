/**
 * This REST resource class provides endpoints for retrieving the top five knowledge articles
 * based on view statistics or data category. The class includes methods for constructing article URLs
 * and determining the environment type.
 *
 * URL Mapping: /services/apexrest/TopFiveArticles/*
 */
@RestResource(urlMapping='/TopFiveArticles/*')
global class TopFiveArticleController {
    /**
     * Inner class representing the structure of an article, including its URL, title, and rank.
     */
    global class ArticleInfo {
        public String url;
        public String title;
        public Integer rank;
    }

    /**
     * Retrieves the top five knowledge articles based on view statistics.
     *
     * @return A list of the top five articles, each represented by an instance of the ArticleInfo class.
     */
    @HttpGet
    global static List<ArticleInfo> getTopFiveArticles() {
        Id knowledgeBaseSiteId = [SELECT Id FROM Site WHERE Name = 'kb']?.Id;
        String urlPrefix = knowledgeBaseSiteId != null
            ? [SELECT SecureUrl FROM SiteDetail WHERE DurableId = :knowledgeBaseSiteId]?.SecureUrl + '/articles/FAQ/'
            : '';

        List<FAQ__ViewStat> articleViewStatList = [
            SELECT Id, ParentId
            FROM FAQ__ViewStat
            ORDER BY ViewCount DESC
            LIMIT 5
        ];
        Set<Id> articleIds = new Set<Id>();
        List<ArticleInfo> articles = new List<ArticleInfo>();
        Integer articleRank = 0;

        if (articleViewStatList.size() > 0) {
            for (FAQ__ViewStat kavs : [
                SELECT Id, ParentId
                FROM FAQ__ViewStat
                WHERE Channel = 'AllChannels'
                ORDER BY ViewCount DESC
                LIMIT 5
            ]) {
                articleIds.add(kavs.ParentId);
            }

            for (FAQ__kav kav : [
                SELECT Id, Title, UrlName, KnowledgeArticleId, PublishStatus, Language
                FROM FAQ__kav
                WHERE PublishStatus = 'Online' AND Language = 'en_US' AND KnowledgeArticleId IN :articleIds
            ]) {
                articleRank++;
                ArticleInfo ai = new ArticleInfo();
                ai.rank = articleRank;
                ai.title = kav.Title;
                ai.url = urlPrefix + kav.UrlName;
                articles.add(ai);
            }
        }

        return articles;
    }

    /**
     * Retrieves the top five knowledge articles based on the specified list name.
     *
     * @param listName The name of the list or data category to filter articles.
     * @return A list of the top five articles, each represented by an instance of the ArticleInfo class.
     */
    @HttpPost
    global static List<ArticleInfo> getTopFiveArticles2(String listName) {
        List<ArticleInfo> articles = new List<ArticleInfo>();
        Integer articleRank = 0;
        Set<Id> kavIds = new Set<Id>();
        Set<Id> articleIds = new Set<Id>();

        String kavQuery =
            'SELECT Id, KnowledgeArticleId ' +
            'FROM FAQ__kav ' +
            'WHERE PublishStatus=\'Online\' ' +
            'AND Language =\'en_US\' ' +
            'AND IsVisibleInPkb = true';
        String dataCategory = '';
        String dcGroup;

        // Determine data category group and category based on list name
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

        // Append data category to query if available
        if (dataCategory != '') {
            kavQuery += ' WITH DATA CATEGORY ' + dcGroup + ' AT ' + dataCategory;
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
        String url = System.URL.getOrgDomainUrl().toExternalForm();
        url = url.replace('salesforce.com', 'salesforce-site.com/kb/articles/');

        String articleTypeString;
        String articleIdPrefix = String.valueOf(kav.Id).substring(0, 3);

        if (articleIdPrefix == 'ka1') {
            articleTypeString = 'FAQ/';
        } else if (articleIdPrefix == 'ka2') {
            articleTypeString = 'How_To/';
        } else if (articleIdPrefix == 'ka3') {
            articleTypeString = 'Informational/';
        } else {
            articleTypeString = articleIdPrefix;
        }

        return url + articleTypeString + kav.UrlName;
    }

    /**
     * Constructs the URL for retrieving more articles based on data category group and category.
     *
     * @param dcGroup The data category group.
     * @param dataCategory The data category.
     * @return The constructed URL as a string.
     */
    global static String getMoreArticlesUrl(String dcGroup, String dataCategory) {
        String url = System.URL.getOrgDomainUrl().toExternalForm();
        url = url.replace('salesforce.com', 'salesforce-site.com');

        url += '/kb/pkb_Home?l=en_US&c=';
        url += dcGroup.replace('__c', '') + '%3A' + dataCategory.replace('__c', '');

        return url;
    }
}