public with sharing class AllPublishedArticlesController {
    public List<KnowledgeArticleWrapper> completeListOfArticles { get; set; }
    public static String knowledgeBasePrefix {
        get {
            if (knowledgeBasePrefix == null) {
                Id knowledgeBaseSiteId = [SELECT Id FROM Site WHERE Name = 'kb']?.Id;
                knowledgeBasePrefix = knowledgeBaseSiteId != null
                    ? [SELECT SecureUrl FROM SiteDetail WHERE DurableId = :knowledgeBaseSiteId]?.SecureUrl +
                      '/articles/'
                    : '/';
            }
            return knowledgeBasePrefix;
        }
        set;
    }
    public AllPublishedArticlesController() {
        completeListOfArticles = new List<KnowledgeArticleWrapper>();
        for (KnowledgeArticleVersion kav : [
            SELECT id, Title, UrlName, KnowledgeArticleId, PublishStatus, language
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND language = 'en_US' AND IsVisibleInPkb = TRUE
        ]) {
            completeListOfArticles.add(new KnowledgeArticleWrapper(kav));
        }
    }

    public class KnowledgeArticleWrapper {
        public String articleName { get; set; }
        public String url { get; set; }

        public KnowledgeArticleWrapper(KnowledgeArticleVersion kav) {
            url = getArticleUrl(kav);
            articleName = kav.title;
        }

        private String getArticleUrl(KnowledgeArticleVersion kav) {
            String articleTypeString;
            String articleIdPrefix = String.valueOf(kav.Id).substring(0, 3);
            if (articleIdPrefix == 'ka1') {
                articleTypeString = 'FAQ/';
            } else {
                articleTypeString = articleIdPrefix;
            }
            return knowledgeBasePrefix + articleTypeString + kav.UrlName;
        }
    }
}
