public with sharing class ServiceCenter 
{
    public final Date EMAILVISIBILITYDATE = Date.newInstance(2015, 04, 06); 
    public final Integer CLOSEDCASELIMIT = 5;

    public Contact contact;
    public Case c { get; set; }
    public Boolean pinError { get;set; }
    public Boolean pinSuccess { get;set; }
    public Date d;
    public Decimal myPin;
    public Decimal newPin { get;set; }
    public Id caseId;
    public List<Opportunity> oppList;
    public String userAlias;
    public String pinMessage { get;set; }
    public Term__c termcAC;
    public Term__c termcB;
    public Case suggestAnArticle {get; set;}

    public ServiceCenter() { setUpPage(); }
    public ServiceCenter(AKBController controller) { setUpPage(); }

    public void setUpPage() 
    {
        getContact();
        c = new Case(); 
        d = date.today();
        termcAC = [SELECT Session_A_C_Start_Date__c 
                   FROM Term__c 
                   WHERE session_A_C_Start_Date__c > :System.today() 
                   LIMIT 1];
        termcB = [SELECT Session_B_Start_Date__c 
                  FROM Term__c 
                  WHERE session_B_Start_Date__c > :System.today() 
                  LIMIT 1];
        oppList = [SELECT Career__c, Term__c, StageName, Admitted_Session__c 
                   FROM Opportunity 
                   WHERE Contact__c = :contact.Id];
        suggestAnArticle = new Case();
    }

    public Contact getContact() 
    {
        userAlias = [SELECT Alias 
                     FROM User 
                     WHERE Id = :UserInfo.getUserId()].Alias;
        contact = [SELECT Id, Name, FirstName, LastName, EmplId__c, CAP__c, Personal_Email__c, Email, CAP_Student_Group_Count__c, Affiliation_Student_Applicant__c, Affiliation_Student__c, Affiliation_Employee__c, Affiliation_Alumni__c, Affiliation_Courtesy_Affiliate__c, Self_Service_PIN__c, PIN_Lockout__c 
                   FROM Contact 
                   WHERE ASURITE_Id__c = :userAlias];
        return contact;
    }

    public List<Case> getMyCases() 
    {
        List<Contact> contacts = new List<Contact> { contact };
        Map<Id, List<Case>> openCaseMap = CaseService.getVisibleOpenCases(contacts);

        return openCaseMap.get(contact.Id)==null ? new List<Case>() : openCaseMap.get(contact.Id);
    }
    
    public List<Case> getClosedCases() 
    {
        List<Case> closedCases = new List<Case>();
        
        List<Contact> contacts = new List<Contact> { contact };
        Map<Id, List<Case>> closedCaseMap = CaseService.getVisibleClosedCases(contacts);

        if (closedCaseMap.get(contact.Id) != null)
        {
            // Limit the number of closed cases that are displayed to CLOSEDCASELIMIT
            if (closedCaseMap.get(contact.Id).size() > CLOSEDCASELIMIT)
            {
                for (Integer i = 0; i < CLOSEDCASELIMIT; i++)
                {
                    closedCases.add(closedCaseMap.get(contact.Id).get(i));

                }
            }
            else 
            {
                closedCases = closedCaseMap.get(contact.Id).clone();
            }
        }

        return closedCases;
    }

    public Case getCaseDetails() 
    {
        return [SELECT Id, CaseNumber, Functional_Group__c, Subject, Description, Feedback_Link__c, CreatedDate, Status, Origin, Created_By_Name__c, ClosedDate 
                FROM Case 
                WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
    } 

    public EmailMessage[] getEmailMessages() { 
        Date launchDate = EMAILVISIBILITYDATE;
        return [SELECT FromName, CreatedDate, HtmlBody, LastModifiedDate, Subject, TextBody, FromAddress, ToAddress, CCAddress 
                FROM EmailMessage 
                WHERE ParentId = :ApexPages.currentPage().getParameters().get('id') 
                AND Incoming = false
                AND CreatedDate > :launchDate 
                AND ToAddress = :contact.Email
                ORDER BY CreatedDate DESC];
    }
    
    public PageReference viewCase() 
    {
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        PageReference viewCasePage = new PageReference('/viewcase');
        viewCasePage.getParameters().put('id', caseId);
        viewCasePage.getParameters().put('source', 'studentSC');

        return viewCasePage;
    }

    public String getSource()
    {
        String source = ApexPages.currentPage().getParameters().get('source');

        if (source == null)
        {
            source = 'studentSC';
        }
        else if (source.equals('viewAllCases'))
        {
            source = 'viewAllCases?source=studentSC';
        }

        return source;
    } 
    
    public Boolean getNormalPhone() 
    {
        if (contact.CAP__c != null) {
            return false;
        } 
        else 
        {
            return true;
        }
    }
    
    public Boolean getRoverPhone() 
    {
        if (contact.CAP__c != null) 
        {
            return true;
        } 
        else 
        {
            return false;
        }
    }
    
    public Boolean getHelpBox() 
    {
        if (contact == Null) 
        {
            return true;
        }
        else if ((oppList == Null && contact != null) || (oppList.size() == 0 && contact != null))
        {
            return true;
        } 
        else if ((oppList[0].StageName == 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && oppList[0].Admitted_Session__c == 'A/C') && d < date.valueOf(termcAC.Session_A_C_Start_Date__c)) 
        {
            return false;
        }
        else if ((oppList[0].StageName == 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && oppList[0].Admitted_Session__c == 'B') && d < date.valueOf(termcB.Session_B_Start_Date__c)) 
        {
            return false;
        }
        else if (oppList[0].StageName != 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && (contact.Affiliation_Student__c == 'Current' || contact.Affiliation_Alumni__c == 'Current' || contact.Affiliation_Courtesy_Affiliate__c == 'Current' || contact.Affiliation_Employee__c == 'Current') && d < date.valueOf(termcB.Session_B_Start_Date__c)) 
        {
            return false;
        } 
        else 
        {
            return true;
        }
    }
    
    public Boolean getQuestionsBox() 
    {
        if (contact == Null) 
        {
            return false;
        } 
        else if ((oppList == Null && contact != null) || (oppList.size() == 0 && contact != null)) 
        {
            return false;
        } 
        else if ((oppList[0].StageName == 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && oppList[0].Admitted_Session__c == 'A/C') && d < date.valueOf(termcAC.Session_A_C_Start_Date__c)) 
        {
            return true;
        }
        else if ((oppList[0].StageName == 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && oppList[0].Admitted_Session__c == 'B') && d < date.valueOf(termcB.Session_B_Start_Date__c)) 
        {
            return true;
        }
        else if (oppList[0].StageName != 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && (contact.Affiliation_Student__c == 'Current' || contact.Affiliation_Alumni__c == 'Current' || contact.Affiliation_Courtesy_Affiliate__c == 'Current' || contact.Affiliation_Employee__c == 'Current') && d < date.valueOf(termcB.Session_B_Start_Date__c)) 
        {
            return true;
        }
        else 
        {
            return false;   
        }
    }
    
    public Boolean getMyCasesBox() 
    {
        if (contact == Null) 
        {
            return true;
        } 
        else if ((oppList == Null && contact != null) || (oppList.size() == 0 && contact != null)) 
        {
            return true;
        } 
        else if ((oppList[0].StageName == 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && oppList[0].Admitted_Session__c == 'A/C') && d < date.valueOf(termcAC.Session_A_C_Start_Date__c)) 
        {
            return false;
        }
        else if ((oppList[0].StageName == 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && oppList[0].Admitted_Session__c == 'B') && d < date.valueOf(termcB.Session_B_Start_Date__c)) 
        {
            return false;
        }
        else if (oppList[0].StageName != 'Enrolled' && oppList[0].Career__c == 'Undergraduate' && (contact.Affiliation_Student__c == 'Current' || contact.Affiliation_Alumni__c == 'Current' || contact.Affiliation_Courtesy_Affiliate__c == 'Current' || contact.Affiliation_Employee__c == 'Current') && d < date.valueOf(termcB.Session_B_Start_Date__c)) 
        {
            return false;
        }
        else 
        {
            return true;   
        }
    }

    public PageReference submitCase() 
    {
        try 
        {
            c.ContactId = contact.Id;
            System.Debug('Case Contact Id: ' + c.ContactId);
            c.Web_Submission__c = 'My ASU Standard';
            insert c;
            PageReference confirmPage = new PageReference('/studentSC?Confirm=newcase');
            confirmPage.setRedirect(true);
            return confirmPage;
        } 
        catch (Exception e) 
        {
            ApexPages.addMessages(e);
            System.Debug ('Message: ' + e.getMessage());
            System.Debug ('Cause: ' + e.getCause());
            System.Debug ('Stack Trace: ' + e.getStackTraceString());
            return null;
       }
    }
    
    public Decimal getMyPin() 
    {
        getContact();
        if (contact != null) 
        {
            myPin = contact.Self_Service_PIN__c;
            return myPin;
        }
        else 
        {
            return null;
        }
    }

    public PageReference changePin() 
    {
        try 
        {
            contact.Self_Service_PIN__c = newPin;
            if (contact.PIN_lockout__c == true) 
            {
                contact.PIN_lockout__c = false;
            }
            update contact;
            pinMessage = 'Your PIN has been updated.';
            pinError = false;
            pinSuccess = true;
            PageReference ref = ApexPages.currentPage();
            return ref;
        }
        catch(DmlException e) 
        {
            if (e.getMessage().contains('InvalidSelfServicePinException')) 
            {
                pinMessage = 'Your PIN cannot contain your year of birth.<br>Your PIN must not use more than 4 duplicate numbers.<br>Your PIN must be different than your previous PIN.<br>Your PIN cannot use more than 4 sequential numbers in your PIN. Forwards or backwards.<br>Your PIN must be between 6 and 10 characters.';
                pinSuccess = false;
                pinError = true;
                return null;    
            }
            else 
            {
                throw e;   
            }
        }
    }

    public PageReference suggestAnArticleSubmit() 
    {
        String userAlias = [SELECT Alias 
                     FROM User 
                     WHERE Id = :UserInfo.getUserId()].Alias;
        Id contactId = [SELECT Id 
                     FROM Contact 
                     WHERE ASURITE_Id__c = :userAlias].Id;

        suggestAnArticle.Subject = 'Suggest An Article';
        suggestAnArticle.Description = suggestAnArticle.Description;
        suggestAnArticle.ContactId = contactId;
        suggestAnArticle.OwnerId = [SELECT Id FROM Group WHERE Name = 'Student-Centric Initiatives (Case)' AND Type = 'Queue'].Id;
        suggestAnArticle.Functional_Group__c = 'Student-Centric Initiatives';
        suggestAnArticle.Category__c = 'Knowledge';
        suggestAnArticle.Origin__c = 'My ASU';
        suggestAnArticle.Visible_by_Contact__c = false;
        insert suggestAnArticle;
        
        PageReference confirmPage = new PageReference('/studentSC' + '?Suggest=yes');
        confirmPage.setRedirect(true);
        return confirmPage;
    }
}