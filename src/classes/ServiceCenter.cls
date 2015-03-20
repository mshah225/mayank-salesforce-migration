public with sharing class ServiceCenter {

    public Contact contact;
    public Contact loggedInContact;
    public Case c { get; set; }
    public Boolean isPinSuccess { get;set; }
    public Id caseId;
    public Id caseContId;
    public Id contId;
    public Date d;
    public Decimal myPin;
    public Decimal newPin { get;set; }
    public List<Contact> cont;
    public List<Opportunity> oppList;
    public List<Contact> contactList;
    public String userAlias;
    public Term__c termcAC;
    public Term__c termcB;

    public ServiceCenter() { 
        c = new Case(); 
        caseContId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
        contactList = [SELECT Id, Name FROM Contact WHERE Id = :caseContId];
        contId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
        d = date.today();
        termcAC = [SELECT Session_A_C_Start_Date__c FROM Term__c where session_A_C_Start_Date__c > :system.today() limit 1];
        termcB = [SELECT Session_B_Start_Date__c FROM Term__c where session_B_Start_Date__c > :system.today() limit 1];
        cont = [SELECT Id, Name, EmplId__c, CAP__c, Personal_Email__c, CAP_Student_Group_Count__c, Affiliation_Student_Applicant__c, Affiliation_Student__c, Affiliation_Employee__c, Affiliation_Alumni__c, Affiliation_Courtesy_Affiliate__c FROM Contact WHERE Id = :contId];
        oppList = [SELECT Career__c, Term__c, StageName, Admitted_Session__c FROM Opportunity WHERE Contact__c = :contId];
    }

    public ServiceCenter(AKBController controller) { 
        c = new Case(); 
        caseContId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
        contactList = [SELECT Id, Name FROM Contact WHERE Id = :caseContId];
        contId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
        d = date.today();
        termcAC = [SELECT Session_A_C_Start_Date__c FROM Term__c where session_A_C_Start_Date__c > :system.today() limit 1];
        termcB = [SELECT Session_B_Start_Date__c FROM Term__c where session_B_Start_Date__c > :system.today() limit 1];
        cont = [SELECT Id, Name, EmplId__c, CAP__c, Personal_Email__c, CAP_Student_Group_Count__c, Affiliation_Student_Applicant__c, Affiliation_Student__c, Affiliation_Employee__c, Affiliation_Alumni__c, Affiliation_Courtesy_Affiliate__c FROM Contact WHERE Id = :contId];
        oppList = [SELECT Career__c, Term__c, StageName, Admitted_Session__c FROM Opportunity WHERE Contact__c = :contId]; 
    }

    public Contact getLoggedInContact() {
        userAlias = [SELECT Alias FROM User WHERE Id = :UserInfo.getUserId()].Alias;
        loggedInContact = [SELECT Id, Name FROM Contact WHERE ASURITE_Id__c = :userAlias];
        System.Debug('User Alias: ' + userAlias);
        System.Debug('Contact: ' + loggedInContact);
        return loggedInContact;
    }
    
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
    
    public PageReference removeParam() {
        PageReference confirmPage = new PageReference('/studentSC');
        confirmPage.setRedirect(true);
        return confirmPage; 
    }
    
    public Solution[] getSolutions() {
        return [SELECT Id, SolutionNumber, SolutionName, Status FROM Solution];
    }
    
    public Case[] getMyCases() {
        if(contactList.isEmpty()){
            getLoggedInContact();
            return [SELECT Subject, Status, Description, Origin, Origin__c FROM Case WHERE IsClosed = False AND Visible_by_Contact__c = true AND ContactId = :loggedInContact.Id];
        } else {
            return [SELECT Subject, Status, Description, Origin, Origin__c FROM Case WHERE IsClosed = False AND Visible_by_Contact__c = true AND ContactId = :caseContId];
        }
    }
    
    public Case[] getClosedCases() {
        if(contactList.isEmpty()) {
            getLoggedInContact();
            return [SELECT Subject, Status, Description, Origin, Origin__c, Feedback_Link__c FROM Case WHERE IsClosed = True AND Visible_by_Contact__c = true AND ContactId = :loggedInContact.Id];
        } else {
            return [SELECT Subject, Status, Description, Origin, Origin__c, Feedback_Link__c FROM Case WHERE IsClosed = True AND Visible_by_Contact__c = true AND ContactId = :caseContId];
        }
    }

    public Case getCaseDetails() {
        return [SELECT Id, CaseNumber, Functional_Group__c, Subject, Description, Feedback_Link__c, CreatedDate, Status, Origin, Created_By_Name__c, ClosedDate FROM Case WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
    } 
    
    public EmailMessage[] getEmailMessages() {
        return [SELECT FromName, CreatedDate, HtmlBody, LastModifiedDate, Subject, TextBody, FromAddress, ToAddress, CCAddress FROM EmailMessage WHERE ParentId = :ApexPages.currentPage().getParameters().get('id') AND Incoming = false ORDER BY CreatedDate ASC];
    }
    
    public PageReference viewCase() {
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        return new PageReference('/viewcase?id=' + caseId);
    }
    
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
        
    public Contact getContact() {
        if(contId != null) {
            contact = [SELECT Id, Self_Service_PIN__c, PIN_Lockout__c FROM Contact WHERE Id = :contId];
            return contact;
        }
        else {
            getLoggedInContact();
            contact = [SELECT Id, Self_Service_PIN__c, PIN_Lockout__c FROM Contact WHERE Id = :loggedInContact.Id];
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