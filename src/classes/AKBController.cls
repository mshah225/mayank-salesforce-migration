public with sharing class AKBController 
{    
    public AKB_Article_Feedback__c feedbackHelpful {get;set;}
    public AKB_Article_Feedback__c[] feedbackGiven;
    public FAQ__kav faq {get;set;}
    public How_To__kav howTo {get;set;}
    public Informational__kav info {get;set;}
    public KnowledgeArticleVersion article {get;set;}
    public Id contactId;
    public Id articleId;
    public List<String> urls;
    public List<String> fixedLinks;
    public String titleKeyword;
    public String newLink;
    public String urlsJSON { get;set; }
    public String fixedLinksJSON { get;set; }
    public String userAlias;
   
    public AKBController() 
    {   
        article = [SELECT Title, ArticleType, ArticleNumber, KnowledgeArticleId 
                   FROM KnowledgeArticleVersion 
                   WHERE KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id') 
                   AND PublishStatus = 'Online'];                      
        if (article.ArticleType.equals('FAQ__kav')) 
        {
            faq = [SELECT KnowledgeArticleId, Title, Functional_Group__c, Question__c, Answer__c 
                   FROM FAQ__kav 
                   WHERE PublishStatus='Online' 
                   AND KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')];
        } 
        else if (article.ArticleType.equals('Informational__kav')) 
        {
            info = [SELECT KnowledgeArticleId, Title, Functional_Group__c, Information__c 
                    FROM Informational__kav 
                    WHERE PublishStatus='Online' 
                    AND KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')];
        } 
        else if (article.ArticleType.equals('How_To__kav')) 
        {
            howTo = [SELECT KnowledgeArticleId, Title, Functional_Group__c, Content__c 
                     FROM How_To__kav 
                     WHERE PublishStatus='Online' 
                     AND KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')];
        }
        feedbackHelpful = new AKB_Article_Feedback__c(); 
    }
    
    public string getTitleKeyword() 
    {        
        if (article.ArticleType.equals('FAQ__kav')) 
        {
            titleKeyword = [SELECT Title 
                            FROM FAQ__kav 
                            WHERE KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id') 
                            AND PublishStatus = 'Online'].Title;
        } 
        else if (article.ArticleType.equals('Informational__kav')) 
        {
            titleKeyword = [SELECT Title 
                            FROM Informational__kav 
                            WHERE KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id') 
                            AND PublishStatus = 'Online'].Title;
        } 
        else if (article.ArticleType.equals('How_To__kav')) 
        {
            titleKeyword = [SELECT Title 
                            FROM How_To__kav 
                            WHERE KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id') 
                            AND PublishStatus = 'Online'].Title;
        }
        if(titleKeyword.length() > 99)
        {
            titleKeyword = titleKeyword.substring(0, 99);
        }
        return titleKeyword;
    }

    public Id getContactId() 
    {
        userAlias = [SELECT Alias 
                     FROM User 
                     WHERE Id = :UserInfo.getUserId()].Alias;
        contactId = [SELECT Id 
                     FROM Contact 
                     WHERE ASURITE_Id__c = :userAlias].Id;
        return contactId;
    }
    
    public PageReference helpfulYes() 
    {
        feedbackHelpful.Article_Id__c = ApexPages.currentPage().getParameters().get('id');
        feedbackHelpful.Article_Number__c = article.ArticleNumber;
        feedbackHelpful.Article_Title__c = article.Title;
        feedbackHelpful.Contact__c = contactId;
        feedbackHelpful.Helpful__c = true;
        feedbackHelpful.Session_ID__c = UserInfo.getSessionId();
        insert feedbackHelpful;
        
        PageReference confirmPage = new PageReference('/akb?id=' + ApexPages.currentPage().getParameters().get('id') + '&Feedback=yes');
        confirmPage.setRedirect(true);
        return confirmPage;
    }
    
    public PageReference helpfulNo() 
    {
        feedbackHelpful.Article_Id__c = ApexPages.currentPage().getParameters().get('id');
        feedbackHelpful.Article_Number__c = article.ArticleNumber;
        feedbackHelpful.Article_Title__c = article.Title;
        feedbackHelpful.Contact__c = contactId;
        feedbackHelpful.Helpful__c = false;
        feedbackHelpful.Session_ID__c = UserInfo.getSessionId();
        feedbackHelpful.Comments__c = feedbackHelpful.Comments__c;
        insert feedbackHelpful;
        
        PageReference confirmPage = new PageReference('/akb?id=' + ApexPages.currentPage().getParameters().get('id') + '&Feedback=yes');
        confirmPage.setRedirect(true);
        return confirmPage;
    }
    
    public Boolean getfeedbackVisible() 
    {
        
        feedbackGiven = [SELECT Article_Id__c 
                         FROM AKB_Article_Feedback__c 
                         WHERE Article_Id__c = :ApexPages.currentPage().getParameters().get('id') 
                         AND Contact__c = :contactId];
        if (feedbackGiven.size() > 0) 
        {
            return false;
        } 
        else 
        {
            return true;
        }
    }
    
    public void changeLink() 
    {
        fixedLinks = new List<String>();
        System.Debug('JSON URLs: ' + urlsJSON);
        urls = (List<String>)JSON.deserialize(urlsJSON, List<String>.class);
        System.Debug('Deserialized URLs: ' + urls);
        for(String s: urls) 
        {
            System.Debug('URLName: ' + s);
            try 
            {
                articleId = [SELECT KnowledgeArticleId 
                             FROM KnowledgeArticleVersion 
                             WHERE UrlName = :s 
                             AND Language = 'en_US'
                             AND PublishStatus = 'Online'].KnowledgeArticleId;
            } 
            catch(Exception e) 
            {
                articleId = null;
            }
            newLink = '/akb?id=' + articleId;
            fixedLinks.add(newLink);
        }
        fixedLinksJSON = JSON.serialize(fixedLinks);
        System.Debug('Here\'s the Fixed Link: ' + fixedLinks);
    }
}