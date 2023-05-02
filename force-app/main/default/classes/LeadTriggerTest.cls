@isTest
public with sharing class LeadTriggerTest {
    static Integer TRIGGERLOAD = 5;

    @testSetup
    static void setup() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User testUser = (User) userCreator.create(1)[0];

        Id saProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        testUser.ProfileId = saProfile;

        insert testUser;
    }

    // Build Leads
    static List<Lead> createLeads(Integer quantity) {
        List<Lead> leadList = new List<Lead>();

        for (Integer i = 0; i < quantity; i++) {
            Lead l = new Lead(
                LastName = 'LName' + i,
                FirstName = 'FName' + i,
                Company = 'Company',
                Email = 'test' + i + '@test.test',
                LeadSource = 'Email'
            );
            leadList.add(l);
        }

        return leadList;
    }

    static Id insertProgram(String programName, String programCode) {
        Program__c testProgram = new Program__c(Name = programName, Program_Code__c = programCode);
        insert testProgram;
        return testProgram.Id;
    }

    static Id insertPlan(String planName, String planCode, Id programId) {
        Plan__c testPlan = new Plan__c(
            Name = planName,
            Plan_Code__c = planCode,
            Plan_Effective_Date__c = Date.today(),
            Program__c = programId
        );
        insert testPlan;
        return testPlan.Id;
    }

    @isTest
    static void testManualLeadConversion() {
        Lead[] leadList = createLeads(TRIGGERLOAD);
        insert leadList;

        Set<Id> leadIds = new Set<Id>();

        // Perform Conversion
        for (Lead l : leadList) {
            l.Convert_Perform_Conversion__c = true;
            leadIds.add(l.Id);
        }

        Test.startTest();
        update leadList;
        Test.stopTest();

        //Check conversion results
        List<Lead> convertedLeads = new List<Lead>([SELECT Id FROM Lead WHERE Id IN :leadIds AND IsConverted = TRUE]);

        System.assertEquals(TRIGGERLOAD, convertedLeads.size());
    }

    @isTest
    static void testConvertMultipleLeadsToOneAccount() {
        Integer DUPETHRESHOLD = 1;

        List<Account> institutionAccounts = new AccountFactory.Institution().create();
        insert institutionAccounts;

        List<Contact> testContacts = ContactService.createTestContacts(TRIGGERLOAD);
        insert testContacts;

        List<Lead> testLeads = LeadService.createTestLeadsToConvert(testContacts);
        insert testLeads;

        testContacts = [SELECT Name, FirstName, LastName, Email, AccountId FROM Contact];

        List<Opportunity> testOpptys = OpportunityService.createTestUndergraduateProspects(testContacts);
        insert testOpptys;

        Set<Id> leadIds = new Set<Id>();

        // Peform conversion
        for (Lead l : testLeads) {
            l.Convert_Perform_Conversion__c = true;
            l.Last_Institution_Attended__c = institutionAccounts[0].Id;
            leadIds.add(l.Id);
        }

        // Create duplicates
        for (Integer i = 1; i < DUPETHRESHOLD; i++) {
            testLeads.get(i).Convert_Contact__c = testContacts.get(0).Id;
        }

        Test.startTest();
        update testLeads;
        Test.stopTest();

        //Check conversion results
        List<Lead> convertedLeads = new List<Lead>([SELECT Id FROM Lead WHERE Id IN :leadIds AND IsConverted = TRUE]);

        System.assertEquals(TRIGGERLOAD, convertedLeads.size(), 'Leads were not converted correctly');
    }

    @isTest
    static void testLeadToOppFieldMapping() {
        Term__c testTerm = TermService.createTestTerm();
        insert testTerm;

        List<Contact> testContacts = ContactService.createTestContacts(10);
        insert testContacts;

        testContacts = [SELECT Name, FirstName, LastName, Email, AccountId FROM Contact];

        List<Opportunity> testOpptys = OpportunityService.createTestUndergraduateProspects(testContacts);
        insert testOpptys;

        List<Lead> testLeads = LeadService.createTestLeadsToConvert(testContacts);

        for (Lead l : testLeads) {
            l.Enrollment_Term__c = testTerm.Id;
        }

        insert testLeads;

        Set<Id> leadIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        // Perform conversion
        for (Lead l : testLeads) {
            l.Convert_Perform_Conversion__c = true;
            leadIds.add(l.Id);
            contactIds.add(l.Convert_Contact__c);
        }

        Test.startTest();
        update testLeads;
        Test.stopTest();

        List<Opportunity> oppsCreated = [
            SELECT
                Contact__c,
                Career__c,
                Term__c,
                Online_Degree__c,
                International_Student__c,
                First_Generation__c,
                Potential_National_Scholar__c,
                Potential_WUE__c,
                Search_Segment__c,
                Self_Reported_SES__c,
                Military_Status__c
            FROM Opportunity
            WHERE Contact__c IN :contactIds
        ];

        Lead expectedData = testLeads.get(0);
        Opportunity actualData = oppsCreated.get(0);

        System.assertEquals(
            expectedData.Convert_Contact__c,
            actualData.Contact__c,
            'Contact was not associated correctly'
        );
    }

    @isTest
    static void testCreationOfPERecordsOnConversion() {
        List<Account> institutionAccounts = new AccountFactory.Institution().create();
        insert institutionAccounts;

        List<Contact> testContacts = ContactService.createTestContacts(5);
        insert testContacts;

        testContacts = [SELECT Name, FirstName, LastName, Email, AccountId FROM Contact];

        List<Opportunity> testOpptys = OpportunityService.createTestUndergraduateProspects(testContacts);
        insert testOpptys;

        List<Lead> testLeads = LeadService.createTestLeadsToConvert(testContacts);
        insert testLeads;

        Set<Id> leadIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        // Perform conversion
        for (Lead l : testLeads) {
            l.Convert_Perform_Conversion__c = true;
            l.Last_Institution_Attended__c = institutionAccounts[0].Id;
            leadIds.add(l.Id);
            contactIds.add(l.Convert_Contact__c);
        }

        Test.startTest();
        update testLeads;
        Test.stopTest();

        List<Previous_Education__c> peRecordsCreated = [
            SELECT Account__c
            FROM Previous_Education__c
            WHERE Contact__c IN :contactIds
        ];

        for (Previous_Education__c pe : peRecordsCreated) {
            System.assertEquals(
                institutionAccounts[0].Id,
                pe.Account__c,
                'Previous Education was not created correctly'
            );
        }
    }

    @isTest
    public static void testLeadFreshmanScholar() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        List<Lead> leadList = new List<Lead>();

        for (Integer i = 0; i < 1; i++) {
            Lead l = new Lead(
                LastName = 'LName' + i,
                FirstName = 'FName' + i,
                Company = 'Company',
                Email = 'test' + i + '@test.test',
                LeadSource = 'Email',
                Potential_National_Scholar__c = true,
                Type__c = 'First Time Freshman'
            );
            leadList.add(l);
        }

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Freshman Scholar';
        aTar1.User__c = TestUser.Id;
        aTar1.Opportunity_Type__c = 'Freshman Scholar';
        insert aTar1;

        Test.startTest();
        insert leadList;

        Test.stopTest();

        List<Lead> newLeadList = new List<Lead>(
            [SELECT Id, Type__c, Territory_Assignment_Last_Rule_Type__c FROM Lead WHERE Id = :leadList[0].Id LIMIT 1]
        );

        System.Assert(
            newLeadList[0].Territory_Assignment_Last_Rule_Type__c == 'Freshman Scholar',
            'Rule did not assign correctly by rule type Freshman Scholar'
        );
    }

    @isTest
    public static void testLeadInternational() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        List<Lead> leadList = new List<Lead>();

        for (Integer i = 0; i < 1; i++) {
            Lead l = new Lead(
                LastName = 'LName' + i,
                FirstName = 'FName' + i,
                Company = 'Company',
                Email = 'test' + i + '@test.test',
                LeadSource = 'Email',
                Type__c = 'First Time Freshman',
                International_Student__c = true
            );
            leadList.add(l);
        }

        Territory_Assignment_Rule__c ATar1 = new Territory_Assignment_Rule__c();
        ATar1.Rule_Type__c = 'International';
        ATar1.User__c = TestUser.Id;
        insert ATar1;

        Test.startTest();
        insert leadList;

        Test.stopTest();

        List<Lead> newLeadList = new List<Lead>(
            [SELECT Id, Type__c, Territory_Assignment_Last_Rule_Type__c FROM Lead WHERE Id = :leadList[0].Id LIMIT 1]
        );

        System.Assert(
            newLeadList[0].Territory_Assignment_Last_Rule_Type__c == 'International||',
            'Rule did not assign correctly by rule type Default User: ' +
            newLeadList[0].Territory_Assignment_Last_Rule_Type__c
        );
    }

    @isTest
    public static void testLeadLastInstitution() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Key_Value__c KVHS = new Key_Value__c();
        KVHS.Geomarket_ZIP__c = '84108';
        KVHS.Geomarket_Code__c = 'UT-01';
        insert KVHS;

        Account HS = new Account();
        HS.Name = 'Test High School';
        HS.ShippingPostalCode = '84108';
        HS.Geomarket_Code__c = 'UT-01';
        HS.Institution_Type__c = 'HS';
        HS.Territory_Manager__c = TestUser.Id;
        insert HS;

        List<Lead> leadList = new List<Lead>();

        for (Integer i = 0; i < 1; i++) {
            Lead l = new Lead(
                LastName = 'LName' + i,
                FirstName = 'FName' + i,
                Company = 'Company',
                Email = 'test' + i + '@test.test',
                LeadSource = 'Email',
                Type__c = 'First Time Freshman',
                Last_Institution_Attended__c = HS.id
            );
            leadList.add(l);
        }

        Test.startTest();
        insert leadList;

        Test.stopTest();

        List<Lead> newLeadList = new List<Lead>(
            [
                SELECT Id, Type__c, Territory_Assignment_Last_Rule_Type__c, OwnerId
                FROM Lead
                WHERE Id = :leadList[0].Id
                LIMIT 1
            ]
        );

        System.Assert(
            newLeadList[0].Territory_Assignment_Last_Rule_Type__c == 'Last Institution Attended',
            'Rule did not assign correctly by rule type Last Institution Attended'
        );
        System.Assert(
            newLeadList[0].OwnerId == testUser.Id,
            'Territory Assignment did not assign Owner correctly for Lead/Last Institution'
        );
    }

    @isTest
    public static void testLeadState() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'State';
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        aTar1.Assignment_By_State__c = 'Texas';
        aTar1.User__c = TestUser.Id;
        insert aTar1;

        List<Lead> leadList = new List<Lead>();

        for (Integer i = 0; i < 1; i++) {
            Lead l = new Lead(
                LastName = 'LName' + i,
                FirstName = 'FName' + i,
                Company = 'Company',
                State = 'Texas',
                Country = 'United States',
                Email = 'test' + i + '@test.test',
                LeadSource = 'Email',
                Type__c = 'First Time Freshman'
            );
            leadList.add(l);
        }

        Test.startTest();
        insert leadList;

        Test.stopTest();

        List<Lead> newLeadList = new List<Lead>(
            [
                SELECT Id, Type__c, OwnerId, Territory_Assignment_Last_Rule_Type__c
                FROM Lead
                WHERE Id = :leadList[0].Id
                LIMIT 1
            ]
        );

        System.Assert(
            newLeadList[0].Territory_Assignment_Last_Rule_Type__c == 'State, Type ' + leadList[0].Type__c,
            'Rule did not assign correctly by rule type Lead/State'
        );
    }

    @isTest
    public static void testLeadDefaultUser() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        List<Lead> leadList = new List<Lead>();

        for (Integer i = 0; i < 1; i++) {
            Lead l = new Lead(
                LastName = 'LName' + i,
                FirstName = 'FName' + i,
                Company = 'Company',
                Email = 'test' + i + '@test.test',
                LeadSource = 'Email',
                Type__c = 'First Time Freshman'
            );
            leadList.add(l);
        }

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Default User';
        aTar1.User__c = TestUser.Id;
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        insert aTar1;

        Test.startTest();
        insert leadList;

        Test.stopTest();

        List<Lead> newLeadList = new List<Lead>(
            [SELECT Id, Type__c, Territory_Assignment_Last_Rule_Type__c FROM Lead WHERE Id = :leadList[0].Id LIMIT 1]
        );

        System.Assert(
            newLeadList[0].Territory_Assignment_Last_Rule_Type__c == 'Default User',
            'Rule did not assign correctly by rule type Default User'
        );
    }

    @isTest
    public static void testLeadUpdate() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        List<User> testUsers = userCreator.create(2);
        Id saProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        for (User u : testUsers) {
            u.ProfileId = saProfile;
            u.UserName += 'leadUpdate';
            u.CommunityNickname += 'leadUpdate';
        }

        insert testUsers;

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Default User';
        aTar1.User__c = testUsers[0].Id;
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        insert aTar1;

        Territory_Assignment_Rule__c aTar2 = new Territory_Assignment_Rule__c();
        aTar2.Rule_Type__c = 'International';
        aTar2.User__c = testUsers[1].Id;
        insert aTar2;

        Lead l = new Lead(
            LastName = 'LName',
            FirstName = 'FName',
            Company = 'Company',
            Email = 'test@test.test',
            LeadSource = 'Email',
            Type__c = 'First Time Freshman'
        );
        insert l;

        Test.startTest();
        // Force an update to run on lead
        TerritoryAssignmentLead.assignTerritoryDone = false;

        Lead updatedLead = [SELECT Id FROM Lead WHERE Id = :l.Id];
        updatedLead.International_Student__c = true;

        update updatedLead;

        Test.stopTest();

        updatedLead = [SELECT OwnerId FROM Lead WHERE Id = :updatedLead.Id];

        System.assertEquals(
            testUsers[1].Id,
            updatedLead.OwnerId,
            'Rule did not assign correctly when changing relevant fields'
        );
    }
}