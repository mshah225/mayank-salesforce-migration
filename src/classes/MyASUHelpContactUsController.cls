public without sharing class MyASUHelpContactUsController {
    public String financeChatButton { get; set; }
    public String financeDisplayName { get; set; }
    public String studentServicesChatButton { get; set; }
    public String studentServicesDisplayName { get; set; }
    public String technicalSupportChatButton { get; set; }
    public String technicalSupportDisplayName { get; set; }
    public String orgId { get; set; }
    public String deploymentId { get; set; }
    public String chatEndpoint { get; set; }

    private Id caseId;
    public Boolean viewingAs { get; set; }
    public Case newCase { get; set; }
    public Contact userContact;
    public String stopViewAsUrl { get; set; }
    public String viewAsUrl { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String emplId { get; set; }
    public String userAsurite;
    public String asurite { get; set; }
    public String masqScopeIdCookie { get; set; }
    public MyAsuViewAs viewAsService;

    public Map<String, String> accordionPanels { get; set; }
    public Map<String, String> accordionPanelsUrlSafe { get; set; }
    public Map<String, String> accordionPanelsIcon { get; set; }

    public MyASUHelpContactUsController() {
        Live_Agent_Button__c financeChatLAB = Live_Agent_Button__c.getInstance('Finances_Live_Chat');
        Live_Agent_Button__c studentServicesChatLAB = Live_Agent_Button__c.getInstance('ASU_Services_Live_Chat');
        Live_Agent_Button__c technicalSupportChatLAB = Live_Agent_Button__c.getInstance('Technical_Support_Live_Chat');

        orgId = financeChatLAB.Org_Id__c;
        deploymentId = financeChatLAB.Chat_Deployment__c;
        chatEndpoint = financeChatLAB.Chat_Endpoint__c;

        financeChatButton = financeChatLAB.Chat_Button_Id__c;
        financeDisplayName = financeChatLAB.Display_Name__c;
        studentServicesChatButton = studentServicesChatLAB.Chat_Button_Id__c;
        studentServicesDisplayName = studentServicesChatLAB.Display_Name__c;
        technicalSupportChatButton = technicalSupportChatLAB.Chat_Button_Id__c;
        technicalSupportDisplayName = technicalSupportChatLAB.Display_Name__c;

        newCase = new Case();
        viewingAs = false;
        createViewAs();
        popUserContact();

        setAccordionPanels();
    }

    public void createViewAs() {
        if (ApexPages.currentPage().getParameters().get('masqScopeIdCookie') != null) {
            masqScopeIdCookie = ApexPages.currentPage().getParameters().get('masqScopeIdCookie');
            userAsurite = [SELECT ASURite_Id__c FROM User WHERE Id = :UserInfo.getUserId()].ASURite_Id__C;
            viewAsService = new MyAsuViewAs(masqScopeIdCookie, userAsurite);
        } else {
            viewingAs = false;
        }
    }

    public void popUserContact() {
        if (viewAsService != null && viewAsService.hasViewAsRights) {
            userContact = viewAsService.getContact(viewAsService.getResponseValueFromMap('effectiveAsurite'));
            stopViewAsUrl = viewAsService.getResponseValueFromMap('stopViewAsUrl');
            viewAsUrl = viewAsService.getResponseValueFromMap('viewAsUrl');
            viewingAs = true;
        } else {
            userContact = ContactService.getLoggedInContact();
        }
        firstName = userContact.FirstName;
        lastName = userContact.LastName;
        emplId = userContact.EMPLID__c;
        asurite = userContact.ASURite_ID__c;
    }

    private void setAccordionPanels() {
        accordionPanels = new Map<String, String>();
        accordionPanelsUrlSafe = new Map<String, String>();
        accordionPanelsIcon = new Map<String, String>();

        String panelOneIcon = 'fa-envelope';
        String panelOneHeader = 'Email Us';
        String panelOneContent =
            '<apex:form>' +
            '<label for="myasu-help-contact-us-email-subject" class="myasu-help-contact-us-email-subject-label">Subject</label>' +
            '<apex:inputField id="myasu-help-contact-us-email-subject" styleClass="myasu-help-contact-us-email-subject" value="{!newCase.Subject}"' +
            'required="true" label="" />' +
            '<label for="myasu-help-contact-us-email-message" class="myasu-help-contact-us-email-message-label">Message</label>' +
            '<apex:inputField id="myasu-help-contact-us-email-message" styleClass="myasu-help-contact-us-email-message" value="{!newCase.Description}"' +
            'required="true" label="" />' +
            '<div class="myasu-help-contact-us-email-message-submit-wrapper">' +
            '<apex:commandLink styleClass="btn btn-primary myasu-help-contact-us-email-message-submit" action="{!submitCase}">' +
            'Submit' +
            '</apex:commandLink>' +
            '</div>' +
            '</apex:form>';

        String panelTwoIcon = 'fa-commenting';
        String panelTwoHeader = 'Live Chat';
        String panelTwoContent = '';

        String panelThreeIcon = 'fa-phone';
        String panelThreeHeader = 'Call ';
        String panelThreeContent = '';

        accordionPanels.put(panelOneHeader, panelOneContent);
    }

    public PageReference viewCase() {
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        String current = ApexPages.currentPage().getUrl();
        current = current.split('apex/')[1];
        PageReference viewCasePage = new PageReference('/viewcase');
        viewCasePage.getParameters().put('id', caseId);

        viewCasePage.getParameters().put('source', current);

        if (viewingAs) {
            viewCasePage.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
        }

        return viewCasePage;
    }

    public PageReference submitCase() {
        Boolean isCaseCreated = true;
        PageReference confirmPage;
        if (viewingAs) {
            PageReference go = new PageReference(ApexPages.currentPage().getUrl());
            go.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
            go.setRedirect(true);

            return go;
        }

        newCase.ContactId = userContact.Id;
        newCase.Web_Submission__c = 'My ASU Standard';
        try {
            insert newCase;
            ApexPages.currentPage().getParameters().put('caseId', newCase.Id);
            confirmPage = viewCase();
            confirmPage.setRedirect(true);
            return confirmPage;
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('ContactId', newCase.ContactId));
            vars.add(ErrorLogger.convertStringToJSON('Subject', newCase.Subject));
            vars.add(ErrorLogger.convertStringToJSON('Description', newCase.Description));
            ErrorLogger.log(e, vars, false);
            return null;
        }
    }
}
