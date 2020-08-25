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
    public MyASUHelpViewAsService viewAsService;

    public Map<String, String> accordionPanels { get; set; }
    public Map<String, String> accordionPanelsId { get; set; }
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

        accordionPanels = new Map<String, String>();
        accordionPanelsId = new Map<String, String>();
        accordionPanelsIcon = new Map<String, String>();
        setContactUsAccordionPanels();
    }

    public void createViewAs() {
        if (ApexPages.currentPage().getParameters().get('masqScopeIdCookie') != null) {
            masqScopeIdCookie = ApexPages.currentPage().getParameters().get('masqScopeIdCookie');
            userAsurite = [SELECT ASURite_Id__c FROM User WHERE Id = :UserInfo.getUserId()].ASURite_Id__C;
            viewAsService = new MyASUHelpViewAsService(masqScopeIdCookie, userAsurite);
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

    public void setContactUsAccordionPanels() {
        String panelOneId = 'myasu-help-contact-us-email';
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

        accordionPanelsId.put(panelOneHeader, panelOneId);
        accordionPanelsIcon.put(panelOneHeader, panelOneIcon);
        accordionPanels.put(panelOneHeader, panelOneContent);

        String panelTwoId = 'myasu-help-contact-us-chat';
        String panelTwoIcon = 'fa-commenting';
        String panelTwoHeader = 'Live Chat';
        String panelTwoContent =
            '<div class="myasu-help-contact-us-chat-link-finance">' +
            '<a id="liveagent_button_online_finances" class="chat-link" style="display: none; cursor: pointer" onclick="window.open(\'https://chatbotweb.m.asu.edu/?full=true\',\'NewButtonWindowName\',\'width=450,height=500,scrollbars=yes\')">{!financeDisplayName}</a>' +
            '<a id="liveagent_button_offline_finances" class="chat-link" style="display: none; cursor: pointer" onclick="window.open(\'https://chatbotweb.m.asu.edu/?full=true\',\'NewButtonWindowName\',\'width=450,height=500,scrollbars=yes\')">{!financeDisplayName}</a>' +
            '<script type="text/javascript">' +
            'if (!window._laq) { window._laq = []; }' +
            'window._laq.push(function () {' +
            'liveagent.showWhenOnline(financesChatId, document.getElementById(\'liveagent_button_online_finances\'));' +
            'liveagent.showWhenOffline(financesChatId, document.getElementById(\'liveagent_button_offline_finances\'));' +
            '});' +
            '</script>' +
            '</div>' +
            '<div class="myasu-help-contact-us-chat-link-technical">' +
            '<a id="liveagent_button_online_technical_support" class="chat-link" style="display: none; cursor: pointer" onclick="liveagent.startChat(techSupportChatId);">{!technicalSupportDisplayName}</a>' +
            '<a id="liveagent_button_offline_technical_support" class="chat-link" style="display: none; cursor: pointer" onclick="liveagent.startChat(techSupportChatId);">{!technicalSupportDisplayName}</a>' +
            '<script type="text/javascript">' +
            'if (!window._laq) { window._laq = []; }' +
            'window._laq.push(function () {' +
            'liveagent.showWhenOnline(techSupportChatId, document.getElementById(\'liveagent_button_online_technical_support\'));' +
            'liveagent.showWhenOffline(techSupportChatId, document.getElementById(\'liveagent_button_offline_technical_support\'));' +
            '});' +
            '</script>' +
            '</div>' +
            '<div class="myasu-help-contact-us-chat-link-student-services">' +
            '<a id="liveagent_button_online_student_services" class="chat-link" style="display: none; border: 0px none; cursor: pointer"' +
            'onclick="liveagent.startChat(studentServiceChatId)">{!studentServicesDisplayName}</a>' +
            '<a id="liveagent_button_offline_student_services" class="chat-link" style="display: none; border: 0px none; cursor: pointer"' +
            'onclick="liveagent.startChat(studentServiceChatId)">{!studentServicesDisplayName}</a>' +
            '<script type="text/javascript">' +
            'if (!window._laq) { window._laq = []; }' +
            'window._laq.push(function () {' +
            'liveagent.showWhenOnline(studentServiceChatId, document.getElementById(\'liveagent_button_online_student_services\'));' +
            'liveagent.showWhenOffline(studentServiceChatId, document.getElementById(\'liveagent_button_offline_student_services\'));' +
            '});' +
            '</script>' +
            '</div>';

        accordionPanelsId.put(panelTwoHeader, panelTwoId);
        accordionPanelsIcon.put(panelTwoHeader, panelTwoIcon);
        accordionPanels.put(panelTwoHeader, panelTwoContent);

        String panelThreeId = 'myasu-help-contact-us-phone';
        String panelThreeIcon = 'fa-phone';
        String panelThreeHeader =
            '<apex:outputText rendered="{!NormalPhone}">Call 1-855-ASU-5080</apex:outputText>' +
            '<apex:outputText rendered="{!RoverPhone}">>Call 1-844-ASU-6693</apex:outputText>';
        String panelThreeContent = '';

        accordionPanels.put(panelThreeHeader, panelThreeContent);
        accordionPanelsId.put(panelThreeHeader, panelThreeId);
        accordionPanelsIcon.put(panelThreeHeader, panelThreeIcon);
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
            // List<String> vars = new List<String>();
            // vars.add(ErrorLogger.convertStringToJSON('ContactId', newCase.ContactId));
            // vars.add(ErrorLogger.convertStringToJSON('Subject', newCase.Subject));
            // vars.add(ErrorLogger.convertStringToJSON('Description', newCase.Description));
            // ErrorLogger.log(e, vars, false);
            return null;
        }
    }
}
