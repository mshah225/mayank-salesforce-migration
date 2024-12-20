@RestResource(urlMapping='/TopFiveArticles/*')
global class TopFiveArticleController {
    global class ArticleInfo {
        string url;
        string title;
        integer rank;
    }

    @HttpGet
    global static List<ArticleInfo> getTopFiveArticles() {
        Id knowledgeBaseSiteId = [SELECT Id FROM Site WHERE Name = 'kb']?.Id;
        String urlPrefix = knowledgeBaseSiteId != null
            ? [SELECT SecureUrl FROM SiteDetail WHERE DurableId = :knowledgeBaseSiteId]?.SecureUrl + '/articles/FAQ/'
            : '';

        List<KnowledgeArticleViewStat> articleViewStatList = [
            SELECT Id, ParentId
            FROM KnowledgeArticleViewStat
            ORDER BY ViewCount DESC
            LIMIT 5
        ];
        Set<Id> articleIds = new Set<Id>();
        System.debug('GRF1: ' + articleIds);
        List<ArticleInfo> articles = new List<ArticleInfo>();
        integer articleRank = 0;
        if (articleViewStatList.size() > 0) {
            for (KnowledgeArticleViewStat kavs : [
                SELECT Id, ParentId
                FROM KnowledgeArticleViewStat
                WHERE Channel = 'AllChannels'
                ORDER BY ViewCount DESC
                LIMIT 5
            ]) {
                articleIds.add(kavs.ParentId);
            }

            for (KnowledgeArticleVersion kav : [
                SELECT Id, Title, UrlName, KnowledgeArticleId, PublishStatus, language
                FROM KnowledgeArticleVersion
                WHERE PublishStatus = 'Online' AND language = 'en_US' AND KnowledgeArticleId IN :articleIds
            ]) {
                articleRank++;
                ArticleInfo ai = new ArticleInfo();
                ai.rank = articleRank;
                ai.title = kav.Title;
                ai.url = urlPrefix + kav.UrlName;
                articles.add(ai);
            }
        }

        System.debug('GRF2: ' + articles);
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
        List<KnowledgeArticleVersion> kavList = new List<KnowledgeArticleVersion>([
            SELECT Id, KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus='Online'
            AND language ='en_US'
            AND isVisibleInPkb = true
            WITH DATA CATEGORY Finances__c ABOVE_OR_BELOW All__c]
        );
        */

        string kavQuery =
            'SELECT Id, KnowledgeArticleId ' +
            'FROM KnowledgeArticleVersion ' +
            'WHERE PublishStatus=\'Online\' ' +
            'AND language =\'en_US\' ' +
            'AND isVisibleInPkb = true';
        string dataCategory = '';
        string dcGroup;
        System.debug('GRF listname: ' + listName);

        if (listName.indexOf('\\') > 0 && listName.indexOf('\\') < listName.length()) {
            Integer slashPosition = listName.indexOf('\\');
            dcGroup = listName.substring(0, slashPosition);
            dataCategory = listName.substring(slashPosition + 1);
            System.debug('GRF backslash found: ' + dcGroup + ' \\ ' + dataCategory);
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
        System.debug('GRF3: ' + kavList);

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
            articles.add(ai);
        }

        return articles;
    }

    global static string getArticleUrl(KnowledgeArticleVersion kav) {
        String url = System.URL.getOrgDomainUrl().toExternalForm();
        url = url.replace('salesforce.com', 'salesforce-site.com/kb/articles/');

        string articleTypeString;
        string articleIdPrefix = String.valueOf(kav.Id).substring(0, 3);

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

    global static string getMoreArticlesUrl(string dcGroup, string dataCategory) {
        String url = System.URL.getOrgDomainUrl().toExternalForm();
        url = url.replace('salesforce.com', 'salesforce-site.com');

        url += '/kb/pkb_Home?l=en_US&c=';

        url += dcGroup.replace('__c', '') + '%3A' + dataCategory.replace('__c', '');

        return url;
    }
}
