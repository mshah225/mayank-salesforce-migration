public with sharing class MyASUHelpPaginationController {
    public String textToSearch { get; set; }
    public String mostRecentSearchText { get; set; }
    public Integer pageSize;
    public Integer currentPage;
    public Integer lastPage;
    public Integer numberOfResults;
    public List<KnowledgeArticleVersion> articleList;

    public Boolean onFirstPage;
    public Boolean onLastPage;

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
    public String getForceRecalculatePaginationValues() {
        // When you attempt to {!forceRecalculatePaginationValues} - this will force the pagination values to all be recalculated.
        setNumberOfResults();
        setLastPageNumber();
        setFirstAndLastPageStatuses();
        return System.now().format('HH:mm:ss');
    }

    private void checkSearchParams() {
        String searchParams = ApexPages.currentPage().getParameters().get('q');
        if (searchParams != null) {
            textToSearch = (searchParams.length() > 99) ? searchParams.substring(0, 99) : searchParams;
        }
    }

    private void setNumberOfResults() {
        if (textToSearch == '' || textToSearch == null) {
            numberOfResults = 0;
        } else {
            String queryString = String.escapeSingleQuotes(textToSearch);
            Search.SearchResults searchResults = Search.find(
                'FIND \'' +
                queryString +
                '*\'' +
                'IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, KnowledgeArticleId, Title, LastModifiedDate WHERE PublishStatus = \'Online\' AND Language = \'en_US\')'
            );
            List<Search.SearchResult> articlelist = searchResults.get('KnowledgeArticleVersion');
            numberOfResults = articlelist.size();
        }
    }

    private void setLastPageNumber() {
        if (numberOfResults > 0) {
            lastPage = (numberOfResults / pageSize) + 1;
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
