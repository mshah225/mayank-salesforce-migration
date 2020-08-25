public with sharing class MyASUHelpMyRequestsController {
    private Id caseId;
    private Map<String, String> viewAsMap;
    private Term__c termcAC;
    private Term__c termcB;
    private Date today;
    public Boolean viewingAs { get; set; }
    public Case newCase { get; set; }
    public List<Opportunity> oppList;
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

    public MyASUHelpMyRequestsController() {
        newCase = new Case();
        viewingAs = false;
        createViewAs();
        popUserContact();
        popTerms();
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

    public void popTerms() {
        today = date.today();

        termcAC = [
            SELECT Session_A_C_Start_Date__c
            FROM Term__c
            WHERE session_A_C_Start_Date__c > :System.today()
            LIMIT 1
        ];

        termcB = [SELECT Session_B_Start_Date__c FROM Term__c WHERE session_B_Start_Date__c > :System.today() LIMIT 1];

        oppList = [
            SELECT Career__c, Term__c, StageName, Admitted_Session__c
            FROM Opportunity
            WHERE Contact__c = :userContact.Id
        ];
    }

    public List<Case> getMyCases() {
        List<Contact> contacts = new List<Contact>{ userContact };
        Map<Id, List<Case>> openCaseMap;
        if (viewAsService != null) {
            openCaseMap = viewAsService.getOpenCases(contacts, 5);
        } else {
            openCaseMap = CaseService.getVisibleOpenCases(contacts, 5);
        }

        return (openCaseMap.get(userContact.Id) == null) ? new List<Case>() : openCaseMap.get(userContact.Id);
    }

    public List<Case> getClosedCases() {
        List<Case> closedCases = new List<Case>();
        List<Contact> contacts = new List<Contact>{ userContact };
        Map<Id, List<Case>> closedCaseMap;

        if (viewAsService != null) {
            closedCaseMap = viewAsService.getClosedCases(contacts, 5);
        } else {
            closedCaseMap = CaseService.getVisibleClosedCases(contacts, 5);
        }

        return (closedCaseMap.get(userContact.Id) == null) ? new List<Case>() : closedCaseMap.get(userContact.Id);
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

    public Boolean getMyCasesBox() {
        if ((oppList == null && userContact != null) || (oppList.size() == 0 && userContact != null)) {
            return true;
        } else if (
            (oppList[0].StageName == 'Enrolled' &&
            oppList[0].Career__c == 'Undergraduate' &&
            oppList[0].Admitted_Session__c == 'A/C') && today < date.valueOf(termcAC.Session_A_C_Start_Date__c)
        ) {
            return false;
        } else if (
            (oppList[0].StageName == 'Enrolled' &&
            oppList[0].Career__c == 'Undergraduate' &&
            oppList[0].Admitted_Session__c == 'B') && today < date.valueOf(termcB.Session_B_Start_Date__c)
        ) {
            return false;
        } else if (
            oppList[0].StageName != 'Enrolled' &&
            oppList[0].Career__c == 'Undergraduate' &&
            (userContact.Affiliation_Student__c == 'Current' ||
            userContact.Affiliation_Alumni__c == 'Current' ||
            userContact.Affiliation_Courtesy_Affiliate__c == 'Current' ||
            userContact.Affiliation_Employee__c == 'Current') &&
            today < date.valueOf(termcB.Session_B_Start_Date__c)
        ) {
            return false;
        } else {
            return true;
        }
    }
}
