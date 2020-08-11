public with sharing class MyASUHelpSuggestAnArticleController {
    public Case suggestAnArticle { get; set; }
    public String suggestedArticleDescription { get; set; }
    private MyAsuViewAs viewAsService;
    public Boolean viewingAs { get; set; }
    public Contact userContact;
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String emplId { get; set; }
    public String masqScopeIdCookie { get; set; }
    public String stopViewAsUrl { get; set; }
    public String viewAsUrl { get; set; }
    public String asurite { get; set; }
    public String userAsurite;

    public MyASUHelpSuggestAnArticleController() {
        suggestAnArticle = new Case();
        viewingAs = false;
        checkForViewAs();
    }

    public void checkForViewAs() {
        if (ApexPages.currentPage().getParameters().get('masqScopeIdCookie') != null) {
            masqScopeIdCookie = ApexPages.currentPage().getParameters().get('masqScopeIdCookie');
            userAsurite = [SELECT ASURite_Id__c FROM User WHERE Id = :UserInfo.getUserId()].ASURite_Id__C;
            viewAsService = new MyAsuViewAs(masqScopeIdCookie, userAsurite);
        } else {
            viewingAs = false;
        }
    }

    public PageReference suggestAnArticleSubmit() {
        if (viewingAs) {
            PageReference go = new PageReference(ApexPages.currentPage().getUrl());
            go.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
            go.setRedirect(true);
            return go;
        }

        suggestAnArticle.Subject = 'Suggest An Article';
        if (suggestedArticleDescription != null) {
            suggestAnArticle.Description = suggestedArticleDescription;
        }
        suggestAnArticle.ContactId = userContact.Id;
        suggestAnArticle.CC_Functional_Group__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Student Success Innovations'
            LIMIT 1
        ]
        .Id;
        suggestAnArticle.CC_Category__c = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Category'
                AND Active__c = TRUE
                AND Name = 'Knowledge'
                AND Parent__c = :suggestAnArticle.CC_Functional_Group__c
            LIMIT 1
        ]
        .Id;
        suggestAnArticle.Origin__c = 'My ASU';
        suggestAnArticle.Visible_by_Contact__c = false;
        suggestAnArticle.OwnerId = [
            SELECT Id
            FROM Group
            WHERE Name = 'Student Success Innovations (Case)' AND Type = 'Queue'
        ]
        .Id;

        insert suggestAnArticle;

        return redirectWithParams(ApexPages.currentPage(), 'Suggest', 'yes');
    }

    public PageReference redirectWithParams(PageReference page, String param, String value) {
        PageReference redirect = page;
        redirect.getParameters().put(param, value);
        redirect.setRedirect(true);
        return redirect;
    }
}
