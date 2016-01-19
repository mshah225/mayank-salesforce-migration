// Custom controller for the HelpDesk page
public with sharing class HelpDeskController
{
    // the following are booleans that are used for rendering/hiding various sections of the page based on context
    public Boolean isNewCaseSelected { get; set; }
    public Boolean isExistingCaseSelected { get; set; }
    public Boolean isNewContactSelected { get; set; }
    public Boolean isCloseCase { get; set; }
    public Boolean isContactSet { get; set; }

    // the new case being created
    public Case mycase { get; set; }

    // the new contact being created
    public Contact mycontact { get; set; }

    // the collection of contacts to display - these are the results of the SOQL query
    public List<Contact> contacts { get; set; }

    // the open cases for the selected contact
    public List<CaseWrapper> cases { get; set; }

    // the soql without the order and limit
    private String soql { get; set; }

    // the selected contact -- this is populated when the "Set as Contact" link is hit on a Contact
    public String selectedContactId { get; set; }

    // the selected case -- this is populated when the "Set as Case" link is hit on a Case
    public String selectedCaseId { get; set; }

    // This method returns a list of Close statuses for Cases
    public List<SelectOption> getcloseCaseStatusOptions()
    {
        List<SelectOption> closeCaseStatusOptions = new List<SelectOption>();
        closeCaseStatusOptions.add(new SelectOption('', '--None--'));
        
        for (CaseStatus cs: [Select Id, MasterLabel From CaseStatus Where IsClosed = true])
        {
            closeCaseStatusOptions.add(new SelectOption(cs.Id, cs.MasterLabel));
        }
        
        return closeCaseStatusOptions;
    }

    public String selectedCloseCaseStatusOption { get; set; }

    // This represents the Contact search fields
    public Contact contactsrch
    {
        get
        {
            if (contactsrch == null)
            {
                contactsrch = new Contact();
            }
            return contactsrch;
        }
        set;
    }

    // This stores the incoming phone number (ANI parameter)
    public String callerId { get; set; }

    // the current sort direction. defaults to asc
    public String sortDir
    {
        get
        {
            if (sortDir == null)
            {
                sortDir = 'asc';
            } return sortDir;
        }
        set;
    }

    // the current field to sort by. defaults to last name
    public String sortField
    {
        get
        {
            if (sortField == null)
            {
                sortField = 'lastName';
            } return sortField;
        }
        set;
    }

    // Init the controller and display some sample data when the page loads
    public HelpDeskController()
    {
        isNewCaseSelected = false;
        isExistingCaseSelected = false;
        isCloseCase = false;
        isNewContactSelected = false;
        isContactSet = false;
        String callerIdWildcarded;
        String callerIdUnformatted;

        soql = 'SELECT Firstname, Lastname, Phone, Help_Desk_Provided_Phone__c, ' +
            'Birthdate, ASURite_ID__c, EMPLID__c, ASU_Email__c,  Personal_Email__c ' +
            'FROM Contact ' +
            'WHERE Firstname != null';

        if (ApexPages.currentPage().getParameters().containsKey('ANI'))
        {
            callerIdUnformatted = ApexPages.currentPage().getParameters().get('ANI');
            callerId = formatPhone(callerIdUnformatted);

            callerIdWildcarded = '%' + callerIdUnformatted.substring(0, 3) + '%' +
                callerIdUnformatted.substring(3, 6) + '%' +
                callerIdUnformatted.substring(6, 10) + '%';

            System.debug(callerIdWildcarded);

            soql += ' AND (HomePhone LIKE \'' + callerIdWildcarded + '\' ' +
                'OR MobilePhone LIKE \'' + callerIdWildcarded + '\' ' +
                'OR OtherPhone LIKE \'' + callerIdWildcarded + '\' ' +
                'OR Phone LIKE \'' + callerIdWildcarded + '\' ' +
                'OR Work_Phone__c LIKE \'' + callerIdWildcarded + '\' ' +
                'OR Help_Desk_Provided_Phone__c LIKE \'' + callerIdWildcarded + '\')';
        }

        runQuery();
    }

    // Reformats a 10 digit phone number to the following format: (xxx) xxx-xxxx
    private static String formatPhone(String phone)
    {
        string nondigits = '[^0-9]';
        string phoneDigits;

        // remove all non numeric
        phoneDigits = phone.replaceAll(nondigits, '');

        // 10 digit: reformat with dashes
        if (phoneDigits.length() == 10)
            return '(' + phoneDigits.substring(0, 3) + ') ' +
                phoneDigits.substring(3, 6) + '-' +
                phoneDigits.substring(6, 10);

        // if it isn't a 10 digit number, return the original because
        // it may contain an extension or special information
        return(phone);
    }

    // toggles the sorting of query from asc<-->desc
    public void toggleSort()
    {
        // simply toggle the direction
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        runQuery();
    }

    // runs the actual query
    public void runQuery()
    {

        try
        {
            contacts = Database.query(
                soql +
                ' ORDER BY ' + sortField + ' ' + sortDir +
                ' LIMIT 20'
            );
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
        }

    }

    // runs the search with parameters passed via Javascript
    public PageReference runSearch()
    {

        String firstName = Apexpages.currentPage().getParameters().get('firstname');
        String lastName = Apexpages.currentPage().getParameters().get('lastname');
        String phone = Apexpages.currentPage().getParameters().get('phone');
        String birthdate = Apexpages.currentPage().getParameters().get('birthdate');
        String asuriteid = Apexpages.currentPage().getParameters().get('asuriteid');
        String emplid = Apexpages.currentPage().getParameters().get('emplid');
        String directoryEmail = Apexpages.currentPage().getParameters().get('directoryemail');
        String personalEmail = Apexpages.currentPage().getParameters().get('personalemail');
        String birthdateFormatted;
        String phoneWildcarded;
        Integer phoneLength = phone.length();

        if (birthdate.length() > 0)
        {
            birthdateFormatted = String.valueOf(date.parse(birthdate));
        }

        if (phoneLength > 0 && phoneLength <= 3)
        {
            phoneWildcarded = '%' + phone.substring(0, math.min(phoneLength, 3)) + '%';
        }
        else if (phoneLength > 3 && phoneLength <= 6)
        {
            phoneWildcarded = '%' + phone.substring(0, 3) + '%' +
                phone.substring(3, math.min(phoneLength, 6)) + '%';
        }
        else if (phoneLength > 6)
        {
            phoneWildcarded = '%' + phone.substring(0, 3) + '%' +
                phone.substring(3, 6) + '%' + phone.substring(6, math.min(phoneLength, 10)) + '%';
        }


        soql = 'SELECT Firstname, Lastname, Phone, Help_Desk_Provided_Phone__c, Birthdate, ' +
                'ASURite_ID__c, EMPLID__c, ASU_Email__c,  Personal_Email__c ' +
            'FROM Contact ' +
            'WHERE Firstname != null';

        if (!firstName.equals(''))
        {
            soql += ' AND Firstname LIKE \'' + String.escapeSingleQuotes(firstName) + '%\'';
        }

        if (!lastName.equals(''))
        {
            soql += ' AND Lastname LIKE \'' + String.escapeSingleQuotes(lastName) + '%\'';
        }

        if (!phone.equals(''))
        {
            soql += ' AND (HomePhone LIKE \'' + phoneWildcarded + '\' ' +
                'OR MobilePhone LIKE \'' + phoneWildcarded + '\' ' +
                'OR OtherPhone LIKE \'' + phoneWildcarded + '\' ' +
                'OR Phone LIKE \'' + phoneWildcarded + '\' ' +
                'OR SF_Mobile__c LIKE \'' + phoneWildcarded + '\' ' +
                'OR SMS_Phone__c LIKE \'' + phoneWildcarded + '\' ' +
                'OR Work_Phone__c LIKE \'' + phoneWildcarded + '\' ' +
                'OR Help_Desk_Provided_Phone__c LIKE \'' + phoneWildcarded + '\')';
        }

        if (!birthdate.equals(''))
        {
            soql += ' AND Birthdate = ' + birthdateFormatted;
        }

        if (!asuriteid.equals(''))
        {
            soql += ' AND ASURite_ID__c LIKE \'' + String.escapeSingleQuotes(asuriteid) + '%\'';
        }

        if (!emplid.equals(''))
        {
            soql += ' AND EMPLID__c LIKE \'' + String.escapeSingleQuotes(emplid) + '%\'';
        }

        if (!directoryEmail.equals(''))
        {
            soql += ' AND ASU_Email__c LIKE \'' +
                String.escapeSingleQuotes(directoryEmail) + '%\'';
        }

        if (!personalEmail.equals(''))
        {
            soql += ' AND Personal_Email__c LIKE \'' +
                String.escapeSingleQuotes(personalEmail) + '%\'';
        }

        // run the query again
        runQuery();

        return null;
    }

    public void newCase()
    {
        isNewCaseSelected = true;

        if (mycase == null)
        {
            mycase = new Case();
        }
        else
        {
            mycase.clear();
        }

        mycase.ContactId = selectedContactId;
        mycase.Status = 'New';
        mycase.Origin = 'Phone';
        mycase.Campus__c = 'Tempe';
        mycase.Functional_Group__c = 'Help Desk';
    }

    public void newContact()
    {
        isNewContactSelected = true;

        if (mycontact == null)
        {
            mycontact = new Contact();
        }

        mycontact.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE name = 'SF Mastered'
            AND SobjectType = 'Contact' limit 1
        ].Id;

        mycontact.MailingCountryCode = 'US';
        mycontact.Firstname = contactsrch.Firstname;
        mycontact.Lastname = contactsrch.Lastname;
        mycontact.Email = contactsrch.Personal_Email__c;
        mycontact.Phone = contactsrch.Phone;
        mycontact.Help_Desk_Provided_Phone__c = callerId;
        isContactSet = false;
        isNewCaseSelected = false;
        isExistingCaseSelected = false;
    }

    public void clearContactSearch()
    {
        isNewContactSelected = false;
        isContactSet = false;

        if (cases != null)
        {
            cases.clear();
        }

        isNewCaseSelected = false;
        isExistingCaseSelected = false;
        selectedContactId = null;

        if (contactsrch != null)
        {
            contactsrch.clear();
        }

        if (contacts != null)
        {
            contacts.clear();
        }
    }

    public void setAsContact()
    {
        List<Case> casesbase;

        // populate the contact search fields based on the selected contact
        for (Contact co : contacts)
        {
            if (co.id == selectedContactId)
            {
                contactsrch = co;
                isContactSet = true;
                isNewCaseSelected = false;
                isExistingCaseSelected = false;
                break;
            }
        }

        // query to get open cases for the contact
        try
        {
            casesbase = Database.query(
                'SELECT Id, Subject, Reason, Description, Status, Origin, Campus__c, ' +
                    'Affiliation__c, Functional_Group__c, Category__c, Sub_Category__c, ' +
                    'Private_Note_Help_Desk__c, ClosedDate ' +
                'FROM Case ' +
                'WHERE ContactId = :selectedContactId'
            );
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
        }

        if (cases == null)
        {
            cases = new List<CaseWrapper>();
        }
        else
        {
            cases.clear();
        }

        for (Case ca : casesbase)
        {
            CaseWrapper mycw = new CaseWrapper(ca);
            cases.add(mycw);
        }

    }

    public void setAsCase()
    {
        isExistingCaseSelected = true;
        Map<Id, CaseWrapper> m = new Map<Id, CaseWrapper>();

        for (CaseWrapper cas : cases)
        {
            m.put(cas.Ca.Id, cas);
        }

        mycase = (Case) m.get(selectedCaseId).Ca;
    }

    public void saveCase()
    {
        try
        {
            if (String.isEmpty(mycase.Subject))
            {
                mycase.Subject = '-';
            }

            if (String.isEmpty(mycase.Description))
            {
                mycase.Description = '-';
            }

            upsert mycase;
        }
        catch (Exception ex)
        {
            ApexPages.addMessages(ex);
        }
    }

    public void cancelCase()
    {
        if (isNewCaseSelected)
        {
            isNewCaseSelected = false;
        }
        else if (isExistingCaseSelected)
        {
            isExistingCaseSelected = false;
        }
    }

    public PageReference saveAndTransferCase()
    {
        boolean success = false;

        try
        {
            upsert mycase;
            PageReference page = new PageReference('/apex/CaseTransfer?id=' + mycase.Id);
            page.setRedirect(true);
            return page;
        }
        catch (Exception ex)
        {
            ApexPages.addMessages(ex);
            return ApexPages.currentPage();
        }
    }

    public void saveAndCloseCase()
    {
        try
        {
            upsert mycase;
            isCloseCase = true;
        }
        catch (Exception ex)
        {
            ApexPages.addMessages(ex);
        }
    }

    public void saveCloseCase()
    {
        if (!(null == selectedCloseCaseStatusOption
            || selectedCloseCaseStatusOption.length() == 0))
        {
            mycase.Status = [
                SELECT MasterLabel
                FROM CaseStatus
                WHERE Id = :selectedCloseCaseStatusOption
            ].MasterLabel;
        }
        try
        {
            upsert mycase;
        }
        catch (Exception ex)
        {
            ApexPages.addMessages(ex);
        }
    }

    public void cancelCloseCase()
    {
        if (isNewCaseSelected)
        {
            isNewCaseSelected = false;
        }
        else if (isExistingCaseSelected)
        {
            isExistingCaseSelected = false;
        }

        if (isCloseCase)
        {
            isCloseCase = false;
        }
    }

    public void saveContact()
    {
        try
        {
            insert mycontact;
            isContactSet = true;
            selectedContactId = mycontact.Id;
            isNewContactSelected = false;
            contactsrch = mycontact;
            isNewCaseSelected = false;
            isExistingCaseSelected = false;
        }
        catch (Exception ex)
        {
            ApexPages.addMessages(ex);
        }
    }

    public void cancelNewContact()
    {
        isNewContactSelected = false;
        isContactSet = false;
        selectedContactId = null;

        if (mycontact != null)
        {
            mycontact = null;
        }
    }

    public void setAsHelpDeskProvidedPhone()
    {
        try
        {
            Contact contactToUpdate = [
                SELECT Id, Help_Desk_Provided_Phone__c
                FROM Contact
                WHERE Id = :selectedContactId
            ];

            contactsrch.Help_Desk_Provided_Phone__c = callerId;
            contactToUpdate.Help_Desk_Provided_Phone__c = contactsrch.Help_Desk_Provided_Phone__c;

            update contactToUpdate;
        }
        catch (Exception ex)
        {
            ApexPages.addMessages(ex);
        }
    }

    // This wrapper class on Case was created so that we can show a truncated case description
    public class CaseWrapper
    {
        public Case Ca { get; set; }
        public String shortDescr { get; set; }
        public String fullDescr { get; set; }

        public CaseWrapper(Case c)
        {
            Ca = c;

            if (String.isNotEmpty(c.Description))
            {
                shortDescr = c.Description.abbreviate(140);
            }
            else
            {
                shortDescr = ' ';
            }

            fullDescr = c.Description;
        }
    }
}