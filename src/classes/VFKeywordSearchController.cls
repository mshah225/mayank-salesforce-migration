public with sharing class VFKeywordSearchController {
    private static final Integer PAGE_NUMBER = 10;
    public String searchstring {get;set;}

    public VFKeywordSearchController(ServiceCenter controller) {}
    public VFKeywordSearchController(ApexPages.StandardController controller) {}
    public VFKeywordSearchController(AKBController controller) {}
         
    public VFKeywordSearchController() {
        String qryString = 'SELECT Id, Title, UrlName, LastPublishedDate, LastModifiedById FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'en_US\') ORDER BY LastPublishedDate Desc';
        List <KnowledgeArticleVersion> articleList= Database.query(qryString);
        maxSize = articleList.size();
    }

    public void checkSearchString() {
        if (searchstring.length() > 99) {
            searchstring = searchstring.substring(0,99);
        }
    }
     
    Integer currentPage = 1;
    Integer maxSize = 1;
     
    public Boolean getPrevRequired() {
        return currentPage > 1;
    }
    
    public Boolean getNextRequired() {
        return currentPage * PAGE_NUMBER < maxSize;
    }
     
    public Decimal getCurrentPageNumber() {
        return this.currentPage;
    }
    
    public PageReference next() {
        if (maxSize > this.currentPage * PAGE_NUMBER) {
            this.currentPage += 1;
        }
        return null;
    }    
     
    public PageReference previous() {
        if(this.currentPage > 1) {
            this.currentPage -= 1;
        }
        return null;
    }
}