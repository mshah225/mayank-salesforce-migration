public class UnifiedProspectPageController
{

    private Id eventRecId;
    private Id eossRecId;

    public Boolean smsText { get; set; }
    public Boolean error { get; set; }
    public Contact contact;
    public Case caseC;
    public Campaign tempCampaign { get; set; }
    public CampaignMember camMemInterest;
    public CampaignMember camMemEvent;
    public Date camStartDate { get; set; }
    public Id selectedInterestId { get; set; }
    public Id accId;
    public Id oppRecType;
    public Id walkInOrig;
    public Id phoneOrig;
    public Id emailOrig;
    public Id elId { get; set; }
    public Id instId { get; set; }
    public Id newOppId { get; set; }
    public List<SelectOption> careers;
    public List<Account> instList;
    public List<Campaign> eventList;
    public Opportunity opportunity;
    public Previous_Education__c previousEducation;
    public String eventName { get; set; }
    public String pickSelection { get; set; }
    public String originSelection { get; set; }
    public String eventSearchString { get; set; }
    public String career { get; set; }
    public String collegeSelected { get; set; }
    public String planSelected { get; set; }
    public String deptColl { get; set; }

    public UnifiedProspectPageController() {
        eventRecId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        eossRecId =  Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('EOSS Event').getRecordTypeId();
        eventList = new List<Campaign>();
        tempCampaign = new Campaign();
    }

    public void setContact(Contact contact) {
        this.contact = contact;
    }

    public void setOpportunity(Opportunity opportunity) {
        this.opportunity = opportunity;
    }

    public void setPreviousEducation(Previous_Education__c previousEducation) {
        this.previousEducation = previousEducation;
    }

    public void setCamMemInterest(CampaignMember camMemInterest) {
        this.camMemInterest = camMemInterest;
    }

    public void setCamMemEvent(CampaignMember camMemEvent) {
        this.camMemEvent = camMemEvent;
    }

    public void setCaseC(Case caseC) {
        this.caseC = caseC;
    }

    public Contact getContact() {
        if (contact == null) {
            contact= new Contact();
        }

        return contact;
    }

    public Opportunity getOpportunity()  {
        if (opportunity == null)  {
            opportunity = new Opportunity();
        }

        if(career == 'graduate' || career == 'law') {
            oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Graduate Prospect').getRecordTypeId();
        } else {
            oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Undergraduate Prospect').getRecordTypeId();
        }
        opportunity.RecordTypeId = oppRecType;

        return opportunity;
    }

    public Previous_Education__c getPreviousEducation() {
        if (previousEducation == null) {
            previousEducation = new Previous_Education__c();
        }

        return previousEducation;
    }

    public CampaignMember getCamMemInterest() {
        if (camMemInterest == null) {
            camMemInterest = new CampaignMember();
        }

        return camMemInterest;
    }

    public CampaignMember getCamMemEvent() {
        if(camMemEvent == null) {
            camMemEvent = new CampaignMember();
        }

        return camMemEvent;
    }

    public List<SelectOption> programList {
        get {
            List<Program__c> ProgramTemp = [
                SELECT p.Name, p.Id
                FROM Program__c p
                WHERE Career__c = :career
                AND Program_Status__c = true
            ];

            programList = new List<SelectOption>();
            programList.add(new SelectOption('0', '-- None --'));

            for (Program__c temp : ProgramTemp) {
                programList.add(new SelectOption(temp.Id, temp.Name));
            }

            return programList;
        }

        set;
    }

    public List<SelectOption> planList {
        get {
            planList = new List<SelectOption>();

            if (collegeSelected != null && collegeSelected != '0') {
                List<Plan__c> PlanTemp = [
                    SELECT p.Degree_Search_Name__c, p.Name, p.Id
                    FROM Plan__c p
                    WHERE p.Program__c = :collegeSelected
                    AND p.Available_in_Degree_Search__c = true
                ];

                planList.add(new SelectOption('0', '-- None --'));

                for(Plan__c temp : PlanTemp) {
                    planList.add(new SelectOption(temp.Id, temp.Degree_Search_Name__c));
                }
            }

            return planList;
        }

        set;
    }

    public Case getCaseC() {
        if (caseC == null) {
            caseC = new Case();
            caseC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ASU Admission Services').getRecordTypeId();
        }

        return caseC;
    }

    public List<Campaign> getEventList() {
        return eventList;
    }

    public List<Account> getInstList() {
        return instList;
    }

    public List<SelectOption> getCareers() {
        if (careers == null) {
            careers = new List<SelectOption>();
            careers.add(new SelectOption('--Select--', '--Select--'));
            careers.add(new SelectOption('undergraduate', 'Undergraduate'));
            careers.add(new SelectOption('graduate', 'Graduate'));
        }
        return careers;
    }

    public void eventSearch() {
        if (eventSearchString.length() < 2) {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR,
                    'You must enter at least 2 characters.'
                )
            );

            return;
        }

        String sosl = '' +
            'FIND \'*' + String.escapeSingleQuotes(eventSearchString.trim()) + '*\' ' +
            'IN ALL FIELDS ' +
            'RETURNING Campaign(Id, Name, Type, Category__c, Event_Start_Date__c, ' +
                'Event_Start_Time__c, Campus_Location__c, Event_Location__c, ' +
                'RecordTypeId, Requested__c ' +
                'WHERE (RecordTypeId = :eventRecId OR RecordTypeId = :eossRecId) ' +
                'AND IsActive = true ';

        if (deptColl != null) {
            sosl += 'AND Requested__c INCLUDES (:deptColl) ';
        }

        Id location = tempCampaign.Campus_Location__c;

        if (tempCampaign.Campus_Location__c != null) {
            sosl += 'AND Campus_Location__c = :location ';
        }

        if (camStartDate != null) {
            sosl += 'AND Event_Start_Date__c = :camStartDate ';
        }

        sosl += 'ORDER BY Name ASC LIMIT 40)';

        List<List<SObject>> sObjects = Search.query(sosl);

        if (sObjects.size() > 0) {
            eventList = sObjects[0];
        } else {
            eventList = new List<Campaign>();
        }
    }

    public void instSearch() {
        String instSearchTerm = '' +
            'SELECT Id, Name, BillingCity, BillingState, Institution_Type__c ' +
            'FROM Account ' +
            'WHERE Id = ' + instId;

        instList = Database.query(instSearchTerm);
    }

    public List<SelectOption> getSelectedEventCamMemStatuses() {
        List<CampaignMemberStatus> camStatuses = [
            SELECT Id, Label
            FROM CampaignMemberStatus
            WHERE CampaignId = :elId
            ORDER BY Label ASC
        ];

        List<SelectOption> camOptions = new List<SelectOption>();
        camOptions.add(new SelectOption('' ,'--Select--'));

        for (CampaignMemberStatus cs : camStatuses) {
            camOptions.add(new SelectOption(cs.Label , cs.Label));
        }

        return camOptions;
    }

    public List<SelectOption> getDepartmentsColleges() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select--'));

        Schema.DescribeFieldResult fieldResult =
            Campaign.Requested__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }

        return options;
    }

    public List<SelectOption> getASULocationIntList() {
        Id interestRecId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Interest').getRecordTypeId();

        List<Campaign> interests = [
            SELECT Id, Name, RecordTypeId
            FROM Campaign
            WHERE RecordTypeId = :IDHelper.getRTID('Campaign', 'Interest')
            AND Type = 'ASU Location'
            AND IsActive = true
            ORDER BY Name ASC
        ];

        List<SelectOption> asuLocationIntList = new List<SelectOption>();
        asuLocationIntList.add(new SelectOption('' ,'--Select--'));

        for (Campaign i : interests) {
            asuLocationIntList.add(new SelectOption(i.Id , i.Name));
        }

        return asuLocationIntList;
    }

    public List<SelectOption> getAcademicIntList() {
        Id interestRecId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Interest').getRecordTypeId();

        List<Campaign> interests = [
            SELECT Id, Name, RecordTypeId
            FROM Campaign
            WHERE RecordTypeId = :IDHelper.getRTID('Campaign', 'Interest')
            AND Type = 'Academic'
            AND IsActive = true
            ORDER BY Name ASC
        ];

        List<SelectOption> academicIntList = new List<SelectOption>();
        academicIntList.add(new SelectOption('' ,'--Select--'));

        for (Campaign i : interests) {
            academicIntList.add(new SelectOption(i.Id , i.Name));
        }

        return academicIntList;
    }

    public List<SelectOption> getASUCollegesIntList() {
        Id interestRecId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Interest').getRecordTypeId();

        List<Campaign> interests = [
            SELECT Id, Name, RecordTypeId
            FROM Campaign
            WHERE RecordTypeId = :IDHelper.getRTID('Campaign', 'Interest')
            AND Type = 'ASU Colleges'
            AND IsActive = true
            ORDER BY Name ASC
        ];

        List<SelectOption> asuCollegesIntList = new List<SelectOption>();
        asuCollegesIntList.add(new SelectOption( '' ,'--Select--'));

        for (Campaign i : interests ) {
            asuCollegesIntList.add(new SelectOption(i.Id , i.Name));
        }

        return asuCollegesIntList;
    }

    public Boolean save() {
        getCaseC();
        addCaseClassificationToCase();
        List<CampaignMember> cams = new List<CampaignMember>();
        Savepoint spException = Database.setSavepoint();
        try {
            error = false;
            
            if (contact.Phone == null && contact.MailingPostalCode == null) {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'You must provide either a Phone number or a Zip code.'
                    )
                );

                error = true;
            }

            if (career == '--Select--') {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'You must select a career.'
                    )
                );

                error = true;
            }

            if (career == 'graduate' && collegeSelected == '0') {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'You must select a college.'
                    )
                );

                error = true;
            }

            if (career == 'graduate' && opportunity.Term__c == null) {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'You must select a Term.'
                    )
                );

                error = true;
            }

            if (originSelection != '--Select--' && elId != null) {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'You must select either ONE case OR ONE event.'
                    )
                );

                error = true;
            }

            if (originSelection == '--Select--' && elId == null) {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'You must select either ONE case OR ONE event.'
                    )
                );

                error = true;
            }

            if (originSelection != '--Select--'
                && (String.isBlank(caseC.Subject) || String.isBlank(caseC.Description))) {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'A case must have a Subject and a Description.'
                    )
                );

                error = true;
            }

            if (originSelection != '--Select--'
                && elId == null
                && caseC.CC_Functional_Group__c == null) {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'When selecting an Origin, you must also select a Functional Group.'
                    )
                );

                error = true;
            }

            if (pickSelection != null
                && pickSelection != '--Select--'
                && selectedInterestId == null) {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'After selecting a type of interest, you must select an interest.'
                    )
                );

                error = true;
            }

            if (error) {
                system.debug('451');
                for (ApexPages.Message apm : ApexPages.getMessages()) {
                    system.debug(string.valueOf(apm));
                }
               return false;
            }

            //Create Contact
            contact.Id = null;
            contact.SF_First_Name__c = contact.FirstName;
            contact.SF_First_Name_Updated__c = Datetime.now();
            contact.SF_Last_Name__c = contact.LastName;
            contact.SF_Last_Name_Updated__c = Datetime.now();
            contact.SF_Mobile__c = contact.MobilePhone;
            Pattern SMSValidate = Pattern.compile('[^0-9]');

            if (contact.Email == null && contact.Lead_Email__c != null) {
                contact.Email = contact.Lead_Email__c;
            }

            if (contact.MobilePhone != null && smsText == true) {
                contact.SMS_Phone__c = contact.MobilePhone;
                contact.SMS_Phone__c = SMSValidate.matcher(contact.SMS_Phone__c).replaceAll('');
            }

            contact.SF_Mobile_Updated__c = Datetime.now();
            contact.SF_Mailing_Street__c = contact.MailingStreet;
            contact.SF_Mailing_City__c = contact.MailingCity;
            contact.SF_Mailing_Country__c = contact.MailingCountryCode;
            contact.SF_Mailing_State__c = contact.MailingStateCode;
            contact.SF_Mailing_ZIP__c = contact.MailingPostalCode;
            contact.SF_Mailing_Address_Updated__c = Datetime.now();
            contact.SF_Birthdate__c = contact.Birthdate;
            contact.SF_Birthdate_Updated__c = Datetime.now();
            contact.silverpop__Sync_to_Silverpop_Chk__c = true;

            insert contact;

            //Create Opportunity
            opportunity.Id = null;

            if (career == 'undergraduate') {
                opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Undergraduate Prospect').getRecordTypeId();
            } else {
                opportunity.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Graduate Prospect').getRecordTypeId();
            }

            Term__c tempTerm = [
                SELECT Id, Session_A_C_Start_Date__c
                FROM Term__c
                WHERE Id = :opportunity.Term__c
                LIMIT 1
            ];

            opportunity.CloseDate = tempTerm.Session_A_C_Start_Date__c + 22;
            opportunity.Career__c = career;

            Datetime DatePreString = Datetime.now();
            String TodayString = DatePreString.format('yyyy-MM-dd');
            opportunity.Name = contact.FirstName + ' ' + contact.LastName + ' ' + TodayString;
            opportunity.Contact__c = contact.id;
            accId = [SELECT AccountId FROM Contact WHERE Id = :Contact.Id][0].AccountId;
            opportunity.AccountId = accId;
            opportunity.StageName = 'Prospect';

            if (collegeSelected != null && collegeSelected != '0') {
               opportunity.College__c = collegeSelected;
            }

            if (planSelected != null && planSelected != '0') {
               opportunity.Academic_Plan__c = planSelected;
            }

            insert opportunity;

            newOppId = opportunity.Id;

            //Create Previous Education
            getPreviousEducation();

            if (previousEducation.Account__c != null) {
                previousEducation.Id = null;
                previousEducation.Contact__c = contact.id;

                insert previousEducation;
            }

            //Create CampaignMember Event
            if (elId != null && originSelection == '--Select--') {
                if (camMemEvent.Status == null) {
                    ApexPages.addmessage(
                        new ApexPages.message(
                            ApexPages.severity.ERROR,
                            'Please select an event status.'
                        )
                    );

                    return false;
                }

                getCamMemEvent();
                camMemEvent.Id = null;
                camMemEvent.CampaignId = elId;
                camMemEvent.ContactId = contact.Id;
                camMemEvent.Opportunity__c = opportunity.Id;
                camMemEvent.Inbound_Interaction__c = true;
                cams.add(camMemEvent);
            }
            //Create Case
            else if (originSelection != '--Select--' && elId == null) {
                caseC.Id = null;
                caseC.Status = 'Closed: Resolved';
                caseC.ContactId = contact.Id;
                caseC.Opportunity__c = opportunity.Id;

                if (originSelection == 'Incoming Call') {
                    if (phoneOrig == null) {
                        Campaign phoneCamp = [
                            SELECT Id
                            FROM Campaign
                            WHERE Name = 'Phone Call'
                            LIMIT 1
                        ];

                        if(phoneCamp != null) {
                            caseC.Case_Source__c = phoneCamp.Id;
                        }
                    }
                } else if (originSelection == 'Email') {
                    if (emailOrig == null) {
                        Campaign emailCamp = [
                            SELECT Id
                            FROM Campaign
                            WHERE Name = 'Email'
                            LIMIT 1
                        ];

                        if (emailCamp != null) {
                            caseC.Case_Source__c = emailCamp.Id;
                        }
                    }
                } else {
                    if (walkInOrig == null) {
                        Campaign walkCamp = [
                            SELECT Id
                            FROM Campaign
                            WHERE Name = 'Walk In'
                            LIMIT 1
                        ];

                        if (walkCamp != null) {
                            caseC.Case_Source__c = walkCamp.Id;
                        }
                    }
                }

                caseC.Origin__c = originSelection;
                caseC.Inbound_Interaction__c = true;
                caseC.Priority = 'Normal';
                String termName = opportunity.Term__c;

                termName = [
                    SELECT Term__r.Name
                    FROM Opportunity
                    WHERE Term__c = :opportunity.Term__c
                    LIMIT 1
                ].Term__r.Name;

                if (caseC.Subject == null && caseC.Description == null) {
                    caseC.Subject = caseC.Origin__c + ' Submission - ' + termName;
                }

                insert caseC;

                //Update Opportunity's case with case Id
                opportunity.Prospect_Case__c = caseC.Id;

                update opportunity;
            } else if (originSelection != '--Select--' && elId != null){
                system.debug('626');
                return false;
            } else if (originSelection == '--Select--' && elId == null) {
                system.debug('629');
                return false;
            } else {
                system.debug('632');
                return false;
            }

            //Create CampaignMember Interest
            if (pickSelection != null && pickSelection != '--Select--') {
                if (selectedInterestId != null) {
                    getCamMemInterest();
                    camMemInterest.Id = null;
                    camMemInterest.CampaignId = selectedInterestId;
                    //This doesn't seem to work either, Status once again is set to 'Sent'
                    camMemInterest.Status = 'Interested';
                    camMemInterest.ContactId = contact.Id;
                    camMemInterest.Opportunity__c = opportunity.Id;
                    cams.add(camMemInterest);
                } else {
                    ApexPages.addmessage(
                        new ApexPages.message(
                            ApexPages.severity.ERROR,
                            'After selecting a type of interest, you must select an interest.'
                        )
                    );

                    system.debug('655');
                    return false;
                }
            }

            if(cams.size() > 0) {
                insert cams;
            }

            //Save success, return true.
            return true;
        } catch (Exception e) {
            // to rollback the insert of Contact/Opportunity/Case in case any
            // unexpected error occurs in insertion of any of three sObjects
            Database.rollback(spException);
            ApexPages.addMessages(e);
            return false;
        }
    }

    public PageReference savePage() {
        Savepoint spValidation = Database.setSavepoint();
        if (save()) {
            PageReference save = new PageReference('/' + newOppId);
            save.setRedirect(true);
            return save;
        } else {
            // to rollback the insert of Contact/Opportunity/Case in case if any
            // Validation fails and PageMessage is shown
            Database.rollback(spValidation);
            return null;
        }
    }

    public PageReference saveAndNew() {
        Savepoint spValidation = Database.setSavepoint();
        if (save()) {
            PageReference save = new PageReference('/apex/Unified_Prospect_Page?saved=true');
            save.setRedirect(true);
            return save;
        } else {
            // to rollback the insert of Contact/Opportunity/Case in case if any
            // Validation fails and PageMessage is shown
            Database.rollback(spValidation);
            return null;
        }
    }
    
    public Map<String, Case_Classification__c> allFunctionalGroups {
        get {
            if (allFunctionalGroups == null) {
                allFunctionalGroups = new Map<String, Case_Classification__c>();
                Id functionalGroupRecordType = [SELECT Id
                                                FROM RecordType
                                                WHERE Name = 'Functional Group'
                                                LIMIT 1
                                               ].Id;
                List<Case_Classification__c> functionalGroups = [SELECT Name
                                                                 FROM Case_Classification__c
                                                                 WHERE RecordTypeId =: functionalGroupRecordType
                                                                 AND Active__c =: TRUE
                                                                 AND Visible__c =: TRUE
                                                                 ORDER By Name
                                                                ];
                for (Case_Classification__c functionalGroup : functionalGroups) {
                    allFunctionalGroups.put(functionalGroup.Name, functionalGroup);
                }
            }
            return allFunctionalGroups;
        }
        set;
    }

    public Map<String, Map<String, Case_Classification__c>> allCategories {
        get {
            if (allCategories == null) {
                allCategories = new Map<String, Map<String, Case_Classification__c>>();
                Id categoryRecordType = [SELECT Id
                                         FROM RecordType
                                         WHERE Name = 'Category'
                                         LIMIT 1
                                        ].Id;
                List<Case_Classification__c> categories = [SELECT Name, Parent__c, Parent__r.Name, Default_Case_Description__c
                                                           FROM Case_Classification__c
                                                           WHERE RecordTypeId =: categoryRecordType
                                                           AND Active__c =: TRUE
                                                           AND Visible__c =: TRUE
                                                           ORDER By Parent__r.Name, Name
                                                          ];
                if (!categories.isEmpty()) {
                    Map<String, Case_Classification__c> uniqueParentMap = new Map<String, Case_Classification__c>();
                    uniqueParentMap.put('--', null);
                    String currentParent = categories[0].Parent__r.Name;
                    for (Case_Classification__c cat : categories) {
                        if (currentParent == cat.Parent__r.Name) {
                            uniqueParentMap.put(cat.Name, cat);
                        } else {
                            allCategories.put(currentParent, uniqueParentMap);
                            uniqueParentMap = new Map<String, Case_Classification__c>();
                            uniqueParentMap.put('--', null);
                            currentParent = cat.Parent__r.Name;
                            uniqueParentMap.put(cat.Name, cat);
                        }
                    }
                    allCategories.put(currentParent, uniqueParentMap);

                    Map<String, Case_Classification__c> noSelectOption = new Map<String, Case_Classification__c>();
                    noSelectOption.put('--', null);
                    allCategories.put('--',  noSelectOption);
                }
                for (String functionalGroupName : allFunctionalGroups.keySet()) {
                    if (allCategories.get(functionalGroupName) == null ) {
                    Map<String, Case_Classification__c> noSelectOption = new Map<String, Case_Classification__c>();
                    noSelectOption.put('--', null);
                    allCategories.put(functionalGroupName,  noSelectOption);
                    }
                }
            }
            return allCategories;
        }
        set;
    }

    public Map<String, Map<String, Case_Classification__c>> allSubCategories {
        get {
            if (allSubCategories == null) {
                allSubCategories = new Map<String, Map<String, Case_Classification__c>>();
                Id subCategoryRecordType = [SELECT Id
                                            FROM RecordType
                                            WHERE Name = 'Sub Category'
                                            LIMIT 1
                                           ].Id;
                List<Case_Classification__c> subCategories = [SELECT Name, Parent__c, Parent__r.Name
                                                              FROM Case_Classification__c
                                                              WHERE RecordTypeId =: subCategoryRecordType
                                                              AND Active__c =: TRUE
                                                              AND Visible__c =: TRUE
                                                              ORDER By Parent__c, Parent__r.Name, Name
                                                             ];
                if (!subCategories.isEmpty()) {
                    Map<String, Case_Classification__c> uniqueParentMap = new Map<String, Case_Classification__c>();
                    uniqueParentMap.put('--', null);
                    String currentParentId = subCategories[0].Parent__c;
                    for (Case_Classification__c subCat : subCategories) {
                        if (currentParentId == subCat.Parent__c) {
                            uniqueParentMap.put(subCat.Name, subCat);
                        } else {
                            allsubCategories.put(currentParentId, uniqueParentMap);
                            uniqueParentMap = new Map<String, Case_Classification__c>();
                            uniqueParentMap.put('--', null);
                            currentParentId = subCat.Parent__c;
                            uniqueParentMap.put(subCat.Name, subCat);
                        }
                    }
                    allsubCategories.put(currentParentId, uniqueParentMap);

                    Map<String, Case_Classification__c> noSelectOption = new Map<String, Case_Classification__c>();
                    noSelectOption.put('--', null);
                    allSubCategories.put('--',  noSelectOption);
                }
            }
            return allSubCategories;
        }
        set;
    }

    public String selectedFunctionalGroup {
        get {
            if (selectedFunctionalGroup == null) {
                selectedFunctionalGroup = '--';
            }
            return selectedFunctionalGroup;
        }
        set;
    }
    public String selectedCategory {
        get {
            if (selectedCategory == null) {
                selectedCategory = '--';
            }
            return selectedCategory;
        }
        set;
    }

    public String selectedSubCategory {
        get {
            if (selectedSubCategory == null) {
                selectedSubCategory = '--';
            }
            return selectedSubCategory;
        }
        set;
    }

    public List<SelectOption> functionalGroupOptions {
        get {
            if (functionalGroupOptions == null) {
                functionalGroupOptions = new List<SelectOption>();
                functionalGroupOptions.add(new SelectOption('--', '--', true));
                for (String functionalGroupOption : allFunctionalGroups.keyset()) {
                    functionalGroupOptions.add(new SelectOption(functionalGroupOption, functionalGroupOption, false));
                }
            }
            return functionalGroupOptions;
        }

        set;
    }

    public List<SelectOption> categoryOptions {
        get {
            if (categoryOptions == null) {
                categoryOptions = new List<SelectOption>();
                if (allCategories != null && selectedFunctionalGroup != null) {
                    Map<String, Case_Classification__c> categoriesForFunctionalGroup = allCategories.get(selectedFunctionalGroup);
                    if (categoriesForFunctionalGroup != null && !categoriesForFunctionalGroup.isEmpty()) {
                        for (String categoryOption : categoriesForFunctionalGroup.keySet()) {
                            if (categoryOption.equals('--')) {
                                categoryOptions.add(new SelectOption('--', '--', false));
                            } else {
                                categoryOptions.add(new SelectOption(categoriesForFunctionalGroup.get(categoryOption).Id, categoryOption, false));
                            }
                        }
                    } else {
                        categoryOptions.add(new SelectOption('--', '--', false));
                    }
                } else {
                    categoryOptions.add(new SelectOption('--', '--', false));
                }
            }
            return categoryOptions;
        }

        set;
    }

    public List<SelectOption> subCategoryOptions {
        get {
            if (subCategoryOptions == null) {
                subCategoryOptions = new List<SelectOption>();
                if (allSubCategories != null && selectedCategory != null) {
                    Map<String, Case_Classification__c> subCategoriesForParent = allsubCategories.get(selectedCategory);

                    if (subCategoriesForParent != null && !subCategoriesForParent.isEmpty()) {
                        for (String subCategoryOption : subCategoriesForParent.keySet()) {
                            subCategoryOptions.add(new SelectOption(subCategoryOption, subCategoryOption, false));
                        }
                    } else {
                        subCategoryOptions.add(new SelectOption('--', '--', false));
                    }
                } else {
                    subCategoryOptions.add(new SelectOption('--', '--', false));
                }
            }
            return subCategoryOptions;
        }

        set;
    }
    
    public PageReference updateCategoryAndSubCategory() {
        updateCategories();
        updateOnCategoryChange();

        return null;
    }
    public PageReference  updateCategories() {
        categoryOptions = new List<SelectOption>();
        System.debug(allCategories);
        System.debug('Selected Functional Group: ' + selectedFunctionalGroup);
        Map<String, Case_Classification__c> categoriesForParent = allCategories.get(selectedFunctionalGroup);
        Boolean firstCategoryUpdated = false;
        if (categoriesForParent != NULL && !categoriesForParent.isEmpty()) {
            for (String categoryName : categoriesForParent.keySet()) {
                if (categoryName.equals('--')) {
                    categoryOptions.add(new SelectOption(categoryName, categoryName, false));
                } else {
                    categoryOptions.add(new SelectOption(categoriesForParent.get(categoryName).Id, categoryName, false));
                }
            }
        } else {
            categoryOptions.add(new SelectOption('--', '--', false));
        }
        System.debug('categoryOptions' + categoryOptions);
        return null;
    }

    public PageReference updateOnCategoryChange() {
        updateSubCategories();
        return null;
    }
    
    public PageReference updateSubCategories() {
        subCategoryOptions = new List<SelectOption>();
        Map<String, Case_Classification__c> subCategoriesForParent = allsubCategories.get(selectedCategory);
        Boolean firstSubCategoryUpdated = false;
        if (subCategoriesForParent != NULL && !subCategoriesForParent.isEmpty()) {
            for (String subCategoryName : subCategoriesForParent.keySet()) {
                subCategoryOptions.add(new SelectOption(subCategoryName, subCategoryName, false));
                if (!firstSubCategoryUpdated) {
                    selectedSubCategory = subCategoryName;
                    firstSubCategoryUpdated = true;
                }
            }
        } else {
            subCategoryOptions.add(new SelectOption('--', '--', false));
        }

        return null;
    }
    
    private void addCaseClassificationToCase() {
        Case_Classification__c functionalGroupToAdd = allFunctionalGroups.get(selectedFunctionalGroup);

        if (functionalGroupToAdd != null) {
            caseC.CC_Functional_Group__c = functionalGroupToAdd.Id;
            if (allCategories.get(functionalGroupToAdd.Name) == NULL || selectedCategory.equals('--')) {
                caseC.CC_Category__c = null;
            } else {
                String categoryName = [SELECT Name FROM Case_Classification__c WHERE Id =: selectedCategory].Name;
                Case_Classification__c categoryToAdd = allCategories.get(functionalGroupToAdd.Name).get(categoryName);
                if (categoryToAdd != null) {
                    caseC.CC_Category__c = categoryToAdd.Id;
                    if (allSubCategories.get(selectedCategory) == NULL) {
                        caseC.CC_Sub_Category__c = null;
                    } else {
                        Case_Classification__c subCategoryToAdd = allSubCategories.get(categoryToAdd.Id).get(selectedSubCategory);
                        if (subCategoryToAdd != null) {
                            caseC.CC_Sub_Category__c = subCategoryToAdd.Id;
                        } else {
                            caseC.CC_Sub_Category__c = null;
                        }
                    }
                } else {
                    caseC.CC_Category__c = null;
                }
            }
        }
    }
}