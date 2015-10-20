public with sharing class ServiceCenter
{
    public final Date EMAILVISIBILITYDATE = Date.newInstance(2015, 04, 06);
    public final Integer CLOSEDCASELIMIT = 5;

    public Boolean viewingAs { get; set; }
    public Case newCase { get; set; }
    public Case suggestAnArticle { get; set; }
    public Contact userContact { get; set; }
    public Date today;
    public Decimal myPin;
    private Decimal origPin;
    public Decimal newPin { get; set; }
    public Id caseId;
    public List<Opportunity> oppList; 
    private Map<String, String> viewAsMap;
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String emplId { get; set; }
    public String masqScopeIdCookie { get; set; }
    public String stopViewAsUrl { get; set; }
    public String viewAsUrl { get; set; }
    public String asurite { get; set; }
    public String userAsurite;
    public Term__c termcAC;
    public Term__c termcB;

    public ServiceCenter()
    {
        viewingAs = false;
        masqScopeIdCookie = ApexPages.currentPage().getParameters().get('masqScopeIdCookie');
        if (masqScopeIdCookie != null)
        {
            userAsurite = [
                    SELECT ASURite_Id__c
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
            ].ASURite_Id__C;

            viewAsMap = MyASUViewAs.getCalloutResponseContents(masqScopeIdCookie, userAsurite);
            viewingAs = MyASUViewAs.checkViewAsRights(viewAsMap, userAsurite);
        }

        if (viewingAs)
        {
            userContact = MyASUViewAs.getViewAsContact(viewAsMap.get('effectiveAsurite'));
            stopViewAsUrl = String.valueOf(viewAsMap.get('stopViewAsUrl'));
            viewAsUrl = String.valueOf(viewAsMap.get('viewAsUrl'));
        }
        else
        {
            userContact = ContactService.getLoggedInContact();
        }

        firstName = userContact.FirstName;
        lastName = userContact.LastName;
        emplId = userContact.EMPLID__c;
        asurite = userContact.ASURite_ID__c;
        newCase = new Case();
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
        suggestAnArticle = new Case();
        origPin = userContact.Self_Service_PIN__c;
    }

    public List<Case> getMyCases()
    {
        List<Contact> contacts = new List<Contact> { userContact };

        Map<Id, List<Case>> openCaseMap;

        if (viewingAs)
        {
            openCaseMap = MyASUViewAs.getViewAsOpenCases(contacts);
        }
        else
        {
            openCaseMap = CaseService.getVisibleOpenCases(contacts);
        }

        return (openCaseMap.get(userContact.Id) == null) ? new List<Case>() : openCaseMap.get(userContact.Id);
    }

    public List<Case> getClosedCases()
    {
        List<Case> closedCases = new List<Case>();

        List<Contact> contacts = new List<Contact> { userContact };

        Map<Id, List<Case>> closedCaseMap;

        if (viewingAs)
        {
            closedCaseMap = MyASUViewAs.getViewAsClosedCases(contacts);
        }
        else
        {
            closedCaseMap = CaseService.getVisibleClosedCases(contacts);
        }

        if (closedCaseMap.get(userContact.Id) != null)
        {
            // Limit the number of closed cases that are displayed to CLOSEDCASELIMIT
            if (closedCaseMap.get(userContact.Id).size() > CLOSEDCASELIMIT)
            {
                for (Integer i = 0; i < CLOSEDCASELIMIT; i++)
                {
                    closedCases.add(closedCaseMap.get(userContact.Id).get(i));
                }
            }
            else
            {
                closedCases = closedCaseMap.get(userContact.Id).clone();
            }
        }

        return closedCases;
    }

    public Case getCaseDetails()
    {
        if (viewingAs)
        {
            return MyASUViewAs.getViewAsCaseDetails(
                    ApexPages.currentPage().getParameters().get('Id')
            );
        }
        else
        {
            return [
                    SELECT Id, CaseNumber, Functional_Group__c, Subject, Description,
                            Feedback_Link__c, CreatedDate, Status, Origin, Created_By_Name__c, ClosedDate
                    FROM Case
                    WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
            ];
        }
    }

    public EmailMessage[] getEmailMessages() {
        Date launchDate = EMAILVISIBILITYDATE;
        if (viewingAs)
        {
            return CaseService.getCaseEmailMessages(
                    EMAILVISIBILITYDATE,
                    ApexPages.currentPage().getParameters().get('id'),
                    userContact.Email
            );
        }
        else
        {
            return [
                    SELECT FromName, CreatedDate, HtmlBody, LastModifiedDate, Subject,
                            TextBody, FromAddress, ToAddress, CCAddress
                    FROM EmailMessage
                    WHERE ParentId = :ApexPages.currentPage().getParameters().get('id')
                    AND Incoming = false
                    AND CreatedDate > :launchDate
                    AND ToAddress = :userContact.Email
                    ORDER BY CreatedDate DESC
            ];
        }
    }

    public PageReference viewCase()
    {
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        String current = ApexPages.currentPage().getUrl();
        current = current.split('apex/')[1];
        PageReference viewCasePage = new PageReference('/viewcase');
        viewCasePage.getParameters().put('id', caseId);

        if (current != 'viewAllCases')
        {
            viewCasePage.getParameters().put('source', current);
        }
        else
        {
            viewCasePage.getParameters().put('source', 'viewAllCases');
        }

        if (viewingAs)
        {
            viewCasePage.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
        }

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
        return (userContact.CAP__c == null) ? true : false;
    }

    public Boolean getRoverPhone()
    {
        return (userContact.CAP__c != null) ? true : false;
    }

    public Boolean getHelpBox()
    {
        if (userContact == Null)
        {
            return true;
        }
        else if ((oppList == Null && userContact != null) || (oppList.size() == 0 && userContact != null))
        {
            return true;
        }
        else if ((oppList[0].StageName == 'Enrolled'
                && oppList[0].Career__c == 'Undergraduate'
                && oppList[0].Admitted_Session__c == 'A/C')
                && today < date.valueOf(termcAC.Session_A_C_Start_Date__c))
        {
            return false;
        }
        else if ((oppList[0].StageName == 'Enrolled'
                && oppList[0].Career__c == 'Undergraduate'
                && oppList[0].Admitted_Session__c == 'B')
                && today < date.valueOf(termcB.Session_B_Start_Date__c))
        {
            return false;
        }
        else if (oppList[0].StageName != 'Enrolled'
                && oppList[0].Career__c == 'Undergraduate'
                && (userContact.Affiliation_Student__c == 'Current'
                || userContact.Affiliation_Alumni__c == 'Current'
                || userContact.Affiliation_Courtesy_Affiliate__c == 'Current'
                || userContact.Affiliation_Employee__c == 'Current')
                && today < date.valueOf(termcB.Session_B_Start_Date__c))
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
        if (userContact == Null)
        {
            return false;
        }
        else if ((oppList == Null && userContact != null)
                || (oppList.size() == 0 && userContact != null))
        {
            return false;
        }
        else if ((oppList[0].StageName == 'Enrolled'
                && oppList[0].Career__c == 'Undergraduate'
                && oppList[0].Admitted_Session__c == 'A/C')
                && today < date.valueOf(termcAC.Session_A_C_Start_Date__c))
        {
            return true;
        }
        else if ((oppList[0].StageName == 'Enrolled'
                && oppList[0].Career__c == 'Undergraduate'
                && oppList[0].Admitted_Session__c == 'B')
                && today < date.valueOf(termcB.Session_B_Start_Date__c))
        {
            return true;
        }
        else if (oppList[0].StageName != 'Enrolled'
                && oppList[0].Career__c == 'Undergraduate'
                && (userContact.Affiliation_Student__c == 'Current'
                || userContact.Affiliation_Alumni__c == 'Current'
                || userContact.Affiliation_Courtesy_Affiliate__c == 'Current'
                || userContact.Affiliation_Employee__c == 'Current')
                && today < date.valueOf(termcB.Session_B_Start_Date__c))
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
        if (userContact == Null)
        {
            return true;
        }
        else if ((oppList == Null && userContact != null)
                || (oppList.size() == 0 && userContact != null))
        {
            return true;
        }
        else if ((oppList[0].StageName == 'Enrolled'
                && oppList[0].Career__c == 'Undergraduate'
                && oppList[0].Admitted_Session__c == 'A/C')
                && today < date.valueOf(termcAC.Session_A_C_Start_Date__c))
        {
            return false;
        }
        else if ((oppList[0].StageName == 'Enrolled'
                && oppList[0].Career__c == 'Undergraduate'
                && oppList[0].Admitted_Session__c == 'B')
                && today < date.valueOf(termcB.Session_B_Start_Date__c))
        {
            return false;
        }
        else if (oppList[0].StageName != 'Enrolled'
                && oppList[0].Career__c == 'Undergraduate'
                && (userContact.Affiliation_Student__c == 'Current'
                || userContact.Affiliation_Alumni__c == 'Current'
                || userContact.Affiliation_Courtesy_Affiliate__c == 'Current'
                || userContact.Affiliation_Employee__c == 'Current')
                && today < date.valueOf(termcB.Session_B_Start_Date__c))
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
        if (viewingAs)
        {
            PageReference go = new PageReference(ApexPages.currentPage().getUrl());
            go.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
            go.setRedirect(true);

            return go;
        }

        try
        {
            newCase.ContactId = userContact.Id;
            newCase.Web_Submission__c = 'My ASU Standard';

            insert newCase;

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
        if (viewingAs)
        {
            return 111111;
        }
        else
        {
            return userContact.Self_Service_PIN__c;
        }
    }

    public PageReference changePin()
    {
        if (viewingAs)
        {
            PageReference go = new PageReference(ApexPages.currentPage().getUrl());
            go.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
            go.setRedirect(true);

            return go;
        }

        if (origPin == newPin)
        {
            PageReference pinError = ApexPages.currentPage();
            pinError.getParameters().put('PIN', 'error');
            pinError.setRedirect(true);
            return pinError;
        }

        if (ContactService.isPinValid(newPin, userContact.Birthdate))
        {
            userContact.Self_Service_PIN__c = newPin;
            if (userContact.PIN_lockout__c == true)
            {
                userContact.PIN_lockout__c = false;
            }

            update userContact;

            PageReference pinSuccess = ApexPages.currentPage();
            pinSuccess.getParameters().put('PIN', 'success');
            pinSuccess.setRedirect(true);
            return pinSuccess;
        }
        else
        {
            PageReference pinError = ApexPages.currentPage();
            pinError.getParameters().put('PIN', 'error');
            pinError.setRedirect(true);
            return pinError;
        }

    }

    public PageReference suggestAnArticleSubmit()
    {
        if (viewingAs)
        {
            PageReference go = new PageReference(ApexPages.currentPage().getUrl());
            go.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
            go.setRedirect(true);

            return go;
        }

        suggestAnArticle.Subject = 'Suggest An Article';
        suggestAnArticle.Description = suggestAnArticle.Description;
        suggestAnArticle.ContactId = userContact.Id;
        suggestAnArticle.OwnerId = [
                SELECT Id
                FROM Group
                WHERE Name = 'Student-Centric Initiatives (Case)'
                AND Type = 'Queue'
        ].Id;

        suggestAnArticle.Functional_Group__c = 'Student-Centric Initiatives';
        suggestAnArticle.Category__c = 'Knowledge';
        suggestAnArticle.Origin__c = 'My ASU';
        suggestAnArticle.Visible_by_Contact__c = false;

        insert suggestAnArticle;

        PageReference confirmPage = ApexPages.currentPage();
        confirmPage.getParameters().put('Suggest', 'yes');
        confirmPage.setRedirect(true);

        return confirmPage;
    }
}
