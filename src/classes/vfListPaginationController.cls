public with sharing class vfListPaginationController
{
    private Integer PAGE_SIZE;
    private String baseQuery;
    public Integer pageNumber = 1;
    public Integer maxSize { get; set; }
    public List<List<KnowledgeARticleVersion>> articleList { get; set; }
    public List<List<KnowledgeArticleVersion>> baseSearchList;
    public List<KnowledgeArticleVersion> currentViewList { get; set; }
    public String searchstring { get; set; }
    public Integer lowListNum { get; set; }
    public Integer highListNum { get; set; }
    public Decimal maxPages { get; set; }

    public vfListPaginationController() { setUp(); }
    public vfListPaginationController(ServiceCenter controller) { setUp(); }

    public void setUp()
    {
        String strurl = getVFPageName();
        System.debug('!!!VF PAGE NAME : ' + strurl);
        if (strurl == 'viewAllArticles')
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

        currentViewList = new List<KnowledgeArticleVersion>();
    }

    public Integer getPageSize() { return PAGE_SIZE; }
    public Integer getPageNumber() { return pageNumber; }

    public void articleSearch()
    {
        if (searchstring.length() > 99)
        {
            searchstring = searchstring.substring(0, 99);
        }

        maxSize = 0;
        String queryString = String.escapeSingleQuotes(searchstring);
        Integer offsetNum = (pageNumber - 1) * PAGE_SIZE;

        baseQuery = 'FIND \'' + queryString + '*\'' +
                    'IN ALL FIELDS ' +
                    'RETURNING KnowledgeArticleVersion (Id, KnowledgeArticleId, ' +
                        'Title, LastModifiedDate ' +
                    'WHERE PublishStatus = \'Online\' AND Language = \'en_US\')';
        baseSearchList = Search.query(baseQuery);

        for (List<KnowledgeArticleVersion> kav : baseSearchList)
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

        if (pageNumber > 1)
        {
            baseQuery = 'FIND \'' + queryString + '*\'' +
                    'IN ALL FIELDS ' +
                    'RETURNING KnowledgeArticleVersion (Id, KnowledgeArticleId, ' +
                    'Title, LastModifiedDate ' +
                    'WHERE PublishStatus = \'Online\' AND Language = \'en_US\' ' +
                    'LIMIT ' + PAGE_SIZE + ' ' +
                    'OFFSET ' + offsetNum + ')';
        }
        else
        {
            baseQuery = 'FIND \'' + queryString + '*\'' +
                    'IN ALL FIELDS ' +
                    'RETURNING KnowledgeArticleVersion (Id, KnowledgeArticleId, ' +
                    'Title, LastModifiedDate ' +
                    'WHERE PublishStatus = \'Online\' AND Language = \'en_US\' ' +
                    'LIMIT ' + PAGE_SIZE + ')';
        }

        System.debug('!!!!Query ' + baseQuery);
        articleList = Search.query(baseQuery);

        for (List<KnowledgeArticleVersion> parentKav : articleList)
        {
            for (KnowledgeArticleVersion kav : parentKav)
            {
                system.debug('!!!!!!!ArticleList Title: ' + kav.Title);
            }
        }

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

    public void next()
    {
        pageNumber++;
        //articleSearch();
        currentViewList.clear();
        Integer maxIndex = pageNumber * PAGE_SIZE;
        Integer minIndex = maxIndex - 19;

        if (maxIndex > maxSize)
        {
            maxIndex = maxSize;
        }

        System.debug('!!!!maxSize: ' + maxSize);
        System.debug('!!!!maxIndex: ' + maxIndex);
        System.debug('!!!!minIndex: ' + minIndex);

        for (List<KnowledgeArticleVersion> listKav : baseSearchList)
        {
            for (Integer i = minIndex; i < maxIndex; i++)
            {
                currentViewList.add(baseSearchList[0][i]);
            }
        }
    }

    public void previous()
    {
        pageNumber--;
        articleSearch();
    }

    public void firstPage()
    {
        pageNumber = 1;
        articleSearch();
    }

    public void lastPage()
    {
        pageNumber = Integer.valueOf(maxPages);
        articleSearch();
    }

    public void clearSearchString()
    {
        searchString = '';
    }

    public string getVFPageName()
    {
        String pageName = ApexPages.CurrentPage().getUrl();
        pageName = pageName.replaceFirst('/apex/','');
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
        String[] pageNameExtra = pageName.split('%3F',0);
        pageName = pageNameExtra[0];

        return pageName;
    }
}