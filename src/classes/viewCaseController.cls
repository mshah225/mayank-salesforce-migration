public class viewCaseController{


    private static final Date EMAILVISIBILITYDATE = Date.newInstance(2015, 04, 06);
    private Date today;
    private Decimal origPin;
    private Term__c termcAC;
    private Term__c termcB;
    private Map<String, String> viewAsMap;
    private MyASUViewAs viewAsService;
    
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
    
   

    public viewCaseController(){
        viewingAs = false;
        checkForViewAs();
        popUserContact();
        popTerms();
        setCaseId();
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

    public void popTerms(){
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
        if (viewAsService.hasViewAsRights) {
            stopViewAsUrl = viewAsService.getResponseValueFromMap('stopViewAsUrl');
            viewAsUrl = viewAsService.getResponseValueFromMap('viewAsUrl');
        }
        
        userContact = viewAsService.getContact(viewAsService.getResponseValueFromMap('effectiveAsurite'));

        firstName = userContact.FirstName;
        lastName = userContact.LastName;
        emplId = userContact.EMPLID__c;
        asurite = userContact.ASURite_ID__c;
        origPin = userContact.Self_Service_PIN__c;
    }


    public void setCaseId(){
        caseId=ApexPages.currentPage().getParameters().get('id');
    }
    
     public Case getCaseDetails(){
        if (viewAsService.hasViewAsRights) {
            return viewAsService.getCaseDetails(ApexPages.currentPage().getParameters().get('Id'));
        } else {
            Case returnCase=[
                SELECT Id, CaseNumber, RecordType.Name, CC_Functional_Group__c, CC_Functional_Group__r.Name, Subject, Description,
                    Feedback_Link__c, CreatedDate, Status, Origin, Created_By_Name__c, ClosedDate
                FROM Case
                WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
                LIMIT 1
            ];
        
            return returnCase;
        }
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

    public EmailMessage[] getEmailMessages(){
        Date launchDate = EMAILVISIBILITYDATE;
        List<String> emailAddresses = new List<String>();
        emailAddresses.add(userContact.Email);
        emailAddresses.add(userContact.ASU_Email__c);
        emailAddresses.add(userContact.ASU_Gmail__c);
        emailAddresses.add(userContact.Personal_Email__c);
        emailAddresses.add(userContact.EPO_Email__c);

        return viewAsService.getCaseEmails(
            EMAILVISIBILITYDATE,
            ApexPages.currentPage().getParameters().get('id'),
            emailAddresses
        );
    }

    public List<bomgar__Event__c> getChatMessages() {
        return [
            SELECT bomgar__DestinationValue__c, bomgar__EventDateTime__c, bomgar__EventType__c, bomgar__PerformedByType__c, 
                bomgar__PerformedByValue__c, bomgar__Text__c, Id, Name, OwnerId 
            FROM bomgar__Event__c 
            WHERE bomgar__BomgarSession__r.bomgar__relatedcase__c =  :ApexPages.currentPage().getParameters().get('Id')
            AND (bomgar__PerformedByType__c = 'representative' OR bomgar__PerformedByType__c  = 'customer') 
            AND bomgar__DestinationValue__c = 'everyone' order by bomgar__EventDateTime__c asc
        ];
    }

    public Boolean getNormalPhone(){
        return (userContact.CAP__c == null) ? true : false;
    }

    public Boolean getRoverPhone(){
        return (userContact.CAP__c != null) ? true : false;
    }

    public Boolean getHelpBox(){
        if ((oppList == Null && userContact != null)
            || (oppList.size() == 0 && userContact != null)){
            return true;
        }
        else if ((oppList[0].StageName == 'Enrolled'
            && oppList[0].Career__c == 'Undergraduate'
            && oppList[0].Admitted_Session__c == 'A/C')
            && today < date.valueOf(termcAC.Session_A_C_Start_Date__c)){
            return false;
        }
        else if ((oppList[0].StageName == 'Enrolled'
            && oppList[0].Career__c == 'Undergraduate'
            && oppList[0].Admitted_Session__c == 'B')
            && today < date.valueOf(termcB.Session_B_Start_Date__c)){
            return false;
        }
        else if (oppList[0].StageName != 'Enrolled'
            && oppList[0].Career__c == 'Undergraduate'
            && (userContact.Affiliation_Student__c == 'Current'
            || userContact.Affiliation_Alumni__c == 'Current'
            || userContact.Affiliation_Courtesy_Affiliate__c == 'Current'
            || userContact.Affiliation_Employee__c == 'Current')
            && today < date.valueOf(termcB.Session_B_Start_Date__c)){
            return false;
        }
        else{
            return true;
        }
    }

    public Decimal getMyPin(){
        return (viewingAs) ? 111111 : userContact.Self_Service_PIN__c;
    }

    public PageReference changePin(){
        if (viewingAs){
            PageReference go = new PageReference(ApexPages.currentPage().getUrl());
            go.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
            go.setRedirect(true);

            return go;
        }

        if (origPin == newPin){
            return redirectWithParams(ApexPages.currentPage(), 'PIN', 'error');
        }

        if (ContactService.isPinValid(newPin, userContact.Birthdate)){
            userContact.Self_Service_PIN__c = newPin;
            if (userContact.PIN_lockout__c == true){
                userContact.PIN_lockout__c = false;
            }
            try{
                update userContact;
                return redirectWithParams(ApexPages.currentPage(), 'PIN', 'success');
            }
            catch(Exception e){
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertStringToJSON('First Name',userContact.FirstName));
                vars.add(ErrorLogger.convertStringToJSON('Last Name',userContact.LastName));
                vars.add(ErrorLogger.convertStringToJSON('Employee Id',userContact.EMPLId__c));
                ErrorLogger.log(e,vars,false);
                return redirectWithParams(ApexPages.currentPage(), 'PIN', 'error');
            }
        }
        else{
            return redirectWithParams(ApexPages.currentPage(), 'PIN', 'error');
        }

    }

    public PageReference redirectWithParams(PageReference page, String param, String value){
        PageReference redirect = page;
        redirect.getParameters().put(param, value);
        redirect.setRedirect(true);
        return redirect;
    }
}