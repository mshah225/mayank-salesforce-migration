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

    public String textToSearch {
        get {
            if (String.isBlank(textToSearch)) {
                textToSearch = '';
            }
            return textToSearch;
        }
        set;
    }

    public String articleCategory {
        get {
            if (articleCategory == null) {
                articleCategory = '';
            }
            return articleCategory;
        }
        set;
    }
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
    public String articleLanguage {
        get {
            if (String.isBlank(articleLanguage)) {
                articleLanguage = 'en_US';
            }
            return articleLanguage;
        }
        set;
    }
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

    public MyASUHelpPaginationController() {
        setupPagination();
    }
    public MyASUHelpPaginationController(MyASUHelpController controller) {
        setupPagination();
    }

    public void setupPagination() {
        initializeVariables();
        checkUrlParameters();
        setPageResults();
    }

    private void initializeVariables() {
        pageSize = 10;
        onFirstPage = true;
        currentPage = 1;
        onLastPage = true;
        lastPage = 1;
        resultCount = 0;
    }

    private void setPageResults() {
        setResultCount();
        setLastPageNumber();
        setFirstAndLastPageStatuses();
    }

    private void setResultCount() {
        if (isTextSearchQuery && !isCategorySearchQuery) {
            String queryString = String.escapeSingleQuotes(textToSearch);
            Search.SearchResults kavResults = Search.find(
                'FIND \'' +
                    queryString +
                    '*\'' +
                    'IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, KnowledgeArticleId, Title, LastModifiedDate WHERE PublishStatus = \'Online\' AND Language = \'en_US\')'
            );
            resultCount = kavResults.get(OBJECT_TYPE).size();
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

    private void setLastPageNumber() {
        if (resultCount > 0) {
            if (Math.Mod(resultCount, pageSize) > 0) {
                lastPage = (resultCount / pageSize) + 1;
            } else {
                lastPage = (resultCount / pageSize);
            }
        } else {
            lastPage = 1;
        }
    }

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

    // Force pagination value recalculation with {!refreshPagination}
    public String getRefreshPagination() {
        setPageResults();
        return System.now().format('HH:mm:ss');
    }

    public void getForceRecalculatePaginationValues() {
        // DELETE THIS METHOD AFTER getRefreshPagination() GOES TO PROD
    }

    public void getLastPageNumber() {
        // DELETE THIS METHOD AFTER lastPage {get; set;} GOES TO PROD
    }

    public Decimal getCurrentPageNumber() {
        determineIfSearchTextHasChanged();
        setPageResults();
        return currentPage;
    }

    private void determineIfSearchTextHasChanged() {
        if (String.isBlank(mostRecentSearchText)) {
            mostRecentSearchText = textToSearch;
        } else if (String.isNotBlank(mostRecentSearchText) && mostRecentSearchText != textToSearch) {
            currentPage = 1;
            setPageResults();
            mostRecentSearchText = textToSearch;
        }
    }

    public void next() {
        if (currentPage < lastPage) {
            currentPage = currentPage + 1;
        }
    }

    public void previous() {
        if (currentPage > 1) {
            currentPage = currentPage - 1;
        }
    }

    public PageReference viewAllResults() {
        PageReference viewAllArticles = new PageReference('/viewAllArticles');
        if (String.isNotBlank(textToSearch)) {
            viewAllArticles.getParameters().put('q', textToSearch);
        }
        viewAllArticles.setRedirect(true);
        return viewAllArticles;
    }
}