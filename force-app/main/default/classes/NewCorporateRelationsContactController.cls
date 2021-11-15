public class NewCorporateRelationsContactController {
    public Account account { get; set; }
    public Contact contact { get; set; }
    public RecordType crRecordType { get; set; }
    public Relationship__c relationship { get; set; }
    public Boolean showCancel { get; set; }
    public Boolean clickedAccount { get; set; }
    public Integer page { get; set; }
    public List<Relationship__c> relationshipList { get; set; }
    public List<CampaignMember> campaignMemberList { get; set; }
    public List<SelectOption> campaignOptions;
    public List<SelectOption> childCampaignOptions { get; set; }
    public List<SelectOption> relTypeOptions;
    public List<Campaign> crCampaigns;
    public List<Campaign> childCrCampaigns;
    public Set<String> currentSet;
    public String selectedParentId { get; set; }
    public String selectedChildId { get; set; }

    public Id contactToAccountRTId {
        get {
            if (contactToAccountRTId == null) {
                contactToAccountRTId = [
                    SELECT Id
                    FROM RecordType
                    WHERE SObjectType = 'Relationship__c' AND Name = 'Contact To Account'
                    LIMIT 1
                ]
                .Id;
            }

            return contactToAccountRTId;
        }
        set;
    }

    public NewCorporateRelationsContactController() {
        page = 1;
        account = new Account();
        contact = new Contact();
        crRecordType = new RecordType();
        currentSet = new Set<String>();
        relationship = new Relationship__c();
        relationship.recordTypeId = contactToAccountRTId;
        relationshipList = new List<Relationship__c>();
        campaignMemberList = new List<CampaignMember>();
        crRecordType = [SELECT Id FROM RecordType WHERE Name = 'Corporate Relations' AND SobjectType = 'Campaign'];
    }

    public List<SelectOption> getCampaignOptions() {
        crCampaigns = [
            SELECT Id, Name, RecordTypeId
            FROM Campaign
            WHERE RecordTypeId = :crRecordType.Id AND IsActive = TRUE AND ParentId = NULL
            ORDER BY Name ASC
        ];

        campaignOptions = new List<SelectOption>();
        campaignOptions.add(new SelectOption('', '--Select--'));
        for (Campaign c : crCampaigns) {
            campaignOptions.add(new SelectOption(c.Id, c.Name));
        }

        return campaignOptions;
    }

    public void populateChildCampaigns() {
        childCrCampaigns = [
            SELECT Id, Name, RecordTypeId
            FROM Campaign
            WHERE RecordTypeId = :crRecordType.Id AND IsActive = TRUE AND ParentId = :selectedParentId
            ORDER BY Name ASC
        ];

        childCampaignOptions = new List<SelectOption>();
        if (childCrCampaigns == null) {
            childCampaignOptions.add(new SelectOption('', '--Select--'));
        } else {
            childCampaignOptions.add(new SelectOption('', 'None'));
        }

        for (Campaign c : childCrCampaigns) {
            childCampaignOptions.add(new SelectOption(c.Id, c.Name));
        }
    }

    public List<SelectOption> getRelTypeOptions() {
        Schema.DescribeFieldResult fieldResult = Relationship__c.Relationship_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        relTypeOptions = new List<SelectOption>();
        relTypeOptions.add(new SelectOption('', '--Select--'));
        for (Schema.PicklistEntry f : ple) {
            if (f.getValue() == 'Employee' || f.getValue() == 'Member' || f.getValue() == 'Volunteer') {
                relTypeOptions.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }
        return relTypeOptions;
    }

    public void addRelationship() {
        Relationship__c rNew = new Relationship__c();
        rNew.Title__c = relationship.Title__c;
        rNew.Related_Account__c = relationship.Account__c;
        rNew.Relationship_Type__c = relationship.Relationship_Type__c;
        rNew.Relationship_Start_Date__c = relationship.Relationship_Start_Date__c;
        relationshipList.add(rNew);
    }

    public void addParentCampaignMember() {
        CampaignMember pNew = new CampaignMember();
        pNew.CampaignId = selectedParentId;
        if (!currentSet.contains(selectedParentId)) {
            campaignMemberList.add(pNew);
            currentSet.add(selectedParentId);
        }
    }

    public void addCampaignMember() {
        if (selectedChildId != null) {
            CampaignMember cNew = new CampaignMember();
            cNew.CampaignId = selectedChildId;
            if (!currentSet.contains(selectedChildId)) {
                campaignMemberList.add(cNew);
                currentSet.add(selectedChildId);
            }
        }
    }

    public PageReference page2() {
        page = 2;

        return ApexPages.currentPage();
    }

    public PageReference page3() {
        page = 3;

        return ApexPages.currentPage();
    }

    public PageReference page4() {
        page = 4;

        return ApexPages.currentPage();
    }

    public PageReference page5() {
        page = 5;

        return ApexPages.currentPage();
    }

    public PageReference page6() {
        page = 6;

        return ApexPages.currentPage();
    }

    public void addPage() {
        if (!validateRT()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Relationship Type.')
            );

            return;
        }

        if (!validateDA()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Department Affiliation.')
            );

            return;
        }
        addRelationship();
        addParentCampaignMember();
        addCampaignMember();
        showCancel = true;
        relationship = null;
        relationship = new Relationship__c();
        relationship.RecordTypeId = contactToAccountRTId;
        selectedParentId = null;
        selectedChildId = null;
        childCampaignOptions = null;
    }

    public void addRelationshipPage() {
        if (!validateRT()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Relationship Type.')
            );

            return;
        }

        if (!validateDA()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Department Affiliation.')
            );
            return;
        }
        addRelationship();
        addParentCampaignMember();
        addCampaignMember();
        relationship = null;
        relationship = new Relationship__c();
        relationship.RecordTypeId = contactToAccountRTId;
        page = 4;
    }

    public void addCampaignPage() {
        if (!validateRT()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Relationship Type.')
            );

            return;
        }

        if (!validateDA()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Department Affiliation.')
            );

            return;
        }
        addRelationship();
        addParentCampaignMember();
        addCampaignMember();
        relationship = null;
        relationship = new Relationship__c();
        relationship.RecordTypeId = contactToAccountRTId;
        selectedParentId = null;
        selectedChildId = null;
        childCampaignOptions = null;
        page = 5;
    }

    public Boolean validateRT() {
        if (relationship.Relationship_Type__c == null) {
            return false;
        } else {
            return true;
        }
    }

    public Boolean validateDA() {
        if (selectedParentId == null) {
            return false;
        } else {
            return true;
        }
    }

    public void click() {
        clickedAccount = true;
    }

    public void backToRelationship() {
        page4();
    }

    public void cancelAccount() {
        page2();
    }

    public PageReference insertAccount() {
        try {
            insert account;
            page = 2;

            return ApexPages.currentPage();
        } catch (Exception e) {
        }

        return null;
    }

    public PageReference insertRelationship() {
        if (!validateRT()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Relationship Type.')
            );

            return null;
        }

        addRelationship();
        saveToDatabase();
        PageReference submit = new PageReference('/' + contact.Id);
        submit.setRedirect(true);

        return submit;
    }

    public PageReference insertCampaignMember() {
        if (!validateDA()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Department Affiliation.')
            );

            return null;
        }
        addParentCampaignMember();
        addCampaignMember();
        saveToDatabase();
        PageReference submit = new PageReference('/' + contact.Id);
        submit.setRedirect(true);

        return submit;
    }

    public PageReference cancelAndSaveCampaignMember() {
        saveToDatabase();
        PageReference submit = new PageReference('/' + contact.Id);
        submit.setRedirect(true);

        return submit;
    }

    public PageReference cancelAndSaveRelationship() {
        saveToDatabase();
        PageReference submit = new PageReference('/' + contact.Id);
        submit.setRedirect(true);

        return submit;
    }

    public PageReference cancelAndSave() {
        saveToDatabase();
        PageReference submit = new PageReference('/' + contact.Id);
        submit.setRedirect(true);

        return submit;
    }

    public PageReference relationshipSaveAndNew() {
        if (!validateRT()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Relationship Type.')
            );

            return null;
        }
        addRelationship();
        saveToDatabase();
        PageReference submit = ApexPages.currentPage();
        submit.setRedirect(true);

        return submit;
    }

    public PageReference campaignMemberSaveAndNew() {
        if (!validateDA()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Department Affiliation.')
            );
            return null;
        }
        addParentCampaignMember();
        addCampaignMember();
        saveToDatabase();
        PageReference submit = ApexPages.currentPage();
        submit.setRedirect(true);

        return submit;
    }

    public PageReference saveAndNew() {
        if (!validateRT()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Relationship Type.')
            );
            return null;
        }

        if (!validateDA()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Department Affiliation.')
            );

            return null;
        }
        addRelationship();
        addParentCampaignMember();
        addCampaignMember();
        saveToDatabase();
        PageReference submit = ApexPages.currentPage();
        submit.setRedirect(true);

        return submit;
    }

    public PageReference save() {
        if (!validateRT()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Relationship Type.')
            );

            return null;
        }
        if (!validateDA()) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Department Affiliation.')
            );

            return null;
        }
        addRelationship();
        addParentCampaignMember();
        addCampaignMember();
        saveToDatabase();
        PageReference submit = new PageReference('/' + contact.Id);
        submit.setRedirect(true);

        return submit;
    }

    public void saveToDatabase() {
        try {
            contact.Corporate_Relations_Email__c = contact.Email;
            contact.SF_First_Name__c = contact.FirstName;
            contact.SF_First_Name_Updated__c = Datetime.now();
            contact.SF_Last_Name__c = contact.LastName;
            contact.SF_Last_Name_Updated__c = Datetime.now();
            contact.SF_Mobile__c = contact.MobilePhone;
            contact.SF_Mobile_Updated__c = Datetime.now();
            contact.SF_Mailing_Street__c = contact.MailingStreet;
            contact.SF_Mailing_City__c = contact.MailingCity;
            contact.SF_Mailing_Country__c = contact.MailingCountryCode;
            contact.SF_Mailing_State__c = contact.MailingStateCode;
            contact.SF_Mailing_ZIP__c = contact.MailingPostalCode;
            contact.SF_Mailing_Address_Updated__c = Datetime.now();
            contact.SF_Birthdate__c = contact.Birthdate;
            contact.SF_Birthdate_Updated__c = Datetime.now();

            insert contact;

            for (Relationship__c r : relationshipList) {
                r.Active_Relationship__c = true;
                r.Contact__c = contact.Id;
                r.recordTypeId = contactToAccountRTID;
            }

            insert relationshipList;

            for (CampaignMember c : campaignMemberList) {
                c.ContactId = contact.Id;
            }

            insert campaignMemberList;
        } catch (exception e) {
        }
    }
}
