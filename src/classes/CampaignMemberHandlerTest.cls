@isTest
public class CampaignMemberHandlerTest {
    private static ContactFactory defaultContactFactory = new ContactFactory(ContactFactory.DEFAULT_CONTACT);
    private static OpportunityFactory opportunityFactory = new OpportunityFactory();

    private static List<Contact> createContacts(Integer qty) {
        return defaultContactFactory.create(qty);
    }

    private static Contact createContact() {
        return defaultContactFactory.createOne();
    }

    private static List<Opportunity> createOpportunities(List<Contact> contactList) {
        opportunityFactory.setRealtedContactsWithAccounts(contactList);
        return opportunityFactory.create(contactList.size());
    }

    private static Opportunity createOpportunity(Contact contact) {
        opportunityFactory.setRealtedContactsWithAccounts(contact);
        return opportunityFactory.createOne();
    }
    
    private static Lead createLead() {
        Lead testLead = LeadFactory.DEFAULT_LEAD;
        LeadFactory factory = new LeadFactory(testLead);
        return factory.createOne();
    }

    private static List<Lead> createLeads(Integer qty) {
        Lead testLead = LeadFactory.DEFAULT_LEAD;
        testLead.Email = 'test@test.test';
        testLead.LeadSource = 'Email';
        LeadFactory factory = new LeadFactory(testLead);
        return factory.create(qty);
    }

    private static Campaign createCampaign(String name, String type) {
        Campaign testCampaign = new Campaign(
            Name = name,
            RecordTypeId = IdHelper.getRecordTypeId('Campaign', 'Interest'),
            Type = type
        );
        insert testCampaign;
        return testCampaign;
    }

    private static CampaignMember createCampaignMember(SObject attachObject, Id campaignId) {
        CampaignMember cm = createCampaignMemberNoInsert(attachObject, campaignId);
        insert cm;
        return cm;
    }

    private static CampaignMember createCampaignMemberNoInsert(SObject attachObject, Id campaignId) {
        CampaignMemberFactory factory = new CampaignMemberFactory(CampaignMemberFactory.DEFAULT_CAMPAIGN_MEMBER);
        factory.setRelatedField('CampaignId', campaignId);
        factory.setLeadOrContact(attachObject);
        return factory.createOne();
    }

