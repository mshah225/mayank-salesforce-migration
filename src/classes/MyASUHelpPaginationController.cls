public with sharing class MyASUHelpPaginationController {
    public Integer pageSize;
    public Integer currentPage;
    public Integer maxSize;
    public Integer rangeStart;
    public Integer rangeEnd;
    public String resultsRange;
    public List<KnowledgeArticleVersion> articleList;
    public String searchstring { get; set; }

    public MyASUHelpPaginationController() {
        setupPagination();
    }
    public MyASUHelpPaginationController(MyASUHelpFAQController controller) {
        setupPagination();
    }

    public void setupPagination() {
        pageSize = 10;
        currentPage = 1;
        rangeStart = 1;
        rangeEnd = 1;
        checkSearchParams();
        setMaxSize();
        setResultsRange();
    }

    private void checkSearchParams() {
        String searchParams = ApexPages.currentPage().getParameters().get('q');
        if (searchParams != null) {
            searchstring = (searchParams.length() > 99) ? searchParams.substring(0, 99) : searchParams;
        }
    }

    private void setMaxSize() {
        if (searchstring != '') {
            String querySOSL = '';
            String queryString = String.escapeSingleQuotes(searchstring);
            Search.SearchResults searchResults = Search.find(
                'FIND \'' +
                queryString +
                '*\'' +
                'IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, KnowledgeArticleId, Title, LastModifiedDate WHERE PublishStatus = \'Online\' AND Language = \'en_US\')'
            );
            List<Search.SearchResult> articlelist = searchResults.get('KnowledgeArticleVersion');
            maxSize = articlelist.size();
        } else {
            maxSize = 0;
        }
    }

    private void setResultsRange() {
        resultsRange = '';
        if (maxSize == 0) {
            rangeStart = 0;
            rangeEnd = 0;
        } else if (maxSize < 10 && maxSize > 0) {
            rangeEnd = maxSize;
            rangeStart = 1;
        } else {
            rangeEnd = currentPage * 10;
            rangeStart = rangeEnd - 9;

            if (rangeEnd > maxSize) {
                rangeEnd = maxSize;
            }
        }

        if (rangeStart != rangeEnd) {
            resultsRange += rangeStart + ' - ' + rangeEnd + ' of ' + maxSize + ' results';
        } else {
            resultsRange += rangeStart;
            if (rangeStart == 1) {
                resultsRange += ' of ' + maxSize + ' result';
            } else if (rangeStart == 0) {
                resultsRange += ' of ' + maxSize + ' results';
            }
        }
    }

    public Integer getMaxSize() {
        return maxSize;
    }
    public Integer getPageSize() {
        return pageSize;
    }

    public String getResultsRange() {
        return resultsRange;
    }

    public void resetForm() {
        currentPage = 1;
    }

    public void clearSearchString() {
        searchString = '';
    }

    public boolean getPrevRequired() {
        return currentPage > 1;
    }

    public boolean getNextRequired() {
        return currentPage * pageSize < maxSize;
    }

    public Decimal getCurrentPageNumber() {
        return this.currentPage;
    }

    public PageReference next() {
        if (maxSize > this.currentPage * pageSize) {
            this.currentPage = this.currentPage + 1;
        }
        setResultsRange();

        return null;
    }

    public PageReference previous() {
        if (this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
        }
        setResultsRange();

        return null;
    }

    public PageReference viewAllResults() {
        PageReference viewAllArticles = new PageReference('/viewAllArticles');
        if (searchstring != null) {
            viewAllArticles.getParameters().put('q', searchstring);
        }
        viewAllArticles.setRedirect(true);
        return viewAllArticles;
    }
}
