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
            }

            return sortDir;
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
                sortField = 'LastName';
            }

            return sortField;
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
        String searchNumber;

        if (ApexPages.currentPage().getParameters().containsKey('ANI'))
        {
            searchNumber = ApexPages.currentPage().getParameters().get('ANI');

            soql = 'FIND \'' + searchNumber + '\' ' +
                'IN PHONE FIELDS ' +
                'RETURNING Contact(' +
                'Firstname, Lastname, Phone, Help_Desk_Provided_Phone__c, ' +
                'Birthdate, ASURite_ID__c, EMPLID__c, ASU_Email__c, ' +
                'Personal_Email__c WHERE FirstName != null ' +
                'ORDER BY ' + sortField + ' ' + sortDir + ' LIMIT 20' +
                ')';

            runQuery(false);
        }
        else
        {
            contacts = new List<Contact>();
        }
    }

    // toggles the sorting of query from asc<-->desc
    public void toggleSort()
    {
        // simply toggle the direction
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        runQuery(false);
    }

    // Runs the actual query, set boolean to run SOQL search. Default SOSL search.
    public void runQuery(Boolean runSOQL)
    {
        contacts = new List<Contact>();

        try
        {
            if (runSOQL)
            {
                contacts = Database.query(soql);
            }
            else
            {
                List<List<SObject>> queryList = Search.query(soql);

                contacts = ((List<Contact>) queryList[0]);
            }
        }
        catch (Exception e)
        {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'There was a problem running the query. Please try again. ' + e.getMessage()
                )
            );
        }

    }

    // runs the search with parameters passed via Javascript
    public void runSearch()
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

        if (birthdate.length() > 0)
        {
            birthdateFormatted = String.valueOf(date.parse(birthdate));
            System.debug('merf birthdateFormatted: ' + birthdateFormatted);
        }

        // Create the main search string.
        String searchString = '';

        // Create checks for different queries
        Boolean nameSearch = false;
        Boolean emailSearch = false;
        Boolean phoneSearch = false;
        Boolean dateSearch = false;

        if ((!firstName.equals('') || !lastName.equals(''))
            && phone.equals('')
            && birthdateFormatted.equals('')
            && asuriteid.equals('')
            && emplid.equals('')
            && directoryEmail.equals('')
            && personalEmail.equals(''))
        {
            nameSearch = true;
        }

        if (firstName.equals('')
            && lastName.equals('')
            && phone.equals('')
            && birthdate.equals('')
            && asuriteid.equals('')
            && emplid.equals('')
            && (!directoryEmail.equals('')
            || !personalEmail.equals('')))
        {
            emailSearch = true;
        }

        if (firstName.equals('')
            && lastName.equals('')
            && !phone.equals('')
            && birthdateFormatted.equals('')
            && asuriteid.equals('')
            && emplid.equals('')
            && directoryEmail.equals('')
            && !personalEmail.equals(''))
        {
            phoneSearch = true;
        }

        if (firstName.equals('')
            && lastName.equals('')
            && phone.equals('')
            && (!birthdateFormatted.equals('') || birthdateFormatted != null)
            && asuriteid.equals('')
            && emplid.equals('')
            && directoryEmail.equals('')
            && personalEmail.equals(''))
        {
            dateSearch = true;
        }

        if (!birthdateFormatted.equals('') || birthdateFormatted != null)
        {
            System.debug('merf not blank');
        }
        else
        {
            System.debug('merf blank');
        }

        if (!firstName.equals(''))
        {
            searchString += ' ' + firstName + '*';
        }

        if (!lastName.equals(''))
        {
            searchString += ' ' + lastName + '*';
        }

        if (!phone.equals(''))
        {
            searchString += ' ' + phone;
        }

        if (!birthdate.equals(''))
        {
            searchString += ' ' + birthdateFormatted;
        }

        if (!asuriteid.equals(''))
        {
            searchString += ' ' + asuriteid + '*';
        }

        if (!emplid.equals(''))
        {
            searchString += ' ' + emplid + '*';
        }

        if (!directoryEmail.equals(''))
        {
            searchString += ' ' + directoryEmail + '*';
        }

        if (!personalEmail.equals(''))
        {
            searchString += ' ' + personalEmail + '*';
        }

        if (searchString != '')
        {
            if (dateSearch)
            {
                soql = '' +
                    'SELECT Firstname, Lastname, Phone, Help_Desk_Provided_Phone__c, ' +
                    'Birthdate, ASURite_ID__c, EMPLID__c, ASU_Email__c, ' +
                    'Personal_Email__c ' +
                    'FROM Contact' +
                    'WHERE FirstName != null ' +
                    'ORDER BY ' + sortField + ' ' + sortDir + ' ' +
                    'LIMIT 20';

                // run the query again
                runQuery(true);
            }
            else
            {
                String returnString = '';

                if (nameSearch)
                {
                    returnString = 'IN NAME FIELDS';
                }
                else if (emailSearch)
                {
                    returnString = 'IN EMAIL FIELDS';
                }
                else if (phoneSearch)
                {
                    returnString = 'IN PHONE FIELDS';
                }
                else
                {
                    returnString = 'IN ALL FIELDS';
                }

                soql = '' +
                    'FIND \'' + String.escapeSingleQuotes(searchString.trim()) + '\' ' +
                    returnString + ' ' +
                    'RETURNING Contact(' +
                    'Firstname, Lastname, Phone, Help_Desk_Provided_Phone__c, ' +
                    'Birthdate, ASURite_ID__c, EMPLID__c, ASU_Email__c, ' +
                    'Personal_Email__c WHERE FirstName != null ' +
                    'ORDER BY ' + sortField + ' ' + sortDir + ' ' +
                    'LIMIT 20' +
                    ')';

                // run the query again
                runQuery(false);
            }
        }
        else
        {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.INFO,
                    'You must enter search terms.'
                )
            );
        }
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

        List<RecordType> sfMastList= [
            SELECT Id
            FROM RecordType
            WHERE name = 'SF Mastered'
            AND SobjectType = 'Contact'
        ];

        mycontact.RecordTypeId = sfMastList[0].Id;
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

    public PageReference saveCase()
    {
        try
        {
            if (String.isEmpty(mycase.Subject) || String.isEmpty(mycase.Description))
            {
                ApexPages.addMessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'You must enter both a Subject and Description to save the Case.'
                    )
                );

                return null;
            }

            upsert mycase;

            PageReference page = new PageReference('/' + mycase.Id);
            page.setRedirect(true);

            return page;
        }
        catch (Exception ex)
        {
            ApexPages.addMessages(ex);

            return ApexPages.currentPage();
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
            if (String.isEmpty(mycase.Subject) || String.isEmpty(mycase.Description))
            {
                ApexPages.addMessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'You must enter both a Subject and Description to save the Case.'
                    )
                );

                return null;
            }

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

    // Upsert Case and set bool value to render the close status panel.
    public void saveAndCloseCase()
    {
        try
        {
            if (String.isEmpty(mycase.Subject) || String.isEmpty(mycase.Description))
            {
                ApexPages.addMessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'You must enter both a Subject and Description to save the Case.'
                    )
                );

                return;
            }

            upsert mycase;

            isCloseCase = true;
        }
        catch (Exception ex)
        {
            ApexPages.addMessages(ex);
        }
    }

    public PageReference saveCloseCase()
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

            PageReference page = new PageReference('/500?fcf=00Bd0000005TDlX');
            page.setRedirect(true);

            return page;
        }
        catch (Exception ex)
        {
            ApexPages.addMessages(ex);

            return ApexPages.currentPage();
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

            ApexPages.addMessage(
                new ApexPages.message(
                    ApexPages.severity.CONFIRM,
                    'Contact created successfully.'
                )
            );

            isContactSet = true;
            selectedContactId = mycontact.Id;
            isNewContactSelected = false;
            contactsrch = mycontact;
            mycontact = new Contact();
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