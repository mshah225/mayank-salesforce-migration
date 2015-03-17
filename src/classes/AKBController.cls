public with sharing class AKBController {
    
    public KnowledgeArticleVersion article {get;set;}
    public FAQ__kav faq {get;set;}
    public Informational__kav info {get;set;}
    public How_To__kav howTo {get;set;}
    public Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
    public AKB_Article_Feedback__c feedbackHelpful {get;set;}
    public AKB_Article_Feedback__c[] feedbackGiven;
    public String articleNumber;
    public String titleKeyword;
   
    // This class decides what type of article is passed to the page and then queries the appropriate category data.
    public AKBController() {   
        article = [SELECT Title, ArticleType, ArticleNumber, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id') AND PublishStatus = 'Online'];
                              
        if (article.ArticleType.equals('FAQ__kav')) {
            faq = [SELECT KnowledgeArticleId, Title, Functional_Group__c, Question__c, Answer__c FROM FAQ__kav WHERE PublishStatus='Online' AND KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')];
        }
        
        else if (article.ArticleType.equals('Informational__kav')) {
            info = [SELECT KnowledgeArticleId, Title, Functional_Group__c, Information__c FROM Informational__kav WHERE PublishStatus='Online' AND KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')];
        }
        
        else if (article.ArticleType.equals('How_To__kav')) {
            howTo = [SELECT KnowledgeArticleId, Title, Functional_Group__c, Content__c FROM How_To__kav WHERE PublishStatus='Online' AND KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')];
        }
        
        feedbackHelpful = new AKB_Article_Feedback__c(); 
        
    }
    
    public string getTitleKeyword() {        
        if (article.ArticleType.equals('FAQ__kav')) {
            titleKeyword = [SELECT Title FROM FAQ__kav WHERE KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id') AND PublishStatus = 'Online'].Title;
            
        }
        
        else if (article.ArticleType.equals('Informational__kav')) {
            titleKeyword = [SELECT Title FROM Informational__kav WHERE KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id') AND PublishStatus = 'Online'].Title;
        }
        
        else if (article.ArticleType.equals('How_To__kav')) {
            titleKeyword = [SELECT Title FROM How_To__kav WHERE KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id') AND PublishStatus = 'Online'].Title;
        }
        
        return titleKeyword;
    }
    
    public PageReference helpfulYes() {
        feedbackHelpful.Article_Id__c = ApexPages.currentPage().getParameters().get('id');
        feedbackHelpful.Article_Number__c = article.ArticleNumber;
        feedbackHelpful.Article_Title__c = article.Title;
        feedbackHelpful.Contact__c = contactId;
        feedbackHelpful.Helpful__c = true;
        feedbackHelpful.Session_ID__c = UserInfo.getSessionId();
        insert feedbackHelpful;
        
        //Page Confirmation
        PageReference confirmPage = new PageReference('/akb?id=' + ApexPages.currentPage().getParameters().get('id') + '&Feedback=yes');
        confirmPage.setRedirect(true);
        return confirmPage;
    }
    
    public PageReference helpfulNo() {
        feedbackHelpful.Article_Id__c = ApexPages.currentPage().getParameters().get('id');
        feedbackHelpful.Article_Number__c = article.ArticleNumber;
        feedbackHelpful.Article_Title__c = article.Title;
        feedbackHelpful.Contact__c = contactId;
        feedbackHelpful.Helpful__c = false;
        feedbackHelpful.Session_ID__c = UserInfo.getSessionId();
        feedbackHelpful.Comments__c = feedbackHelpful.Comments__c;
        insert feedbackHelpful;
        
        //Page Confirmation
        PageReference confirmPage = new PageReference('/akb?id=' + ApexPages.currentPage().getParameters().get('id') + '&Feedback=yes');
        confirmPage.setRedirect(true);
        return confirmPage;
    }
    
    public Boolean getfeedbackVisible() {
        if(contactId != null) {
            feedbackGiven = [SELECT Article_Id__c FROM AKB_Article_Feedback__c WHERE Article_Id__c = :ApexPages.currentPage().getParameters().get('id') AND Contact__c = :contactId];
            System.Debug('Here\'s feeedbackGiven. Contact not null: ' + feedbackGiven);
        } else {
            String sfAlias = [SELECT Alias FROM User WHERE Id = :UserInfo.getUserId()].Alias;
            Id sfContact = [SELECT Id FROM Contact WHERE ASURITE_Id__c = :sfAlias LIMIT 1].Id;
            feedbackGiven = [SELECT Article_Id__c FROM AKB_Article_Feedback__c WHERE Article_Id__c = :ApexPages.currentPage().getParameters().get('id') AND Contact__c = :sfContact];
            System.Debug('Here\'s feeedbackGiven. Contact null: ' + feedbackGiven);
        }

        if(feedbackGiven.size() > 0) {
            return false;
        } else {
            return true;
        }
    }
    
    
    //Removes the confirmation from the screen and then refreshes the page.
    public PageReference removeFeedbackParam() {
        PageReference casePage = new PageReference('/akb?id=' + ApexPages.currentPage().getParameters().get('id'));
        casePage.setRedirect(true);
        return casePage; 
    }
    
    public String getArticleNumber() {
        articleNumber = [SELECT ArticleNumber FROM KnowledgeArticleVersion WHERE KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')  AND PublishStatus = 'Online'].ArticleNumber;
        return articleNumber;
    }
}