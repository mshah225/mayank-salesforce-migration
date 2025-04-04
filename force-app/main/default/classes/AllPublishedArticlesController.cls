/**
 * Controller for retrieving and wrapping all published articles.
 */
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

    /**
     * Constructor to initialize the list of published articles.
     */
    public AllPublishedArticlesController() {
        completeListOfArticles = new List<KnowledgeArticleWrapper>();
        for (FAQ__kav kav : [
            SELECT Id, Title, UrlName, KnowledgeArticleId, PublishStatus, Language
            FROM FAQ__kav
            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND IsVisibleInPkb = TRUE
        ]) {
            completeListOfArticles.add(new KnowledgeArticleWrapper(kav));
        }
    }

    /**
     * Wrapper class for knowledge articles.
     */
    public class KnowledgeArticleWrapper {
        public String articleName { get; set; }
        public String url { get; set; }

        /**
         * Constructor to create a wrapper for a FAQ__kav article.
         * @param kav The FAQ__kav article to wrap.
         */
        public KnowledgeArticleWrapper(FAQ__kav kav) {
            url = getArticleUrl(kav);
            articleName = kav.Title;
        }

        /**
         * Generates the URL for the given article.
         * @param kav The FAQ__kav article.
         * @return The URL for the article.
         */
        private String getArticleUrl(FAQ__kav kav) {
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