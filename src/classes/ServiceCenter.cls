public with sharing class ServiceCenter {

    public Case c { get; set; }
    public Id caseContId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
    public List<Contact> contactList = [SELECT Id, Name FROM Contact WHERE Id = :caseContId];
    public Id caseId;
    Contact loggedInContact;
    String userAlias;

    public ServiceCenter() { c = new Case(); }
    public ServiceCenter(AKBController controller) { c = new Case(); }

    //Grab the logged in contact.
    public Contact getLoggedInContact() {
        userAlias = [SELECT Alias FROM User WHERE Id = :UserInfo.getUserId()].Alias;
        loggedInContact = [SELECT Id, Name FROM Contact WHERE ASURITE_Id__c = :userAlias];

        System.Debug('User Alias: ' + userAlias);
        System.Debug('Contact: ' + loggedInContact);
        return loggedInContact;
    }
    
    //Create and submit the case. Redirects user to service tab with confirmation.
    public PageReference submitCase() {
        getLoggedInContact();
        try {
            c.ContactId = loggedInContact.Id;
            System.Debug('Case Contact Id: ' + c.ContactId);
            c.Web_Submission__c = 'My ASU Standard';
            insert c;
            PageReference confirmPage = new PageReference('/studentSC?Confirm=case');
            confirmPage.setRedirect(true);
            return confirmPage;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            System.Debug ('Message: ' + e.getMessage());
            System.Debug ('Cause: ' + e.getCause());
            System.Debug ('Stack Trace: ' + e.getStackTraceString());
            return null;
        }
    }
    
    //Removes the confirmation fromt the screen and then refreshes the page.
    public PageReference removeParam() {
        PageReference confirmPage = new PageReference('/studentSC');
        confirmPage.setRedirect(true);
        return confirmPage; 
    }
    
    
    //Codeblock for getting and displaying cases.
    public Solution[] getSolutions() {
        return [SELECT Id, SolutionNumber, SolutionName, Status FROM Solution];
    }
    
    public Case[] getMyCases() {
        if(contactList.isEmpty()){
            return [SELECT Subject, Status, Description, Origin, Origin__c FROM Case WHERE IsClosed = False AND Visible_by_Contact__c = true AND Created_By_Name__c = :UserInfo.getName()];
        } else {
            return [SELECT Subject, Status, Description, Origin, Origin__c FROM Case WHERE IsClosed = False AND Visible_by_Contact__c = true AND ContactId = :caseContId];
        }
    }
    
    public Case[] getClosedCases() {
        if(contactList.isEmpty()) {
            return [SELECT Subject, Status, Description, Origin, Origin__c FROM Case WHERE IsClosed = True AND Visible_by_Contact__c = true AND Created_By_Name__c = :UserInfo.getName()];
        } else {
            return [SELECT Subject, Status, Description, Origin FROM Case WHERE IsClosed = True AND Visible_by_Contact__c = true AND ContactId = :caseContId];
        }
    }
    
    public CaseFeed[] getCaseFeed() {
        return [SELECT Body, SystemModStamp from CaseFeed WHERE ParentId = :ApexPages.currentPage().getParameters().get('id') and CreatedById = :UserInfo.getUserId()];
    }
    
    public PageReference viewCase() {
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        return new PageReference('/viewcase?id=' + caseId);
    }
    
    
    //Codeblock for showing/hiding elements on the page. Includes contact/opportunity information.
    public Id contId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
    public Date d = date.today();
   
    public Term__c termcAC = [SELECT Session_A_C_Start_Date__c FROM Term__c where session_A_C_Start_Date__c > :system.today() limit 1];
    public Term__c termcB = [SELECT Session_B_Start_Date__c FROM Term__c where session_B_Start_Date__c > :system.today() limit 1];
    
    //public List<Term__c> termc = [SELECT Session_A_C_Start_Date__c, Session_B_Start_Date__c FROM Term__c];
    public List<Contact> cont = [SELECT Id, Name, EmplId__c, CAP__c, Personal_Email__c, CAP_Student_Group_Count__c, Affiliation_Student_Applicant__c, Affiliation_Student__c, Affiliation_Employee__c, Affiliation_Alumni__c, Affiliation_Courtesy_Affiliate__c FROM Contact WHERE Id = :contId];
    public List<Opportunity> oppList = [SELECT Career__c, Term__c, StageName, Admitted_Session__c FROM Opportunity WHERE Contact__c = :contId];

    public Boolean getNormalPhone() {
        if(cont == Null || cont.size() == 0) {
            return true;
        } else if(cont[0].CAP__c == Null) {
            return true;
        } else {
            return false;
        }
    }
    
    public Boolean getRoverPhone() {
        if(cont == Null || cont.size() == 0) {
            return false;
        } else if(cont[0].CAP__c == Null) {
            return false;
        } else {
            return true;
        }
    }
    
    //Code to show the different boxes on the Service Tab
    public Boolean getHelpBox() {
        if(cont == Null || cont.size() == 0) {
            return true;
        }
        else if((oppList == Null && cont.size() > 0) || (oppList.size() == 0 && cont.size() > 0)) {
            return true;
        } 
        else if((oppList[0].StageName == 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && oppList[0].Admitted_Session__c == 'A/C') && d < date.valueOf(termcAC.Session_A_C_Start_Date__c)) {
            return false;
        }
        else if((oppList[0].StageName == 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && oppList[0].Admitted_Session__c == 'B') && d < date.valueOf(termcB.Session_B_Start_Date__c)) {
            return false;
        }
        else if(oppList[0].StageName != 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && (cont[0].Affiliation_Student__c == 'Current' || cont[0].Affiliation_Alumni__c == 'Current' || cont[0].Affiliation_Courtesy_Affiliate__c == 'Current' || cont[0].Affiliation_Employee__c == 'Current') && d < date.valueOf(termcB.Session_B_Start_Date__c)) {
            return false;
        }
        else if(cont[0].CAP__c == Null) {
            return true;
        } 
        else {
            return true;
        }
    }
    
    public Boolean getQuestionsBox() {
        if(cont == Null || cont.size() == 0) {
            return false;
        } 
        else if((oppList == Null && cont.size() > 0) || (oppList.size() == 0 && cont.size() > 0)) {
            return false;
        } 
        else if((oppList[0].StageName == 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && oppList[0].Admitted_Session__c == 'A/C') && d < date.valueOf(termcAC.Session_A_C_Start_Date__c)) {
            return true;
        }
        else if((oppList[0].StageName == 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && oppList[0].Admitted_Session__c == 'B') && d < date.valueOf(termcB.Session_B_Start_Date__c)) {
            return true;
        }
        else if(oppList[0].StageName != 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && (cont[0].Affiliation_Student__c == 'Current' || cont[0].Affiliation_Alumni__c == 'Current' || cont[0].Affiliation_Courtesy_Affiliate__c == 'Current' || cont[0].Affiliation_Employee__c == 'Current') && d < date.valueOf(termcB.Session_B_Start_Date__c)) {
            return true;
        }
        else {
            return false;   
        }
    }
    
    public Boolean getMyCasesBox() {
        if(cont == Null || cont.size() == 0) {
            return true;
        } 
        else if((oppList == Null && cont.size() > 0) || (oppList.size() == 0 && cont.size() > 0)) {
            return true;
        } 
        else if((oppList[0].StageName == 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && oppList[0].Admitted_Session__c == 'A/C') && d < date.valueOf(termcAC.Session_A_C_Start_Date__c)) {
            return false;
        }
        else if((oppList[0].StageName == 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && oppList[0].Admitted_Session__c == 'B') && d < date.valueOf(termcB.Session_B_Start_Date__c)) {
            return false;
        }
        else if(oppList[0].StageName != 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && (cont[0].Affiliation_Student__c == 'Current' || cont[0].Affiliation_Alumni__c == 'Current' || cont[0].Affiliation_Courtesy_Affiliate__c == 'Current' || cont[0].Affiliation_Employee__c == 'Current') && d < date.valueOf(termcB.Session_B_Start_Date__c)) {
            return false;
        }
        else {
            return true;   
        }
    }
 
    
    //CodeBlock to get Case details for viewcase page.    
    public Case getCaseDetails() {
        return [SELECT Id, CaseNumber, Functional_Group__c, Subject, Description, CreatedDate, Status, Origin, Created_By_Name__c, ClosedDate FROM Case WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
    } 

    //MyPin reset
    public Decimal myPin;
    public Decimal newPin { get;set; }
    Contact contact;
    public Boolean isPinSuccess { get;set; }
        
    public Contact getContact() {
        if(contId != null) {
            contact = [SELECT Id, Self_Service_PIN__c, PIN_Lockout__c FROM Contact WHERE Id = :contId];
            return contact;
        }
        else {
            contact = [SELECT Id, Self_Service_PIN__c, PIN_Lockout__c FROM Contact WHERE Name = :UserInfo.getName() LIMIT 1];
            return contact;
        }   
    }
    
    public Decimal getMyPin() {
        getContact();
        if(contact != null) {
            myPin = contact.Self_Service_PIN__c;
            return myPin;
        }
        else {
            return null;
        }
    }
    
    public void closePinMessageBox() {
        ApexPages.getMessages().clear();
        isPinSuccess = false;
    }

    public PageReference changePin() {
        try {
            contact.Self_Service_PIN__c = newPin;
            if(contact.PIN_lockout__c == true) {
                contact.PIN_lockout__c = false;
            }
            update contact;
            ApexPages.Message success = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your PIN has been updated.');
            ApexPages.addMessage(success);
            isPinSuccess = true;
            PageReference ref = ApexPages.currentPage();
            return ref;
        }
        catch(DmlException e) {
            if(e.getMessage().contains('InvalidSelfServicePinException')) {
                ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR,'Your PIN cannot contain your year of birth.<br>Your PIN must not use more than 4 duplicate numbers.<br>Your PIN must be different than your previous PIN.<br>Your PIN cannot use more than 4 sequential numbers in your PIN. Forwards or backwards.<br>Your PIN must be between 6 and 10 characters.');
                ApexPages.addMessage(error);
                isPinSuccess = false;
                return null;    
            }
            else {
                throw e;   
            }
        }
    }
}