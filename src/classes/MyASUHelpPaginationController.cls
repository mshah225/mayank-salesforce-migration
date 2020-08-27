public with sharing class MyASUHelpPaginationController {
    public String textToSearch { get; set; }
    public Integer pageSize;
    public Integer currentPage;
    public Integer maxSize;
    public List<KnowledgeArticleVersion> articleList;

    public MyASUHelpPaginationController() {
        setupPagination();
    }
    public MyASUHelpPaginationController(MyASUHelpFAQController controller) {
        setupPagination();
    }

    public void setupPagination() {
        pageSize = 10;
        currentPage = 1;
        checkSearchParams();
        setMaxSize();
    }

    private void checkSearchParams() {
        String searchParams = ApexPages.currentPage().getParameters().get('q');
        if (searchParams != null) {
            textToSearch = (searchParams.length() > 99) ? searchParams.substring(0, 99) : searchParams;
        }
    }

    private void setMaxSize() {
        if (textToSearch == '' || textToSearch == null) {
            maxSize = 0;
        } else {
            String queryString = String.escapeSingleQuotes(textToSearch);
            Search.SearchResults searchResults = Search.find(
                'FIND \'' +
                queryString +
                '*\'' +
                'IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, KnowledgeArticleId, Title, LastModifiedDate WHERE PublishStatus = \'Online\' AND Language = \'en_US\')'
            );
            List<Search.SearchResult> articlelist = searchResults.get('KnowledgeArticleVersion');
            maxSize = articlelist.size();
        }
    }

    public Integer getMaxSize() {
        return maxSize;
    }

    public Integer getPageSize() {
        return pageSize;
    }

    public Decimal getCurrentPageNumber() {
        return currentPage;
    }

    public boolean getPrevRequired() {
        return currentPage > 1;
    }

    public boolean getNextRequired() {
        return currentPage * pageSize < maxSize;
    }

    public void next() {
        if (maxSize > currentPage * pageSize) {
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
