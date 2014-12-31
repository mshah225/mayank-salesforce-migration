public with sharing class vfKeywordSearchController {

    public vfKeywordSearchController(ServiceCenter controller) { }
    public vfKeywordSearchController(ApexPages.StandardController controller) { }
    public vfKeywordSearchController(AKBController controller) { }

    //Page Size
     private Static Final Integer PAGE_NUMBER = 10;
     
    //Search String used in ArticleList tag
    public String searchstring { get; set; }
         

     public vfKeywordSearchController() {
     String qryString = 'SELECT Id, title, UrlName, LastPublishedDate, LastModifiedById FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'en_US\') ORDER BY LastPublishedDate Desc';
      List<KnowledgeArticleVersion> articleList= Database.query(qryString);
      maxSize = articleList.size() ;
     }
     
     //Keeps track of current page & max size of article list
     Integer currentPage = 1;
     Integer maxSize = 1;
     
     // Returns whether we need to see previous button or not
     public boolean getPrevRequired() {
      return currentPage > 1;
     }
    
     // Returns whether we need to see next button or not
     public boolean getNextRequired() {
      return currentPage * PAGE_NUMBER < maxSize;
     }
     
     //Returns current page number 
     public Decimal getCurrentPageNumber() {
      return this.currentPage;
     }
    
     //action for next click
     public PageReference next() {
      if(maxSize > this.currentPage * PAGE_NUMBER) {
       this.currentPage = this.currentPage + 1;
      }
      return null;
     }    
     
     //action for previous click
     public PageReference previous() {        
      if(this.currentPage > 1)
       this.currentPage = this.currentPage - 1;
      return null;
     }
     
}