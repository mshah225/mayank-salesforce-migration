public class ServiceCenter {

    public ServiceCenter(AKBController controller) { }

    public Case c { get; set; }
    
    public ServiceCenter() {
        c = new Case();
    }
    
    //Create and submit the case. Redirects user to service tab with confirmation.
    //-----------------------------------------------------------------------------------------------
    public PageReference submitCase() {
        try {
            INSERT c;
            PageReference confirmPage = new PageReference('/studentSC?Confirm=case');
              confirmPage.setRedirect(true);
              return confirmPage;
        } catch (Exception e) {
            ApexPages.addMessages(e);
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
    //-----------------------------------------------------------------------------------------------
    public Id caseContId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
    public List<Contact> contactList = [SELECT Id, Name FROM Contact WHERE Id = :caseContId];
   
    public Case selectedCase { get; set; }
    
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
        String caseId = ApexPages.currentPage().getParameters().get('caseId');
        selectedCase = [SELECT Id FROM Case WHERE Id = :caseId];
        return new PageReference('/viewcase?id=' + caseId);
    }
    
    
    //Codeblock for showing/hiding elements on the page. Includes contact/opportunity information.
    //-----------------------------------------------------------------------------------------------
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
        else if(oppList[0].Career__c == Null || (cont[0].Affiliation_Student_Applicant__c == 'Current' && (oppList[0].Career__c != 'Graduate' || oppList[0].Career__c != 'Law'))) {
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
        else if((cont[0].Affiliation_Student__c == Null || cont[0].Affiliation_Alumni__c == Null || cont[0].Affiliation_Courtesy_Affiliate__c == Null || cont[0].Affiliation_Employee__c == Null) && d < date.valueOf(termcB.Session_B_Start_Date__c)) {
            return false;
        }
        else if(oppList == Null || oppList.size() == 0) {
            return true;   
        } 
         
        else if(cont[0].CAP__c == Null) {
            return true;
        } 
        else {
            return false;
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
        else if(oppList == Null || oppList.size() == 0) {
            return false;   
        }
        else if((cont[0].Affiliation_Student__c == Null || cont[0].Affiliation_Alumni__c == Null || cont[0].Affiliation_Courtesy_Affiliate__c == Null || cont[0].Affiliation_Employee__c == Null) && d < date.valueOf(termcB.Session_B_Start_Date__c)) {
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
        else if(oppList[0].Career__c == Null || (cont[0].Affiliation_Student_Applicant__c == 'Current' && (oppList[0].Career__c != 'Graduate' || oppList[0].Career__c != 'Law'))) {
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
        else if((cont[0].Affiliation_Student__c == Null || cont[0].Affiliation_Alumni__c == Null || cont[0].Affiliation_Courtesy_Affiliate__c == Null || cont[0].Affiliation_Employee__c == Null) && d < date.valueOf(termcB.Session_B_Start_Date__c)) {
            return false;
        }
        else if(oppList == Null || oppList.size() == 0) {
            return true;   
        } 
        else {
            return false;   
        }
    }
 
    
    //CodeBlock to get Case details for viewcase page.
    //-----------------------------------------------------------------------------------------------
    
    public Case getCaseDetails() {
        return [SELECT Id, CaseNumber, Functional_Group__c, Subject, Description, CreatedDate, Status, Origin, Created_By_Name__c, ClosedDate FROM Case WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
    } 
}