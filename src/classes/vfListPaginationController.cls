public with sharing class vfListPaginationController
{
    private final Integer PAGE_SIZE = 10;
    private String baseQuery;
    public Integer pageNumber = 1;
    public Integer maxSize { get; set; }
    public List<KnowledgeARticleVersion> articleList { get; set; }
    public String searchstring { get; set; }
    public Integer lowListNum { get; set; }
    public Integer highListNum { get; set; }
    public Decimal maxPages { get; set; }

    public vfListPaginationController() { }
    public vfListPaginationController(ServiceCenter controller) { }
    public vfListPaginationController(AKBController controller) { }

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

    public void articleSearch() {
        if (searchstring.length() > 99) {
            searchstring = searchstring.substring(0, 99);
        }

        String[] queryArray = searchstring.split(' ');
        System.debug('!!!!!!!String array size: ' + queryArray.size());
        String queryString = '';
        if (queryArray.size() > 1)
        {
            Boolean firstRun = true;
            for (String s: queryArray)
            {
                if (firstRun)
                {
                    s = 'WHERE (Title LIKE \'%' + String.escapeSingleQuotes(s) + '%\'';
                }
                else
                {
                    s = 'OR Title LIKE \'%' + String.escapeSingleQuotes(s) + '%\'';
                }

                queryString = queryString + s;
                firstRun = false;
            }
        }
        else
        {
            queryString = 'WHERE (Title LIKE \'%' + String.escapeSingleQuotes(searchstring) + '%\'';
        }

        baseQuery  = 'SELECT Id, Title, UrlName, LastPublishedDate, LastModifiedById ' +
                     'FROM KnowledgeArticleVersion ' +
                     queryString + ')' +
                     'AND (PublishStatus = \'online\' AND Language = \'en_US\')';
        System.debug('!!!!Query ' + baseQuery);
        maxSize = Database.query(baseQuery).size();

        Integer offsetNum = (pageNumber - 1) * PAGE_SIZE;
        String query = baseQuery + ' LIMIT ' + PAGE_SIZE + ' OFFSET ' + offsetNum;

        String strMaxSize = maxSize.format();
        String strPAGE_SIZE = PAGE_SIZE.format();
        maxPages = Math.ceil(Decimal.valueOf(strMaxSize)/Decimal.valueOf(strPAGE_SIZE));

        lowListNum = offsetNum + 1;
        if (pageNumber == maxPages)
        {
            highListNum = maxSize;
        }
        else
        {
            highListNum = pageNumber * PAGE_SIZE;
        }

        searchstring = searchstring.capitalize();

        try
        {
            articleList = Database.query(query);
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);
        }
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
}