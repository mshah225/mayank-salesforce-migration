/**
 * The AKBController class manages the operations related to article feedback and suggestions within the MyASUHelpController context.
 */
public without sharing class AKBController {
    private MyASUHelpController myASUHelp;
    public AKB_Article_Feedback__c feedbackHelpful { get; set; }
    public AKB_Article_Feedback__c[] feedbackGiven;
    public Case suggestAnArticle { get; set; }
    public FAQ__kav article { get; set; }
    public Contact userContact { get; set; }
    public Id articleId;
    public List<String> fixedLinks;
    public String titleKeyword;
    public String urlsJSON { get; set; }
    public String fixedLinksJSON { get; set; }
    public String articleWasHelpful { get; set; }

    /**
     * Constructor to initialize AKBController with MyASUHelpController.
     * Queries the article based on the current page's ID parameter.
     *
     * @param myASUHelp An instance of MyASUHelpController
     */
    public AKBController(MyASUHelpController myASUHelp) {
        this.myASUHelp = myASUHelp;
        userContact = myASUHelp.userContact;

        for (FAQ__kav matchedArticle : [
            SELECT
                Id,
                KnowledgeArticleId,
                Title,
                RecordTypeId,
                RecordType.Name,
                RecordType.DeveloperName,
                ArticleNumber,
                CreatedBy.Name,
                UrlName,
                IsVisibleInPkb,
                IsVisibleInApp,
                LastModifiedDate,
                Functional_Group__c,
                Answer__c
            FROM FAQ__kav
            WHERE
                KnowledgeArticleId = :ApexPages.currentPage().getParameters().get('id')
                AND RecordType.Name = 'FAQ'
                AND PublishStatus = 'Online'
                AND ValidationStatus = 'Published'
                AND IsDeleted = FALSE
                AND IsLatestVersion = TRUE
            LIMIT 1
        ]) {
            article = matchedArticle;
        }

        articleWasHelpful = '';
        feedbackHelpful = new AKB_Article_Feedback__c();
        suggestAnArticle = new Case();
    }

    /**
     * Retrieves the title keyword of the article.
     * Truncates the title to 99 characters if necessary.
     *
     * @return the title keyword
     */
    public String getTitleKeyword() {
        if (article.RecordType.Name == 'FAQ') {
            titleKeyword = article.Title;
        }
        if (titleKeyword.length() > 99) {
            titleKeyword = titleKeyword.substring(0, 99);
        }
        return titleKeyword;
    }

    /**
     * Marks the article as helpful and inserts feedback.
     * Redirects to the confirmation page.
     *
     * @return the PageReference to the confirmation page
     */
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
        if (article.RecordType.Name == 'FAQ') {
            feedbackHelpful.Functional_Group__c = article.Functional_Group__c;
            feedbackHelpful.Type__c = article.RecordType.Name;
        }
        insert feedbackHelpful;
        PageReference confirmPage = new PageReference(
            '/authkb?id=' + ApexPages.currentPage().getParameters().get('id') + '&Feedback=yes'
        );
        confirmPage.setRedirect(true);
        return confirmPage;
    }

    /**
     * Marks the article as not helpful and inserts feedback.
     * Redirects to the confirmation page.
     *
     * @return the PageReference to the confirmation page
     */
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
        if (article.RecordType.Name == 'FAQ') {
            feedbackHelpful.Functional_Group__c = article.Functional_Group__c;
            feedbackHelpful.Type__c = article.RecordType.Name;
        }
        insert feedbackHelpful;
        PageReference confirmPage = new PageReference(
            '/authkb?id=' + ApexPages.currentPage().getParameters().get('id') + '&Feedback=yes'
        );
        confirmPage.setRedirect(true);
        return confirmPage;
    }

    /**
     * Resets the article helpfulness status to null.
     */
    public void setArticleHelpfulNull() {
        articleWasHelpful = '';
    }

    /**
     * Sets the article helpfulness status to 'no'.
     */
    public void setArticleHelpfulNo() {
        articleWasHelpful = 'no';
    }

    /**
     * Checks if feedback is visible for the current article.
     *
     * @return true if feedback is not given yet, otherwise false
     */
    public Boolean getFeedbackVisible() {
        feedbackGiven = [
            SELECT Article_Id__c
            FROM AKB_Article_Feedback__c
            WHERE Article_Id__c = :ApexPages.currentPage().getParameters().get('id') AND Contact__c = :userContact.Id
        ];
        return (feedbackGiven.size() > 0) ? false : true;
    }

    /**
     * Changes the article links based on the provided JSON of URLs.
     * Updates the fixedLinksJSON with new links.
     */
    public void changeLink() {
        fixedLinks = new List<String>();
        List<String> urls = (List<String>) JSON.deserialize(urlsJSON, List<String>.class);
        for (String url : urls) {
            try {
                articleId = [
                    SELECT KnowledgeArticleId
                    FROM FAQ__kav
                    WHERE
                        UrlName = :url
                        AND Language = 'en_US'
                        AND RecordType.Name = 'FAQ'
                        AND ValidationStatus = 'Published'
                        AND PublishStatus = 'Online'
                        AND IsDeleted = FALSE
                        AND IsLatestVersion = TRUE
                ]
                .KnowledgeArticleId;
            } catch (Exception e) {
                articleId = null;
            }
            String newLink = '/authkb?id=' + articleId;
            fixedLinks.add(newLink);
        }
        fixedLinksJSON = JSON.serialize(fixedLinks);
    }
}