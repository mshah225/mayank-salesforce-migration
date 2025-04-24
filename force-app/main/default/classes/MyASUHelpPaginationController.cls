/**
 * Controller for handling pagination of My ASU Help articles.
 */
public with sharing class MyASUHelpPaginationController {
    private final String OBJECT_TYPE = 'KnowledgeArticleVersion';
    public Integer pageSize { get; set; }
    public Integer currentPage { get; set; }
    public Integer lastPage { get; set; }
    public Boolean onFirstPage { get; set; }
    public Boolean onLastPage { get; set; }
    public Integer resultCount { get; set; }
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
        set;
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
        setPageResults();
    }

    /**
     * Initializes pagination variables.
     */
    private void initializeVariables() {
        pageSize = 10;
        onFirstPage = true;
        currentPage = 1;
        onLastPage = true;
        lastPage = 1;
        resultCount = 0;
    }

    /**
     * Sets the page results, result count, and first and last page statuses.
     */
    private void setPageResults() {
        setResultCount();
        setLastPageNumber();
        setFirstAndLastPageStatuses();
    }

    /**
     * Sets the result count based on the search query or category.
     */
    private void setResultCount() {
        if (isTextSearchQuery && !isCategorySearchQuery) {
            String queryString = String.escapeSingleQuotes(textToSearch);
            String soslObjectType = isTestMode ? 'FAQ__kav' : OBJECT_TYPE;

            Search.SearchResults kavResults = Search.find(
                'FIND \'' +
                    queryString +
                    '*\' IN ALL FIELDS RETURNING ' +
                    soslObjectType +
                    '(Id, KnowledgeArticleId, Title, LastModifiedDate WHERE PublishStatus = \'Online\' AND Language = \'en_US\')'
            );

            List<Search.SearchResult> results = kavResults.get(soslObjectType);
            resultCount = (results != null) ? results.size() : 0;
        } else if (
            !isTextSearchQuery &&
            isCategorySearchQuery &&
            String.isNotBlank(articleLanguage) &&
            String.isNotBlank(articleCategoryGroupName) &&
            String.isNotBlank(articleCategoryName)
        ) {
            String kavResults =
                'SELECT COUNT() ' +
                'FROM KnowledgeArticleVersion ' +
                'WHERE PublishStatus=\'Online\' ' +
                'AND Language =\'' +
                articleLanguage +
                '\' ' +
                'WITH DATA CATEGORY ' +
                articleCategoryGroupName +
                '__c' +
                ' AT ' +
                articleCategoryName +
                '__c';
            resultCount = Database.countQuery(kavResults);
        } else {
            resultCount = 0;
        }
    }

    /**
     * Sets the last page number based on the result count and page size.
     */
    private void setLastPageNumber() {
        if (resultCount > 0) {
            if (Math.mod(resultCount, pageSize) > 0) {
                lastPage = (resultCount / pageSize) + 1;
            } else {
                lastPage = (resultCount / pageSize);
            }
        } else {
            lastPage = 1;
        }
    }

    /**
     * Sets the statuses of the first and last pages.
     */
    private void setFirstAndLastPageStatuses() {
        if (currentPage == 1) {
            onFirstPage = true;
            if (lastPage == 1) {
                onLastPage = true;
            } else if (lastPage > 1) {
                onLastPage = false;
            }
        } else if (currentPage > 1) {
            onFirstPage = false;
            if (lastPage == currentPage) {
                onLastPage = true;
            } else if (lastPage != currentPage) {
                onLastPage = false;
            }
        }
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
        setPageResults();
        return System.now().format('HH:mm:ss');
    }

    /**
     * Placeholder method to be deleted after getRefreshPagination() goes to prod.
     */
    public void getForceRecalculatePaginationValues() {
        // DELETE THIS METHOD AFTER getRefreshPagination() GOES TO PROD
    }

    /**
     * Placeholder method to be deleted after lastPage {get; set;} goes to prod.
     */
    public void getLastPageNumber() {
        // DELETE THIS METHOD AFTER lastPage {get; set;} GOES TO PROD
    }

    /**
     * Gets the current page number after determining if the search text has changed.
     * @return The current page number
     */
    public Decimal getCurrentPageNumber() {
        determineIfSearchTextHasChanged();
        setPageResults();
        return currentPage;
    }

    /**
     * Determines if the search text has changed and updates the current page accordingly.
     */
    private void determineIfSearchTextHasChanged() {
        if (String.isBlank(mostRecentSearchText)) {
            mostRecentSearchText = textToSearch;
        } else if (String.isNotBlank(mostRecentSearchText) && mostRecentSearchText != textToSearch) {
            currentPage = 1;
            setPageResults();
            mostRecentSearchText = textToSearch;
        }
    }

    /**
     * Advances to the next page if possible.
     */
    public void next() {
        if (currentPage < lastPage) {
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