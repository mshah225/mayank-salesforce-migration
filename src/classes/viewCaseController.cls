public with sharing class viewCaseController {

    private static final Date EMAIL_VISIBILITY_DATE = Date.newInstance(2015, 04, 06);
    private static final Integer REPLY_ACCEPTANCE_THRESHOLD = 14;
    private Date today;
    private Decimal origPin;
    private Term__c termcAC;
    private Term__c termcB;
    private Map<String, String> viewAsMap;
    private MyAsuViewAs viewAsService;
    
    public Id caseId {get;set;}
    public Decimal newPin { get; set; }
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
    public Boolean showReplyBox { get; set; }
    public Boolean showReplyButton { get; set; }
    public String caseReply { get; set; }
    public Attachment replyCaseAttachment { get; set; }
    public List<String> varsForErrorLogging { get; set; }
    public List<Attachment> allCaseAttachments { get; set; }
    public Boolean showCaseAttachments { get; set; }
    public Boolean showOpenNewCaseAlert { get; set; }
   
    public viewCaseController() {
        viewingAs = false;
        showReplyBox = false;
        showReplyButton = true;
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
        Case caseOnPage = [SELECT ClosedDate FROM Case WHERE Id =: caseId];
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
            ORDER BY  CreatedDate DESC
        ];
        if (allCaseAttachments == null || allCaseAttachments.isEmpty()) {
            showCaseAttachments = false;    
        } else {
            showCaseAttachments = true;
        }
    }
    
    public void checkForViewAs() {
        if (ApexPages.currentPage().getParameters().get('masqScopeIdCookie') != null){
            masqScopeIdCookie = ApexPages.currentPage().getParameters().get('masqScopeIdCookie');

            userAsurite = [
                SELECT ASURite_Id__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ].ASURite_Id__C;

            viewAsService = new MyAsuViewAs(masqScopeIdCookie, userAsurite);
        } else {
            viewingAs = false;
        }
    }

    public void popTerms() {
        today = date.today();

        termcAC = [
            SELECT Session_A_C_Start_Date__c
            FROM Term__c
            WHERE session_A_C_Start_Date__c > :System.today()
            LIMIT 1
        ];

        termcB = [
            SELECT Session_B_Start_Date__c
            FROM Term__c
            WHERE session_B_Start_Date__c > :System.today()
            LIMIT 1
        ];

        oppList = [
            SELECT Career__c, Term__c, StageName, Admitted_Session__c
            FROM Opportunity
            WHERE Contact__c = :userContact.Id
        ];
    }

    public void popUserContact(){
        if (viewAsService != null &&  viewAsService.hasViewAsRights) {
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
        origPin = userContact.Self_Service_PIN__c;
    }


    public void setCaseId() {
        caseId = ApexPages.currentPage().getParameters().get('id');
    }
    
     public Case getCaseDetails(){
        if (viewAsService != null && viewAsService.hasViewAsRights) {
            return viewAsService.getCaseDetails(ApexPages.currentPage().getParameters().get('Id'));
        } else {
            Case returnCase = [
                SELECT Id, CaseNumber, RecordType.Name, CC_Functional_Group__c, CC_Functional_Group__r.Name, Subject, Description,
                    Feedback_Link__c, CreatedDate, Status, Origin, Created_By_Name__c, ClosedDate
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
            SELECT bomgar__DestinationValue__c, bomgar__EventDateTime__c, bomgar__EventType__c, bomgar__PerformedByType__c,
            bomgar__PerformedByValue__c, bomgar__Text__c, Id, Name, OwnerId
            FROM bomgar__Event__c
            WHERE bomgar__BomgarSession__r.bomgar__relatedcase__c = :ApexPages.currentPage().getParameters().get('Id')
            AND(bomgar__PerformedByType__c = 'representative' OR bomgar__PerformedByType__c = 'customer')
            AND bomgar__DestinationValue__c = 'everyone' order by bomgar__EventDateTime__c asc
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
        if ((oppList == Null && userContact != null)
                || (oppList.size() == 0 && userContact != null)) {
            return true;
        } else if ((oppList[0].StageName == 'Enrolled'
                && oppList[0].Career__c == 'Undergraduate'
                && oppList[0].Admitted_Session__c == 'A/C')
                && today < date.valueOf(termcAC.Session_A_C_Start_Date__c)) {
            return false;
        } else if ((oppList[0].StageName == 'Enrolled'
                && oppList[0].Career__c == 'Undergraduate'
                && oppList[0].Admitted_Session__c == 'B')
                && today < date.valueOf(termcB.Session_B_Start_Date__c)) {
            return false;
        } else if (oppList[0].StageName != 'Enrolled'
                && oppList[0].Career__c == 'Undergraduate'
                && (userContact.Affiliation_Student__c == 'Current'
                || userContact.Affiliation_Alumni__c == 'Current'
                || userContact.Affiliation_Courtesy_Affiliate__c == 'Current'
                || userContact.Affiliation_Employee__c == 'Current')
                && today < date.valueOf(termcB.Session_B_Start_Date__c)) {
            return false;
        } else {
            return true;
        }
    }

    public Decimal getMyPin() {
        return (viewingAs) ? 111111 : userContact.Self_Service_PIN__c;
    }

    public PageReference changePin() {
        if (viewingAs) {
            PageReference go = new PageReference(ApexPages.currentPage().getUrl());
            go.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
            go.setRedirect(true);

            return go;
        }

        if (origPin == newPin) {
            return redirectWithParams(ApexPages.currentPage(), 'PIN', 'error');
        }

        if (ContactService.isPinValid(newPin, userContact.Birthdate)) {
            userContact.Self_Service_PIN__c = newPin;
            if (userContact.PIN_lockout__c == true) {
                userContact.PIN_lockout__c = false;
            }
            try {
                update userContact;
                return redirectWithParams(ApexPages.currentPage(), 'PIN', 'success');
            } catch (Exception e) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertStringToJSON('First Name',userContact.FirstName));
                vars.add(ErrorLogger.convertStringToJSON('Last Name',userContact.LastName));
                vars.add(ErrorLogger.convertStringToJSON('Employee Id',userContact.EMPLId__c));
                ErrorLogger.log(e,vars,false);
                return redirectWithParams(ApexPages.currentPage(), 'PIN', 'error');
            }
        } else {
            return redirectWithParams(ApexPages.currentPage(), 'PIN', 'error');
        }

    }

    public PageReference redirectWithParams(PageReference page, String param, String value) {
        PageReference redirect = page;
        redirect.getParameters().put(param, value);
        redirect.setRedirect(true);
        return redirect;
    }
    
    public void displayReplyBox() {
        showReplyBox = true;
        showReplyButton = false;
    }
    
    private void clearReplyContents() {
        caseReply = '';
    }
    
    private void closeReplyBox() {
        showReplyBox = false;
        showReplyButton = true;
    }
    
    private void clearReplyAttachment() {
        replyCaseAttachment = new Attachment();
    }
    
    public PageReference clearContentsAndCloseBox() {
        clearReplyContents();
        closeReplyBox();
        clearReplyAttachment();    
        return null;
    }
    
    public PageReference submitReply() {
        Boolean isCaseReplySuccess = submitCaseReply();
        Boolean isAttachmentSuccess = submitAttachmentReply();
        if (isCaseReplySuccess && isAttachmentSuccess) {
            closeReplyBox();
            PageReference page = new PageReference(ApexPages.currentPage().getUrl());
            page.setRedirect(true);
            return page;
        } else {
            return null;
        }
    }
    
    private Boolean submitCaseReply() {
        if (!String.isBlank(caseReply)) {
            RestCallResponse restStatusAndInfo = createAndSendEmailMessage();
            if (restStatusAndInfo.isSuccessfull()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Your response to the case was submitted successfully.'));
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not add response to case. Please try again or contact a system administrator.'));
                ErrorLogger error = new ErrorLogger();
                error.setClassName('viewCaseController');
                error.setDetails('Error submitting case reply from service center. Error: ' + restStatusAndInfo.getMessage());
                error.log();
                return false;
            }
        }
        return true;
    }
    
    private Boolean submitAttachmentReply() {
        if (replyCaseAttachment.Name != null && replyCaseAttachment.Body != null && caseId != null) {
            String attachmentUploadResponse = uploadAttachment();
            if (attachmentUploadResponse.contains('success')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Attachment to Case submitted Successfully'));
                retrieveAttachmentList();
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not upload attachment, please try again'));
                return false;
            }
        }
        return true;
    }
    
    private RestCallResponse createAndSendEmailMessage() {
        String jsonEmailBody = createJsonEmail();
        HttpRequest emailMessageRequest = createEmailMessageRequestWithJsonBody(jsonEmailBody);
        RestCallResponse restStatusAndInfo = sendRequestAndParseResponse(emailMessageRequest);
        return restStatusAndInfo;
    }
    
    private String createJsonEmail() {
        User currentUser = [SELECT Id, Name, FirstName, LastName, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Case currentCase = [SELECT Id, Owner.Email FROM Case WHERE Id = :caseId LIMIT 1];
        
        String ownerEmail = '';
        if (currentCase.Owner.Email != null) {
            ownerEmail = currentCase.Owner.Email;
        }
        String emailSubject = 'Reply by ' + currentUser.FirstName + ' ' + currentUser.LastName + 
                ' from the MyASU Service Center at ' + DateTime.now() + ':';
        InsertEmailMessageCalloutBody emailMessageObjectBody = new InsertEmailMessageCalloutBody(caseReply, caseId,
                                                            emailSubject, userContact.Name, 
                                                            userContact.Email, ownerEmail
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
            RestCallResponse restStatusAndInfo = (RestCallResponse) JSON.deserialize(httpResponseBody, RestCallResponse.class);
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
