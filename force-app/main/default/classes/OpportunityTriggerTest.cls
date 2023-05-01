@isTest
public with sharing class OpportunityTriggerTest {
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
            // Plan_Status__c = 'Active',
            Plan_Effective_Date__c = Date.today(),
            Program__c = programId
        );

        insert testPlan;
        return testPlan.Id;
    }

    //Convert Leads and create Opportunities
    static testMethod void testOpportunityTrigger() {
        List<Contact> contacts = ContactService.createTestContacts(TRIGGERLOAD);
        insert contacts;

        List<Lead> leadList = LeadService.createTestLeadsToConvert(contacts);
        insert leadList;

        Set<Id> leadIds = new Set<Id>();

        // Perform Conversion
        for (Lead l : leadList) {
            l.Convert_Perform_Conversion__c = true;
            l.Convert_Create_Opportunity__c = true;
            leadIds.add(l.Id);
        }

        Test.startTest();
        update leadList;
        Test.stopTest();

        List<Lead> checkLeads = new List<Lead>([SELECT ConvertedContactID FROM Lead WHERE Id IN :leadIds]);

        Set<Id> contactIds = new Set<Id>();

        for (Lead l : checkLeads) {
            contactIds.add(l.ConvertedContactId);
        }

        // Confirm that Opps were created during lead conversion
        List<Opportunity> oppList = new List<Opportunity>(
            [SELECT Id, contact__c FROM Opportunity WHERE contact__c IN :contactIds]
        );

        System.assertEquals(opplist.size(), leadList.size());
    }

    // Validate that Contacts were updated on Opps (contact__c field)
    static testMethod void testCollegeFieldInsert() {
        List<Contact> contacts = ContactService.createTestContacts(TRIGGERLOAD);
        insert contacts;

        contacts = [SELECT AccountId, Name FROM Contact];

        List<Opportunity> opps = OpportunityService.createTestUndergraduateProspects(contacts);

        Id program1 = insertProgram('Test Program 1', '12345');
        Id program2 = insertProgram('Test Program 2', '23456');
        Id academicPlan1 = insertPlan('Academic Plan 1', '12345', program1);
        Id admittedPlan1 = insertPlan('Admitted Plan 1', '23456', program2);

        opps.get(0).Admitted_Plan__c = admittedPlan1;
        opps.get(1).Academic_Plan__c = academicPlan1;
        opps.get(2).Admitted_Plan__c = admittedPlan1;
        opps.get(2).Academic_Plan__c = academicPlan1;
        opps.get(3).Academic_Plan__c = academicPlan1;
        opps.get(3).College__c = program2;

        Test.startTest();
        insert opps;
        Test.stopTest();

        Opportunity o1 = opps[0];
        Opportunity o2 = opps[1];
        Opportunity o3 = opps[2];
        Opportunity o4 = opps[3];

        System.assert(opps.get(0).College__c == null);
        o1 = [SELECT College__c FROM Opportunity WHERE Id = :o1.Id];
        System.assert(o1.College__c == program2);

        System.assert(opps.get(1).College__c == null);
        o2 = [SELECT College__c FROM Opportunity WHERE Id = :o2.Id];
        System.assert(o2.College__c == program1);

        System.assert(opps.get(2).College__c == null);
        o3 = [SELECT College__c FROM Opportunity WHERE Id = :o3.Id];
        System.assert(o3.College__c == program2);

        System.assert(opps.get(3).College__c == program2);
        o4 = [SELECT College__c FROM Opportunity WHERE Id = :o4.Id];
        System.assert(o4.College__c == program1);

        o1.Name = 'Opportunity Update';
        update o1;
        o1 = [SELECT College__c FROM Opportunity WHERE Id = :o1.Id];
        System.assert(o1.College__c == program2);

        o2.Admitted_Plan__c = null;
        update o2;
        o2 = [SELECT College__c FROM Opportunity WHERE Id = :o2.Id];
        System.assert(o2.College__c == program1);
    }

    static testMethod void testCollegeFieldUpdate() {
        List<Contact> contacts = ContactService.createTestContacts(TRIGGERLOAD);
        insert contacts;

        contacts = [SELECT AccountId, Name FROM Contact];

        List<Opportunity> opps = OpportunityService.createTestUndergraduateProspects(contacts);
        insert opps;

        Opportunity o1 = opps[0];
        Opportunity o2 = opps[1];
        Opportunity o3 = opps[2];

        Id program1 = insertProgram('Test Program 1', '12345');
        Id program2 = insertProgram('Test Program 2', '23456');
        Id academicPlan1 = insertPlan('Academic Plan 1', '12345', program1);
        Id admittedPlan1 = insertPlan('Admitted Plan 1', '23456', program2);

        Test.startTest();
        o1.Academic_Plan__c = academicPlan1;
        System.assert(o1.College__c == null);
        update o1;
        Test.stopTest();

        o1 = [SELECT College__c FROM Opportunity WHERE Id = :o1.Id];
        System.assert(o1.College__c == program1);

        o2.Admitted_Plan__c = admittedPlan1;
        System.assert(o2.College__c == null);
        update o2;
        o2 = [SELECT College__c FROM Opportunity WHERE Id = :o2.Id];
        System.assert(o2.College__c == program2);

        o3.Admitted_Plan__c = admittedPlan1;
        System.assert(o3.College__c == null);
        update o3;
        o3 = [SELECT College__c FROM Opportunity WHERE Id = :o3.Id];
        System.assert(o3.College__c == program2);

        o1.Name = 'Opportunity Update';
        update o1;
        o1 = [SELECT College__c FROM Opportunity WHERE Id = :o1.Id];
        System.assert(o1.College__c == program1);

        o2.Admitted_Plan__c = null;
        update o2;
        o2 = [SELECT College__c FROM Opportunity WHERE Id = :o2.Id];
        System.assert(o2.College__c == program2);
    }

    @isTest
    public static void testFreshmanScholar() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        insert con;

        con = [SELECT Id, AccountId FROM Contact WHERE Id = :con.Id];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Freshman Scholar';
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        aTar1.User__c = TestUser.Id;
        insert aTar1;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.StageName = 'Prospect';
        opp.Type = 'test';
        opp.Career__c = 'Undergraduate';
        opp.CloseDate = date.today() + 365;
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;
        insert opp;

        Test.startTest();
        opp.Type = 'First Time Freshman';
        opp.Potential_National_Scholar__c = true;
        update opp;

        Test.stopTest();

        String lastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;
        System.Assert(
            lastRuleType == 'Freshman Scholar',
            'Rule did not assign correctly by rule type Freshman Scholar: ' + lastRuleType
        );
    }

    @isTest
    public static void testGraduateOpportunity() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        List<Contact> testContacts = ContactService.createTestContacts(1);

        insert testContacts;

        Contact con = [SELECT Id, AccountId FROM Contact WHERE Id = :testContacts[0].Id];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'International';
        aTar1.International__c = true;
        aTar1.User__c = testUser.Id;
        insert aTar1;

        Test.startTest();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.StageName = 'Prospect';
        opp.Type = 'First Time Freshman';
        opp.Career__c = 'Graduate';
        opp.CloseDate = date.today() + 365;
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;
        insert opp;

        Id originalOwner = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id].Id;

        opp.International_Student__c = true;
        update opp;

        Test.stopTest();

        opp = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id];

        System.assertNotEquals(
            originalOwner,
            testUser.Id,
            'Territory assignment occurred on insert for Graduate opportunity'
        );
        System.assertNotEquals(
            opp.OwnerId,
            testUser.Id,
            'Territory assignment occurred on update for Graduate opportunity'
        );
    }

    @isTest
    public static void testInternational() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        insert con;

        con = [SELECT Id, AccountId FROM Contact WHERE Id = :con.Id];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'International';
        aTar1.International__c = true;
        aTar1.User__c = TestUser.Id;
        insert aTar1;
        String tarRuleKey = [SELECT Rule_Key__c FROM Territory_Assignment_Rule__c WHERE Id = :aTar1.Id].Rule_Key__c;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.StageName = 'Prospect';
        opp.Career__c = 'Undergraduate';
        opp.Type = 'First Time Freshman';
        opp.CloseDate = date.today() + 365;
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;
        insert opp;

        Test.startTest();
        opp.International_Student__c = true;
        update opp;

        Test.stopTest();

        String lastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;

        System.Assert(lastRuleType == tarRuleKey, 'Rule did not assign correctly by rule type International');
    }

    @isTest
    public static void testInternationalChina() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        List<User> chinaManagers = userCreator.create(2);
        Id saProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        for (User u : chinaManagers) {
            u.ProfileId = saProfile;
            u.UserName += 'China';
            u.CommunityNickname += 'China';
        }

        insert chinaManagers;

        PS_Country_Map__c chinaMap = new PS_Country_Map__c();
        chinaMap.Name = 'China';
        chinaMap.PS_Country_Code__c = 'CHN';
        chinaMap.Country_Name__c = 'China';
        chinaMap.Integration_Value__c = 'China';
        chinaMap.Country_Code__c = 'CN';
        insert chinaMap;

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'International';
        aTar1.International__c = true;
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        aTar1.Assignment_By_Country__c = 'China';
        aTar1.Range_Start__c = 1;
        aTar1.Range_End__c = 50;
        aTar1.User__c = chinaManagers[0].Id;
        insert aTar1;

        Territory_Assignment_Rule__c aTar2 = new Territory_Assignment_Rule__c();
        aTar2.Rule_Type__c = 'International';
        aTar2.International__c = true;
        aTar2.Opportunity_Type__c = 'First Time Freshman';
        aTar2.Assignment_By_Country__c = 'China';
        aTar2.Range_Start__c = 51;
        aTar2.Range_End__c = 100;
        aTar2.User__c = chinaManagers[1].Id;
        insert aTar2;

        List<Contact> testContacts = ContactService.createTestContacts(2);

        for (Contact con : testContacts) {
            con.MailingCountry = 'China';
        }

        insert testContacts;

        Contact chinaContact1 = [SELECT Id, AccountId FROM Contact WHERE Id = :testContacts[0].Id];
        Contact chinaContact2 = [SELECT Id, AccountId FROM Contact WHERE Id = :testContacts[1].Id];

        Opportunity chinaOpp1 = new Opportunity();
        chinaOpp1.Name = 'China Opportunity 1';
        chinaOpp1.StageName = 'Prospect';
        chinaOpp1.Type = 'First Time Freshman';
        chinaOpp1.Career__c = 'Undergraduate';
        chinaOpp1.CloseDate = Date.today() + 365;
        chinaOpp1.Contact__c = chinaContact1.Id;
        chinaOpp1.AccountId = chinaContact1.AccountId;
        insert chinaOpp1;

        Opportunity chinaOpp2 = new Opportunity();
        chinaOpp2.Name = 'China Opportunity 2';
        chinaOpp2.StageName = 'Prospect';
        chinaOpp2.Type = 'First Time Freshman';
        chinaOpp2.Career__c = 'Undergraduate';
        chinaOpp2.CloseDate = Date.today() + 365;
        chinaOpp2.Contact__c = chinaContact2.Id;
        chinaOpp2.AccountId = chinaContact2.AccountId;
        insert chinaOpp2;

        Test.startTest();
        chinaOpp1.Opportunity_Assignment_Number_Rand__c = 25;
        chinaOpp1.International_Student__c = true;

        chinaOpp2.Opportunity_Assignment_Number_Rand__c = null;
        chinaOpp2.International_Student__c = true;

        update chinaOpp1;
        update chinaOpp2;

        Test.stopTest();

        chinaOpp1 = [SELECT OwnerId FROM Opportunity WHERE Name = 'China Opportunity 1'];

        System.assertEquals(
            chinaManagers[0].Id,
            chinaOpp1.OwnerId,
            'Rule did not assign correct China territory manager.'
        );

        chinaOpp2 = [
            SELECT OwnerId, Opportunity_Assignment_Number__c
            FROM Opportunity
            WHERE Name = 'China Opportunity 2'
        ];

        if (chinaOpp2.Opportunity_Assignment_Number__c <= aTar1.Range_End__c) {
            System.assertEquals(
                chinaManagers[0].Id,
                chinaOpp2.OwnerId,
                'Rule did not assign correct China territory manager.'
            );
        } else {
            System.assertEquals(
                chinaManagers[1].Id,
                chinaOpp2.OwnerId,
                'Rule did not assign correct China territory manager.'
            );
        }
    }

    @isTest
    public static void testInternationalUnitedStates() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        List<User> usManagers = userCreator.create(2);
        Id saProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        for (User u : usManagers) {
            u.ProfileId = saProfile;
            u.UserName += 'US';
            u.CommunityNickname += 'US';
        }

        insert usManagers;

        PS_Country_Map__c usMap = new PS_Country_Map__c();
        usMap.Name = 'United States';
        usMap.PS_Country_Code__c = 'USA';
        usMap.Country_Name__c = 'United States';
        usMap.Integration_Value__c = 'United States';
        usMap.Country_Code__c = 'CN';
        insert usMap;

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'International';
        aTar1.International__c = true;
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        aTar1.Assignment_By_Country__c = 'United States';
        aTar1.Range_Start__c = 1;
        aTar1.Range_End__c = 50;
        aTar1.User__c = usManagers[0].Id;
        insert aTar1;

        Territory_Assignment_Rule__c aTar2 = new Territory_Assignment_Rule__c();
        aTar2.Rule_Type__c = 'International';
        aTar2.International__c = true;
        aTar2.Opportunity_Type__c = 'First Time Freshman';
        aTar2.Assignment_By_Country__c = 'United States';
        aTar2.Range_Start__c = 51;
        aTar2.Range_End__c = 100;
        aTar2.User__c = usManagers[1].Id;
        insert aTar2;

        List<Contact> testContacts = ContactService.createTestContacts(2);

        for (Contact con : testContacts) {
            con.MailingCountry = 'United States';
        }

        insert testContacts;

        Contact usContact1 = [SELECT Id, AccountId FROM Contact WHERE Id = :testContacts[0].Id];
        Contact usContact2 = [SELECT Id, AccountId FROM Contact WHERE Id = :testContacts[1].Id];

        Opportunity usOpp1 = new Opportunity();
        usOpp1.Name = 'US Opportunity 1';
        usOpp1.StageName = 'Prospect';
        usOpp1.Type = 'First Time Freshman';
        usOpp1.CloseDate = Date.today() + 365;
        usOpp1.Career__c = 'Undergraduate';
        usOpp1.Contact__c = usContact1.Id;
        usOpp1.AccountId = usContact1.AccountId;
        insert usOpp1;

        Opportunity usOpp2 = new Opportunity();
        usOpp2.Name = 'US Opportunity 2';
        usOpp2.StageName = 'Prospect';
        usOpp2.Type = 'First Time Freshman';
        usOpp2.CloseDate = Date.today() + 365;
        usOpp2.Career__c = 'Undergraduate';
        usOpp2.Contact__c = usContact2.Id;
        usOpp2.AccountId = usContact2.AccountId;
        insert usOpp2;

        Test.startTest();
        usOpp1.Opportunity_Assignment_Number_Rand__c = 25;
        usOpp1.International_Student__c = true;

        usOpp2.Opportunity_Assignment_Number_Rand__c = null;
        usOpp2.International_Student__c = true;

        update usOpp1;
        update usOpp2;

        Test.stopTest();

        usOpp1 = [SELECT OwnerId FROM Opportunity WHERE Name = 'US Opportunity 1'];

        System.assertEquals(usManagers[0].Id, usOpp1.OwnerId, 'Rule did not assign correct US territory manager.');

        usOpp2 = [SELECT OwnerId, Opportunity_Assignment_Number__c FROM Opportunity WHERE Name = 'US Opportunity 2'];

        if (usOpp2.Opportunity_Assignment_Number__c <= aTar1.Range_End__c) {
            System.assertEquals(usManagers[0].Id, usOpp2.OwnerId, 'Rule did not assign correct US territory manager.');
        } else {
            System.assertEquals(usManagers[1].Id, usOpp2.OwnerId, 'Rule did not assign correct US territory manager.');
        }
    }

    @isTest
    public static void testInternationalTransfer() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        List<User> transferManagers = userCreator.create(2);
        Id saProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        for (User u : transferManagers) {
            u.ProfileId = saProfile;
            u.UserName += 'tManagers';
            u.CommunityNickname += 'tManagers';
        }

        insert transferManagers;

        PS_Country_Map__c vietnamMap = new PS_Country_Map__c();
        vietnamMap.Name = 'Vietnam';
        vietnamMap.PS_Country_Code__c = 'VNM';
        vietnamMap.Country_Name__c = 'Viet Nam';
        vietnamMap.Integration_Value__c = 'Vietnam';
        vietnamMap.Country_Code__c = 'VN';
        insert vietnamMap;

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'International';
        aTar1.International__c = true;
        aTar1.Opportunity_Type__c = 'Transfer';
        aTar1.Assignment_By_Country__c = 'Viet Nam';
        aTar1.User__c = transferManagers[0].Id;
        insert aTar1;

        Territory_Assignment_Rule__c aTar2 = new Territory_Assignment_Rule__c();
        aTar2.Rule_Type__c = 'International';
        aTar2.International__c = true;
        aTar2.Opportunity_Type__c = 'Transfer';
        aTar2.User__c = transferManagers[1].Id;
        insert aTar2;

        List<Contact> testContacts = ContactService.createTestContacts(2);

        testContacts[0].MailingCountry = 'Vietnam';

        insert testContacts;

        Contact transferContact1 = [SELECT Id, AccountId FROM Contact WHERE Id = :testContacts[0].Id];

        Contact transferContact2 = [SELECT Id, AccountId FROM Contact WHERE Id = :testContacts[1].Id];

        Opportunity transferOpp = new Opportunity();
        transferOpp.Name = 'Transfer Opportunity 1';
        transferOpp.StageName = 'Prospect';
        transferOpp.Type = 'Transfer';
        transferOpp.Career__c = 'Undergraduate';
        transferOpp.CloseDate = Date.today() + 365;
        transferOpp.Contact__c = transferContact1.Id;
        transferOpp.AccountId = transferContact1.AccountId;
        insert transferOpp;

        Opportunity transferOpp2 = new Opportunity();
        transferOpp2.Name = 'Transfer Opportunity 2';
        transferOpp2.StageName = 'Prospect';
        transferOpp2.Career__c = 'Undergraduate';
        transferOpp2.Type = 'Transfer';
        transferOpp2.CloseDate = Date.today() + 365;
        transferOpp2.Contact__c = transferContact2.Id;
        transferOpp2.AccountId = transferContact2.AccountId;
        insert transferOpp2;

        Test.startTest();
        transferOpp.International_Student__c = true;
        transferOpp2.International_Student__c = true;

        update transferOpp;
        update transferOpp2;

        Test.stopTest();

        transferOpp = [SELECT OwnerId FROM Opportunity WHERE Name = 'Transfer Opportunity 1'];
        transferOpp2 = [SELECT OwnerId FROM Opportunity WHERE Name = 'Transfer Opportunity 2'];

        System.assertEquals(
            transferManagers[0].Id,
            transferOpp.OwnerId,
            'Rule did not assign correct transfer territory manager.'
        );
        System.assertEquals(
            transferManagers[1].Id,
            transferOpp2.OwnerId,
            'Rule did not assign correct default transfer territory manager.'
        );
    }

    @isTest
    public static void testInternationalAdmitConditional() {
        User conditAdmitManager = [
            SELECT Id
            FROM User
            WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'
        ];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'International Admitted - Conditional';
        aTar1.International__c = true;
        aTar1.User__c = conditAdmitManager.Id;
        insert aTar1;

        Contact testContact = ContactService.createTestContact();

        insert testContact;

        testContact = [SELECT Id, AccountId FROM Contact WHERE Id = :testContact.Id];

        Opportunity admitCondOpp = OpportunityService.createTestUndergraduateProspect(testContact);
        admitCondOpp.Name = 'International Admit Opportunity';
        admitCondOpp.StageName = 'Admitted - Conditional';
        admitCondOpp.Career__c = 'Undergraduate';
        insert admitCondOpp;

        Test.startTest();
        admitCondOpp.International_Student__c = true;

        update admitCondOpp;

        Test.stopTest();

        admitCondOpp = [SELECT OwnerId FROM Opportunity WHERE Contact__c = :testContact.Id];

        System.assertEquals(
            conditAdmitManager.Id,
            admitCondOpp.OwnerId,
            'Rule did not assign correct transfer territory manager.'
        );
    }

    @isTest
    public static void testInternationalStageChange() {
        User conditAdmitManager = [
            SELECT Id
            FROM User
            WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'
        ];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'International Admitted - Conditional';
        aTar1.International__c = true;
        aTar1.User__c = conditAdmitManager.Id;
        insert aTar1;

        Contact testContact = ContactService.createTestContact();

        insert testContact;

        Contact admitCondCon = [SELECT Id, AccountId FROM Contact WHERE Id = :testContact.Id];

        Opportunity admitCondOpp = OpportunityService.createTestUndergraduateProspect(admitCondCon);
        admitCondOpp.Name = 'Conditional Admit Opportunity 1';
        admitCondOpp.StageName = 'Applied';
        admitCondOpp.Career__c = 'Undergraduate';
        admitCondOpp.International_Student__c = true;

        insert admitCondOpp;

        admitCondOpp = [SELECT OwnerId FROM Opportunity WHERE Contact__c = :admitCondCon.Id];

        System.assertNotEquals(
            conditAdmitManager.Id,
            admitCondOpp.OwnerId,
            'Rule did not assign correct default territory manager.'
        );

        Test.startTest();
        admitCondOpp.StageName = 'Admitted - Conditional';

        update admitCondOpp;

        Test.stopTest();

        admitCondOpp = [SELECT OwnerId FROM Opportunity WHERE Contact__c = :admitCondCon.Id];

        System.assertEquals(
            conditAdmitManager.Id,
            admitCondOpp.OwnerId,
            'Rule did not assign correct conditioal admit territory manager.'
        );
    }

    @isTest
    public static void testLocation() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        insert con;

        con = [SELECT Id, AccountId FROM Contact WHERE Id = :con.Id];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Location';
        aTar1.User__c = TestUser.Id;
        aTar1.Location__c = 'Lake Havasu';
        insert aTar1;

        Location__c lakeHavasu = new Location__c();
        lakeHavasu.Name = 'Lake Havasu';
        lakeHavasu.Location_Code__c = 'CALHC';
        insert lakeHavasu;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.StageName = 'Prospect';
        opp.Type = 'First Time Freshman';
        opp.Career__c = 'Undergraduate';
        opp.International_Student__c = true;
        opp.CloseDate = date.today() + 365;
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;
        opp.Location__c = lakeHavasu.Id;

        Test.startTest();
        insert opp;

        Test.stopTest();

        String lastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;
        System.Assert(
            lastRuleType == 'Location - Lake Havasu',
            'Rule did not assign correctly by rule type Lake Havasu: ' + lastRuleType
        );
    }

    @isTest
    public static void testAdmittedLocation() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        insert con;

        con = [SELECT Id, AccountId FROM Contact WHERE Id = :con.Id];
        System.assertNotEquals(con.AccountId, null);
        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Location';
        aTar1.User__c = TestUser.Id;
        aTar1.Location__c = 'Lake Havasu';
        insert aTar1;

        Location__c lakeHavasu = new Location__c();
        lakeHavasu.Name = 'Lake Havasu';
        lakeHavasu.Location_Code__c = 'CALHC';
        insert lakeHavasu;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.StageName = 'Prospect';
        opp.Type = 'First Time Freshman';
        opp.Career__c = 'Undergraduate';
        opp.CloseDate = date.today() + 365;
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;
        opp.Admitted_Location__c = lakeHavasu.Id;

        Test.startTest();
        insert opp;
        Test.stopTest();

        String lastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;
        System.Assert(
            lastRuleType == 'Location - Lake Havasu',
            'Rule did not assign correctly by rule type Lake Havasu: ' + lastRuleType
        );
    }

    @isTest
    public static void testLastHighSchoolAttended() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Account highSchool = new Account();
        highSchool.Name = 'Test High School';
        highSchool.Institution_Type__c = 'highSchool';
        highSchool.Territory_Manager__c = TestUser.Id;
        insert highSchool;

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        con.Email = 'test@test.com';
        insert con;

        Previous_Education__c pe = new Previous_Education__c();
        pe.Contact__c = con.Id;
        pe.Account__c = highSchool.Id;
        insert pe;

        con = [SELECT Id, AccountId FROM Contact WHERE Id = :con.Id];

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;
        opp.StageName = 'Prospect';
        opp.Career__c = 'Undergraduate';
        opp.Type = 'Test';
        opp.CloseDate = Date.today() + 365;
        insert opp;

        Test.startTest();
        opp.Type = 'First Time Freshman';
        update opp;

        Test.stopTest();

        String lastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;

        System.Assert(
            lastRuleType == 'Last Attended High School',
            'Rule did not assign correctly by rule type Last High School Attended'
        );
    }

    @isTest
    public static void testLastCollegeAttended() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.User__c = TestUser.Id;
        aTar1.Rule_Type__c = 'Default User';
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        insert aTar1;

        Territory_Assignment_Rule__c aTar2 = new Territory_Assignment_Rule__c();
        aTar2.User__c = TestUser.Id;
        aTar2.Rule_Type__c = 'Default User';
        aTar2.Opportunity_Type__c = 'Transfer';
        insert aTar2;

        Territory_Assignment_Rule__c aTar3 = new Territory_Assignment_Rule__c();
        aTar3.User__c = TestUser.Id;
        aTar3.Rule_Type__c = 'Default User';
        aTar3.Opportunity_Type__c = 'Non-Degree';
        insert aTar3;

        Territory_Assignment_Rule__c aTar4 = new Territory_Assignment_Rule__c();
        aTar4.User__c = TestUser.Id;
        aTar4.Rule_Type__c = 'Default User';
        aTar4.Opportunity_Type__c = 'Readmission';
        insert aTar4;

        Territory_Assignment_Rule__c aTar5 = new Territory_Assignment_Rule__c();
        aTar5.User__c = TestUser.Id;
        aTar5.Rule_Type__c = 'Default User';
        aTar5.Opportunity_Type__c = 'Law';
        insert aTar5;

        Territory_Assignment_Rule__c aTar6 = new Territory_Assignment_Rule__c();
        aTar6.User__c = TestUser.Id;
        aTar6.Rule_Type__c = 'Default User';
        aTar6.Opportunity_Type__c = 'Graduate';
        insert aTar6;

        Territory_Assignment_Rule__c aTar7 = new Territory_Assignment_Rule__c();
        aTar7.User__c = TestUser.Id;
        aTar7.Rule_Type__c = 'Default User';
        aTar7.Opportunity_Type__c = 'Non-Degree';
        insert aTar7;

        Account college = new Account();
        college.Name = 'Test College';
        college.Institution_Type__c = '4YR';
        college.Territory_Manager__c = TestUser.Id;
        insert college;

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        con.Email = 'test@test.com';
        insert con;

        Previous_Education__c pe = new Previous_Education__c();
        pe.Contact__c = con.Id;
        pe.Account__c = college.Id;
        insert pe;

        con = [SELECT AccountId FROM Contact WHERE Id = :con.Id];

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;
        opp.Career__c = 'Undergraduate';
        opp.StageName = 'Prospect';
        opp.Type = 'Test';
        opp.CloseDate = date.today() + 365;
        insert opp;

        Test.startTest();
        opp.Type = 'First Time Freshman';
        update opp;
        opp.Type = 'Transfer';
        update opp;

        Test.stopTest();

        String lastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;

        System.Assert(
            lastRuleType == 'Last Attended College, Type ' + opp.Type,
            'Rule did not assign correctly by rule type Last College Attended'
        );
    }

    @isTest
    public static void testGeomarketCode() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Geomarket';
        aTar1.User__c = TestUser.Id;
        aTar1.Geomarket__c = 'AZ-01';
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        insert aTar1;

        Key_Value__c KVContact = new Key_Value__c();
        KVContact.Geomarket_ZIP__c = '85123';
        KVContact.Geomarket_Code__c = 'AZ-01';
        insert KVContact;

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        con.Email = 'test@test.com';
        con.MailingPostalCode = '85123';
        con.Geomarket_Code__c = 'AZ-01';
        insert con;

        con = [SELECT AccountId FROM Contact WHERE Id = :con.Id];

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.StageName = 'Prospect';
        opp.Career__c = 'Undergraduate';
        opp.Type = 'First Time Freshman';
        opp.CloseDate = date.today() + 365;
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;

        Test.startTest();
        insert opp;

        Test.stopTest();

        String lastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;

        System.Assert(
            lastRuleType == 'Geomarket, Type ' + opp.Type,
            'Rule did not assign correctly by rule type Geomarket'
        );
    }

    @isTest
    public static void testState() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'State';
        aTar1.User__c = TestUser.Id;
        aTar1.Assignment_By_State__c = 'Arizona';
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        insert aTar1;

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        con.Email = 'test@test.com';
        con.MailingCountry = 'United States';
        insert con;

        con = [SELECT AccountId FROM Contact WHERE Id = :con.Id];

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.StageName = 'Prospect';
        opp.Type = 'First Time Freshman';
        opp.Career__c = 'Undergraduate';
        opp.CloseDate = date.today() + 365;
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;
        insert opp;

        Test.startTest();
        con.MailingState = 'Arizona';
        update con;

        Test.stopTest();

        String lastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;

        System.Assert(
            lastRuleType == 'State, ' + con.MailingState + ', Type ' + opp.Type,
            'Rule did not assign correctly by rule type State: ' + lastRuleType
        );
    }

    @isTest
    public static void testDefaultUser() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        insert con;

        con = [SELECT AccountId FROM Contact WHERE Id = :con.Id];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Default User';
        aTar1.User__c = TestUser.Id;
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        insert aTar1;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.StageName = 'Prospect';
        opp.Career__c = 'Undergraduate';
        opp.Type = 'First Time Freshman';
        opp.CloseDate = date.today() + 365;
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;

        Test.startTest();
        insert opp;

        Test.stopTest();

        String lastRuleType = [
            SELECT Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;

        System.Assert(
            lastRuleType == 'Default User',
            'Rule did not assign correctly by rule type Default User: ' + lastRuleType
        );
    }

    @isTest
    public static void testInactiveUser() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Profile saProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User InactiveUser = (User) userCreator.create(1)[0];
        InactiveUser.FirstName = 'Test';
        InactiveUser.LastName = 'Name';
        InactiveUser.CompanyName = 'Test Company';
        InactiveUser.MobilePhone = '123-456-7890';
        InactiveUser.Username = 'testUser-Inactive@test.test';
        InactiveUser.Email = 'testUser-Inactive@test.test';
        InactiveUser.Alias = 'testXX';
        InactiveUser.CommunityNickname = 'test1';
        InactiveUser.TimeZoneSidKey = 'America/New_York';
        InactiveUser.LocaleSidKey = 'en_US';
        InactiveUser.EmailEncodingKey = 'UTF-8';
        InactiveUser.ProfileId = saProfile.Id;
        InactiveUser.LanguageLocaleKey = 'en_US';
        InactiveUser.IsActive = false;
        insert InactiveUser;

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Default User';
        aTar1.User__c = TestUser.Id;
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        insert aTar1;

        Account highSchool = new Account();
        highSchool.Name = 'Test High School';
        highSchool.Institution_Type__c = 'highSchool';
        highSchool.Territory_Manager__c = InactiveUser.Id;
        insert highSchool;

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        con.Email = 'test@test.com';
        con.Last_HS_Attended__c = highSchool.Id;
        insert con;

        Previous_Education__c pe = new Previous_Education__c();
        pe.Contact__c = con.Id;
        pe.Account__c = highSchool.Id;
        insert pe;

        con = [SELECT AccountId FROM Contact WHERE Id = :con.Id];

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;
        opp.StageName = 'Prospect';
        opp.Career__c = 'Undergraduate';
        opp.Type = 'First Time Freshman';
        opp.CloseDate = Date.today() + 365;

        Test.startTest();
        insert opp;

        Test.stopTest();

        Opportunity OppAfterInsert = [
            SELECT Territory_Assignment_Last_Rule_Type__c, OwnerId
            FROM Opportunity
            WHERE Id = :opp.Id
            LIMIT 1
        ];

        System.Assert(OppAfterInsert.OwnerId == TestUser.Id);
        System.Assert(
            OppAfterInsert.Territory_Assignment_Last_Rule_Type__c == 'Inactive Territory Manager',
            'Did not correctly identify inactive User: ' + OppAfterInsert.Territory_Assignment_Last_Rule_Type__c
        );
    }
}