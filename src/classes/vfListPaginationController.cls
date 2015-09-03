public with sharing class vfListPaginationController
{
    private Integer PAGE_SIZE;
    private String baseQuery;
    public Integer pageNumber = 1;
    public Integer maxSize { get; set; }
    public List<List<KnowledgeARticleVersion>> articleList { get; set; }
    public List<List<KnowledgeArticleVersion>> sizeQuery;
    public String searchstring { get; set; }
    public Integer lowListNum { get; set; }
    public Integer highListNum { get; set; }
    public Decimal maxPages { get; set; }

    public vfListPaginationController() { setUp(); }
    public vfListPaginationController(ServiceCenter controller) { setUp(); }
    public vfListPaginationController(AKBController controller) { }

    public void setUp()
    {
        String strurl = ApexPages.currentPage().getUrl();
        strurl = strurl.split('apex/')[1];
        if (strurl.contains('viewAllArticles'))
        {
            PAGE_SIZE = 20;
        }
        else
        {
            PAGE_SIZE = 10;
        }

        String q = ApexPages.currentPage().getParameters().get('q');
        if (q != null)
        {
            searchString = q;
            articleSearch();
        }
    }

    public Integer getPageSize() { return PAGE_SIZE; }
    public Integer getPageNumber() { return pageNumber; }

    public PageReference next()
    {
        pageNumber++;
        articleSearch();

        return null;
    }

    public PageReference previous()
    {
        pageNumber--;
        articleSearch();

        return null;
    }

    public void articleSearch()
    {
        if (searchstring.length() > 99)
        {
            searchstring = searchstring.substring(0, 99);
        }

        maxSize = 0;
        String queryString = String.escapeSingleQuotes(searchstring);
        Integer offsetNum = (pageNumber - 1) * PAGE_SIZE;

        baseQuery = 'FIND \'*' + queryString + '*\'' +
                    'IN ALL FIELDS ' +
                    'RETURNING KnowledgeArticleVersion (Id, KnowledgeArticleId, ' +
                        'Title, LastModifiedDate ' +
                    'WHERE PublishStatus = \'Online\' AND Language = \'en_US\')';
        sizeQuery = Search.query(baseQuery);

        for (List<KnowledgeArticleVersion> kav : sizeQuery)
        {
            maxSize = maxSize + kav.size();
        }

        String strMaxSize = maxSize.format();
        String strPAGE_SIZE = PAGE_SIZE.format();
        maxPages = Math.ceil(Decimal.valueOf(strMaxSize) / Decimal.valueOf(strPAGE_SIZE));

        if (maxSize == 0)
        {
            lowListNum = 0;
        }
        else
        {
            lowListNum = offsetNum + 1;
        }

        if (maxSize == 0)
        {
            highListNum = 0;
        }
        else if (pageNumber == maxPages)
        {
            highListNum = maxSize;
        }
        else
        {
            highListNum = pageNumber * PAGE_SIZE;
        }

        baseQuery = 'FIND \'*' + queryString + '*\'' +
                    'IN ALL FIELDS ' +
                    'RETURNING KnowledgeArticleVersion (Id, KnowledgeArticleId, ' +
                        'Title, LastModifiedDate ' +
                    'WHERE PublishStatus = \'Online\' AND Language = \'en_US\' ' +
                    'LIMIT ' + PAGE_SIZE + 'OFFSET ' + offsetNum + ')';

        System.debug('!!!!Query ' + baseQuery);
        articleList = Search.query(baseQuery);

        searchstring = searchstring.capitalize();
    }

    public void startSearch()
    {
        pageNumber = 1;

        articleSearch();
    }

    public Boolean getNextRequired()
    {
        return pageNumber * PAGE_SIZE < maxSize;
    }

    public Boolean getPrevRequired()
    {
        return pageNumber > 1;
    }

    public PageReference viewAllResults()
    {
        PageReference viewAllArts = new PageReference('/viewAllArticles');

        if (searchstring != null)
        {
            viewAllArts.getParameters().put('q', searchstring);
        }

        viewAllArts.setRedirect(true);

        return viewAllArts;
    }

    public void clearSearchString()
    {
        searchString = '';
    }
}