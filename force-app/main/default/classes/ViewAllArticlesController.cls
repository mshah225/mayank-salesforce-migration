public class ViewAllArticlesController {
    private ApexPages.StandardSetController con;

    public String searchString { get; set; }
    public String searchLanguage {
        get {
            if (searchLanguage == null) {
                searchLanguage = 'en_US';
            }
            return searchLanguage;
        }
        set;
    }
    public List<KnowledgeArticleVersion> articleList { get; set; }

    public ViewAllArticlesController() {
        initialize();
    }
    public ViewAllArticlesController(MyASUHelpController controller) {
        initialize();
    }

    public void initialize() {
        String q = ApexPages.currentPage().getParameters().get('q');
        if (q != null) {
            searchString = q;
            startSearch();
        } else {
            String l = ApexPages.currentPage().getParameters().get('l');
            String c = ApexPages.currentPage().getParameters().get('c');
            if (l != null && c != null) {
                searchLanguage = l;
                searchString = c;
                startSearch();
            }
        }
    }

    /** Method to get data result based on search word and on click on search button **/
    public void startSearch() {
        String querySOSL = '';
        String querySOQL = '';
        String queryString = String.escapeSingleQuotes(searchString);

        querySOQL = 'SELECT KnowledgeArticleId, Id, Title, LastModifiedDate ' + 'FROM KnowledgeArticleVersion';

        querySOSL =
            'FIND \'' +
            queryString +
            '*\'' +
            'IN ALL FIELDS ' +
            'RETURNING KnowledgeArticleVersion (Id, KnowledgeArticleId, ' +
            'Title, LastModifiedDate ' +
            'WHERE PublishStatus = \'Online\' AND Language = \'' +
            searchLanguage +
            '\')';

        system.debug('=====' + querySOSL);

        List<List<KnowledgeArticleVersion>> resultListOfList = search.query(querySOSL);

        if (resultListOfList[0] != null && resultListOfList[0].size() > 0) {
            querySOQL = querySOQL + ' WHERE Id IN (' + getRecordIds(resultListOfList[0]) + ')';
            system.debug('=====querySOQL' + querySOQL);
            con = new ApexPages.StandardSetController(Database.getQueryLocator(querySOQL));
            system.debug('!!!CON' + con);
            con.setPageSize(20);
            articleList = new List<KnowledgeArticleVersion>();
            for (KnowledgeArticleVersion nextRec : (List<KnowledgeArticleVersion>) Con.getRecords()) {
                articleList.add(nextRec);
            }
        }

        system.debug('===ARTICLELIST' + articleList);
    }

    /** method to concatenate ids of search results **/
    private String getRecordIds(List<KnowledgeArticleVersion> KnowledgeArticleVersionList) {
        String ids = '';
        Integer i = 0;
        for (KnowledgeArticleVersion nextObj : KnowledgeArticleVersionList) {
            i = i + 1;

            if (i == 1)
                ids = '\'' + nextObj.id + '\'';
            else
                ids = ids + ',\'' + nextObj.id + '\'';
        }
        return ids;
    }

    public Boolean nextRequired {
        get {
            return con.getHasNext();
        }
        set;
    }

    public Boolean prevRequired {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    public void first() {
        con.first();
    }

    public void last() {
        con.last();
    }

    public void previous() {
        con.previous();
    }

    public void next() {
        con.next();
    }

    public void clearSearchString() {
        searchString = '';
    }
}