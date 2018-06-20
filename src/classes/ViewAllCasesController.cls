public with sharing class ViewAllCasesController 
{
    private Id caseId;
    private Map<String, String> viewAsMap;
    private Decimal origPin;
    private MyASUViewAs viewAsService;
    
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String emplId { get; set; }
    public Boolean viewingAs { get; set; }
    public String stopViewAsUrl { get; set; }
    public String viewAsUrl { get; set; }
    public String asurite { get; set; }
    public String masqScopeIdCookie { get; set; }
    public Contact userContact;
    public String userAsurite;
    
    public ViewAllCasesController() { 
        viewingAs = false;
        checkForViewAs();
        popUserContact();
    }

    public void checkForViewAs(){
        if (ApexPages.currentPage().getParameters().get('masqScopeIdCookie') != null){
            
            masqScopeIdCookie = ApexPages.currentPage().getParameters().get('masqScopeIdCookie');

            userAsurite = [
                SELECT ASURite_Id__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ].ASURite_Id__C;

            viewAsService = new MyASUViewAs(masqScopeIdCookie, userAsurite);
        }
    }

    public void popUserContact(){
        if (viewAsService.hasViewAsRights){
            stopViewAsUrl = viewAsService.getResponseValueFromMap('stopViewAsUrl');
            viewAsUrl = viewAsService.getResponseValueFromMap('viewAsUrl');
        }
        userContact = viewAsService.getViewAsContact(viewAsService.getResponseValueFromMap('effectiveAsurite'));
        firstName = userContact.FirstName;
        lastName = userContact.LastName;
        emplId = userContact.EMPLID__c;
        asurite = userContact.ASURite_ID__c;
        origPin = userContact.Self_Service_PIN__c;
    }

    public List<Case> getMyCases(){
        List<Contact> contacts = new List<Contact> { userContact };
        Map<Id, List<Case>> openCaseMap;

        openCaseMap = viewAsService.getViewAsOpenCases(contacts)
            
        return (openCaseMap.get(userContact.Id) == null)
            ? new List<Case>() : openCaseMap.get(userContact.Id);
    }

    public PageReference viewCase(){
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        String current = ApexPages.currentPage().getUrl();
        current = current.split('apex/')[1];
        PageReference viewCasePage = new PageReference('/viewcase');
        viewCasePage.getParameters().put('id', caseId);
        viewCasePage.getParameters().put('source', 'viewAllCases');
        if (viewingAs){
            viewCasePage.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
        }
        return viewCasePage;
    }

    public List<Case> getAllClosedCases(){
        List<Contact> loggedInContacts = new List<Contact> { userContact };

        Map<Id, List<Case>> closedCaseMap;

        closedCaseMap = viewAsService.getViewAsClosedCases(loggedInContacts);

        return closedCaseMap.get(userContact.Id) == null ? new List<Case>() : closedCaseMap.get(userContact.Id);
    }

    public String getSource(){
        String source = ApexPages.currentPage().getParameters().get('source');

        if (source == null){
            source = 'studentSC';
        }
        else if (source.equals('viewAllCases')){
            source = 'viewAllCases?source=studentSC';
        }
        return source;
    }
}