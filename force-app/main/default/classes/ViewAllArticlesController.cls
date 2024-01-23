public class ViewAllArticlesController {
    private ApexPages.StandardSetController con;

    public string searchString { get; set; }
    public List<KnowledgeArticleVersion> articleList { get; set; }

    public ViewAllArticlesController() {
        setUp();
    }
    public ViewAllArticlesController(MyASUHelpController controller) {
        setUp();
    }

    public void setUp() {
        String q = ApexPages.currentPage().getParameters().get('q');
        if (q != null) {
            searchString = q;
            startSearch();
        }
    }

    /** Method to get data result based on search word and on click on search button **/
    public void startSearch() {
        String querySOSL = '';
        String querySQL = '';
        String queryString = String.escapeSingleQuotes(searchstring);

        querySQL = 'SELECT KnowledgeArticleId, Id, Title, LastModifiedDate ' + 'FROM KnowledgeArticleVersion';

        querySosl =
            'FIND \'' +
            queryString +
            '*\'' +
            'IN ALL FIELDS ' +
            'RETURNING KnowledgeArticleVersion (Id, KnowledgeArticleId, ' +
            'Title, LastModifiedDate ' +
            'WHERE PublishStatus = \'Online\' AND Language = \'en_US\')';

        system.debug('=====' + QuerySOSL);

        List<List<KnowledgeArticleVersion>> resultListOfList = search.query(querySOSL);

        if (resultListOfList[0] != null && resultListOfList[0].size() > 0) {
            querySQL = querySQL + ' where id in (' + getRecordIds(resultListOfList[0]) + ')';
            system.debug('=====QUERYSQL' + QuerySQL);
            con = new ApexPages.StandardSetController(Database.getQueryLocator(querySQL));
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
    private string getRecordIds(List<KnowledgeArticleVersion> KnowledgeArticleVersionList) {
        string ids = '';
        integer i = 0;
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
