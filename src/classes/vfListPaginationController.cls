public with sharing class vfListPaginationController
{
    private final Integer PAGE_SIZE = 10;
    private String baseQuery;
    public Integer maxSize { get; set; }
    public List<KnowledgeARticleVersion> articleList { get; set; }
    public String searchstring { get; set; }
    public Integer pageNumber = 1;

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

    public void articleSearch()
    {
        if (searchstring.length() > 99)
        {
            searchstring = searchstring.substring(0,99);
        }

        baseQuery  = 'SELECT Id, Title, UrlName, LastPublishedDate,LastModifiedById ' +
                     'FROM KnowledgeArticleVersion ' +
                     'WHERE Title LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\' ' +
                     'AND (PublishStatus = \'online\' AND Language = \'en_US\')';
        maxSize = Database.query(baseQuery).size();

        Integer offsetNum = (pageNumber - 1) * PAGE_SIZE;
        String query = baseQuery + ' LIMIT ' + PAGE_SIZE + ' OFFSET ' + offsetNum;
        try
        {
            articleList = Database.query(query);
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);
        }
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