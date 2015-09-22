public with sharing class vfListPaginationController
{
    private Integer PAGE_SIZE;
    private String baseQuery;
    public Integer pageNumber;
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

        if (ApexPages.currentPage().getParameters().get('q') != null)
        {
            searchString = q;
            articleSearch();
        }
    }

    public Integer getPageNumber() { return pageNumber; }

    public void articleSearch()
    {
        searchstring = (searchString.length() > 99) ? searchstring.substring(0, 99) : searchstring;
        currentViewList = new List<KnowledgeArticleVersion>();
        pageNumber = 1;
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
        lowListNum = (maxSize == 0) ? 0 : offsetNum + 1;

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

        System.debug('!!!! Query ' + baseQuery);
        articleList = Search.query(baseQuery);
        Integer maxIndex = (maxSize < PAGE_SIZE) ? maxSize : PAGE_SIZE;

        for (List<KnowledgeArticleVersion> listKav : baseSearchList)
        {
            for (Integer i = 0; i < maxIndex; i++)
            {
                System.debug('!!!! Article: ' + baseSearchList[0][i]);
                currentViewList.add(baseSearchList[0][i]);
            }
        }

        System.debug('!!!! CurrentViewList: ' + currentViewList);
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
        navigateSearchResults(pageNumber);
    }

    public void previous()
    {
        pageNumber--;
        navigateSearchResults(pageNumber);
    }

    public void firstPage()
    {
        pageNumber = 1;
        navigateSearchResults(pageNumber);
    }

    public void lastPage()
    {
        pageNumber = Integer.valueOf(maxPages);
        navigateSearchResults(pageNumber);
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

    public void navigateSearchResults(Integer pageNumber)
    {
        currentViewList.clear();
        Integer maxIndex = pageNumber * PAGE_SIZE;
        Integer minIndex = maxIndex - 20;
        maxIndex = (maxIndex > maxSize) ? maxSize : maxIndex;
        lowListNum = (minIndex == 0) ? 1 : minIndex;
        highListNum = maxIndex;

        for (List<KnowledgeArticleVersion> listKav : baseSearchList)
        {
            for (Integer i = minIndex; i < maxIndex; i++)
            {
                currentViewList.add(baseSearchList[0][i]);
            }
        }
    }
}