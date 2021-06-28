@isTest
private class NewCorporateRelationsControllerTest {
    private static Campaign testCampaign;
    private static Campaign testChildCampaign;
    private static Account testAccount;
    private static Contact testContact;
    private static Relationship__c testR;
    private static CampaignMember testCM;
    private static Id crId;
    private static NewCorporateRelationsContactController ncr;

    private static void setupData() {
        // Create custom setting to store the recip values
        Relationships__c partnerRel = new Relationships__c();
        partnerRel.Name = 'Partner';
        partnerRel.Reciprocal__c = 'Partner';

        insert partnerRel;

        crId = [SELECT Id FROM RecordType WHERE Name = 'Corporate Relations' AND SobjectType = 'Campaign'].Id;

        testCampaign = new Campaign(Name = 'Test Campaign', RecordTypeId = crId);

        insert testCampaign;

        testChildCampaign = new Campaign(Name = 'Test Child Campaign', ParentId = testCampaign.Id, RecordTypeId = crId);

        insert testChildCampaign;

        testAccount = new Account(Name = 'Test Account', Website = 'www.example.com');

        insert testAccount;

        testContact = new Contact(FirstName = 'John', LastName = 'Doe');

        insert testContact;

        testR = new Relationship__c(
            Related_Account__c = testAccount.Id,
            Active_Relationship__c = true,
            Contact__c = testContact.Id,
            Title__c = 'Test Title',
            Relationship_Type__c = 'Partner',
            Relationship_Start_Date__c = Date.today()
        );

        insert testR;

        testCM = new CampaignMember(CampaignId = testCampaign.Id, ContactId = testContact.Id);

        insert testCM;

        ncr = new NewCorporateRelationsContactController();
    }

    @isTest
    static void testSave() {
        setupData();
        PageReference crPage = Page.NewCorporateRelationsContact;
        Test.setCurrentPage(crPage);
        ncr.getRelTypeOptions();
        ncr.contact = testContact;
        ncr.relationship = testR;
        ncr.selectedParentId = testCampaign.Id;
        ncr.selectedChildId = testChildCampaign.Id;
        ncr.getCampaignOptions();
        ncr.populateChildCampaigns();
        PageReference confirmSave = new PageReference('/' + testContact.Id);
        System.assertEquals(confirmSave.getUrl(), ncr.save().getUrl());
    }

    @isTest
    static void testInsertAccount() {
        setupData();
        PageReference crPage = Page.NewCorporateRelationsContact;
        Test.setCurrentPage(crPage);
        ncr.account = testAccount;
        ncr.cancelAccount();
        ncr.page3();
        ncr.page6();
        ncr.backToRelationship();
        ncr.click();
        ncr.insertAccount();
        List<Account> accountList = [SELECT Id FROM Account];

        System.assertNotEquals(null, accountList);
    }

    @isTest
    static void testInsertRelationship() {
        setupData();
        PageReference crPage = Page.NewCorporateRelationsContact;
        Test.setCurrentPage(crPage);
        ncr.relationship = testR;
        ncr.addRelationshipPage();
        ncr.insertRelationship();
        List<Relationship__c> relList = [SELECT Id FROM Relationship__c];

        System.assertNotEquals(null, relList);
    }

    @isTest
    static void testInsertCampaignMember() {
        setupData();
        PageReference crPage = Page.NewCorporateRelationsContact;
        Test.setCurrentPage(crPage);
        ncr.page5();
        ncr.addCampaignPage();
        ncr.selectedParentId = testCampaign.Id;
        ncr.selectedChildId = testChildCampaign.Id;
        ncr.getCampaignOptions();
        ncr.populateChildCampaigns();
        ncr.insertCampaignMember();
        List<CampaignMember> camMemList = [SELECT Id FROM CampaignMember];

        System.assertNotEquals(null, camMemList);
    }

    @isTest
    static void testSaveAndNew() {
        setupData();
        PageReference crPage = Page.NewCorporateRelationsContact;
        Test.setCurrentPage(crPage);
        ncr.contact = testContact;
        ncr.relationship = testR;
        ncr.selectedParentId = testCampaign.Id;
        ncr.selectedChildId = testChildCampaign.Id;
        ncr.getCampaignOptions();
        ncr.populateChildCampaigns();
        PageReference confirmSave = ApexPages.currentPage();

        System.assertEquals(confirmSave.getUrl(), ncr.saveAndNew().getUrl());
    }

    @isTest
    static void testAddPageSave() {
        setupData();
        PageReference crPage = Page.NewCorporateRelationsContact;
        Test.setCurrentPage(crPage);
        ncr.contact = testContact;
        ncr.relationship = testR;
        ncr.selectedParentId = testCampaign.Id;
        ncr.selectedChildId = testChildCampaign.Id;
        ncr.getCampaignOptions();
        ncr.populateChildCampaigns();
        ncr.page2();
        ncr.addPage();
        ncr.relationship = testR;
        ncr.selectedParentId = testCampaign.Id;
        ncr.selectedChildId = testChildCampaign.Id;
        PageReference confirmSave = new PageReference('/' + testContact.Id);

        System.assertEquals(confirmSave.getUrl(), ncr.save().getUrl());
    }

    @isTest
    static void testValidations() {
        setupData();
        PageReference crPage = Page.NewCorporateRelationsContact;
        Test.setCurrentPage(crPage);
        ncr.relationship.Relationship_Type__c = null;
        ncr.insertRelationship();
        ncr.selectedParentId = null;
        ncr.addPage();
        ncr.saveAndNew();
        ncr.insertCampaignMember();
        ncr.cancelAndSaveRelationship();
        ncr.cancelAndSaveCampaignMember();
        ncr.cancelAndSave();
        ncr.relationshipSaveAndNew();
        ncr.campaignMemberSaveAndNew();
        ncr.contact = testContact;
        ncr.relationship = testR;
        ncr.selectedParentId = testCampaign.Id;
        ncr.selectedChildId = testChildCampaign.Id;
        ncr.getCampaignOptions();
        ncr.populateChildCampaigns();
        ncr.insertRelationship();
        ncr.insertCampaignMember();
        ncr.cancelAndSaveRelationship();
        ncr.cancelAndSaveCampaignMember();
        ncr.cancelAndSave();
        ncr.relationshipSaveAndNew();
        ncr.campaignMemberSaveAndNew();
        ncr.addRelationshipPage();
        ncr.relationship.Relationship_Type__c = null;
        ncr.addRelationshipPage();
        ncr.relationship.Relationship_Type__c = 'Email';
        ncr.addCampaignPage();
    }
}
