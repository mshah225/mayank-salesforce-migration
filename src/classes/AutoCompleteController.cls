// AutoCompleteController.cls
global with sharing class AutoCompleteController {

    public AutoCompleteController(ServiceCenter controller) { }
    public AutoCompleteController(AKBController controller) { }
    public AutoCompleteController(ApexPages.StandardController controller) { }

    // Instance fields
    public String searchTerm {get; set;}
    public String selectedArticle {get; set;}
    
    // JS Remoting action called when searching for an article
    @RemoteAction
    global static List<KnowledgeArticleVersion> searchArticle(String searchTerm) {
        List<KnowledgeArticleVersion> articles = Database.query('SELECT Id, KnowledgeArticleId, Title FROM KnowledgeArticleVersion where (PublishStatus = \'online\' and Language = \'en_US\') AND title like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' LIMIT 30');
        return articles;
    }
}