    // Testing Primary Interests
    @isTest
    private static void testOpportunityPrimaryInterestAdd() {
        List<Contact> contactList = createContacts(2);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c: contactList) {
            contactIds.add(c.Id);
        }

        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, LastName, AccountId FROM Contact WHERE Id IN :contactIds];
        Contact contact = contactList[0];

        Campaign camp1 = createCampaign('Test PSMajor 1', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');

        List<Opportunity> oppList = createOpportunities(contactList);
        insert oppList;
        Opportunity opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        System.assertEquals(null, opp.Primary_Interest__c);

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp1.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        System.assert(!cm1.Is_Primary_Interest__c);

        //Test that inserting a new cm sets its opportunity to primary
        insert cm1;

        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];

        System.assertEquals(opp.Id, cm1.Opportunity__c);
        System.assert(cm1.Is_Primary_Interest__c);
        System.assertEquals(camp1.Id, opp.primary_interest__c);

        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        System.assert(cm2.Is_Primary_Interest__c == false);

        //Test that inserting a second cm that doesn't update the primary does not update the opportunity
        Test.startTest();
        insert cm2;
        Test.stopTest();
        
        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];
        cm2 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp2.Id LIMIT 1];

        System.assertEquals(opp.Id, cm1.Opportunity__c);
        System.assertEquals(opp.Id, cm2.Opportunity__c);
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
        System.assertEquals(camp1.Id, opp.primary_interest__c);
    }

    @isTest
    private static void testOpportunityPrimaryInterestAdd2() {
        List<Contact> contactList = createContacts(2);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c: contactList) {
            contactIds.add(c.Id);
        }

        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, LastName, AccountId FROM Contact WHERE Id IN :contactIds];
        Contact contact = contactList[0];

        Campaign camp1 = createCampaign('Test PSMajor 1', 'PSMajors');
        Campaign camp3 = createCampaign('Test PSMajor 2', 'PSMajors');

        List<Opportunity> oppList = createOpportunities(contactList);
        insert oppList;
        Opportunity opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        System.assertEquals(null, opp.Primary_Interest__c);

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp1.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        System.assert(!cm1.Is_Primary_Interest__c);

        insert cm1;

        CampaignMember cm3 = createCampaignMemberNoInsert(contact, camp3.Id);
        System.assert(!cm3.Is_Primary_Interest__c);

        //Test that inserting a new primary cm updates the opportunity
        Test.startTest();
        insert cm3;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];
        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        cm3 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp3.Id LIMIT 1];

        System.assertEquals(opp.Id, cm1.Opportunity__c);
        System.assertEquals(opp.Id, cm3.Opportunity__c);
        System.assert(!cm1.Is_Primary_Interest__c);
        System.assert(cm3.Is_Primary_Interest__c);
        System.assertEquals(camp3.Id, opp.primary_interest__c);
    }

    @isTest
    private static void testOpportunityPrimaryInterestRemove() {
        List<Contact> contactList = createContacts(2);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c: contactList) {
            contactIds.add(c.Id);
        }
        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, LastName, AccountId FROM Contact WHERE Id IN :contactIds];
        Contact contact = contactList[0];

        Campaign camp1 = createCampaign('Test PSMajor 1', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');

        List<Opportunity> oppList = createOpportunities(contactList);
        insert oppList;
        Opportunity opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        System.assertEquals(null, opp.Primary_Interest__c);

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp1.Id);
        System.assert(!cm1.Is_Primary_Interest__c);
        insert cm1;

        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];

        System.assertEquals(opp.Id, cm1.Opportunity__c);
        System.assert(cm1.Is_Primary_Interest__c);
        System.assertEquals(camp1.Id, opp.primary_interest__c);

        Test.startTest();
        delete cm1;
        Test.stopTest();

        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        System.assertEquals(opp.primary_interest__c, null);

        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        System.assert(!cm2.Is_Primary_Interest__c);

        insert cm2;
        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        cm2 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp2.Id LIMIT 1];

        System.assertEquals(opp.primary_interest__c, camp2.Id);
    }

    @isTest
    private static void testLeadPrimaryInterestAdd() {
        List<Lead> leadList = createLeads(1);
        Lead testLead = leadList[0];
        insert testLead;

        testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(null, testLead.Primary_Interest__c);

        Campaign camp1 = createCampaign('Test PSMajor 1', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Campaign camp3 = createCampaign('Test PSMajor 2', 'PSMajors');

        CampaignMember cm1 = createCampaignMemberNoInsert(testLead, camp1.Id);
        System.assert(!cm1.Is_Primary_Interest__c);

        insert cm1;

        testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];

        System.assert(cm1.Is_Primary_Interest__c);
        System.assertEquals(camp1.Id, testLead.primary_interest__c);

        CampaignMember cm2 = createCampaignMemberNoInsert(testLead, camp2.Id);
        System.assert(!cm2.Is_Primary_Interest__c);

        insert cm2;
        testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp2.Id LIMIT 1];

        System.assert(cm1.Is_Primary_Interest__c);
        System.assertEquals(camp1.Id, testLead.Primary_Interest__c);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assertEquals(camp1.Id, testLead.Primary_Interest__c);

        CampaignMember cm3 = createCampaignMemberNoInsert(testLead, camp3.Id);
        System.assert(!cm3.Is_Primary_Interest__c);

        Test.startTest();
        insert cm3;
        Test.stopTest();

        testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
        cm3 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp3.Id LIMIT 1];

        System.assert(cm3.Is_Primary_Interest__c);
        System.assertEquals(camp3.Id, testLead.Primary_Interest__c);
    }

    @isTest
    private static void testLeadPrimaryInterestRemove() {
        List<Lead> leadList = createLeads(1);
        Lead testLead = leadList[0];
        insert testLead;

        testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(null, testLead.Primary_Interest__c);

        Campaign camp1 = createCampaign('Test PSMajor 1', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');

        CampaignMember cm1 = createCampaignMemberNoInsert(testLead, camp1.Id);
        System.assert(!cm1.Is_Primary_Interest__c);

        insert cm1;

        testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];

        System.assert(cm1.Is_Primary_Interest__c == true);
        System.assertEquals(camp1.Id, testLead.Primary_Interest__c);

        Test.startTest();
        delete cm1;
        Test.stopTest();

        testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(testLead.Primary_Interest__c, null);

        CampaignMember cm2 = createCampaignMemberNoInsert(testLead, camp2.Id);
        System.assert(!cm2.Is_Primary_Interest__c);

        insert cm2;
        testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp2.Id LIMIT 1];

        System.assertEquals(testLead.Primary_Interest__c, camp2.Id);
    }

    // Testing Scholarships
    @isTest
    private static void testOpportunityScholarshipAdd() {
        List<Contact> contactList = createContacts(2);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c: contactList) {
            contactIds.add(c.Id);
        }

        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, LastName, AccountId FROM Contact WHERE Id IN :contactIds];

        List<Opportunity> oppList = createOpportunities(contactList);
        insert oppList;

        Campaign camp = new Campaign(
            Name = 'National Achievement Finalist',
            Type = 'Scholarship - ASU',
            RecordTypeId = IdHelper.getRecordTypeId('Campaign', 'Scholarship'),
            IsActive = true
        );
        insert camp;

        List<CampaignMember> cmList = new List<CampaignMember>();
        for (Contact c: contactList) {
            cmList.add(createCampaignMemberNoInsert(c, camp.Id));
        }

        Test.startTest();
        insert cmList;
        Test.stopTest();

        List<Opportunity> newOppList = [
            SELECT Id, National_Merit_Semifinalist__c 
            FROM Opportunity 
            WHERE Contact__c IN :contactIds
        ];
        for (Opportunity o: newOppList) {
            System.assert(o.National_Merit_Semifinalist__c, 'Opportunity National Merit Semifinalist was not set to true upon insert');
        }
    }

    @isTest
    private static void insertContactPSMajorLoad() {
        List<Contact> contacts = createContacts(200);
        insert contacts;

        List<CampaignMember> cms = new List<CampaignMember>();
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        for (Contact contact : contacts) {
            cms.add(createCampaignMemberNoInsert(contact, camp.Id));
        }

        Test.startTest();
        insert cms;
        Test.stopTest();

        cms = [SELECT Is_Primary_Interest__c FROM CampaignMember WHERE CampaignId = :camp.Id];
        for (CampaignMember member : cms) {
            System.assert(member.Is_Primary_Interest__c == TRUE);
        }
    }

    @isTest
    private static void insertContactPSMajorExistingPSMajor() {
        //Inserting PSMajor CM w/ Contact, no preexisting Primary
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Contact contact = createContact();
        insert contact;

        CampaignMember cm1 = createCampaignMember(contact, camp.Id);
        System.assert(!cm1.Is_Primary_Interest__c);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        System.assert(cm1.Is_Primary_Interest__c);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        System.assert(cm1.Is_Primary_Interest__c);

        //Inserting PSMajor CM w/ Contact, preexisting PSMajor Primary
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');

        Test.startTest(); 
        CampaignMember cm2 = createCampaignMember(contact, camp2.Id);
        Test.stopTest();

        System.assert(!cm2.Is_Primary_Interest__c);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(!cm1.Is_Primary_Interest__c);
        System.assert(cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void insertContactNonPSMajorExistingPSMajor() {
        //Inserting PSMajor CM w/ Contact, no preexisting Primary
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Contact contact = createContact();
        insert contact;

        CampaignMember cm1 = createCampaignMember(contact, camp.Id);
        System.assert(!cm1.Is_Primary_Interest__c);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        System.assert(cm1.Is_Primary_Interest__c);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        System.assert(cm1.Is_Primary_Interest__c);

        //Inserting Non-PSMajor Cm w/ Contact, preexisting PSMajor Primary
        Campaign camp2 = createCampaign('Test Non-PSMajor', 'Academic');

        Test.startTest();
        CampaignMember cm2 = createCampaignMember(contact, camp2.Id);
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void insertContactPSMajorExistingNonPSMajor() {
        //Inserting Non PSMajor CM w/ Contact, no preexisting Primary
        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember cm1 = createCampaignMember(contact, camp.Id);
        System.assert(!cm1.Is_Primary_Interest__c);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        System.assert(cm1.Is_Primary_Interest__c);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        System.assert(cm1.Is_Primary_Interest__c);

        //Inserting PSMajor CM w/ Contact, preexisting Non PSMajor Primary
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');

        Test.startTest();
        CampaignMember cm2 = createCampaignMember(contact, camp2.Id);
        Test.stopTest();

        System.assert(!cm2.Is_Primary_Interest__c);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(!cm1.Is_Primary_Interest__c);
        System.assert(cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void insertContactNonPSMajorExistingNonPSMajor() {
        //Inserting Non PSMajor CM w/ Contact, no preexisting Primary
        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember cm1 = createCampaignMember(contact, camp.Id);
        System.assert(!cm1.Is_Primary_Interest__c);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        System.assert(cm1.Is_Primary_Interest__c);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        System.assert(cm1.Is_Primary_Interest__c);

        //Inserting Non PSMajor CM w/ Contact, preexisting Non PSMajor Primary
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');

        Test.startTest();
        CampaignMember cm2 = createCampaignMember(contact, camp2.Id);
        Test.stopTest();

        System.assert(!cm2.Is_Primary_Interest__c);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(!cm1.Is_Primary_Interest__c);
        System.assert(cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateContactPSMajorNoPrimaryPreexisting() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        System.assert(!cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);

        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);

        //Updating Non PSMajor CM w/ Contact, no preexisting primary
        cm1.Is_Primary_Interest__c = FALSE;
        cm2.Is_Primary_Interest__c = FALSE;
        cm1.Status = 'Required';
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateContactPSMajorNonPSMajorPrimaryPreexisting() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];

        //Updating Non PSMajor CM w/ Contact, no preexisting primary
        cm1.Is_Primary_Interest__c = FALSE;
        cm1.Status = 'Required';
        cm2.Is_Primary_Interest__c = TRUE;
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    private static testMethod void updateContactPSMajorPSMajorPrimaryPreexisting() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
        Contact contact = createContact();
        insert contact;

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];

        cm1.Status = 'Required';
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateContactPSMajorPSMajorPrimaryPreexistingChangeStatus() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
        Contact contact = createContact();
        insert contact;

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);

        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];

        cm2.Status = 'No Longer Interested';
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateContactNonPSMajorNoPrimaryPreexisting() {
        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];

        cm1.Is_Primary_Interest__c = FALSE;
        cm2.Is_Primary_Interest__c = FALSE;
        cm1.Status = 'Required';
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateContactNonPSMajorNonPSMajorPrimaryPreexisting() {
        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);

        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];

        cm1.Status = 'Required';
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateContactNonPSMajorPSMajorPrimaryPreexisting() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);

        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];

        //Updating Non PSMajor CM w/ Contact, PSMajor preexisting primary
        cm2.Status = 'Required';
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void deleteContactPSMajorReassignPSMajor() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Campaign camp3 = createCampaign('Test PSMajor 3', 'PSMajors');

        Contact contact = createContact();
        insert contact;
        contact = [SELECT Id, AccountId FROM Contact WHERE Id = :contact.Id];

        Opportunity opp = createOpportunity(contact);
        insert opp;

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        CampaignMember cm3 = createCampaignMemberNoInsert(contact, camp3.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);

        System.assert(!cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
        System.assert(!cm3.Is_Primary_Interest__c);
        System.assertEquals(null, opp.Primary_Interest__c);

        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        cmsToUpdate.add(cm3);

        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        cm3 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm3.Id];
        opp = [SELECT Id, Primary_Interest__c FROM Opportunity WHERE Id = :opp.Id];

        System.assert(!cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
        System.assert(cm3.Is_Primary_Interest__c);
        System.assertEquals(camp3.Id, opp.Primary_Interest__c);

        Test.startTest();
        delete cm3;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        opp = [SELECT Id, Primary_Interest__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
        System.assertEquals(camp.Id, opp.Primary_Interest__c);
    }

    @isTest
    private static void deleteContactPSMajorReassignNonPSMajor() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');

        Contact contact = createContact();
        insert contact;

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);

        System.assert(!cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);

        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);

        Test.startTest();
        delete cm1;
        Test.stopTest(); 

        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void deleteContactNonPSMajorReassignNonPSMajor() {
        Contact contact = createContact();
        insert contact;

        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Campaign camp3 = createCampaign('Test Non PSMajor 3', 'Academic');
        
        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        CampaignMember cm3 = createCampaignMemberNoInsert(contact, camp3.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        cmsToUpdate.add(cm3);
        insert cmsToUpdate;
        
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        cm3 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm3.Id];

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        update cmsToUpdate;

        Test.startTest();
        delete cm3;
        Test.stopTest();

        cm1 = [SELECT Id, Status, Last_Member_Status_Change__c, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Status, Last_Member_Status_Change__c, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void insertLeadPSMajorExistingPSMajor() {
        //Inserting PSMajor CM w/ Lead, no preexisting Primary
        Lead lead = createLead();
        insert lead;
        
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        CampaignMember cm1 = createCampaignMember(lead, camp.Id);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        
        //Inserting PSMajor CM w/ Lead, preexisting PSMajor Primary
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');

        Test.startTest();
        CampaignMember cm2 = createCampaignMember(lead, camp2.Id);
        Test.stopTest();

        System.assert(cm2.Is_Primary_Interest__c == FALSE);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c == FALSE);
        System.assert(cm2.Is_Primary_Interest__c == TRUE);
    }

    @isTest
    private static void insertLeadNonPSMajorExistingPSMajor() {
        //Inserting PSMajor CM w/ Lead, no preexisting Primary
        Lead lead = LeadService.createTestLead();
        insert lead;
        
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        CampaignMember cm1 = createCampaignMember(lead, camp.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        //Inserting Non-PSMajor Cm w/ Lead, preexisting PSMajor Primary
        Campaign camp2 = createCampaign('Test Non-PSMajor', 'Academic');

        Test.startTest();
        CampaignMember cm2 = createCampaignMember(lead, camp2.Id);
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
    }

    @isTest
    private static void insertLeadPSMajorExistingNonPSMajor() {
        //Inserting Non PSMajor CM w/ Lead, no preexisting Primary
        Lead lead = createLead();
        insert lead;
        
        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        CampaignMember cm1 = createCampaignMember(lead, camp.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;

        //Inserting PSMajor CM w/ Lead, preexisting Non PSMajor Primary
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');

        Test.startTest();
        CampaignMember cm2 = createCampaignMember(lead, camp2.Id);
        Test.stopTest();

        System.assert(!cm2.Is_Primary_Interest__c);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(!cm1.Is_Primary_Interest__c);
        System.assert(cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void insertLeadNonPSMajorExistingNonPSMajor() {
        //Inserting Non PSMajor CM w/ Lead, no preexisting Primary
        Lead lead = createLead();
        insert lead;
        
        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        CampaignMember cm1 = createCampaignMember(lead, camp.Id);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;

        //Inserting Non PSMajor CM w/ Lead, preexisting Non PSMajor Primary
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');

        Test.startTest();
        CampaignMember cm2 = createCampaignMember(lead, camp2.Id);
        Test.stopTest();

        System.assert(!cm2.Is_Primary_Interest__c);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(!cm1.Is_Primary_Interest__c);
        System.assert(cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateLeadPSMajorNoPrimaryPreexisting() {
        Lead lead = createLead();
        insert lead;
        
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;

        //Updating Non PSMajor CM w/ Lead, no preexisting primary
        cm1.Is_Primary_Interest__c = FALSE;
        cm2.Is_Primary_Interest__c = FALSE;
        cm1.Status = 'Required';
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateLeadPSMajorNonPSMajorPrimaryPreexisting() {
        Lead lead = createLead();
        insert lead;
        
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;

        //Updating Non PSMajor CM w/ Lead, no preexisting primary
        cm1.Is_Primary_Interest__c = FALSE;
        cm1.Status = 'Required';
        cm2.Is_Primary_Interest__c = TRUE;
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateLeadPSMajorPSMajorPrimaryPreexisting() {
        Lead lead = createLead();
        insert lead;
        
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
        CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];

        cm1.Status = 'Required';
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateLeadNonPSMajorNoPrimaryPreexisting()
    {
        Lead lead = createLead();
        insert lead;
        
        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];

        cm1.Is_Primary_Interest__c = FALSE;
        cm2.Is_Primary_Interest__c = FALSE;
        cm1.Status = 'Required';
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateLeadNonPSMajorNonPSMajorPrimaryPreexisting() {
        Lead lead = createLead();
        insert lead;
        
        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];

        cm1.Status = 'Required';
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateLeadNonPSMajorPSMajorPrimaryPreexisting() {
        Lead lead = createLead();
        insert lead;
        
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];

        //Updating Non PSMajor CM w/ Lead, PSMajor preexisting primary
        cm2.Status = 'Required';
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);

        Test.startTest();
        update cmsToUpdate;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void deleteLeadPSMajorReassignPSMajor() {
        Lead lead = createLead();
        insert lead;

        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Campaign camp3 = createCampaign('Test PSMajor 3', 'PSMajors');
        CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);
        CampaignMember cm3 = createCampaignMemberNoInsert(lead, camp3.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);

        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        cmsToUpdate.add(cm3);
        insert cmsToUpdate;

        Test.startTest();
        delete cm3;
        Test.stopTest();

        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void deleteLeadPSMajorReassignNonPSMajor() {
        Lead lead = createLead();
        insert lead;

        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);

        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        insert cmsToUpdate;

        Test.startTest();
        delete cm1;
        Test.stopTest();

        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        System.assert(cm2.Is_Primary_Interest__c);
    }

    @isTest
    private static void deleteLeadNonPSMajorReassignNonPSMajor() {
        Lead lead = createLead();
        insert lead;
        lead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(null, lead.Primary_Interest__c);

        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Campaign camp3 = createCampaign('Test Non PSMajor 3', 'Academic');
        CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
        CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);
        CampaignMember cm3 = createCampaignMemberNoInsert(lead, camp3.Id);
        
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        cmsToUpdate.add(cm3);
        insert cmsToUpdate;
        
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        cm3 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm3.Id];

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        cmsToUpdate = new List<CampaignMember>();
        cmsToUpdate.add(cm1);
        cmsToUpdate.add(cm2);
        update cmsToUpdate;

        Test.startTest();
        delete cm3;
        Test.stopTest();

        cm1 = [SELECT Id, Status, Last_Member_Status_Change__c, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Status, Last_Member_Status_Change__c, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
        lead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :lead.Id];
        System.assert(cm1.Is_Primary_Interest__c);
        System.assert(!cm2.Is_Primary_Interest__c);
        System.assertEquals(camp.Id, lead.Primary_Interest__c);
    }
    
    @isTest
    private static void mostRecentOppportunityAssigned() {
        insert createContacts(2);
        List<Contact> testContacts = [SELECT LastName, AccountId FROM Contact];

        List<Opportunity> testOpportunities = new List<Opportunity>();
        testOpportunities.addAll(createOpportunities(testContacts));
        testOpportunities.addAll(createOpportunities(testContacts));
        testOpportunities.addAll(createOpportunities(testContacts));
        insert testOpportunities;
        
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(createCampaign('Test Non PSMajor', 'Academic'));
        campaigns.add(createCampaign('Test Non PSMajor 2', 'Academic'));
        campaigns.add(createCampaign('Test Non PSMajor 3', 'Academic'));
        update campaigns;
        
        List<CampaignMember> testMembers = new List<CampaignMember>();
        testMembers.add(createCampaignMemberNoInsert(testContacts[0], campaigns[0].Id));
        testMembers.add(createCampaignMemberNoInsert(testContacts[1], campaigns[1].Id));
        
        Test.startTest();
        insert testMembers;
        Test.stopTest();
        
        List<CampaignMember> postTestMembers = [
            SELECT Opportunity__c
            FROM CampaignMember
        ];
        
        System.assertEquals(testOpportunities[testOpportunities.size() - 2].Id, postTestMembers[0].Opportunity__c);
        System.assertEquals(testOpportunities[testOpportunities.size() - 1].Id, postTestMembers[1].Opportunity__c);
    }
    
    @isTest
    private static void closedOpportunitiesAreNotAssigned() {
        insert createContacts(2);
        List<Contact> testContacts = [SELECT LastName, AccountId FROM Contact];

        List<Opportunity> testOpportunities = new List<Opportunity>();
        testOpportunities.addAll(createOpportunities(testContacts));
        testOpportunities.addAll(createOpportunities(testContacts));
        testOpportunities.addAll(createOpportunities(testContacts));
        insert testOpportunities;
        
        testOpportunities[testOpportunities.size() - 2].CloseDate = Date.today();
        testOpportunities[testOpportunities.size() - 1].CloseDate = Date.today();
        testOpportunities[testOpportunities.size() - 2].StageName = 'Closed - Won';
        testOpportunities[testOpportunities.size() - 1].StageName = 'Closed - Won';
        
        update testOpportunities;
        
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(createCampaign('Test Non PSMajor', 'Academic'));
        campaigns.add(createCampaign('Test Non PSMajor 2', 'Academic'));
        campaigns.add(createCampaign('Test Non PSMajor 3', 'Academic'));
        update campaigns;
        
        List<CampaignMember> testMembers = new List<CampaignMember>();
        testMembers.add(createCampaignMemberNoInsert(testContacts[0], campaigns[0].Id));
        testMembers.add(createCampaignMemberNoInsert(testContacts[1], campaigns[1].Id));
        
        Test.startTest();
        insert testMembers;
        Test.stopTest();
        
        List<CampaignMember> postTestMembers = [
            SELECT Opportunity__c
            FROM CampaignMember
        ];
        
        Map<Id, Opportunity> closedOpps = new Map<Id, Opportunity>([SELECT IsClosed FROM Opportunity]);
        
        System.assert(closedOpps.get(testOpportunities[testOpportunities.size() - 2].Id).IsClosed);
        System.assert(closedOpps.get(testOpportunities[testOpportunities.size() - 1].Id).IsClosed);
        System.assertNotEquals(testOpportunities[testOpportunities.size() - 2].Id, postTestMembers[0].Opportunity__c);
        System.assertNotEquals(testOpportunities[testOpportunities.size() - 1].Id, postTestMembers[1].Opportunity__c);
        System.assertEquals(testOpportunities[testOpportunities.size() - 4].Id, postTestMembers[0].Opportunity__c);
        System.assertEquals(testOpportunities[testOpportunities.size() - 3].Id, postTestMembers[1].Opportunity__c);
    }
    
    @isTest
    private static void mostRecentlyClosedIsSelectedIfAllClosed() {
        insert createContacts(2);
        List<Contact> testContacts = [SELECT LastName, AccountId FROM Contact];

        List<Opportunity> testOpportunities = new List<Opportunity>();
        testOpportunities.addAll(createOpportunities(testContacts));
        testOpportunities.addAll(createOpportunities(testContacts));
        testOpportunities.addAll(createOpportunities(testContacts));
        insert testOpportunities;
        
        for (Opportunity opp : testOpportunities) {
            opp.CloseDate = Date.today();
            opp.StageName = 'Closed - Won';
        }
        testOpportunities[2].CloseDate = Date.today().addDays(-2);
        testOpportunities[3].CloseDate = Date.today().addDays(-2);
        
        update testOpportunities;
        
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(createCampaign('Test Non PSMajor', 'Academic'));
        campaigns.add(createCampaign('Test Non PSMajor 2', 'Academic'));
        campaigns.add(createCampaign('Test Non PSMajor 3', 'Academic'));
        update campaigns;
        
        List<CampaignMember> testMembers = new List<CampaignMember>();
        testMembers.add(createCampaignMemberNoInsert(testContacts[0], campaigns[0].Id));
        testMembers.add(createCampaignMemberNoInsert(testContacts[1], campaigns[1].Id));
        
        Test.startTest();
        insert testMembers;
        Test.stopTest();
        
        List<CampaignMember> postTestMembers = [
            SELECT Opportunity__c
            FROM CampaignMember
        ];
        
        Map<Id, Opportunity> closedOpps = new Map<Id, Opportunity>([SELECT IsClosed FROM Opportunity WHERE IsClosed = TRUE]);
        
        System.assertEquals(testOpportunities.size(), closedOpps.size());
        System.assertEquals(testOpportunities[2].Id, postTestMembers[0].Opportunity__c);
        System.assertEquals(testOpportunities[3].Id, postTestMembers[1].Opportunity__c);
    }
}