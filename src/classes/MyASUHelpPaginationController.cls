public with sharing class MyASUHelpPaginationController {
    public Integer pageSize;
    public List<KnowledgeArticleVersion> articleList;
    public String searchstring { get; set; }

    public MyASUHelpPaginationController() {
        setUpPage();
    }
    public MyASUHelpPaginationController(MyASUHelpFAQController controller) {
        setUpPage();
    }

    public void setUpPage() {
        String strurl = getVFPageName();

        if (strurl == 'viewAllArticles') {
            pageSize = 20;
        } else {
            pageSize = 10;
        }

        String qryString =
            'SELECT Id, Title, UrlName, LastPublishedDate,LastModifiedById ' +
            'FROM KnowledgeArticleVersion ' +
            'WHERE PublishStatus = \'online\' ' +
            'AND Language = \'en_US\'';
        articleList = Database.query(qryString);
        maxSize = articleList.size();
        checkSearchParams();
    }

    Integer currentPage = 1;
    Integer maxSize = 1;

    public Integer getMaxSize() {
        return maxSize;
    }
    public Integer getPageSize() {
        return pageSize;
    }

    public void clearSearchString() {
        searchString = '';
    }

    public string getVFPageName() {
        String pageName = ApexPages.CurrentPage().getUrl();
        pageName = pageName.replaceFirst('/apex/', '');
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
        String[] pageNameExtra = pageName.split('%3F', 0);
        pageName = pageNameExtra[0];

        return pageName;
    }

    public void checkSearchParams() {
        String q = ApexPages.currentPage().getParameters().get('q');

        if (ApexPages.currentPage().getParameters().get('q') != null) {
            searchstring = (q.length() > 99) ? q.substring(0, 99) : q;
        }
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

        return null;
    }

    public PageReference previous() {
        if (this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
        }

        return null;
    }

    public void resetForm() {
        currentPage = 1;
    }

    public PageReference viewAllResults() {
        PageReference viewAllArts = new PageReference('/viewAllArticles');

        if (searchstring != null) {
            viewAllArts.getParameters().put('q', searchstring);
        }

        viewAllArts.setRedirect(true);

        return viewAllArts;
    }
}
