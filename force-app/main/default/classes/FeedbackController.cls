public with sharing class FeedbackController {
    private MyASUHelpController sc;

    public Case c { get; set; }
    public Contact feedbackContact { get; set; }
    public Group queue { get; set; }
    public String comments { get; set; }
    public String userAlias;

    public FeedbackController(MyASUHelpController sc) {
        this.sc = sc;
        c = new Case();
        feedbackContact = sc.userContact;
        Queue = new Group();
    }

    public PageReference submit() {
        if (sc.viewingAs) {
            PageReference go = new PageReference(ApexPages.currentPage().getUrl());
            go.getParameters().put('masqScopeIdCookie', sc.masqScopeIdCookie);
            go.setRedirect(true);
            return go;
        }

        try {
            Queue = [SELECT Id FROM Group WHERE Name = 'Student-Centric Initiatives (Case)' AND Type = 'Queue'];
            c.OwnerId = Queue.Id;
            c.Subject = 'My ASU Help Tab Feedback';
            c.Description = comments;
            if (comments == '' || comments == null) {
                return null;
            }

            if (feedbackContact != null) {
                c.ContactId = feedbackContact.Id;
            }

            c.CC_Functional_Group__c = [
                SELECT Id
                FROM Case_Classification__c
                WHERE
                    RecordType.Name = 'Functional Group'
                    AND Active__c = TRUE
                    AND Name = 'Student-Centric Initiatives'
                    AND Parent__c = NULL
                LIMIT 1
            ]
            .Id;
            c.CC_Category__c = [
                SELECT Id
                FROM Case_Classification__c
                WHERE
                    RecordType.Name = 'Category'
                    AND Active__c = TRUE
                    AND Name = 'Service Center Feedback'
                    AND Parent__c = :c.CC_Functional_Group__c
                LIMIT 1
            ]
            .Id;
            c.Origin__c = 'My ASU';
            c.Visible_by_Contact__c = false;
            insert c;
        } catch (Exception e) {
        }

        PageReference submit = new PageReference('/studentSC?Confirm=feedback');
        submit.setRedirect(true);
        return submit;
    }
}
