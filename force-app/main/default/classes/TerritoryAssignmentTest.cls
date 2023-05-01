@isTest
public without sharing class TerritoryAssignmentTest {
    @testSetup
    static void setup() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User testUser = (User) userCreator.create(1)[0];

        Id saProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        testUser.ProfileId = saProfile;

        insert testUser;
    }

    @isTest
    public static void testAccountGeomarketCodeAssignment() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Account HS = new Account();
        HS.Name = 'Test High School';
        insert HS;

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        con.MailingPostalCode = '90210';
        con.Geomarket_Code__c = 'CA-01';
        insert con;

        con = [SELECT Id, AccountId FROM Contact WHERE Id = :con.Id];

        Key_Value__c KV = new Key_Value__c();
        KV.Geomarket_ZIP__c = '85287';
        KV.Geomarket_Code__c = 'GM-01';
        insert KV;

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.Contact__c = con.Id;
        Opp.AccountId = con.AccountID;
        Opp.StageName = 'Prospect';
        Opp.CloseDate = date.today() + 365;
        Opp.Type = 'First Time Freshman';
        Opp.OwnerId = TestUser.Id;
        insert Opp;

        TerritoryAssignmentAccount.assignTerritoryDone = false;

        Test.startTest();
        HS.ShippingPostalCode = '85287';
        HS.Territory_Manager__c = TestUser.Id;
        update HS;
        Test.stopTest();

        String accountGeoCodeAfterUpdate = [SELECT Id, Geomarket_Code__c FROM Account WHERE Id = :HS.Id LIMIT 1]
        .Geomarket_Code__c;

        System.Assert(
            accountGeoCodeAfterUpdate == KV.Geomarket_Code__c,
            'Account Geomarket Code did not match by ZIP code'
        );
    }

    @isTest
    public static void testContactGeomarketCodeAssignment() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        con.MailingPostalCode = '90210';
        con.Geomarket_Code__c = 'CA-01';
        insert con;

        con = [SELECT Id, AccountId FROM Contact WHERE Id = :con.Id];

        Key_Value__c KVContact = new Key_Value__c();
        KVContact.Geomarket_ZIP__c = '90210';
        KVContact.Geomarket_Code__c = 'CA-01';
        insert KVContact;

        Key_Value__c KVHS = new Key_Value__c();
        KVHS.Geomarket_ZIP__c = '84108';
        KVHS.Geomarket_Code__c = 'UT-01';
        insert KVHS;

        Key_Value__c KVCollege = new Key_Value__c();
        KVCollege.Geomarket_ZIP__c = '85287';
        KVCollege.Geomarket_Code__c = 'AZ-01';
        insert KVCollege;

        Account HS = new Account();
        HS.Name = 'Test High School';
        HS.ShippingPostalCode = '84108';
        HS.Geomarket_Code__c = 'UT-01';
        insert HS;

        Account college = new Account();
        college.Name = 'Test College School';
        college.ShippingPostalCode = '85287';
        college.Geomarket_Code__c = 'AZ-01';
        insert college;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;
        opp.StageName = 'Prospect';
        opp.CloseDate = Date.today() + 365;
        opp.Type = 'First Time Freshman';
        //TODO: Commented out until territory assignment goes live with owner.
        //opp.OwnerId = TestUser.Id;
        //opp.Territory_Assignment_UserID__c = TestUser.Id;

        Test.startTest();

        insert opp;
        String contactGeoCodeAfterUpdate = [SELECT Id, Geomarket_Code__c FROM Contact WHERE Id = :con.Id LIMIT 1]
        .Geomarket_Code__c;

        // Fire Account Trigger to set Account.Geomarketcode__c
        HS.ShippingPostalCode = '84108';
        HS.Geomarket_Code__c = 'UT-01';
        update HS;

        con.Last_HS_Attended__c = HS.Id;
        update con;

        opp.Type = 'First Time Freshman';
        opp.Territory_Assignment_Required__c = true;
        update opp;

        String contactHSGeoCodeAfterUpdate = [SELECT Id, Geomarket_Code__c FROM Contact WHERE Id = :Con.Id LIMIT 1]
        .Geomarket_Code__c;

        opp.Type = 'Transfer';
        update opp;

        con.Last_HS_Attended__c = null;
        con.Last_College_Attended__c = College.Id;
        update con;

        opp.Type = 'Transfer';
        opp.Territory_Assignment_Required__c = true;
        update opp;

        String contactCollegeGeoCodeAfterUpdate = [SELECT Id, Geomarket_Code__c FROM Contact WHERE Id = :Con.Id LIMIT 1]
        .Geomarket_Code__c;

        Test.stopTest();

        System.Assert(
            contactGeoCodeAfterUpdate == KVContact.Geomarket_Code__c,
            'Contact Geomarket Code did not match by ZIP code'
        );
        System.Assert(
            contactHSGeoCodeAfterUpdate == KVHS.Geomarket_Code__c,
            'Contact Geomarket Code did not match by Last Attended High School Geomarket Code'
        );
        System.Assert(
            contactCollegeGeoCodeAfterUpdate == KVCollege.Geomarket_Code__c,
            'Contact Geomarket Code did not match by Last Attended College Geomarket Code'
        );
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

    @isTest
    public static void testErrorLogger() {
        Test.startTest();
        TerritoryAssignmentService.updateContactList(null);
        TerritoryAssignmentService.updateOpportunityList(null);
        Test.stopTest();

        List<Case> errorList = [SELECT Id FROM Case];

        System.assertEquals(2, errorList.size());
    }

    public testMethod static void testTerritoryAssignmentRule() {
        Territory_Assignment_Rule__c testRule = new Territory_Assignment_Rule__c();
        List<User> userList = [SELECT Id FROM User LIMIT 2];
        testRule.User__c = userList[0].Id;
        insert testRule;

        testRule.User__c = userList[1].Id;
        update testRule;
        List<Territory_Assignment_Rule__c> ruleList = [SELECT User__c FROM Territory_Assignment_Rule__c];
        System.assertEquals(userList[1].Id, ruleList[0].User__c);
    }
}