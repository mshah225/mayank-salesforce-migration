public with sharing class MyASUHelpPaginationController {
    public Integer pageSize;
    public Integer currentPage;
    public Integer lastPage;
    public Boolean onFirstPage;
    public Boolean onLastPage;
    public Integer numberOfResults;
    public Integer extraRows;
    public List<KnowledgeArticleVersion> articleList;
    public String textToSearch { get; set; }
    public String mostRecentSearchText { get; set; }
    public String articleCategory { get; set; }

    public String articleCategoryName {
        get {
            if (articleCategory.contains('Academics') && articleCategory.contains('My_ASU_Classes')) {
                articleCategoryName = 'My Classes';
            } else if (articleCategory.contains('Academics') && articleCategory.contains('My_ASU_Programs_and')) {
                articleCategoryName = 'My Programs';
            }
            return articleCategoryName;
        }
        set;
    }
    public String articleLanguage {
        get {
            if (articleLanguage == null) {
                articleLanguage = 'en_US';
            }
            return articleLanguage;
        }
        set;
    }
    private Boolean isTextSearchQuery {
        get {
            if (textToSearch == '' || textToSearch == null) {
                isTextSearchQuery = false;
            } else {
                isTextSearchQuery = true;
            }
            return isTextSearchQuery;
        }
        set;
    }
    private Boolean isCategorySearchQuery {
        get {
            if (
                articleCategory == '' ||
                articleCategory == null ||
                articleCategoryName == '' ||
                articleCategoryName == null
            ) {
                isCategorySearchQuery = false;
            } else {
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
        pageSize = 10;
        onFirstPage = true;
        currentPage = 1;
        checkSearchParams();
        setNumberOfResults();
        setLastPageNumber();
        setFirstAndLastPageStatuses();
    }

    // Force pagination value recalculation with {!refreshPagination}
    public String getRefreshPagination() {
        setNumberOfResults();
        setLastPageNumber();
        setFirstAndLastPageStatuses();
        return System.now().format('HH:mm:ss');
    }

    private void checkSearchParams() {
        String q = ApexPages.currentPage().getParameters().get('q');
        if (q != null) {
            textToSearch = (q.length() > 99) ? q.substring(0, 99) : q;
        } else {
            String l = ApexPages.currentPage().getParameters().get('l');
            String c = ApexPages.currentPage().getParameters().get('c');
            if (l != null && c != null) {
                articleLanguage = l;
                articleCategory = c;
            }
        }
    }

    private void setNumberOfResults() {
        if (!isTextSearchQuery && !isCategorySearchQuery) {
            numberOfResults = 0;
        } else if (isTextSearchQuery && !isCategorySearchQuery) {
            String queryString = String.escapeSingleQuotes(textToSearch);
            Search.SearchResults kavResults = Search.find(
                'FIND \'' +
                    queryString +
                    '*\'' +
                    'IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, KnowledgeArticleId, Title, LastModifiedDate WHERE PublishStatus = \'Online\' AND Language = \'en_US\')'
            );
            numberOfResults = kavResults.get('KnowledgeArticleVersion').size();
        } else if (!isTextSearchQuery && isCategorySearchQuery) {
            String dataCategoryGroup = '';
            String dataCategory = '';

            if (articleCategoryName == 'My Classes') {
                dataCategoryGroup = 'Academics__c';
                dataCategory = 'My_ASU_Classes__c';
            } else if (articleCategoryName == 'My Programs') {
                dataCategoryGroup = 'Academics__c';
                dataCategory = 'My_ASU_Programs_and__c';
            }

            if (dataCategory != '' && dataCategoryGroup != '') {
                String kavResults =
                    'SELECT COUNT() ' +
                    'FROM KnowledgeArticleVersion ' +
                    'WHERE PublishStatus=\'Online\' ' +
                    'AND Language =\'' +
                    articleLanguage +
                    '\' ' +
                    // 'AND IsVisibleInPkb = true ' +
                    'WITH DATA CATEGORY ' +
                    dataCategoryGroup +
                    ' AT ' +
                    dataCategory;
                numberOfResults = Database.countQuery(kavResults);
            } else {
                numberOfResults = 0;
            }
        }
    }

    private void setLastPageNumber() {
        if (numberOfResults > 0) {
            extraRows = Math.Mod(numberOfResults, pageSize);
            if (extraRows > 0) {
                lastPage = (numberOfResults / pageSize) + 1;
            } else {
                lastPage = (numberOfResults / pageSize);
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

    public Boolean getOnFirstPage() {
        return onFirstPage;
    }

    public Boolean getOnLastPage() {
        return onLastPage;
    }

    public Integer getPageSize() {
        return pageSize;
    }

    public Decimal getCurrentPageNumber() {
        determineIfSearchTextHasChanged();
        setFirstAndLastPageStatuses();
        return currentPage;
    }

    private void determineIfSearchTextHasChanged() {
        if (mostRecentSearchText == '' || mostRecentSearchText == null) {
            mostRecentSearchText = textToSearch;
        } else if (mostRecentSearchText != '' && mostRecentSearchText != null && mostRecentSearchText != textToSearch) {
            currentPage = 1;
            setNumberOfResults();
            setLastPageNumber();
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
        if (textToSearch != null) {
            viewAllArticles.getParameters().put('q', textToSearch);
        }
        viewAllArticles.setRedirect(true);
        return viewAllArticles;
    }
}