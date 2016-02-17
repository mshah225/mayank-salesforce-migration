// Custom controller for the HelpDesk page
public with sharing class HelpDeskController
{
    private String soql { get; set; }

    public Boolean isNewCaseSelected { get; set; }
    public Boolean isExistingCaseSelected { get; set; }
    public Boolean isNewContactSelected { get; set; }
    public Boolean isCloseCase { get; set; }
    public Boolean isContactSet { get; set; }
    public Boolean isKnowledgeSearch { get; set;}
    public Case mycase { get; set; }
    public Contact mycontact { get; set; }
    public List<Contact> contacts { get; set; }
    public List<CaseWrapper> cases { get; set; }
    public List<FAQ__kav> faqList { get; set; }
    public List<List<SObject>> knowledgeResults { get; set; }
    public String selectedContactId { get; set; }
    public String selectedCaseId { get; set; }
    public String contactName { get; set; }
    public String knowString { get; set; }

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
        isKnowledgeSearch = false;
        knowString = '';
        faqList = new List<FAQ__kav>();
        String searchNumber;

        if (ApexPages.currentPage().getParameters().containsKey('ANI'))
        {
            searchNumber = ApexPages.currentPage().getParameters().get('ANI');
            callerId = formatPhone(searchNumber);

            soql = 'FIND \'' + searchNumber + '\' ' +
                'IN PHONE FIELDS ' +
                'RETURNING Contact(' +
                'Name, Firstname, Lastname, Phone, Help_Desk_Provided_Phone__c, ' +
                'Birthdate, ASURite_ID__c, EMPLID__c, ASU_Email__c, ' +
                'Personal_Email__c WHERE FirstName != null ' +
                'ORDER BY ' + sortField + ' ' + sortDir + ' LIMIT 25' +
                ')';

            runSearch(false);
        }
        else
        {
            contacts = new List<Contact>();
        }

        if (contacts.size() == 1)
        {
            selectedContactId = contacts[0].Id;
            setAsContact();
        }
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
        //runSearch(false);
        buildSearchString();
    }

    // Runs the actual query, set boolean to run SOQL search. Default SOSL search.
    public void runSearch(Boolean runSOQL)
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
    public void buildSearchString()
    {
        isKnowledgeSearch = false;
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

        // Create the main search string.
        String searchString = '';
        String soqlOptions = '';

        // Create checks for different queries
        Boolean nameSearch = false;
        Boolean emailSearch = false;
        Boolean phoneSearch = false;
        Boolean dateSearch = false;

        if ((!firstName.equals('') || !lastName.equals(''))
            && phone.equals('')
            && birthdate.equals('')
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
            && birthdate.equals('')
            && asuriteid.equals('')
            && emplid.equals('')
            && directoryEmail.equals('')
            && personalEmail.equals(''))
        {
            phoneSearch = true;
        }

        if (!birthdate.equals(''))
        {
            dateSearch = true;
        }

        if (!firstName.equals('') && !dateSearch)
        {
            searchString += ' ' + firstName.trim() + '*';
        }
        else if (!firstName.equals('') && dateSearch)
        {
            soqlOptions += ' AND Firstname LIKE \'' +
                String.escapeSingleQuotes(firstName.trim()) + '%\'';
        }

        if (!lastName.equals('') && !dateSearch)
        {
            searchString += ' ' + lastName.trim() + '*';
        }
        else if (!lastName.equals('') && dateSearch)
        {
            soqlOptions += ' AND Lastname LIKE \'' +
                String.escapeSingleQuotes(lastName.trim()) + '%\'';
        }

        if (!phone.equals('') && !dateSearch)
        {
            searchString += ' ' + phone;
        }
        else if (!phone.equals('') && dateSearch)
        {
            phone = formatPhone(phone);

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
                    phone.substring(3, 6) + '%' +
                    phone.substring(6, math.min(phoneLength, 10)) + '%';
            }

            soqlOptions += ' AND (HomePhone like \'' + phoneWildcarded + '\' ' +
                'OR MobilePhone like \'' + phoneWildcarded + '\' ' +
                'OR OtherPhone like \'' + phoneWildcarded + '\' ' +
                'OR Phone like \'' + phoneWildcarded + '\' ' +
                'OR Work_Phone__c like \'' + phoneWildcarded + '\' ' +
                'OR Help_Desk_Provided_Phone__c like \'' + phoneWildcarded + '\'' +
            ')';
        }

        // This only sets the soqlOptions if date is being searched. Doesn't set date for SOSL.
        if (!birthdate.equals('') && dateSearch)
        {
            soqlOptions += ' AND Birthdate = ' + birthdateFormatted.trim();
        }

        if (!asuriteid.equals('') && !dateSearch)
        {
            searchString += ' ' + asuriteid.trim() + '*';
        }
        else if (!asuriteid.equals('') && dateSearch)
        {
            soqlOptions += ' AND ASURite_ID__c LIKE \'' +
                String.escapeSingleQuotes(asuriteid.trim()) + '%\'';
        }

        if (!emplid.equals('') && !dateSearch)
        {
            searchString += ' ' + emplid.trim() + '*';
        }
        else if (!emplid.equals('') && dateSearch)
        {
            soqlOptions += ' AND EMPLID__c LIKE \'' +
                String.escapeSingleQuotes(emplid.trim()) + '%\'';
        }

        if (!directoryEmail.equals('') && !dateSearch)
        {
            searchString += ' ' + directoryEmail.trim() + '*';
        }
        else if (!directoryEmail.equals('') && dateSearch)
        {
            soqlOptions += ' AND ASU_Email__c LIKE \'' +
                String.escapeSingleQuotes(directoryEmail.trim()) + '%\'';
        }

        if (!personalEmail.equals('') && !dateSearch)
        {
            searchString += ' ' + personalEmail.trim() + '*';
        }
        else if (!personalEmail.equals('') && dateSearch)
        {
            soqlOptions += ' AND Personal_Email__c LIKE \'' +
                String.escapeSingleQuotes(personalEmail.trim()) + '%\'';
        }

        if (dateSearch)
        {
            if (soqlOptions != '')
            {
                soql = '' +
                    'SELECT Name, Firstname, Lastname, Phone, Help_Desk_Provided_Phone__c, ' +
                    'Birthdate, ASURite_ID__c, EMPLID__c, ASU_Email__c, ' +
                    'Personal_Email__c ' +
                    'FROM Contact ' +
                    'WHERE FirstName != null';

                soql += soqlOptions;

                soql += ' ORDER BY ' + sortField + ' ' + sortDir + ' ' +
                    'LIMIT 25';

                // run the query again
                runSearch(true);
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
        else
        {
            if (searchString != '')
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
                    'Name, Firstname, Lastname, Phone, Help_Desk_Provided_Phone__c, ' +
                    'Birthdate, ASURite_ID__c, EMPLID__c, ASU_Email__c, ' +
                    'Personal_Email__c WHERE FirstName != null ' +
                    'ORDER BY ' + sortField + ' ' + sortDir + ' ' +
                    'LIMIT 25' +
                    ')';

                // run the query again
                runSearch(false);
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
    }

    public void knowledgeSearch()
    {
        if (knowString != '')
        {
            knowledgeResults = new List<List<SObject>>();

            String sosl = '' +
                'FIND \'' + String.escapeSingleQuotes(knowString.trim()) + '*\' ' +
                'IN ALL FIELDS RETURNING ' +
                'FAQ__kav(' +
                'KnowledgeArticleId, Title, Answer__c ' +
                'WHERE Language = \'en_US\' ' +
                'AND PublishStatus = \'Online\'' +
                ')';

            knowledgeResults = Search.query(sosl);

            if (knowledgeResults.size() > 0)
            {
                faqList = knowledgeResults[0];
            }
            else
            {
                faqList = new List<FAQ__kav>();
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
                contactName = co.Name;
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
                    'WHERE ContactId = :selectedContactId ' +
                    'ORDER BY CreatedDate DESC'
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
        isKnowledgeSearch = true;
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
//        isContactSet = false;
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