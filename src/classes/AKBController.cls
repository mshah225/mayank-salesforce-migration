public with sharing class AKBController {
    
    public KnowledgeArticleVersion article {get;set;}
    public FAQ__kav faq {get;set;}
    public Informational__kav info {get;set;}
    public How_To__kav howto {get;set;}
   
    // This class decides what type of article is passed to the page and then queries the appropriate category data.
    public AKBController() {   
        article = [SELECT Title, ArticleType, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id') AND PublishStatus = 'Online'];
          
                              
        if (article.ArticleType.equals('FAQ__kav')) {
            faq = [SELECT KnowledgeArticleId, Title, Functional_Group__c, Question__c, Answer__c FROM FAQ__kav WHERE PublishStatus='Online' AND KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')];
        }
        
        else if (article.ArticleType.equals('Informational__kav')) {
            info = [SELECT KnowledgeArticleId, Title, Functional_Group__c, Information__c FROM Informational__kav WHERE PublishStatus='Online' AND KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')];
        }
        
        else if (article.ArticleType.equals('How_To__kav')) {
            howto = [SELECT KnowledgeArticleId, Title, Functional_Group__c, Content__c FROM How_To__kav WHERE PublishStatus='Online' AND KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')];
        }
    }
}