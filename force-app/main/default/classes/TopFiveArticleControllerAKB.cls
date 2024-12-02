@RestResource(urlMapping='/TopFiveArticlesAKB/*')
global class TopFiveArticleControllerAKB {
    global class ArticleInfo {
        public String id;
        public String url;
        public String title;
        public Integer rank;
    }

    /**
     * This has to return void and instead manually modify the RestContext.response object because we want to be able to send
     * error payloads without aborting the transaction (since we need to error log them).
     *
     * On happy path we set the payload of RestContext.response to be a List<ArticleInfo>, and on error path
     * we manually construct a payload identical to what Salesforce would generate if we just used `throw ex`
     *
     * @return {List<ArticleInfo>} Response statusCode=200 and payload is a list of ArticleInfos
     * @throws {Exception} Response statusCode=500 and has error payload if anything went wrong
     */
    @HttpPost
    global static void getTopFiveArticles(String listName) {
        try {
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
                SELECT id, Title, KnowledgeArticleId
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

            // Set response object
            RestContext.response.headers.put('Content-Type', 'application/json;charset=UTF-8');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(articles));
            RestContext.response.statusCode = 200;
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('listName', listName));
            ErrorLogger.log(ex, vars, false);

            // Construct error response that matches format that Salesforce sends by default
            List<Map<String, String>> errorList = new List<Map<String, String>>();
            Map<String, String> errorObj = new Map<String, String>();
            errorObj.put('errorCode', 'APEX_ERROR');
            errorObj.put('message', ex.getMessage());
            errorList.add(errorObj);

            RestContext.response.headers.put('Content-Type', 'application/json;charset=UTF-8');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorList));
            RestContext.response.statusCode = 500;
        }
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
