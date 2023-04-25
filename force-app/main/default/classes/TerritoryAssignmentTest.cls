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

        System.assert(
            contactGeoCodeAfterUpdate == KVContact.Geomarket_Code__c,
            'Contact Geomarket Code did not match by ZIP code'
        );
        System.assert(
            contactHSGeoCodeAfterUpdate == KVHS.Geomarket_Code__c,
            'Contact Geomarket Code did not match by Last Attended High School Geomarket Code'
        );
        System.assert(
            contactCollegeGeoCodeAfterUpdate == KVCollege.Geomarket_Code__c,
            'Contact Geomarket Code did not match by Last Attended College Geomarket Code'
        );
    }

    @isTest
    public static void testFreshmanScholar() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        insert Con;

        Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Freshman Scholar';
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        aTar1.User__c = TestUser.Id;
        insert aTar1;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospect';
        opp.Type = 'test';
        opp.Career__c = 'Undergraduate';
        opp.CloseDate = date.today() + 365;
        opp.Contact__c = Con.Id;
        opp.AccountId = Con.AccountId;
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
        System.assert(
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

        Territory_Assignment_Rule__c ATar1 = new Territory_Assignment_Rule__c();
        ATar1.Rule_Type__c = 'International';
        ATar1.International__c = true;
        ATar1.User__c = testUser.Id;
        insert ATar1;

        Test.startTest();
        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.StageName = 'Prospect';
        Opp.Type = 'First Time Freshman';
        Opp.Career__c = 'Graduate';
        Opp.CloseDate = date.today() + 365;
        Opp.Contact__c = Con.Id;
        Opp.AccountId = Con.AccountId;
        insert Opp;

        Id originalOwner = [SELECT OwnerId FROM Opportunity WHERE Id = :Opp.Id].Id;

        Opp.International_Student__c = true;
        update Opp;

        Test.stopTest();

        Opp = [SELECT OwnerId FROM Opportunity WHERE Id = :Opp.Id];

        System.assertNotEquals(
            originalOwner,
            testUser.Id,
            'Territory assignment occurred on insert for Graduate opportunity'
        );
        System.assertNotEquals(
            Opp.OwnerId,
            testUser.Id,
            'Territory assignment occurred on update for Graduate opportunity'
        );
    }

    @isTest
    public static void testInternational() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        insert Con;

        Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];

        Territory_Assignment_Rule__c ATar1 = new Territory_Assignment_Rule__c();
        ATar1.Rule_Type__c = 'International';
        ATar1.International__c = true;
        ATar1.User__c = TestUser.Id;
        insert ATar1;
        String tarRuleKey = [SELECT Rule_Key__c FROM Territory_Assignment_Rule__c WHERE Id = :ATar1.Id].Rule_Key__c;

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.StageName = 'Prospect';
        Opp.Career__c = 'Undergraduate';
        Opp.Type = 'First Time Freshman';
        Opp.CloseDate = date.today() + 365;
        Opp.Contact__c = Con.Id;
        Opp.AccountId = Con.AccountId;
        insert Opp;

        Test.startTest();
        Opp.International_Student__c = true;
        update Opp;

        Test.stopTest();

        String LastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :Opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;

        System.assert(LastRuleType == tarRuleKey, 'Rule did not assign correctly by rule type International');
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

        Territory_Assignment_Rule__c ATar1 = new Territory_Assignment_Rule__c();
        ATar1.Rule_Type__c = 'International';
        ATar1.International__c = true;
        ATar1.Opportunity_Type__c = 'First Time Freshman';
        ATar1.Assignment_By_Country__c = 'China';
        ATar1.Range_Start__c = 1;
        ATar1.Range_End__c = 50;
        ATar1.User__c = chinaManagers[0].Id;
        insert ATar1;

        Territory_Assignment_Rule__c ATar2 = new Territory_Assignment_Rule__c();
        ATar2.Rule_Type__c = 'International';
        ATar2.International__c = true;
        ATar2.Opportunity_Type__c = 'First Time Freshman';
        ATar2.Assignment_By_Country__c = 'China';
        ATar2.Range_Start__c = 51;
        Atar2.Range_End__c = 100;
        ATar2.User__c = chinaManagers[1].Id;
        insert ATar2;

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

        if (chinaOpp2.Opportunity_Assignment_Number__c <= ATar1.Range_End__c) {
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

        Territory_Assignment_Rule__c ATar1 = new Territory_Assignment_Rule__c();
        ATar1.Rule_Type__c = 'International';
        ATar1.International__c = true;
        ATar1.Opportunity_Type__c = 'First Time Freshman';
        ATar1.Assignment_By_Country__c = 'United States';
        ATar1.Range_Start__c = 1;
        ATar1.Range_End__c = 50;
        ATar1.User__c = usManagers[0].Id;
        insert ATar1;

        Territory_Assignment_Rule__c ATar2 = new Territory_Assignment_Rule__c();
        ATar2.Rule_Type__c = 'International';
        ATar2.International__c = true;
        ATar2.Opportunity_Type__c = 'First Time Freshman';
        ATar2.Assignment_By_Country__c = 'United States';
        ATar2.Range_Start__c = 51;
        Atar2.Range_End__c = 100;
        ATar2.User__c = usManagers[1].Id;
        insert ATar2;

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

        if (usOpp2.Opportunity_Assignment_Number__c <= ATar1.Range_End__c) {
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

        Territory_Assignment_Rule__c ATar1 = new Territory_Assignment_Rule__c();
        ATar1.Rule_Type__c = 'International';
        ATar1.International__c = true;
        ATar1.Opportunity_Type__c = 'Transfer';
        ATar1.Assignment_By_Country__c = 'Viet Nam';
        ATar1.User__c = transferManagers[0].Id;
        insert ATar1;

        Territory_Assignment_Rule__c ATar2 = new Territory_Assignment_Rule__c();
        ATar2.Rule_Type__c = 'International';
        ATar2.International__c = true;
        ATar2.Opportunity_Type__c = 'Transfer';
        ATar2.User__c = transferManagers[1].Id;
        insert ATar2;

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

        Territory_Assignment_Rule__c ATar1 = new Territory_Assignment_Rule__c();
        ATar1.Rule_Type__c = 'International Admitted - Conditional';
        ATar1.International__c = true;
        ATar1.User__c = conditAdmitManager.Id;
        insert ATar1;

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

        Territory_Assignment_Rule__c ATar1 = new Territory_Assignment_Rule__c();
        ATar1.Rule_Type__c = 'International Admitted - Conditional';
        ATar1.International__c = true;
        ATar1.User__c = conditAdmitManager.Id;
        insert ATar1;

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

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        insert Con;

        Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Location';
        aTar1.User__c = TestUser.Id;
        aTar1.Location__c = 'Lake Havasu';
        insert aTar1;

        Location__c LakeHavasu = new Location__c();
        LakeHavasu.Name = 'Lake Havasu';
        LakeHavasu.Location_Code__c = 'CALHC';
        insert LakeHavasu;

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.StageName = 'Prospect';
        Opp.Type = 'First Time Freshman';
        Opp.Career__c = 'Undergraduate';
        Opp.International_Student__c = true;
        Opp.CloseDate = date.today() + 365;
        Opp.Contact__c = Con.Id;
        Opp.AccountId = Con.AccountId;
        Opp.Location__c = LakeHavasu.Id;

        Test.startTest();
        insert Opp;

        Test.stopTest();

        String LastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :Opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;
        System.assert(
            LastRuleType == 'Location - Lake Havasu',
            'Rule did not assign correctly by rule type Lake Havasu: ' + LastRuleType
        );
    }

    @isTest
    public static void testAdmittedLocation() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        insert Con;

        Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];
        System.assertNotEquals(con.AccountId, null);
        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Location';
        aTar1.User__c = TestUser.Id;
        aTar1.Location__c = 'Lake Havasu';
        insert aTar1;

        Location__c LakeHavasu = new Location__c();
        LakeHavasu.Name = 'Lake Havasu';
        LakeHavasu.Location_Code__c = 'CALHC';
        insert LakeHavasu;

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.StageName = 'Prospect';
        Opp.Type = 'First Time Freshman';
        Opp.Career__c = 'Undergraduate';
        Opp.CloseDate = date.today() + 365;
        Opp.Contact__c = Con.Id;
        Opp.AccountId = Con.AccountId;
        Opp.Admitted_Location__c = LakeHavasu.Id;

        Test.startTest();
        insert Opp;
        Test.stopTest();

        String LastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :Opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;
        System.assert(
            LastRuleType == 'Location - Lake Havasu',
            'Rule did not assign correctly by rule type Lake Havasu: ' + LastRuleType
        );
    }

    @isTest
    public static void testLastHighSchoolAttended() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Account HS = new Account();
        HS.Name = 'Test High School';
        HS.Institution_Type__c = 'HS';
        HS.Territory_Manager__c = TestUser.Id;
        insert HS;

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        Con.Email = 'test@test.com';
        insert Con;

        Previous_Education__c pe = new Previous_Education__c();
        pe.Contact__c = Con.Id;
        pe.Account__c = HS.Id;
        insert pe;

        Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.Contact__c = Con.Id;
        Opp.AccountId = Con.AccountId;
        Opp.StageName = 'Prospect';
        Opp.Career__c = 'Undergraduate';
        Opp.Type = 'Test';
        Opp.CloseDate = Date.today() + 365;
        insert Opp;

        Test.startTest();
        Opp.Type = 'First Time Freshman';
        update Opp;

        Test.stopTest();

        String LastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :Opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;

        System.assert(
            LastRuleType == 'Last Attended High School',
            'Rule did not assign correctly by rule type Last High School Attended'
        );
    }

    @isTest
    public static void testLastCollegeAttended() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Territory_Assignment_Rule__c ATar1 = new Territory_Assignment_Rule__c();
        ATar1.User__c = TestUser.Id;
        ATar1.Rule_Type__c = 'Default User';
        ATar1.Opportunity_Type__c = 'First Time Freshman';
        insert ATar1;

        Territory_Assignment_Rule__c Atar2 = new Territory_Assignment_Rule__c();
        Atar2.User__c = TestUser.Id;
        Atar2.Rule_Type__c = 'Default User';
        Atar2.Opportunity_Type__c = 'Transfer';
        insert Atar2;

        Territory_Assignment_Rule__c Atar3 = new Territory_Assignment_Rule__c();
        Atar3.User__c = TestUser.Id;
        Atar3.Rule_Type__c = 'Default User';
        Atar3.Opportunity_Type__c = 'Non-Degree';
        insert Atar3;

        Territory_Assignment_Rule__c Atar4 = new Territory_Assignment_Rule__c();
        Atar4.User__c = TestUser.Id;
        Atar4.Rule_Type__c = 'Default User';
        Atar4.Opportunity_Type__c = 'Readmission';
        insert Atar4;

        Territory_Assignment_Rule__c Atar5 = new Territory_Assignment_Rule__c();
        Atar5.User__c = TestUser.Id;
        Atar5.Rule_Type__c = 'Default User';
        Atar5.Opportunity_Type__c = 'Law';
        insert Atar5;

        Territory_Assignment_Rule__c Atar6 = new Territory_Assignment_Rule__c();
        Atar6.User__c = TestUser.Id;
        Atar6.Rule_Type__c = 'Default User';
        Atar6.Opportunity_Type__c = 'Graduate';
        insert Atar6;

        Territory_Assignment_Rule__c Atar7 = new Territory_Assignment_Rule__c();
        Atar7.User__c = TestUser.Id;
        Atar7.Rule_Type__c = 'Default User';
        Atar7.Opportunity_Type__c = 'Non-Degree';
        insert Atar7;

        Account College = new Account();
        College.Name = 'Test College';
        College.Institution_Type__c = '4YR';
        College.Territory_Manager__c = TestUser.Id;
        insert College;

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        Con.Email = 'test@test.com';
        insert Con;

        Previous_Education__c pe = new Previous_Education__c();
        pe.Contact__c = Con.Id;
        pe.Account__c = College.Id;
        insert pe;

        Con = [SELECT AccountId FROM Contact WHERE Id = :Con.Id];

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.Contact__c = Con.Id;
        Opp.AccountId = Con.AccountId;
        Opp.Career__c = 'Undergraduate';
        Opp.StageName = 'Prospect';
        Opp.Type = 'Test';
        Opp.CloseDate = date.today() + 365;
        insert Opp;

        Test.startTest();
        Opp.Type = 'First Time Freshman';
        update Opp;
        Opp.Type = 'Transfer';
        update Opp;

        Test.stopTest();

        String LastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :Opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;

        System.assert(
            LastRuleType == 'Last Attended College, Type ' + Opp.Type,
            'Rule did not assign correctly by rule type Last College Attended'
        );
    }

    @isTest
    public static void testGeomarketCode() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Territory_Assignment_Rule__c ATar1 = new Territory_Assignment_Rule__c();
        ATar1.Rule_Type__c = 'Geomarket';
        ATar1.User__c = TestUser.Id;
        ATar1.Geomarket__c = 'AZ-01';
        ATar1.Opportunity_Type__c = 'First Time Freshman';
        insert ATar1;

        Key_Value__c KVContact = new Key_Value__c();
        KVContact.Geomarket_ZIP__c = '85123';
        KVContact.Geomarket_Code__c = 'AZ-01';
        insert KVContact;

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        Con.Email = 'test@test.com';
        Con.MailingPostalCode = '85123';
        Con.Geomarket_Code__c = 'AZ-01';
        insert Con;

        Con = [SELECT AccountId FROM Contact WHERE Id = :Con.Id];

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.StageName = 'Prospect';
        Opp.Career__c = 'Undergraduate';
        Opp.Type = 'First Time Freshman';
        Opp.CloseDate = date.today() + 365;
        Opp.Contact__c = Con.Id;
        Opp.AccountId = Con.AccountId;

        Test.startTest();
        insert Opp;

        Test.stopTest();

        String LastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :Opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;

        System.assert(
            LastRuleType == 'Geomarket, Type ' + Opp.Type,
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

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        Con.Email = 'test@test.com';
        Con.MailingCountry = 'United States';
        insert Con;

        Con = [SELECT AccountId FROM Contact WHERE Id = :Con.Id];

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.StageName = 'Prospect';
        Opp.Type = 'First Time Freshman';
        Opp.Career__c = 'Undergraduate';
        Opp.CloseDate = date.today() + 365;
        Opp.Contact__c = Con.Id;
        Opp.AccountId = Con.AccountId;
        insert Opp;

        Test.startTest();
        Con.MailingState = 'Arizona';
        update Con;

        Test.stopTest();

        String LastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :Opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;

        System.assert(
            LastRuleType == 'State, ' + Con.MailingState + ', Type ' + Opp.Type,
            'Rule did not assign correctly by rule type State: ' + LastRuleType
        );
    }

    @isTest
    public static void testDefaultUser() {
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user.Emperor.Of.Byzantium@test.example.com0'];

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        insert Con;

        Con = [SELECT AccountId FROM Contact WHERE Id = :Con.Id];

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'Default User';
        aTar1.User__c = TestUser.Id;
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        insert aTar1;

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.StageName = 'Prospect';
        Opp.Career__c = 'Undergraduate';
        Opp.Type = 'First Time Freshman';
        Opp.CloseDate = date.today() + 365;
        Opp.Contact__c = Con.Id;
        Opp.AccountId = Con.AccountId;

        Test.startTest();
        insert Opp;

        Test.stopTest();

        String LastRuleType = [
            SELECT Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :Opp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;

        System.assert(
            LastRuleType == 'Default User',
            'Rule did not assign correctly by rule type Default User: ' + LastRuleType
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

        Account HS = new Account();
        HS.Name = 'Test High School';
        HS.Institution_Type__c = 'HS';
        HS.Territory_Manager__c = InactiveUser.Id;
        insert HS;

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        Con.Email = 'test@test.com';
        Con.Last_HS_Attended__c = HS.Id;
        insert Con;

        Previous_Education__c pe = new Previous_Education__c();
        pe.Contact__c = Con.Id;
        pe.Account__c = HS.Id;
        insert pe;

        Con = [SELECT AccountId FROM Contact WHERE Id = :Con.Id];

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.Contact__c = Con.Id;
        Opp.AccountId = Con.AccountId;
        Opp.StageName = 'Prospect';
        Opp.Career__c = 'Undergraduate';
        Opp.Type = 'First Time Freshman';
        Opp.CloseDate = Date.today() + 365;

        Test.startTest();
        insert Opp;

        Test.stopTest();

        Opportunity OppAfterInsert = [
            SELECT Territory_Assignment_Last_Rule_Type__c, OwnerId
            FROM Opportunity
            WHERE Id = :Opp.Id
            LIMIT 1
        ];

        System.assert(OppAfterInsert.OwnerId == TestUser.Id);
        System.assert(
            OppAfterInsert.Territory_Assignment_Last_Rule_Type__c == 'Inactive Territory Manager',
            'Did not correctly identify inactive User: ' + OppAfterInsert.Territory_Assignment_Last_Rule_Type__c
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

        System.assert(
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

        System.assert(
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

        System.assert(
            newLeadList[0].Territory_Assignment_Last_Rule_Type__c == 'Last Institution Attended',
            'Rule did not assign correctly by rule type Last Institution Attended'
        );
        System.assert(
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

        System.assert(
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

        System.assert(
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

    public testMethod static void testErrorLogger() {
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