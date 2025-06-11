/**
 * Controller for handling pagination of My ASU Help articles.
 */
public with sharing class MyASUHelpPaginationController {
    private final String OBJECT_TYPE = 'KnowledgeArticleVersion';
    public Integer pageSize { get; set; }
    public Integer currentPage { get; set; }
    // @deprecated - remove `lastPage` after deploying to prod
    public Integer lastPage { get; set; }
    public Boolean onFirstPage {
        get {
            return currentPage == 1;
        }
        set;
    }
    // @deprecated - remove `onLastPage` after deploying to prod
    public Boolean onLastPage {
        get {
            return currentPage == lastPage;
        }
        set;
    }
    public Boolean moreResults { get; set; }
    public String mostRecentSearchText { get; set; }
    public String articleCategoryGroupName { get; set; }
    public String articleCategoryName { get; set; }
    @TestVisible
    private static Boolean isTestMode = false;

    /**
     * Gets or sets the text to search.
     */
    public String textToSearch {
        get {
            if (String.isBlank(textToSearch)) {
                textToSearch = '';
            }
            return textToSearch;
        }
        set {
            textToSearch = value;
            if (String.isBlank(mostRecentSearchText)) {
                mostRecentSearchText = textToSearch;
            } else if (String.isNotBlank(mostRecentSearchText) && mostRecentSearchText != textToSearch) {
                currentPage = 1; // reset page to first page
                mostRecentSearchText = textToSearch;
            }
        }
    }

    /**
     * Gets or sets the article category.
     */
    public String articleCategory {
        get {
            if (articleCategory == null) {
                articleCategory = '';
            }
            return articleCategory;
        }
        set;
    }

    /**
     * Gets or sets the article category label.
     */
    public String articleCategoryLabel {
        get {
            if (articleCategoryLabel == null) {
                if (
                    articleCategory.contains(':') &&
                    String.isNotBlank(articleCategoryGroupName) &&
                    String.isNotBlank(articleCategoryName) &&
                    ObjectHelper.isValidDataCategory(OBJECT_TYPE, articleCategoryGroupName, articleCategoryName)
                ) {
                    articleCategoryLabel = ObjectHelper.getDataCategoryLabelByName(
                            OBJECT_TYPE,
                            articleCategoryGroupName,
                            articleCategoryName
                        )
                        .remove('My ASU ')
                        .trim();
                } else {
                    articleCategoryLabel = '';
                }
            }
            return articleCategoryLabel;
        }
        set;
    }

    /**
     * Gets or sets the article language.
     */
    public String articleLanguage {
        get {
            if (String.isBlank(articleLanguage)) {
                articleLanguage = 'en_US';
            }
            return articleLanguage;
        }
        set;
    }

    /**
     * Gets or sets the text search query status.
     */
    public Boolean isTextSearchQuery {
        get {
            if (String.isBlank(textToSearch)) {
                isTextSearchQuery = false;
            } else {
                isTextSearchQuery = true;
                isCategorySearchQuery = false;
            }
            return isTextSearchQuery;
        }
        set;
    }

    /**
     * Gets or sets the category search query status.
     */
    public Boolean isCategorySearchQuery {
        get {
            if (isTextSearchQuery || String.isBlank(articleCategory) || String.isBlank(articleCategoryLabel)) {
                isCategorySearchQuery = false;
            } else {
                isTextSearchQuery = false;
                isCategorySearchQuery = true;
            }
            return isCategorySearchQuery;
        }
        set;
    }

    /**
     * Default constructor for MyASUHelpPaginationController.
     */
    public MyASUHelpPaginationController() {
        setupPagination();
    }

    /**
     * Constructor for MyASUHelpPaginationController with a MyASUHelpController parameter.
     * @param controller An instance of MyASUHelpController
     */
    public MyASUHelpPaginationController(MyASUHelpController controller) {
        setupPagination();
    }

    /**
     * Sets up pagination by initializing variables and setting page results.
     */
    public void setupPagination() {
        initializeVariables();
        checkUrlParameters();
    }

    /**
     * Initializes pagination variables.
     */
    private void initializeVariables() {
        pageSize = 10;
        currentPage = 1;
    }

    /**
     * Checks URL parameters for search terms and sets the query type accordingly.
     */
    private void checkUrlParameters() {
        String q = ApexPages.currentPage().getParameters().get('q');
        String l = ApexPages.currentPage().getParameters().get('l');
        String c = ApexPages.currentPage().getParameters().get('c');

        if (String.isNotBlank(q)) {
            textToSearch = (q.length() > 99) ? q.substring(0, 99) : q;
            isTextSearchQuery = true;
            isCategorySearchQuery = false;
        } else if (
            String.isNotBlank(l) &&
            String.isNotBlank(c) &&
            c.contains(':') &&
            ObjectHelper.isValidDataCategory(OBJECT_TYPE, c.split(':')[0], c.split(':')[1])
        ) {
            articleCategoryGroupName = c.split(':')[0];
            articleCategoryName = c.split(':')[1];
            articleCategory = c;
            articleLanguage = l;

            isTextSearchQuery = false;
            isCategorySearchQuery = true;
        }
    }

    /**
     * Forces pagination value recalculation.
     * @return The current time as a string
     */
    public String getRefreshPagination() {
        return System.now().format('HH:mm:ss');
    }

    /**
     * Advances to the next page. When calling this, you MUST make sure moreResults has been set, as knowledge:articleList
     * will NOT do it automatically. You can do this by passing the value of moreResults with apex:param
     */
    public void next() {
        // compare to true to prevent page from completely failing (due to nullRef) if moreResults is null
        if (moreResults == true) {
            currentPage = currentPage + 1;
        }
    }

    /**
     * Goes to the previous page if possible.
     */
    public void previous() {
        if (currentPage > 1) {
            currentPage = currentPage - 1;
        }
    }

    /**
     * Navigates to the view all results page with search parameters.
     * @return A PageReference to the view all results page
     */
    public PageReference viewAllResults() {
        PageReference viewAllArticles = new PageReference('/viewAllArticles');
        if (String.isNotBlank(textToSearch)) {
            viewAllArticles.getParameters().put('q', textToSearch);
        }
        viewAllArticles.setRedirect(true);
        return viewAllArticles;
    }
}