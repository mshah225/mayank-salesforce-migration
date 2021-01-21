public without sharing class AKBController {
    private MyASUHelpController myASUHelp;
    public AKB_Article_Feedback__c feedbackHelpful { get; set; }
    public AKB_Article_Feedback__c[] feedbackGiven;
    public Case suggestAnArticle { get; set; }
    public FAQ__kav faq { get; set; }
    public KnowledgeArticleVersion article { get; set; }
    public Contact userContact { get; set; }
    public Id articleId;
    public List<String> urls;
    public List<String> fixedLinks;
    public String titleKeyword;
    public String newLink;
    public String urlsJSON { get; set; }
    public String fixedLinksJSON { get; set; }
    public String userAlias;
    public String funcGroup { get; set; }
    public String artType { get; set; }
    public String articleWasHelpful { get; set; }

    public AKBController(MyASUHelpController myASUHelp) {
        this.myASUHelp = myASUHelp;
        userContact = myASUHelp.userContact;
        article = [
            SELECT Title, ArticleType, ArticleNumber, KnowledgeArticleId, CreatedBy.Name
            FROM KnowledgeArticleVersion
            WHERE KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id') AND PublishStatus = 'Online'
        ];

        if (article.ArticleType.equals('FAQ__kav')) {
            faq = [
                SELECT KnowledgeArticleId, Title, Functional_Group__c, Answer__c, toLabel(ArticleType), LastModifiedDate
                FROM FAQ__kav
                WHERE
                    PublishStatus = 'Online'
                    AND KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')
            ];

            funcGroup = faq.Functional_Group__c;
            artType = faq.ArticleType;
        }

        articleWasHelpful = '';
        feedbackHelpful = new AKB_Article_Feedback__c();
        suggestAnArticle = new Case();
    }

    public string getTitleKeyword() {
        if (article.ArticleType.equals('FAQ__kav')) {
            titleKeyword = [
                SELECT Title
                FROM FAQ__kav
                WHERE
                    KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')
                    AND PublishStatus = 'Online'
            ]
            .Title;
        }

        if (titleKeyword.length() > 99) {
            titleKeyword = titleKeyword.substring(0, 99);
        }

        return titleKeyword;
    }

    public PageReference helpfulYes() {
        if (myASUHelp.viewingAs) {
            PageReference go = new PageReference(ApexPages.currentPage().getUrl());
            go.getParameters().put('masqScopeIdCookie', myASUHelp.masqScopeIdCookie);
            go.setRedirect(true);
            return go;
        }

        articleWasHelpful = 'yes';

        feedbackHelpful.Article_Id__c = ApexPages.currentPage().getParameters().get('id');
        feedbackHelpful.Article_Number__c = article.ArticleNumber;
        feedbackHelpful.Article_Title__c = article.Title;
        feedbackHelpful.Contact__c = userContact.Id;
        feedbackHelpful.Helpful__c = true;
        feedbackHelpful.Session_ID__c = UserInfo.getSessionId();
        feedbackHelpful.Article_Author__c = article.CreatedBy.Name;

        if (article.ArticleType.equals('FAQ__kav')) {
            feedbackHelpful.Functional_Group__c = faq.Functional_Group__c;
            feedbackHelpful.Type__c = faq.ArticleType;
        }

        insert feedbackHelpful;

        PageReference confirmPage = new PageReference(
            '/authkb?id=' +
            ApexPages.currentPage().getParameters().get('id') +
            '&Feedback=yes'
        );
        confirmPage.setRedirect(true);

        return confirmPage;
    }

    public PageReference helpfulNo() {
        if (myASUHelp.viewingAs) {
            PageReference go = new PageReference(ApexPages.currentPage().getUrl());
            go.getParameters().put('masqScopeIdCookie', myASUHelp.masqScopeIdCookie);
            go.setRedirect(true);
            return go;
        }

        feedbackHelpful.Article_Id__c = ApexPages.currentPage().getParameters().get('id');
        feedbackHelpful.Article_Number__c = article.ArticleNumber;
        feedbackHelpful.Article_Title__c = article.Title;
        feedbackHelpful.Contact__c = userContact.Id;
        feedbackHelpful.Helpful__c = false;
        feedbackHelpful.Session_ID__c = UserInfo.getSessionId();
        feedbackHelpful.Comments__c = feedbackHelpful.Comments__c;
        feedbackHelpful.Article_Author__c = article.CreatedBy.Name;

        if (article.ArticleType.equals('FAQ__kav')) {
            feedbackHelpful.Functional_Group__c = faq.Functional_Group__c;
            feedbackHelpful.Type__c = faq.ArticleType;
        }

        insert feedbackHelpful;

        PageReference confirmPage = new PageReference(
            '/authkb?id=' +
            ApexPages.currentPage().getParameters().get('id') +
            '&Feedback=yes'
        );
        confirmPage.setRedirect(true);

        return confirmPage;
    }

    public void setArticleHelpfulNull() {
        articleWasHelpful = '';
    }

    public void setArticleHelpfulNo() {
        articleWasHelpful = 'no';
    }

    public Boolean getfeedbackVisible() {
        feedbackGiven = [
            SELECT Article_Id__c
            FROM AKB_Article_Feedback__c
            WHERE Article_Id__c = :ApexPages.currentPage().getParameters().get('id') AND Contact__c = :userContact.Id
        ];

        return (feedbackGiven.size() > 0) ? false : true;
    }

    public void changeLink() {
        fixedLinks = new List<String>();
        System.Debug('JSON URLs: ' + urlsJSON);
        urls = (List<String>) JSON.deserialize(urlsJSON, List<String>.class);
        System.Debug('Deserialized URLs: ' + urls);

        for (String s : urls) {
            System.Debug('URLName: ' + s);

            try {
                articleId = [
                    SELECT KnowledgeArticleId
                    FROM KnowledgeArticleVersion
                    WHERE UrlName = :s AND Language = 'en_US' AND PublishStatus = 'Online'
                ]
                .KnowledgeArticleId;
            } catch (Exception e) {
                articleId = null;
            }

            newLink = '/authkb?id=' + articleId;
            fixedLinks.add(newLink);
        }

        fixedLinksJSON = JSON.serialize(fixedLinks);
        System.Debug('Here\'s the Fixed Link: ' + fixedLinks);
    }
}
