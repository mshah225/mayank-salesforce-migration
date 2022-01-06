@isTest
public class CampaignMemberTriggerTest {
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
            RecordTypeId = RecordIdHelper.getRecordTypeId('Campaign', 'Interest'),
            Type = type
        );
        insert testCampaign;
        return testCampaign;
    }

    private static CampaignMember createCampaignMember(SObject attachObject, Id campaignId) {
        CampaignMember member = createCampaignMemberNoInsert(attachObject, campaignId);
        insert member;
        return member;
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
        for (Contact c : contactList) {
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

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp1.Id);
        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        System.assert(!member1.Is_Primary_Interest__c);

        //Test that inserting a new member sets its opportunity to primary
        insert member1;

        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        member1 = [
            SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
            FROM CampaignMember
            WHERE CampaignId = :camp1.Id
            LIMIT 1
        ];

        System.assertEquals(opp.Id, member1.Opportunity__c);
        System.assert(member1.Is_Primary_Interest__c);
        System.assertEquals(camp1.Id, opp.primary_interest__c);

        CampaignMember member2 = createCampaignMemberNoInsert(contact, camp2.Id);
        System.assert(member2.Is_Primary_Interest__c == false);

        //Test that inserting a second member that doesn't update the primary does not update the opportunity
        Test.startTest();
        insert member2;
        Test.stopTest();

        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        member1 = [
            SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
            FROM CampaignMember
            WHERE CampaignId = :camp1.Id
            LIMIT 1
        ];
        member2 = [
            SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
            FROM CampaignMember
            WHERE CampaignId = :camp2.Id
            LIMIT 1
        ];

        System.assertEquals(opp.Id, member1.Opportunity__c);
        System.assertEquals(opp.Id, member2.Opportunity__c);
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
        System.assertEquals(camp1.Id, opp.primary_interest__c);
    }

    @isTest
    private static void testOpportunityPrimaryInterestAdd2() {
        List<Contact> contactList = createContacts(2);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c : contactList) {
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

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp1.Id);
        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        System.assert(!member1.Is_Primary_Interest__c);

        insert member1;

        CampaignMember member3 = createCampaignMemberNoInsert(contact, camp3.Id);
        System.assert(!member3.Is_Primary_Interest__c);

        //Test that inserting a new primary member updates the opportunity
        Test.startTest();
        insert member3;
        Test.stopTest();

        member1 = [
            SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
            FROM CampaignMember
            WHERE CampaignId = :camp1.Id
            LIMIT 1
        ];
        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        member3 = [
            SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
            FROM CampaignMember
            WHERE CampaignId = :camp3.Id
            LIMIT 1
        ];

        System.assertEquals(opp.Id, member1.Opportunity__c);
        System.assertEquals(opp.Id, member3.Opportunity__c);
        System.assert(!member1.Is_Primary_Interest__c);
        System.assert(member3.Is_Primary_Interest__c);
        System.assertEquals(camp3.Id, opp.primary_interest__c);
    }

    @isTest
    private static void testOpportunityPrimaryInterestRemove() {
        List<Contact> contactList = createContacts(2);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c : contactList) {
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

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp1.Id);
        System.assert(!member1.Is_Primary_Interest__c);
        insert member1;

        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        member1 = [
            SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
            FROM CampaignMember
            WHERE CampaignId = :camp1.Id
            LIMIT 1
        ];

        System.assertEquals(opp.Id, member1.Opportunity__c);
        System.assert(member1.Is_Primary_Interest__c);
        System.assertEquals(camp1.Id, opp.primary_interest__c);

        Test.startTest();
        delete member1;
        Test.stopTest();

        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        System.assertEquals(opp.primary_interest__c, null);

        CampaignMember member2 = createCampaignMemberNoInsert(contact, camp2.Id);
        System.assert(!member2.Is_Primary_Interest__c);

        insert member2;
        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        member2 = [
            SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
            FROM CampaignMember
            WHERE CampaignId = :camp2.Id
            LIMIT 1
        ];

        System.assertEquals(opp.primary_interest__c, camp2.Id);
    }

    // @isTest
    // private static void testLeadPrimaryInterestAdd() {
    //     List<Lead> leadList = createLeads(1);
    //     Lead testLead = leadList[0];
    //     insert testLead;

    //     testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
    //     System.assertEquals(null, testLead.Primary_Interest__c);

    //     Campaign camp1 = createCampaign('Test PSMajor 1', 'PSMajors');
    //     Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
    //     Campaign camp3 = createCampaign('Test PSMajor 2', 'PSMajors');

    //     CampaignMember member1 = createCampaignMemberNoInsert(testLead, camp1.Id);
    //     System.assert(!member1.Is_Primary_Interest__c);

    //     insert member1;

    //     testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
    //     member1 = [
    //         SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
    //         FROM CampaignMember
    //         WHERE CampaignId = :camp1.Id
    //         LIMIT 1
    //     ];

    //     System.assert(member1.Is_Primary_Interest__c);
    //     System.assertEquals(camp1.Id, testLead.primary_interest__c);

    //     CampaignMember member2 = createCampaignMemberNoInsert(testLead, camp2.Id);
    //     System.assert(!member2.Is_Primary_Interest__c);

    //     insert member2;
    //     testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
    //     member2 = [
    //         SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
    //         FROM CampaignMember
    //         WHERE CampaignId = :camp2.Id
    //         LIMIT 1
    //     ];

    //     System.assert(member1.Is_Primary_Interest__c);
    //     System.assertEquals(camp1.Id, testLead.Primary_Interest__c);

    //     member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
    //     update member1;
    //     testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
    //     member1 = [
    //         SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
    //         FROM CampaignMember
    //         WHERE CampaignId = :camp1.Id
    //         LIMIT 1
    //     ];
    //     System.assert(member1.Is_Primary_Interest__c);
    //     System.assertEquals(camp1.Id, testLead.Primary_Interest__c);

    //     CampaignMember member3 = createCampaignMemberNoInsert(testLead, camp3.Id);
    //     System.assert(!member3.Is_Primary_Interest__c);

    //     Test.startTest();
    //     insert member3;
    //     Test.stopTest();

    //     testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
    //     member3 = [
    //         SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
    //         FROM CampaignMember
    //         WHERE CampaignId = :camp3.Id
    //         LIMIT 1
    //     ];

    //     System.assert(member3.Is_Primary_Interest__c);
    //     System.assertEquals(camp3.Id, testLead.Primary_Interest__c);
    // }

    // @isTest
    // private static void testLeadPrimaryInterestRemove() {
    //     List<Lead> leadList = createLeads(1);
    //     Lead testLead = leadList[0];
    //     insert testLead;

    //     testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
    //     System.assertEquals(null, testLead.Primary_Interest__c);

    //     Campaign camp1 = createCampaign('Test PSMajor 1', 'PSMajors');
    //     Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');

    //     CampaignMember member1 = createCampaignMemberNoInsert(testLead, camp1.Id);
    //     System.assert(!member1.Is_Primary_Interest__c);

    //     insert member1;

    //     testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
    //     member1 = [
    //         SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
    //         FROM CampaignMember
    //         WHERE CampaignId = :camp1.Id
    //         LIMIT 1
    //     ];

    //     System.assert(member1.Is_Primary_Interest__c == true);
    //     System.assertEquals(camp1.Id, testLead.Primary_Interest__c);

    //     Test.startTest();
    //     delete member1;
    //     Test.stopTest();

    //     testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
    //     System.assertEquals(testLead.Primary_Interest__c, null);

    //     CampaignMember member2 = createCampaignMemberNoInsert(testLead, camp2.Id);
    //     System.assert(!member2.Is_Primary_Interest__c);

    //     insert member2;
    //     testLead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :testLead.Id];
    //     member2 = [
    //         SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId
    //         FROM CampaignMember
    //         WHERE CampaignId = :camp2.Id
    //         LIMIT 1
    //     ];

    //     System.assertEquals(testLead.Primary_Interest__c, camp2.Id);
    // }

    // Testing Scholarships
    @isTest
    private static void testOpportunityScholarshipAdd() {
        List<Contact> contactList = createContacts(2);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c : contactList) {
            contactIds.add(c.Id);
        }

        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, LastName, AccountId FROM Contact WHERE Id IN :contactIds];

        List<Opportunity> oppList = createOpportunities(contactList);
        insert oppList;

        Campaign camp = new Campaign(
            Name = 'National Achievement Finalist',
            Type = 'Scholarship - ASU',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Campaign', 'Scholarship'),
            IsActive = true
        );
        insert camp;

        List<CampaignMember> memberList = new List<CampaignMember>();
        for (Contact c : contactList) {
            memberList.add(createCampaignMemberNoInsert(c, camp.Id));
        }

        Test.startTest();
        insert memberList;
        Test.stopTest();

        List<Opportunity> newOppList = [
            SELECT Id, National_Merit_Semifinalist__c
            FROM Opportunity
            WHERE Contact__c IN :contactIds
        ];
        for (Opportunity o : newOppList) {
            System.assert(
                o.National_Merit_Semifinalist__c,
                'Opportunity National Merit Semifinalist was not set to true upon insert'
            );
        }
    }

    @isTest
    private static void insertContactPSMajorLoad() {
        List<Contact> contacts = createContacts(150);
        insert contacts;

        List<CampaignMember> members = new List<CampaignMember>();
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        for (Contact contact : contacts) {
            members.add(createCampaignMemberNoInsert(contact, camp.Id));
        }

        Test.startTest();
        insert members;
        Test.stopTest();

        members = [SELECT Is_Primary_Interest__c FROM CampaignMember WHERE CampaignId = :camp.Id];
        for (CampaignMember member : members) {
            System.assert(member.Is_Primary_Interest__c == true);
        }
    }

    @isTest
    private static void insertContactPSMajorExistingPSMajor() {
        //Inserting PSMajor CM w/ Contact, no preexisting Primary
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Contact contact = createContact();
        insert contact;

        CampaignMember member1 = createCampaignMember(contact, camp.Id);
        System.assert(!member1.Is_Primary_Interest__c);
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        System.assert(member1.Is_Primary_Interest__c);

        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update member1;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        System.assert(member1.Is_Primary_Interest__c);

        //Inserting PSMajor CM w/ Contact, preexisting PSMajor Primary
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');

        Test.startTest();
        CampaignMember member2 = createCampaignMember(contact, camp2.Id);
        Test.stopTest();

        System.assert(!member2.Is_Primary_Interest__c);
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(!member1.Is_Primary_Interest__c);
        System.assert(member2.Is_Primary_Interest__c);
    }

    @isTest
    private static void insertContactNonPSMajorExistingPSMajor() {
        //Inserting PSMajor CM w/ Contact, no preexisting Primary
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Contact contact = createContact();
        insert contact;

        CampaignMember member1 = createCampaignMember(contact, camp.Id);
        System.assert(!member1.Is_Primary_Interest__c);
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        System.assert(member1.Is_Primary_Interest__c);

        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update member1;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        System.assert(member1.Is_Primary_Interest__c);

        //Inserting Non-PSMajor Cm w/ Contact, preexisting PSMajor Primary
        Campaign camp2 = createCampaign('Test Non-PSMajor', 'Academic');

        Test.startTest();
        CampaignMember member2 = createCampaignMember(contact, camp2.Id);
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
    }

    @isTest
    private static void insertContactPSMajorExistingNonPSMajor() {
        //Inserting Non PSMajor CM w/ Contact, no preexisting Primary
        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember member1 = createCampaignMember(contact, camp.Id);
        System.assert(!member1.Is_Primary_Interest__c);
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        System.assert(member1.Is_Primary_Interest__c);

        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update member1;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        System.assert(member1.Is_Primary_Interest__c);

        //Inserting PSMajor CM w/ Contact, preexisting Non PSMajor Primary
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');

        Test.startTest();
        CampaignMember member2 = createCampaignMember(contact, camp2.Id);
        Test.stopTest();

        System.assert(!member2.Is_Primary_Interest__c);
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(!member1.Is_Primary_Interest__c);
        System.assert(member2.Is_Primary_Interest__c);
    }

    @isTest
    private static void insertContactNonPSMajorExistingNonPSMajor() {
        //Inserting Non PSMajor CM w/ Contact, no preexisting Primary
        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember member1 = createCampaignMember(contact, camp.Id);
        System.assert(!member1.Is_Primary_Interest__c);
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        System.assert(member1.Is_Primary_Interest__c);

        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update member1;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        System.assert(member1.Is_Primary_Interest__c);

        //Inserting Non PSMajor CM w/ Contact, preexisting Non PSMajor Primary
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');

        Test.startTest();
        CampaignMember member2 = createCampaignMember(contact, camp2.Id);
        Test.stopTest();

        System.assert(!member2.Is_Primary_Interest__c);
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(!member1.Is_Primary_Interest__c);
        System.assert(member2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateContactPSMajorNoPrimaryPreexisting() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(contact, camp2.Id);
        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        System.assert(!member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);

        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        insert membersToUpdate;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);

        //Updating Non PSMajor CM w/ Contact, no preexisting primary
        member1.Is_Primary_Interest__c = false;
        member2.Is_Primary_Interest__c = false;
        member1.Status = 'Required';
        member2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);

        Test.startTest();
        update membersToUpdate;
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateContactPSMajorNonPSMajorPrimaryPreexisting() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(contact, camp2.Id);
        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        insert membersToUpdate;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];

        //Updating Non PSMajor CM w/ Contact, no preexisting primary
        member1.Is_Primary_Interest__c = false;
        member1.Status = 'Required';
        member2.Is_Primary_Interest__c = true;
        member2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);

        Test.startTest();
        update membersToUpdate;
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
    }

    private static testMethod void updateContactPSMajorPSMajorPrimaryPreexisting() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
        Contact contact = createContact();
        insert contact;

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(contact, camp2.Id);
        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        insert membersToUpdate;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];

        member1.Status = 'Required';
        membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);

        Test.startTest();
        update membersToUpdate;
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateContactPSMajorPSMajorPrimaryPreexistingChangeStatus() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
        Contact contact = createContact();
        insert contact;

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(contact, camp2.Id);
        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);

        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        insert membersToUpdate;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];

        member2.Status = 'No Longer Interested';
        membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);

        Test.startTest();
        update membersToUpdate;
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateContactNonPSMajorNoPrimaryPreexisting() {
        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(contact, camp2.Id);
        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        insert membersToUpdate;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];

        member1.Is_Primary_Interest__c = false;
        member2.Is_Primary_Interest__c = false;
        member1.Status = 'Required';
        member2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);

        Test.startTest();
        update membersToUpdate;
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateContactNonPSMajorNonPSMajorPrimaryPreexisting() {
        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(contact, camp2.Id);
        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);

        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        insert membersToUpdate;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];

        member1.Status = 'Required';
        member2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);

        Test.startTest();
        update membersToUpdate;
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateContactNonPSMajorPSMajorPrimaryPreexisting() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Contact contact = createContact();
        insert contact;

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(contact, camp2.Id);
        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);

        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        insert membersToUpdate;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];

        //Updating Non PSMajor CM w/ Contact, PSMajor preexisting primary
        member2.Status = 'Required';
        membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);

        Test.startTest();
        update membersToUpdate;
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
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

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(contact, camp2.Id);
        CampaignMember member3 = createCampaignMemberNoInsert(contact, camp3.Id);
        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);

        System.assert(!member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
        System.assert(!member3.Is_Primary_Interest__c);
        System.assertEquals(null, opp.Primary_Interest__c);

        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        membersToUpdate.add(member3);

        insert membersToUpdate;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        member3 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member3.Id];
        opp = [SELECT Id, Primary_Interest__c FROM Opportunity WHERE Id = :opp.Id];

        System.assert(!member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
        System.assert(member3.Is_Primary_Interest__c);
        System.assertEquals(camp3.Id, opp.Primary_Interest__c);

        Test.startTest();
        delete member3;
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        opp = [SELECT Id, Primary_Interest__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
        System.assertEquals(camp.Id, opp.Primary_Interest__c);
    }

    @isTest
    private static void deleteContactPSMajorReassignNonPSMajor() {
        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');

        Contact contact = createContact();
        insert contact;

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(contact, camp2.Id);

        System.assert(!member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);

        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);

        insert membersToUpdate;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);

        Test.startTest();
        delete member1;
        Test.stopTest();

        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member2.Is_Primary_Interest__c);
    }

    @isTest
    private static void deleteContactNonPSMajorReassignNonPSMajor() {
        Contact contact = createContact();
        insert contact;

        Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Campaign camp3 = createCampaign('Test Non PSMajor 3', 'Academic');

        CampaignMember member1 = createCampaignMemberNoInsert(contact, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(contact, camp2.Id);
        CampaignMember member3 = createCampaignMemberNoInsert(contact, camp3.Id);
        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        member2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);

        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        membersToUpdate.add(member3);
        insert membersToUpdate;

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        member3 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member3.Id];

        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        member2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        update membersToUpdate;

        Test.startTest();
        delete member3;
        Test.stopTest();

        member1 = [
            SELECT Id, Status, Last_Member_Status_Change__c, Is_Primary_Interest__c
            FROM CampaignMember
            WHERE Id = :member1.Id
        ];
        member2 = [
            SELECT Id, Status, Last_Member_Status_Change__c, Is_Primary_Interest__c
            FROM CampaignMember
            WHERE Id = :member2.Id
        ];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
    }

    // @isTest
    // private static void insertLeadPSMajorExistingPSMajor() {
    //     //Inserting PSMajor CM w/ Lead, no preexisting Primary
    //     Lead lead = createLead();
    //     insert lead;

    //     Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
    //     CampaignMember member1 = createCampaignMember(lead, camp.Id);
    //     member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
    //     member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
    //     update member1;

    //     //Inserting PSMajor CM w/ Lead, preexisting PSMajor Primary
    //     Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');

    //     Test.startTest();
    //     CampaignMember member2 = createCampaignMember(lead, camp2.Id);
    //     Test.stopTest();

    //     System.assert(member2.Is_Primary_Interest__c == false);
    //     member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
    //     member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
    //     System.assert(member1.Is_Primary_Interest__c == false);
    //     System.assert(member2.Is_Primary_Interest__c == true);
    // }

    @isTest
    private static void insertLeadNonPSMajorExistingPSMajor() {
        //Inserting PSMajor CM w/ Lead, no preexisting Primary
        Lead lead = LeadService.createTestLead();
        insert lead;

        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        CampaignMember member1 = createCampaignMember(lead, camp.Id);
        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update member1;
        //Inserting Non-PSMajor Cm w/ Lead, preexisting PSMajor Primary
        Campaign camp2 = createCampaign('Test Non-PSMajor', 'Academic');

        Test.startTest();
        CampaignMember member2 = createCampaignMember(lead, camp2.Id);
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c == true);
        System.assert(member2.Is_Primary_Interest__c == false);
    }

    // @isTest
    // private static void insertLeadPSMajorExistingNonPSMajor() {
    //     //Inserting Non PSMajor CM w/ Lead, no preexisting Primary
    //     Lead lead = createLead();
    //     insert lead;

    //     Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
    //     CampaignMember member1 = createCampaignMember(lead, camp.Id);
    //     member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
    //     update member1;

    //     //Inserting PSMajor CM w/ Lead, preexisting Non PSMajor Primary
    //     Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');

    //     Test.startTest();
    //     CampaignMember member2 = createCampaignMember(lead, camp2.Id);
    //     Test.stopTest();

    //     System.assert(!member2.Is_Primary_Interest__c);
    //     member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
    //     member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
    //     System.assert(!member1.Is_Primary_Interest__c);
    //     System.assert(member2.Is_Primary_Interest__c);
    // }

    // @isTest
    // private static void insertLeadNonPSMajorExistingNonPSMajor() {
    //     //Inserting Non PSMajor CM w/ Lead, no preexisting Primary
    //     Lead lead = createLead();
    //     insert lead;

    //     Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
    //     CampaignMember member1 = createCampaignMember(lead, camp.Id);

    //     member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
    //     update member1;

    //     //Inserting Non PSMajor CM w/ Lead, preexisting Non PSMajor Primary
    //     Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');

    //     Test.startTest();
    //     CampaignMember member2 = createCampaignMember(lead, camp2.Id);
    //     Test.stopTest();

    //     System.assert(!member2.Is_Primary_Interest__c);
    //     member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
    //     member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
    //     System.assert(!member1.Is_Primary_Interest__c);
    //     System.assert(member2.Is_Primary_Interest__c);
    // }

    @isTest
    private static void updateLeadPSMajorNoPrimaryPreexisting() {
        Lead lead = createLead();
        insert lead;

        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        CampaignMember member1 = createCampaignMemberNoInsert(lead, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(lead, camp2.Id);

        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        insert membersToUpdate;

        //Updating Non PSMajor CM w/ Lead, no preexisting primary
        member1.Is_Primary_Interest__c = false;
        member2.Is_Primary_Interest__c = false;
        member1.Status = 'Required';
        member2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);

        Test.startTest();
        update membersToUpdate;
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
    }

    @isTest
    private static void updateLeadPSMajorNonPSMajorPrimaryPreexisting() {
        Lead lead = createLead();
        insert lead;

        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        CampaignMember member1 = createCampaignMemberNoInsert(lead, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(lead, camp2.Id);

        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        insert membersToUpdate;

        //Updating Non PSMajor CM w/ Lead, no preexisting primary
        member1.Is_Primary_Interest__c = false;
        member1.Status = 'Required';
        member2.Is_Primary_Interest__c = true;
        member2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
        membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);

        Test.startTest();
        update membersToUpdate;
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
    }

    // @isTest
    // private static void updateLeadPSMajorPSMajorPrimaryPreexisting() {
    //     Lead lead = createLead();
    //     insert lead;

    //     Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
    //     Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
    //     CampaignMember member1 = createCampaignMemberNoInsert(lead, camp.Id);
    //     CampaignMember member2 = createCampaignMemberNoInsert(lead, camp2.Id);

    //     member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
    //     List<CampaignMember> membersToUpdate = new List<CampaignMember>();
    //     membersToUpdate.add(member1);
    //     membersToUpdate.add(member2);
    //     insert membersToUpdate;
    //     member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
    //     member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];

    //     member1.Status = 'Required';
    //     membersToUpdate = new List<CampaignMember>();
    //     membersToUpdate.add(member1);
    //     membersToUpdate.add(member2);

    //     Test.startTest();
    //     update membersToUpdate;
    //     Test.stopTest();

    //     member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
    //     member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
    //     System.assert(member1.Is_Primary_Interest__c);
    //     System.assert(!member2.Is_Primary_Interest__c);
    // }

    // @isTest
    // private static void updateLeadNonPSMajorNoPrimaryPreexisting() {
    //     Lead lead = createLead();
    //     insert lead;

    //     Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
    //     Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
    //     CampaignMember member1 = createCampaignMemberNoInsert(lead, camp.Id);
    //     CampaignMember member2 = createCampaignMemberNoInsert(lead, camp2.Id);

    //     member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
    //     List<CampaignMember> membersToUpdate = new List<CampaignMember>();
    //     membersToUpdate.add(member1);
    //     membersToUpdate.add(member2);
    //     insert membersToUpdate;
    //     member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
    //     member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];

    //     member1.Is_Primary_Interest__c = false;
    //     member2.Is_Primary_Interest__c = false;
    //     member1.Status = 'Required';
    //     member2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
    //     membersToUpdate = new List<CampaignMember>();
    //     membersToUpdate.add(member1);
    //     membersToUpdate.add(member2);

    //     Test.startTest();
    //     update membersToUpdate;
    //     Test.stopTest();

    //     member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
    //     member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
    //     System.assert(member1.Is_Primary_Interest__c);
    //     System.assert(!member2.Is_Primary_Interest__c);
    // }

    // @isTest
    // private static void updateLeadNonPSMajorNonPSMajorPrimaryPreexisting() {
    //     Lead lead = createLead();
    //     insert lead;

    //     Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
    //     Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
    //     CampaignMember member1 = createCampaignMemberNoInsert(lead, camp.Id);
    //     CampaignMember member2 = createCampaignMemberNoInsert(lead, camp2.Id);

    //     member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
    //     List<CampaignMember> membersToUpdate = new List<CampaignMember>();
    //     membersToUpdate.add(member1);
    //     membersToUpdate.add(member2);
    //     insert membersToUpdate;
    //     member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
    //     member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];

    //     member1.Status = 'Required';
    //     member2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
    //     membersToUpdate = new List<CampaignMember>();
    //     membersToUpdate.add(member1);
    //     membersToUpdate.add(member2);

    //     Test.startTest();
    //     update membersToUpdate;
    //     Test.stopTest();

    //     member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
    //     member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
    //     System.assert(member1.Is_Primary_Interest__c);
    //     System.assert(!member2.Is_Primary_Interest__c);
    // }

    @isTest
    private static void updateLeadNonPSMajorPSMajorPrimaryPreexisting() {
        Lead lead = createLead();
        insert lead;

        Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        CampaignMember member1 = createCampaignMemberNoInsert(lead, camp.Id);
        CampaignMember member2 = createCampaignMemberNoInsert(lead, camp2.Id);

        member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);
        insert membersToUpdate;
        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];

        //Updating Non PSMajor CM w/ Lead, PSMajor preexisting primary
        member2.Status = 'Required';
        membersToUpdate = new List<CampaignMember>();
        membersToUpdate.add(member1);
        membersToUpdate.add(member2);

        Test.startTest();
        update membersToUpdate;
        Test.stopTest();

        member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
        member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
        System.assert(member1.Is_Primary_Interest__c);
        System.assert(!member2.Is_Primary_Interest__c);
    }

    // @isTest
    // private static void deleteLeadPSMajorReassignPSMajor() {
    //     Lead lead = createLead();
    //     insert lead;

    //     Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
    //     Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
    //     Campaign camp3 = createCampaign('Test PSMajor 3', 'PSMajors');
    //     CampaignMember member1 = createCampaignMemberNoInsert(lead, camp.Id);
    //     CampaignMember member2 = createCampaignMemberNoInsert(lead, camp2.Id);
    //     CampaignMember member3 = createCampaignMemberNoInsert(lead, camp3.Id);
    //     member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);

    //     List<CampaignMember> membersToUpdate = new List<CampaignMember>();
    //     membersToUpdate.add(member1);
    //     membersToUpdate.add(member2);
    //     membersToUpdate.add(member3);
    //     insert membersToUpdate;

    //     Test.startTest();
    //     delete member3;
    //     Test.stopTest();

    //     member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
    //     member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
    //     System.assert(member1.Is_Primary_Interest__c);
    //     System.assert(!member2.Is_Primary_Interest__c);
    // }

    // @isTest
    // private static void deleteLeadPSMajorReassignNonPSMajor() {
    //     Lead lead = createLead();
    //     insert lead;

    //     Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
    //     Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
    //     CampaignMember member1 = createCampaignMemberNoInsert(lead, camp.Id);
    //     CampaignMember member2 = createCampaignMemberNoInsert(lead, camp2.Id);

    //     List<CampaignMember> membersToUpdate = new List<CampaignMember>();
    //     membersToUpdate.add(member1);
    //     membersToUpdate.add(member2);
    //     insert membersToUpdate;

    //     Test.startTest();
    //     delete member1;
    //     Test.stopTest();

    //     member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
    //     System.assert(member2.Is_Primary_Interest__c);
    // }

    // @isTest
    // private static void deleteLeadNonPSMajorReassignNonPSMajor() {
    //     Lead lead = createLead();
    //     insert lead;
    //     lead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :lead.Id];
    //     System.assertEquals(null, lead.Primary_Interest__c);

    //     Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
    //     Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
    //     Campaign camp3 = createCampaign('Test Non PSMajor 3', 'Academic');
    //     CampaignMember member1 = createCampaignMemberNoInsert(lead, camp.Id);
    //     CampaignMember member2 = createCampaignMemberNoInsert(lead, camp2.Id);
    //     CampaignMember member3 = createCampaignMemberNoInsert(lead, camp3.Id);

    //     member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
    //     member2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
    //     List<CampaignMember> membersToUpdate = new List<CampaignMember>();
    //     membersToUpdate.add(member1);
    //     membersToUpdate.add(member2);
    //     membersToUpdate.add(member3);
    //     insert membersToUpdate;

    //     member1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member1.Id];
    //     member2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member2.Id];
    //     member3 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :member3.Id];

    //     member1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
    //     member2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
    //     membersToUpdate = new List<CampaignMember>();
    //     membersToUpdate.add(member1);
    //     membersToUpdate.add(member2);
    //     update membersToUpdate;

    //     Test.startTest();
    //     delete member3;
    //     Test.stopTest();

    //     member1 = [
    //         SELECT Id, Status, Last_Member_Status_Change__c, Is_Primary_Interest__c
    //         FROM CampaignMember
    //         WHERE Id = :member1.Id
    //     ];
    //     member2 = [
    //         SELECT Id, Status, Last_Member_Status_Change__c, Is_Primary_Interest__c
    //         FROM CampaignMember
    //         WHERE Id = :member2.Id
    //     ];
    //     lead = [SELECT Id, Primary_Interest__c FROM Lead WHERE Id = :lead.Id];
    //     System.assert(member1.Is_Primary_Interest__c);
    //     System.assert(!member2.Is_Primary_Interest__c);
    //     System.assertEquals(camp.Id, lead.Primary_Interest__c);
    // }

    @isTest
    private static void mostRecentOppportunityAssigned() {
        insert createContacts(6);
        List<Contact> testContacts = [SELECT LastName, AccountId FROM Contact];

        List<Opportunity> testOpportunities = new List<Opportunity>();
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

        List<CampaignMember> postTestMembers = [SELECT Opportunity__c FROM CampaignMember];

        System.assertEquals(testOpportunities[0].Id, postTestMembers[0].Opportunity__c);
        System.assertEquals(testOpportunities[1].Id, postTestMembers[1].Opportunity__c);
    }

    @isTest
    private static void closedOpportunitiesAreNotAssigned() {
        insert createContacts(6);
        List<Contact> testContacts = [SELECT LastName, AccountId FROM Contact];

        List<Opportunity> testOpportunities = new List<Opportunity>();
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

        List<CampaignMember> postTestMembers = [SELECT Opportunity__c FROM CampaignMember];

        Map<Id, Opportunity> closedOpps = new Map<Id, Opportunity>([SELECT IsClosed FROM Opportunity]);

        System.assert(closedOpps.get(testOpportunities[testOpportunities.size() - 2].Id).IsClosed);
        System.assert(closedOpps.get(testOpportunities[testOpportunities.size() - 1].Id).IsClosed);
        System.assertNotEquals(testOpportunities[testOpportunities.size() - 2].Id, postTestMembers[0].Opportunity__c);
        System.assertNotEquals(testOpportunities[testOpportunities.size() - 1].Id, postTestMembers[1].Opportunity__c);
        System.assertEquals(testOpportunities[0].Id, postTestMembers[0].Opportunity__c);
        System.assertEquals(testOpportunities[1].Id, postTestMembers[1].Opportunity__c);
    }

    @isTest
    private static void noOpportunityAssignedIfAllClosed() {
        insert createContacts(20);
        List<Contact> testContacts = [SELECT LastName, AccountId FROM Contact];

        List<Opportunity> testOpportunities = new List<Opportunity>();
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

        List<CampaignMember> postTestMembers = [SELECT Opportunity__c FROM CampaignMember];

        Map<Id, Opportunity> closedOpps = new Map<Id, Opportunity>(
            [SELECT IsClosed FROM Opportunity WHERE IsClosed = TRUE]
        );

        System.assertEquals(testOpportunities.size(), closedOpps.size());
        System.assertEquals(null, postTestMembers[0].Opportunity__c);
        System.assertEquals(null, postTestMembers[1].Opportunity__c);
    }
}
