// Custom controller for the HelpDesk page
public with sharing class HelpDeskController {
    private String soql { get; set; }
    public CaseClassificationPicklistService ccPicklist { get; set; }
    public Boolean isPageLoaded;
    public static final String CLOSED_FORWARDED {
        get {
            return 'Closed: Forwarded';
        }
        set;
    }
    public static final String OTHER_UNIT {
        get {
            return 'Other Unit';
        }
        set;
    }
    public static final String SERVICE_NOW {
        get {
            return 'ServiceNow';
        }
        set;
    }
    public Boolean isNewCaseSelected { get; set; }
    public Boolean isArticleDetails { get; set; }
    public Boolean isExistingCaseSelected { get; set; }
    public Boolean isNewContactSelected { get; set; }
    public Boolean isCloseCase { get; set; }
    public Boolean isContactSet { get; set; }
    public Boolean isKnowledgeSearch { get; set; }
    public Boolean isKnowSearchBox { get; set; }
    public Boolean isAttached { get; set; }
    public Case myCase { get; set; }
    public Contact mycontact { get; set; }
    public FAQ__kav selectedFAQ { get; set; }
    public List<Contact> contacts { get; set; }
    public List<CaseWrapper> cases { get; set; }
    public List<FAQ__kav> attachedFAQs { get; set; }
    public List<FAQ__kav> faqList { get; set; }
    public List<List<SObject>> knowledgeResults { get; set; }
    public String selectedContactId { get; set; }
    public String selectedCaseId { get; set; }
    public String selectedKnowledgeArticleId { get; set; }
    public String contactName { get; set; }
    public String knowString { get; set; }
    public Boolean savedAndClosed { get; set; }

    // This method returns a list of Close statuses for Cases
    public List<SelectOption> getcloseCaseStatusOptions() {
        List<SelectOption> closeCaseStatusOptions = new List<SelectOption>();
        closeCaseStatusOptions.add(new SelectOption('', '--None--'));

        for (CaseStatus cs : [SELECT Id, MasterLabel FROM CaseStatus WHERE IsClosed = TRUE]) {
            if (!(cs.MasterLabel == CLOSED_FORWARDED)) {
                closeCaseStatusOptions.add(new SelectOption(cs.Id, cs.MasterLabel));
            }
        }

        return closeCaseStatusOptions;
    }

    public List<SelectOption> getOriginOptions() {
        List<SelectOption> origins = new List<SelectOption>();
        origins.add(new SelectOption('Incoming Call', 'Incoming Call'));
        origins.add(new SelectOption('Outbound Call', 'Outbound Call'));
        origins.add(new SelectOption('My ASU', 'My ASU'));
        origins.add(new SelectOption('Chat', 'Chat'));
        return origins;
    }

    // This represents the Contact search fields
    public Contact contactsrch {
        get {
            if (contactsrch == null) {
                contactsrch = new Contact();
            }

            return contactsrch;
        }
        set;
    }

    // This stores the incoming phone number (ANI parameter)
    public String callerId { get; set; }
    public Boolean isDuoAuthenticated { get; set; }
    public Boolean hasANIPresent { get; set; }

    // the current sort direction. defaults to asc
    public String sortDir {
        get {
            if (sortDir == null) {
                sortDir = 'asc';
            }

            return sortDir;
        }
        set;
    }

    // the current field to sort by. defaults to last name
    public String sortField {
        get {
            if (sortField == null) {
                sortField = 'LastName';
            }

            return sortField;
        }
        set;
    }

    // Init the controller and display some sample data when the page loads
    public HelpDeskController() {
        isNewCaseSelected = false;
        isExistingCaseSelected = false;
        isCloseCase = false;
        isNewContactSelected = false;
        isContactSet = false;
        isKnowledgeSearch = false;
        isKnowSearchBox = false;
        isArticleDetails = false;
        isAttached = false;
        isPageLoaded = false;
        isDuoAuthenticated = false;
        hasANIPresent = false;
        knowString = '';
        faqList = new List<FAQ__kav>();
        attachedFAQs = new List<FAQ__kav>();
        contacts = new List<Contact>();
        ccPicklist = new CaseClassificationPicklistService();
        setCallerId();
        isPageLoaded = true;
    }

    private void setCallerId() {
        if (ApexPages.currentPage().getParameters().containsKey('ANI')) {
            if (ApexPages.currentPage().getParameters().get('ANI') != '') {
                hasANIPresent = true;
                String searchNumber = ApexPages.currentPage().getParameters().get('ANI');
                callerId = formatPhone(searchNumber);

                soql =
                    'FIND \'' +
                    callerId +
                    '\' ' +
                    'IN PHONE FIELDS ' +
                    'RETURNING Contact(' +
                    'Name, Firstname, Lastname, Phone, Help_Desk_Provided_Phone__c, ' +
                    'Birthdate, ASURite_ID__c, EMPLID__c, ASU_Email__c, FERPA_Directory_Hold__c,' +
                    'Personal_Email__c, CAP__c WHERE FirstName != null ' +
                    'ORDER BY ' +
                    sortField +
                    ' ' +
                    sortDir +
                    ' LIMIT 25' +
                    ')';

                runSearch(false);
                setDuoAuthenticatedStatus();
            } else {
                populateNonAffiliate();
            }
        } else {
            populateNonAffiliate();
        }
    }

    private void setDuoAuthenticatedStatus() {
        List<DUO_Authentication__c> authenticatedUsers = new List<DUO_Authentication__c>();
        authenticatedUsers = [
            SELECT Id, ANI__c, Status__c
            FROM DUO_Authentication__c
            WHERE ANI__c = :callerId AND Time_of_Authentication__c > :Datetime.now().addMinutes(-5)
            LIMIT 1
        ];
        if (authenticatedUsers.size() > 0 && authenticatedUsers[0].Status__c == 'Authenticated') {
            isDuoAuthenticated = true;
        }
    }

    // Help Desk requests to have the non affiliate 1st in the list at all times.
    // Call this method after all searches to place it there.
    public void populateNonAffiliate() {
        // Always add the Non-Affiliate Caller to the list results.
        List<Contact> nonAffiliateList = [
            SELECT
                Id,
                Name,
                FirstName,
                LastName,
                Phone,
                Help_Desk_Provided_Phone__c,
                Birthdate,
                ASURite_ID__c,
                EMPLID__c,
                ASU_Email__c,
                Personal_Email__c,
                CAP__c,
                FERPA_Directory_Hold__c
            FROM Contact
            WHERE Name = 'Non-Affiliate Caller'
        ];

        if (nonAffiliateList.size() > 0) {
            // Add the non affiliate caller to the list at index 0
            if (contacts.size() > 0) {
                contacts.add(0, nonAffiliateList[0]);
            } else {
                contacts.add(nonAffiliateList[0]);
            }
        }
    }

    // Reformats a 10 digit phone number to the following format: (xxx) xxx-xxxx
    private static String formatPhone(String phone) {
        // remove all non numeric
        String phoneDigits = phone.replaceAll('[^0-9]', '');

        if (phoneDigits == '')
            phoneDigits = '0000000000';

        return phoneDigits;
    }

    // toggles the sorting of query from asc<-->desc
    public void toggleSort() {
        // simply toggle the direction
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';

        // run the query again
        buildSearchString();
    }

    // Runs the actual query, set boolean to run SOQL search. Default SOSL search.
    public void runSearch(Boolean runSOQL) {
        isContactSet = false;
        isNewCaseSelected = false;
        isExistingCaseSelected = false;
        isCloseCase = false;
        isKnowledgeSearch = false;
        isNewContactSelected = false;
        contacts = new List<Contact>();

        try {
            if (runSOQL) {
                contacts = Database.query(soql);
            } else {
                List<List<SObject>> queryList = Search.query(soql);

                contacts = ((List<Contact>) queryList[0]);
            }

            if (!isPageLoaded) {
                if (contacts.size() == 1) {
                    selectedContactId = contacts[0].Id;
                    setAsContact();
                }
            }

            populateNonAffiliate();
        } catch (Exception e) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'There was a problem running the query. Please try again. ' + e.getMessage()
                )
            );
        }
    }

    // runs the search with parameters passed via Javascript
    public void buildSearchString() {
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

        if (birthdate.length() > 0) {
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

        if (
            (!firstName.equals('') || !lastName.equals('')) &&
            phone.equals('') &&
            birthdate.equals('') &&
            asuriteid.equals('') &&
            emplid.equals('') &&
            directoryEmail.equals('') &&
            personalEmail.equals('')
        ) {
            nameSearch = true;
        }

        if (
            firstName.equals('') &&
            lastName.equals('') &&
            phone.equals('') &&
            birthdate.equals('') &&
            asuriteid.equals('') &&
            emplid.equals('') &&
            (!directoryEmail.equals('') || !personalEmail.equals(''))
        ) {
            emailSearch = true;
        }

        if (
            firstName.equals('') &&
            lastName.equals('') &&
            !phone.equals('') &&
            birthdate.equals('') &&
            asuriteid.equals('') &&
            emplid.equals('') &&
            directoryEmail.equals('') &&
            personalEmail.equals('')
        ) {
            phoneSearch = true;
        }

        if (!birthdate.equals('')) {
            dateSearch = true;
        }

        if (!firstName.equals('') && !dateSearch) {
            searchString += ' ' + firstName.trim() + '*';
        } else if (!firstName.equals('') && dateSearch) {
            soqlOptions += ' AND Firstname LIKE \'' + String.escapeSingleQuotes(firstName.trim()) + '%\'';
        }

        if (!lastName.equals('') && !dateSearch) {
            searchString += ' ' + lastName.trim() + '*';
        } else if (!lastName.equals('') && dateSearch) {
            soqlOptions += ' AND Lastname LIKE \'' + String.escapeSingleQuotes(lastName.trim()) + '%\'';
        }

        if (!phone.equals('') && !dateSearch) {
            searchString += ' ' + phone;
        } else if (!phone.equals('') && dateSearch) {
            Integer phoneLength = phone.length();
            phone = formatPhone(phone);

            if (phoneLength > 0 && phoneLength <= 3) {
                phoneWildcarded = '%' + phone.substring(0, math.min(phoneLength, 3)) + '%';
            } else if (phoneLength > 3 && phoneLength <= 6) {
                phoneWildcarded =
                    '%' +
                    phone.substring(0, 3) +
                    '%' +
                    phone.substring(3, math.min(phoneLength, 6)) +
                    '%';
            } else if (phoneLength > 6) {
                phoneWildcarded =
                    '%' +
                    phone.substring(0, 3) +
                    '%' +
                    phone.substring(3, 6) +
                    '%' +
                    phone.substring(6, math.min(phoneLength, 10)) +
                    '%';
            }

            soqlOptions +=
                ' AND (HomePhone like \'' +
                phoneWildcarded +
                '\' ' +
                'OR MobilePhone like \'' +
                phoneWildcarded +
                '\' ' +
                'OR OtherPhone like \'' +
                phoneWildcarded +
                '\' ' +
                'OR Phone like \'' +
                phoneWildcarded +
                '\' ' +
                'OR Work_Phone__c like \'' +
                phoneWildcarded +
                '\' ' +
                'OR Help_Desk_Provided_Phone__c like \'' +
                phoneWildcarded +
                '\'' +
                ')';
        }

        // This only sets the soqlOptions if date is being searched. Doesn't set date for SOSL.
        if (!birthdate.equals('') && dateSearch) {
            soqlOptions += ' AND Birthdate = ' + birthdateFormatted.trim();
        }

        if (!asuriteid.equals('') && !dateSearch) {
            searchString += ' ' + asuriteid.trim() + '*';
        } else if (!asuriteid.equals('') && dateSearch) {
            soqlOptions += ' AND ASURite_ID__c LIKE \'' + String.escapeSingleQuotes(asuriteid.trim()) + '%\'';
        }

        if (!emplid.equals('') && !dateSearch) {
            searchString += ' ' + emplid.trim() + '*';
        } else if (!emplid.equals('') && dateSearch) {
            soqlOptions += ' AND EMPLID__c LIKE \'' + String.escapeSingleQuotes(emplid.trim()) + '%\'';
        }

        if (!directoryEmail.equals('') && !dateSearch) {
            searchString += ' ' + directoryEmail.trim() + '*';
        } else if (!directoryEmail.equals('') && dateSearch) {
            soqlOptions += ' AND ASU_Email__c LIKE \'' + String.escapeSingleQuotes(directoryEmail.trim()) + '%\'';
        }

        if (!personalEmail.equals('') && !dateSearch) {
            searchString += ' ' + personalEmail.trim() + '*';
        } else if (!personalEmail.equals('') && dateSearch) {
            soqlOptions += ' AND Personal_Email__c LIKE \'' + String.escapeSingleQuotes(personalEmail.trim()) + '%\'';
        }

        if (dateSearch) {
            soql =
                '' +
                'SELECT Name, Firstname, Lastname, Phone, Help_Desk_Provided_Phone__c, ' +
                'Birthdate, ASURite_ID__c, EMPLID__c, ASU_Email__c, ' +
                'Personal_Email__c, CAP__c, FERPA_Directory_Hold__c ' +
                'FROM Contact ' +
                'WHERE FirstName != null';

            soql += soqlOptions;

            soql += ' ORDER BY ' + sortField + ' ' + sortDir + ' ' + 'LIMIT 25';

            // run the query again
            runSearch(true);
        } else {
            if (searchString != '') {
                String returnString = '';

                if (nameSearch) {
                    returnString = 'IN NAME FIELDS';
                } else if (emailSearch) {
                    returnString = 'IN EMAIL FIELDS';
                } else if (phoneSearch) {
                    returnString = 'IN PHONE FIELDS';
                } else {
                    returnString = 'IN ALL FIELDS';
                }

                soql =
                    '' +
                    'FIND \'' +
                    String.escapeSingleQuotes(searchString.trim()) +
                    '\' ' +
                    returnString +
                    ' ' +
                    'RETURNING Contact(' +
                    'Name, Firstname, Lastname, Phone, Help_Desk_Provided_Phone__c, ' +
                    'Birthdate, ASURite_ID__c, EMPLID__c, ASU_Email__c, CAP__c, ' +
                    'Personal_Email__c, FERPA_Directory_Hold__c WHERE FirstName != null ' +
                    'ORDER BY ' +
                    sortField +
                    ' ' +
                    sortDir +
                    ' ' +
                    'LIMIT 25' +
                    ')';

                // run the query again
                runSearch(false);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You must enter search terms.'));
            }
        }
    }

    // Perform the search for knowledge articles
    public void knowledgeSearch() {
        if (knowString != '') {
            knowledgeResults = new List<List<SObject>>();

            String sosl =
                '' +
                'FIND \'' +
                String.escapeSingleQuotes(knowString.trim()) +
                '*\' ' +
                'IN ALL FIELDS RETURNING ' +
                'FAQ__kav(' +
                'KnowledgeArticleId, Title, Answer__c, Summary ' +
                'WHERE Language = \'en_US\' ' +
                'AND PublishStatus = \'Online\'';

            Set<Id> caseArticleIds = getCaseArticleIds();

            // if we found some, query for their info to display on the page.
            if (caseArticleIds.size() > 0) {
                sosl += ' AND KnowledgeArticleId NOT IN :caseArticleIds LIMIT 30)';
            } else {
                sosl += ' LIMIT 30)';
            }

            knowledgeResults = Search.query(sosl);

            if (knowledgeResults.size() > 0) {
                faqList = knowledgeResults[0];
            } else {
                faqList = new List<FAQ__kav>();
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You must enter search terms.'));
        }
    }

    public Set<Id> getCaseArticleIds() {
        // Query for CaseArticle(s) attached to the Case.
        Set<Id> caseArticleIds = new Set<Id>();
        List<CaseArticle> caseArticles = [SELECT KnowledgeArticleId FROM CaseArticle WHERE CaseId = :selectedCaseId];

        // if we found some, query for their info to display on the page.
        if (caseArticles.size() > 0) {
            for (CaseArticle ca : caseArticles) {
                caseArticleIds.add(ca.KnowledgeArticleId);
            }
        }

        return caseArticleIds;
    }

    // Attach an article to the case.
    public void attachArticleToCase() {
        if (selectedKnowledgeArticleId != null && selectedCaseId != null) {
            CaseArticle art = new CaseArticle(CaseId = selectedCaseId, KnowledgeArticleId = selectedKnowledgeArticleId);

            insert art;
        }

        // re-run the setAsCase method to requery for CaseArticles
        setAsCase();
        faqList = new List<FAQ__kav>();
        isKnowSearchBox = false;
    }

    // Remove an article from a case.
    public void removeArticleFromCase() {
        if (selectedKnowledgeArticleId != null && selectedCaseId != null) {
            CaseArticle artToDelete = [
                SELECT Id
                FROM CaseArticle
                WHERE CaseId = :selectedCaseId AND KnowledgeArticleId = :selectedKnowledgeArticleId
            ];

            delete artToDelete;
        }

        // re-run the setAsCase method to requery for CaseArticles
        setAsCase();
        faqList = new List<FAQ__kav>();
        isKnowledgeSearch = true;
    }

    // Get the details for the selected article
    public void articleDetails() {
        isArticleDetails = true;
        isKnowSearchBox = false;

        selectedFAQ = [
            SELECT Id, KnowledgeArticleId, Title, Answer__c, Summary
            FROM FAQ__kav
            WHERE KnowledgeArticleId = :selectedKnowledgeArticleId AND PublishStatus = 'Online' AND Language = 'en_US'
        ];
    }

    public void newCase() {
        isNewCaseSelected = true;
        isExistingCaseSelected = false;

        if (myCase == null) {
            myCase = new Case();
        } else {
            myCase.clear();
        }

        ID functionalTypeId = RecordIdService.getRTID('Case_Classification__c', 'Functional_Group');
        myCase.ContactId = selectedContactId;
        myCase.Status = 'New';
        myCase.Campus__c = 'Tempe';
        myCase.CC_Functional_Group__c = [
            SELECT Id, Name
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Help Desk'
            LIMIT 1
        ]
        .Id;
        ccPicklist.selectedFunctionalGroup = myCase.CC_Functional_Group__c;
        ccPicklist.updateCategoryAndSubCategory();
    }

    public void newContact() {
        if (mycontact == null) {
            mycontact = new Contact();
        }

        List<RecordType> sfMastList = [
            SELECT Id
            FROM RecordType
            WHERE name = 'SF Mastered' AND SobjectType = 'Contact'
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
        isNewContactSelected = true;
    }

    public void cancelNewContact() {
        isNewContactSelected = false;

        if (selectedContactId != null) {
            isContactSet = true;
            isNewCaseSelected = false;

            if (selectedCaseId != null) {
                isExistingCaseSelected = true;
                isKnowledgeSearch = true;
            } else {
                isExistingCaseSelected = false;
            }
        }
        ApexPages.getMessages().clear();
    }

    public void clearContactSearch() {
        isNewContactSelected = false;
        isContactSet = false;
        isKnowledgeSearch = false;
        isNewCaseSelected = false;
        isExistingCaseSelected = false;
        selectedContactId = null;

        if (cases != null) {
            cases.clear();
        }

        if (contactsrch != null) {
            contactsrch.clear();
        }

        if (contacts != null) {
            contacts.clear();
        }

        populateNonAffiliate();
    }

    public void setAsContact() {
        List<Case> casesbase;

        // populate the contact search fields based on the selected contact
        for (Contact co : contacts) {
            if (co.id == selectedContactId) {
                contactName = co.Name;
                contactsrch = co;
                isContactSet = true;
                isNewCaseSelected = false;
                isExistingCaseSelected = false;
                break;
            }
        }

        // query to get open cases for the contact
        casesbase = [
            SELECT
                Id,
                Subject,
                Reason,
                Description,
                Status,
                Origin__c,
                Campus__c,
                Affiliation__c,
                CC_Functional_Group__c,
                CC_Category__c,
                CC_Sub_Category__c,
                CC_Functional_Group__r.Name,
                CC_Category__r.Name,
                CC_Category__r.Id,
                CC_Sub_Category__r.Name,
                Reporting_Category__c,
                Private_Note_Help_Desk__c,
                Forward_To_Unit__c,
                ServiceNow_Ticket_Number__c,
                Forward_Case_Comments__c,
                Forward_To_Email__c,
                ClosedDate,
                CaseNumber,
                CreatedDate
            FROM Case
            WHERE ContactId = :selectedContactId
            ORDER BY Status, CreatedDate DESC
            LIMIT 25
        ];

        if (cases == null) {
            cases = new List<CaseWrapper>();
        } else {
            cases.clear();
        }

        for (Case ca : casesbase) {
            CaseWrapper mycw = new CaseWrapper(ca);
            cases.add(mycw);
        }
    }

    // Set user selected case for view on page.
    public void setAsCase() {
        isExistingCaseSelected = true;
        isNewContactSelected = false;
        isKnowledgeSearch = true;
        isKnowSearchBox = false;
        isArticleDetails = false;
        Map<Id, CaseWrapper> caseWrappers = new Map<Id, CaseWrapper>();

        for (CaseWrapper cas : cases) {
            caseWrappers.put(cas.Ca.Id, cas);
        }

        Case orignalCase = (Case) caseWrappers.get(selectedCaseId).Ca;
        myCase = orignalCase.clone(true, true, true, true);

        ccPicklist.selectedFunctionalGroup = myCase.CC_Functional_Group__c;

        ccPicklist.updateCategoryAndSubCategory();
        ccPicklist.selectedCategory = myCase.CC_Category__c;

        ccPicklist.updateSubCategories();
        ccPicklist.selectedSubCategory = myCase.CC_Sub_Category__c;

        // Query for CaseArticle(s) attached to the Case.
        Set<Id> caseArticleIds = getCaseArticleIds();

        // if we found some, query for their info to display on the page.
        if (caseArticleIds.size() > 0) {
            attachedFAQs = [
                SELECT KnowledgeArticleId, Title, Answer__c, Summary
                FROM FAQ__kav
                WHERE KnowledgeArticleId IN :caseArticleIds AND PublishStatus = 'Online' AND Language = 'en_US'
            ];
        } else {
            attachedFAQs = new List<FAQ__kav>();
        }
    }

    public PageReference saveCase() {
        Boolean isSaveSuccess = upsertCase();
        return isSaveSuccess ? redirectPage(myCase) : null;
    }

    public PageReference saveAndTransferCase() {
        Boolean isSaveSuccess = upsertCase();
        PageReference page = new PageReference('/apex/CaseTransfer?id=' + myCase.Id);
        page.setRedirect(true);
        return isSaveSuccess ? page : null;
    }

    public void saveAndCloseCase() {
        myCase.Status = myCase.Status.contains('Closed') ? myCase.Status : 'Closed: Resolved';
        savedAndClosed = upsertCase();
    }

    private Boolean upsertCase() {
        try {
            ccPicklist.addCaseClassificationToCase(myCase);
            upsert myCase;

            return true;
        } catch (DmlException e) {
            if (e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertStringToJSON('caseSubj', myCase.Subject));
                vars.add(ErrorLogger.convertStringToJSON('caseDescription', myCase.Description));
                vars.add(ErrorLogger.convertStringToJSON('Case Contact Id', myCase.ContactId));
                ErrorLogger.log(e, vars, false);
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        'Case has been logged with an admin due to ' + e.getMessage()
                    )
                );
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            }

            return false;
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('caseSubj No DML', myCase.Subject));
            vars.add(ErrorLogger.convertStringToJSON('caseDescription No DML', myCase.Description));
            vars.add(ErrorLogger.convertStringToJSON('Case Contact Id No DML', myCase.ContactId));
            ErrorLogger.log(e, vars, false);
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Case has been logged with an admin due to ' + e.getMessage()
                )
            );

            return false;
        }
    }

    private PageReference redirectPage(Case caseToTrasferTo) {
        PageReference page = new PageReference('/' + caseToTrasferTo.Id);
        page.setRedirect(true);
        return page;
    }

    public void cancelCase() {
        isNewCaseSelected = false;
        isExistingCaseSelected = false;
        isKnowledgeSearch = false;
        myCase = null;
        ApexPages.getMessages().clear();
    }

    public void cancelCloseCase() {
        isNewCaseSelected = false;
        isExistingCaseSelected = true;
        isKnowledgeSearch = false;

        if (isCloseCase) {
            isCloseCase = false;
        }
    }

    public void saveContact() {
        try {
            insert mycontact;

            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Contact created successfully.'));

            isContactSet = true;
            selectedContactId = mycontact.Id;
            isNewContactSelected = false;
            contactsrch = mycontact;
            mycontact = new Contact();
            isNewCaseSelected = false;
            isExistingCaseSelected = false;
            if (cases != null)
                cases.clear();
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
    }

    public void setAsHelpDeskProvidedPhone() {
        try {
            Contact contactToUpdate = [
                SELECT Id, Help_Desk_Provided_Phone__c
                FROM Contact
                WHERE Id = :selectedContactId
            ];

            contactsrch.Help_Desk_Provided_Phone__c = callerId;
            contactToUpdate.Help_Desk_Provided_Phone__c = contactsrch.Help_Desk_Provided_Phone__c;

            update contactToUpdate;
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
    }

    // This wrapper class on Case was created so that we can show a truncated case description
    public class CaseWrapper {
        public Case Ca { get; set; }
        public String shortDescr { get; set; }
        public String fullDescr { get; set; }

        public CaseWrapper(Case c) {
            Ca = c;

            if (String.isNotEmpty(c.Description)) {
                shortDescr = c.Description.abbreviate(140);
            } else {
                shortDescr = ' ';
            }

            fullDescr = c.Description;
        }
    }

    public void updateOnCategoryChange() {
        ccPicklist.updateSubCategories();
        addCategoryDescription();
    }

    private String getCategoryDescription() {
        if (ccPicklist.selectedCategory == null || ccPicklist.selectedCategory == '--') {
            return '';
        }
        String categoryDefaultCaseDescription = [
            SELECT Default_Case_Description__c
            FROM Case_Classification__c
            WHERE Id = :ccPicklist.selectedCategory
        ]
        .Default_Case_Description__c;
        return categoryDefaultCaseDescription == null ? '' : categoryDefaultCaseDescription;
    }

    private void addCategoryDescription() {
        String categoryDescription = getCategoryDescription();
        if (myCase.Description == null) {
            myCase.Description = '';
        }
        myCase.Description += categoryDescription;
    }

    public void saveDescription() {
        myCase.Description = myCase.Description;
    }
}
