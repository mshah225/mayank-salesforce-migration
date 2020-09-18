public with sharing class ViewCaseController {
    private static final Date EMAIL_VISIBILITY_DATE = Date.newInstance(2015, 4, 6);
    private static final Integer REPLY_ACCEPTANCE_THRESHOLD = 14;
    private Date today;
    private Term__c termAc;
    private Term__c termB;
    private Map<String, String> viewAsMap;
    private MyASUHelpViewAsService viewAsService;

    public Id caseId { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String emplId { get; set; }
    public String asurite { get; set; }
    public Boolean viewingAs { get; set; }
    public String stopViewAsUrl { get; set; }
    public String masqScopeIdCookie { get; set; }
    public String userAsurite;
    public Contact userContact;
    public String viewAsUrl { get; set; }
    public String caseFunctionalGroup { get; set; }
    public List<Opportunity> oppList;
    public String caseReply { get; set; }
    public Attachment replyCaseAttachment { get; set; }
    public List<String> varsForErrorLogging { get; set; }
    public List<Attachment> allCaseAttachments { get; set; }
    public Boolean showCaseAttachments { get; set; }
    public Boolean showOpenNewCaseAlert { get; set; }
    public String siteTitleName { get; set; }
    public String siteTitleUrl { get; set; }

    public ViewCaseController() {
        siteTitleName = 'My ASU';
        siteTitleUrl = '{!$Label.MyASU_Help_Base_URL}/myasu';
        viewingAs = false;
        replyCaseAttachment = new Attachment();
        checkForViewAs();
        popUserContact();
        popTerms();
        setCaseId();
        retrieveAttachmentList();
        showOpenNewCaseAlert = displayOpenNewCaseAlert();
    }

    public Boolean displayOpenNewCaseAlert() {
        if (String.isEmpty(caseId)) {
            return false;
        }
        Case caseOnPage = [SELECT ClosedDate FROM Case WHERE Id = :caseId];
        if (caseOnPage.ClosedDate == null) {
            return false;
        }
        Date caseClosedDate = caseOnPage.ClosedDate.date();
        if (caseClosedDate.daysBetween(System.Today()) > REPLY_ACCEPTANCE_THRESHOLD) {
            return true;
        }
        return false;
    }

    public void retrieveAttachmentList() {
        allCaseAttachments = [
            SELECT Id, Name, CreatedDate
            FROM Attachment
            WHERE ParentId = :caseId
            ORDER BY CreatedDate DESC
        ];
        if (allCaseAttachments == null || allCaseAttachments.isEmpty()) {
            showCaseAttachments = false;
        } else {
            showCaseAttachments = true;
        }
    }

    public void checkForViewAs() {
        if (ApexPages.currentPage().getParameters().get('masqScopeIdCookie') != null) {
            masqScopeIdCookie = ApexPages.currentPage().getParameters().get('masqScopeIdCookie');

            userAsurite = [SELECT ASURite_Id__c FROM User WHERE Id = :UserInfo.getUserId()].ASURite_Id__C;

            viewAsService = new MyASUHelpViewAsService(masqScopeIdCookie, userAsurite);
        } else {
            viewingAs = false;
        }
    }

    public void popTerms() {
        today = date.today();

        termAc = [
            SELECT Session_A_C_Start_Date__c
            FROM Term__c
            WHERE session_A_C_Start_Date__c > :System.today()
            LIMIT 1
        ];

        termB = [SELECT Session_B_Start_Date__c FROM Term__c WHERE session_B_Start_Date__c > :System.today() LIMIT 1];

        oppList = [
            SELECT Career__c, Term__c, StageName, Admitted_Session__c
            FROM Opportunity
            WHERE Contact__c = :userContact.Id
        ];
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

    public void setCaseId() {
        caseId = ApexPages.currentPage().getParameters().get('id');
    }

    public Case getCaseDetails() {
        if (viewAsService != null && viewAsService.hasViewAsRights) {
            return viewAsService.getCaseDetails(ApexPages.currentPage().getParameters().get('Id'));
        } else {
            Case returnCase = [
                SELECT
                    Id,
                    CaseNumber,
                    RecordType.Name,
                    CC_Functional_Group__c,
                    CC_Functional_Group__r.Name,
                    Subject,
                    Description,
                    Feedback_Link__c,
                    CreatedDate,
                    Status,
                    Origin,
                    Created_By_Name__c,
                    ClosedDate
                FROM Case
                WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
                LIMIT 1
            ];

            return returnCase;
        }
    }

    public String getSource() {
        String source = ApexPages.currentPage().getParameters().get('source');

        if (source == null) {
            source = 'studentSC';
        } else if (source.equals('viewAllCases')) {
            source = 'viewAllCases?source=studentSC';
        }

        return source;
    }

    public EmailMessage[] getEmailMessages() {
        Date launchDate = EMAIL_VISIBILITY_DATE;
        List<String> emailAddresses = new List<String>();
        emailAddresses.add(userContact.Email);
        emailAddresses.add(userContact.ASU_Email__c);
        emailAddresses.add(userContact.ASU_Gmail__c);
        emailAddresses.add(userContact.Personal_Email__c);
        emailAddresses.add(userContact.EPO_Email__c);
        emailAddresses.add(userContact.Lead_Email__c);
        emailAddresses.add(userContact.Lead_Secondary_Email__c);

        if (viewAsService != null) {
            return viewAsService.getCaseEmails(
                EMAIL_VISIBILITY_DATE,
                ApexPages.currentPage().getParameters().get('id'),
                emailAddresses
            );
        } else {
            return CaseService.getCaseEmailMessages(
                EMAIL_VISIBILITY_DATE,
                ApexPages.currentPage().getParameters().get('id'),
                emailAddresses
            );
        }
    }

    public List<ChatMessage> getChatMessages() {
        List<ChatMessage> allChatMessages = new List<ChatMessage>();
        allChatMessages.addAll(getBomgarChatMessages());
        allChatMessages.addAll(getLiveChatMessages());
        return allChatMessages;
    }

    private List<ChatMessage> getBomgarChatMessages() {
        List<bomgar__Event__c> bomgarMessages = [
            SELECT
                bomgar__DestinationValue__c,
                bomgar__EventDateTime__c,
                bomgar__EventType__c,
                bomgar__PerformedByType__c,
                bomgar__PerformedByValue__c,
                bomgar__Text__c,
                Id,
                Name,
                OwnerId
            FROM bomgar__Event__c
            WHERE
                bomgar__BomgarSession__r.bomgar__relatedcase__c = :ApexPages.currentPage().getParameters().get('Id')
                AND (bomgar__PerformedByType__c = 'representative'
                OR bomgar__PerformedByType__c = 'customer')
                AND bomgar__DestinationValue__c = 'everyone'
            ORDER BY bomgar__EventDateTime__c ASC
        ];

        List<ChatMessage> bomgarChatMessages = new List<ChatMessage>();
        for (bomgar__Event__c bomgarMessage : bomgarMessages) {
            bomgarChatMessages.add(new ChatMessage(bomgarMessage));
        }
        return bomgarChatMessages;
    }

    private List<ChatMessage> getLiveChatMessages() {
        List<Chat_Message__c> chatMessages = [
            SELECT Body__c
            FROM Chat_Message__c
            WHERE Case__c = :ApexPages.currentPage().getParameters().get('Id')
        ];
        List<ChatMessage> liveChatMessages = new List<ChatMessage>();
        for (Chat_Message__c message : chatMessages) {
            liveChatMessages.add(new ChatMessage(message));
        }
        return liveChatMessages;
    }

    public Boolean getNormalPhone() {
        return (userContact.CAP__c == null) ? true : false;
    }

    public Boolean getRoverPhone() {
        return (userContact.CAP__c != null) ? true : false;
    }

    public Boolean getHelpBox() {
        if ((oppList == null && userContact != null) || (oppList.size() == 0 && userContact != null)) {
            return true;
        } else if (
            (oppList[0].StageName == 'Enrolled' &&
            oppList[0].Career__c == 'Undergraduate' &&
            oppList[0].Admitted_Session__c == 'A/C') && today < date.valueOf(termAc.Session_A_C_Start_Date__c)
        ) {
            return false;
        } else if (
            (oppList[0].StageName == 'Enrolled' &&
            oppList[0].Career__c == 'Undergraduate' &&
            oppList[0].Admitted_Session__c == 'B') && today < date.valueOf(termB.Session_B_Start_Date__c)
        ) {
            return false;
        } else if (
            oppList[0].StageName != 'Enrolled' &&
            oppList[0].Career__c == 'Undergraduate' &&
            (userContact.Affiliation_Student__c == 'Current' ||
            userContact.Affiliation_Alumni__c == 'Current' ||
            userContact.Affiliation_Courtesy_Affiliate__c == 'Current' ||
            userContact.Affiliation_Employee__c == 'Current') &&
            today < date.valueOf(termB.Session_B_Start_Date__c)
        ) {
            return false;
        } else {
            return true;
        }
    }

    private PageReference redirectWithParams(String param, String value) {
        PageReference redirect = ApexPages.currentPage();
        redirect.getParameters().put(param, value);
        redirect.setRedirect(true);
        return redirect;
    }

    private void clearReplyContents() {
        caseReply = '';
    }

    private void clearReplyAttachment() {
        replyCaseAttachment = new Attachment();
    }

    public PageReference clearContentsAndCloseBox() {
        clearReplyContents();
        clearReplyAttachment();
        return null;
    }

    public PageReference submitReply() {
        submitCaseReply();
        submitAttachmentReply();
        return null;
    }

    private void submitCaseReply() {
        if (!String.isBlank(caseReply)) {
            RestCallResponse restStatusAndInfo = createAndSendEmailMessage();
            if (restStatusAndInfo.isSuccessfull()) {
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.CONFIRM, 'Your response was submitted successfully.')
                );
            } else {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'Your response was not submitted successfully. Please try again, or contact us at 1-855-ASU-5080.'
                    )
                );
            }
        }
        clearReplyContents();
    }

    private void submitAttachmentReply() {
        if (replyCaseAttachment.Name != null && replyCaseAttachment.Body != null && caseId != null) {
            String attachmentUploadResponse = uploadAttachment();
            if (attachmentUploadResponse.contains('success')) {
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.CONFIRM, 'Your attachment upload was successful.')
                );
                retrieveAttachmentList();
            } else {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'Your attachment upload was not successful. Please try again, or contact us at 1-855-ASU-5080.'
                    )
                );
            }
        }
    }

    private RestCallResponse createAndSendEmailMessage() {
        String jsonEmailBody = createJsonEmail();
        HttpRequest emailMessageRequest = createEmailMessageRequestWithJsonBody(jsonEmailBody);
        RestCallResponse restStatusAndInfo = sendRequestAndParseResponse(emailMessageRequest);
        return restStatusAndInfo;
    }

    @TestVisible
    private String createJsonEmail() {
        User currentUser = [
            SELECT Id, Name, FirstName, LastName, Email
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        Case currentCase = [SELECT Id, Owner.Email, Intended_Recipient__c FROM Case WHERE Id = :caseId LIMIT 1];

        String ownerEmail = '';
        if (currentCase.Intended_Recipient__c != null) {
            ownerEmail = currentCase.Intended_Recipient__c;
        } else {
            Email_To_Case_Configuration__c defaultEmail = Email_To_Case_Configuration__c.getValues(
                'Default Org Wide Email Address'
            );
            ownerEmail = defaultEmail.Value__c;
        }
        String emailSubject =
            'Reply by ' +
            currentUser.FirstName +
            ' ' +
            currentUser.LastName +
            ' from the My ASU Help tab at ' +
            DateTime.now();
        InsertEmailMessageCalloutBody emailMessageObjectBody = new InsertEmailMessageCalloutBody(
            caseReply,
            caseId,
            emailSubject,
            userContact.Name,
            userContact.Email,
            ownerEmail
        );
        String jsonEmailMessageInput = JSON.serialize(emailMessageObjectBody);
        return jsonEmailMessageInput;
    }

    private HttpRequest createEmailMessageRequestWithJsonBody(String jsonEmailMessage) {
        HttpRequest emailMessageInsertRequest = new HttpRequest();

        String baseURL = System.URL.getSalesforceBaseURL().toExternalForm();

        emailMessageInsertRequest.setHeader('Content-Type', 'application/json');
        emailMessageInsertRequest.setEndpoint(baseURL + '/services/apexrest/InsertEmailMessage');
        emailMessageInsertRequest.setMethod('POST');
        emailMessageInsertRequest.setBody(jsonEmailMessage);
        return emailMessageInsertRequest;
    }

    private RestCallResponse sendRequestAndParseResponse(HttpRequest emailMessageRequest) {
        Http objHttp = new Http();
        HttpResponse httpEmailResponse;
        try {
            httpEmailResponse = objHttp.send(emailMessageRequest);
            String httpResponseBody = httpEmailResponse.getBody();
            RestCallResponse restStatusAndInfo = (RestCallResponse) JSON.deserialize(
                httpResponseBody,
                RestCallResponse.class
            );
            return restStatusAndInfo;
        } catch (Exception e) {
            String httpResponseBody = httpEmailResponse.getBody();
            List<String> errorCaseVariables = new List<String>();
            errorCaseVariables.add(ErrorLogger.convertStringToJSON('Rest Status: ', httpEmailResponse.getStatus()));
            errorCaseVariables.add(ErrorLogger.convertStringToJSON('Error Info: ', httpResponseBody));
            errorCaseVariables.add(ErrorLogger.convertStringToJSON('Case Id: ', caseId));
            ErrorLogger.log(e, errorCaseVariables, false);

            RestCallResponse restStatusAndInfo = new RestCallResponse(httpEmailResponse.getStatus(), httpResponseBody);
            return restStatusAndInfo;
        }
    }

    private String uploadAttachment() {
        replyCaseAttachment.ParentId = caseId;
        try {
            insert replyCaseAttachment;
            clearReplyAttachment();
            return 'success attachment Id: ' + replyCaseAttachment.Id;
        } catch (Exception e) {
            varsForErrorLogging = new List<String>();
            varsForErrorLogging.add(ErrorLogger.convertStringToJSON('name', replyCaseAttachment.name));
            ErrorLogger.log(e, varsForErrorLogging, false);
            clearReplyAttachment();
            return 'failure';
        }
    }
}
