public with sharing class GlobalKnowledgeSearchController {
    // Data structure for each article result
    public class Article {
        @AuraEnabled public String Id;
        @AuraEnabled public String Title;
        @AuraEnabled public String Answer;
        @AuraEnabled public String KnowledgeArticleId;
        @AuraEnabled public String FunctionalGroup;
        @AuraEnabled public Integer ArticleTotalViewCount;
        @AuraEnabled public String LastPublishedDate;
        @AuraEnabled public String PublishStatus;
        @AuraEnabled public List<String> Categories;
    }

    public class PagedResult {
        @AuraEnabled public List<Article> articles;
        @AuraEnabled public Boolean hasNextPage;
        @AuraEnabled public Boolean hasPreviousPage;
        @AuraEnabled public Integer currentPage;
        @AuraEnabled public Integer totalResults;
        @AuraEnabled public Integer totalPages;
    }

    @TestVisible private static Boolean isTesting = false;
    @TestVisible private static List<FAQ__DataCategorySelection> testSelections;

    @AuraEnabled(cacheable=true)
    public static PagedResult searchArticles(String searchTerm, Integer pageSize, Integer pageNumber, String categoryFilter) {
        if (pageSize == null || pageSize <= 0) pageSize = 10;
        if (pageNumber == null || pageNumber < 1) pageNumber = 1;

        String cleanedTerm = searchTerm != null ? searchTerm.trim() : '';
        cleanedTerm = cleanedTerm.replaceAll('[\\{\\}\\*\'"]', '');
        if (String.isBlank(cleanedTerm)) {
            throw new AuraHandledException('Search term cannot be blank or contain only invalid characters.');
        }

        String query = 'FIND {' + cleanedTerm + '} RETURNING FAQ__kav(' +
            'Id, Title, Answer__c, ArticleTotalViewCount, Functional_Group__c, ' +
            'KnowledgeArticleId, LastPublishedDate, PublishStatus' +
        ')';

        String endpoint = '/services/data/v63.0/search/?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SalesforceSearch' + endpoint);
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            throw new AuraHandledException('Global search failed: ' + res.getStatus());
        }

        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> records = (List<Object>) payload.get('searchRecords');

        Map<String, Article> articleMap = new Map<String, Article>();
        for (Object obj : records) {
            Map<String, Object> rec = (Map<String, Object>) obj;
            if ((String) rec.get('PublishStatus') != 'Online') continue;

            Article a = new Article();
            a.Id = (String) rec.get('Id');
            a.Title = (String) rec.get('Title');
            a.Answer = (String) rec.get('Answer__c');
            a.FunctionalGroup = (String) rec.get('Functional_Group__c');
            a.KnowledgeArticleId = (String) rec.get('KnowledgeArticleId');
            a.LastPublishedDate = (String) rec.get('LastPublishedDate');
            a.PublishStatus = (String) rec.get('PublishStatus');

            if (rec.get('ArticleTotalViewCount') != null) {
                a.ArticleTotalViewCount = Integer.valueOf(String.valueOf(rec.get('ArticleTotalViewCount')));
            }

            a.Categories = new List<String>();
            articleMap.put(a.Id, a);
        }

        if (!articleMap.isEmpty()) {
            List<FAQ__DataCategorySelection> selections = getSelections(articleMap.keySet());
            System.debug('✅ Selections returned: ' + selections.size());

            if (categoryFilter != null && categoryFilter != '*') {
                for (FAQ__DataCategorySelection sel : selections) {
                    String articleId = sel.ParentId;
                    if (articleMap.containsKey(articleId) && sel.DataCategoryGroupName == categoryFilter) {
                        articleMap.get(articleId).Categories.add(sel.DataCategoryGroupName + ':' + sel.DataCategoryName);
                    }
                }

                Set<String> idsToRemove = new Set<String>();
                for (String id : articleMap.keySet()) {
                    if (articleMap.get(id).Categories.isEmpty()) {
                        idsToRemove.add(id);
                    }
                }
                articleMap.keySet().removeAll(idsToRemove);
            } else {
                for (FAQ__DataCategorySelection sel : selections) {
                    String articleId = sel.ParentId;
                    if (articleMap.containsKey(articleId)) {
                        articleMap.get(articleId).Categories.add(sel.DataCategoryGroupName + ':' + sel.DataCategoryName);
                    }
                }
            }
        }

        List<Article> allArticles = new List<Article>(articleMap.values());
        Integer totalResults = allArticles.size();
        Integer totalPages = (Integer) Math.ceil((Decimal) totalResults / pageSize);

        Integer startIdx = (pageNumber - 1) * pageSize;
        Integer endIdx = Math.min(startIdx + pageSize, totalResults);

        List<Article> pageArticles = new List<Article>();
        for (Integer i = startIdx; i < endIdx; i++) {
            pageArticles.add(allArticles[i]);
        }

        PagedResult result = new PagedResult();
        result.articles = pageArticles;
        result.hasNextPage = endIdx < totalResults;
        result.hasPreviousPage = startIdx > 0;
        result.currentPage = pageNumber;
        result.totalResults = totalResults;
        result.totalPages = totalPages;

        return result;
    }

    @TestVisible
    private static List<FAQ__DataCategorySelection> getSelections(Set<String> articleIds) {
        if (isTesting && testSelections != null) {
            System.debug('🧪 Using test override for selections.');
            return testSelections;
        }

        return [
            SELECT ParentId, DataCategoryGroupName, DataCategoryName
            FROM FAQ__DataCategorySelection
            WHERE ParentId IN :articleIds
        ];
    }
}
