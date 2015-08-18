public with sharing class vfKeywordSearchController 
{
    private Static Final Integer PAGE_NUMBER = 10;
    public String searchstring { get;set; }

    public vfKeywordSearchController(ServiceCenter controller) {}
    public vfKeywordSearchController(ApexPages.StandardController controller) {}
    public vfKeywordSearchController(AKBController controller) {}
         
    public vfKeywordSearchController() 
    {
        String qryString = 'SELECT Id, title, UrlName, LastPublishedDate, LastModifiedById FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'en_US\') ORDER BY LastPublishedDate Desc';
        List<KnowledgeArticleVersion> articleList= Database.query(qryString);
        maxSize = articleList.size() ;
    }

    public void checkSearchString()
    {
        if (searchstring.length() > 99) 
        {
            searchstring = searchstring.substring(0,99);
        }
    }
     
    Integer currentPage = 1;
    Integer maxSize = 1;
     
    public Boolean getPrevRequired() 
    {
        return currentPage > 1;
    }
    
    public Boolean getNextRequired() 
    {
        return currentPage * PAGE_NUMBER < maxSize;
    }
     
    public Decimal getCurrentPageNumber() 
    {
        return this.currentPage;
    }
    
    public PageReference next() 
    {
        if (maxSize > this.currentPage * PAGE_NUMBER) 
        {
            this.currentPage = this.currentPage + 1;
        }
        return null;
    }    
     
    public PageReference previous() 
    {        
        if(this.currentPage > 1)
        {
            this.currentPage = this.currentPage - 1;
        }
        return null;
    }
}