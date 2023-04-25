@isTest
private with sharing class PreviousEducationTriggerTest {
    @TestSetup
    private static void setup() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User testUser = (User) userCreator.create(1)[0];
        Id saProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        testUser.ProfileId = saProfile;
        insert testUser;

        Contact testCon = new Contact(FirstName = 'PreviousEducation Trigger', LastName = 'Test Contact');
        Contact testCon2 = new Contact(FirstName = 'PreviousEducation Trigger', LastName = 'Test Contact 2');
        insert new List<Contact>{ testCon, testCon2 };

        Account highSchool1 = new Account(Name = 'Test HS 1', Institution_Type__c = 'HS');
        Account highSchool2 = new Account(Name = 'Test HS 2', Institution_Type__c = 'HS');
        Account college1 = new Account(Name = 'Test College 1', Institution_Type__c = '4YR');
        Account college2 = new Account(Name = 'Test College 2', Institution_Type__c = '2YR');
        insert new List<Account>{ highSchool1, highSchool2, college1, college2 };
    }

    @isTest
    private static void testUpdateContactLastHS() {
        // Retrieve setup data
        Contact testCon = [SELECT Id FROM Contact LIMIT 1];
        Account testHs = [SELECT Id FROM Account WHERE Institution_Type__c = 'HS' LIMIT 1];

        // Contact will has a HS Prev Education
        Previous_Education__c hsPrevEd = new Previous_Education__c(Contact__c = testCon.Id, Account__c = testHs.Id);

        // Should update the contact's Last HS
        Test.startTest();
        insert hsPrevEd;
        Test.stopTest();

        // Retrieve updated contact
        testCon = [SELECT Id, Last_HS_Attended__c, Last_College_Attended__c FROM Contact WHERE Id = :testCon.Id];

        // Assert
        System.assertEquals(testHs.Id, testCon.Last_HS_Attended__c);
        System.assertEquals(null, testCon.Last_College_Attended__c);
    }

    @isTest
    private static void testUpdateContactLastCollege() {
        // Retrieve setup data
        Contact testCon = [SELECT Id FROM Contact LIMIT 1];
        Account testCollege = [SELECT Id FROM Account WHERE Institution_Type__c = '4YR' LIMIT 1];

        // Contact will has a College Prev Education
        Previous_Education__c collegePrevEd = new Previous_Education__c(
            Contact__c = testCon.Id,
            Account__c = testCollege.Id
        );

        // Should update the contact's Last College
        Test.startTest();
        insert collegePrevEd;
        Test.stopTest();

        // Retrieve updated contact
        testCon = [SELECT Id, Last_HS_Attended__c, Last_College_Attended__c FROM Contact WHERE Id = :testCon.Id];

        // Assert
        System.assertEquals(null, testCon.Last_HS_Attended__c);
        System.assertEquals(testCollege.Id, testCon.Last_College_Attended__c);
    }

    @isTest
    private static void testUpdateContactMultipleInsert() {
        // Retrieve setup data
        Contact testCon = [SELECT Id FROM Contact LIMIT 1];
        List<Account> testHSs = [SELECT Id FROM Account WHERE Institution_Type__c = 'HS'];
        Account testHS1 = testHSs[0];
        Account testHS2 = testHSs[1];

        // Contact will have multiple HS Prev Educations
        Previous_Education__c hsPrevEd = new Previous_Education__c(Contact__c = testCon.Id, Account__c = testHS1.Id);
        insert hsPrevEd; // this will set the contact's Last HS to testHS1

        ObjectService.wait(2000); // need to ensure the update timestamp on hsPrevEd2 is later than the timestamp on hsPrevEd

        // Should update the contact's Last HS to testHS2
        Test.startTest();
        Previous_Education__c hsPrevEd2 = new Previous_Education__c(Contact__c = testCon.Id, Account__c = testHS2.Id);
        insert hsPrevEd2;
        Test.stopTest();

        // Retrieve updated contact
        testCon = [SELECT Id, Last_HS_Attended__c, Last_College_Attended__c FROM Contact WHERE Id = :testCon.Id];

        // Assert
        System.assertEquals(testHS2.Id, testCon.Last_HS_Attended__c);
        System.assertEquals(null, testCon.Last_College_Attended__c);
    }

    @isTest
    private static void testUpdateContactMultipleUpdate() {
        // Retrieve setup data
        Contact testCon = [SELECT Id FROM Contact LIMIT 1];
        List<Account> testHSs = [SELECT Id FROM Account WHERE Institution_Type__c = 'HS'];
        Account testHS1 = testHSs[0];
        Account testHS2 = testHSs[1];

        // Contact will have multiple HS Prev Educations
        Previous_Education__c hsPrevEd = new Previous_Education__c(Contact__c = testCon.Id, Account__c = testHS1.Id);
        insert hsPrevEd; // this will set the contact's Last HS to testHS1
        ObjectService.wait(2000); // need to ensure the update timestamp on hsPrevEd2 is later than the timestamp on hsPrevEd

        Previous_Education__c hsPrevEd2 = new Previous_Education__c(Contact__c = testCon.Id, Account__c = testHS2.Id);
        insert hsPrevEd2; // this will set the contact's Last HS to testHS2
        ObjectService.wait(2000); // need to ensure the update timestamp on hsPrevEd is later than the timestamp on hsPrevEd2

        // Should update the contact's Last HS back to testHS1
        Test.startTest();
        update hsPrevEd;
        Test.stopTest();

        // Retrieve updated contact
        testCon = [SELECT Id, Last_HS_Attended__c, Last_College_Attended__c FROM Contact WHERE Id = :testCon.Id];

        // Assert
        System.assertEquals(testHS1.Id, testCon.Last_HS_Attended__c);
        System.assertEquals(null, testCon.Last_College_Attended__c);
    }

    @isTest
    private static void testUpdateContactMultipleDelete() {
        // Retrieve setup data
        Contact testCon = [SELECT Id FROM Contact LIMIT 1];
        List<Account> testHSs = [SELECT Id FROM Account WHERE Institution_Type__c = 'HS'];
        Account testHS1 = testHSs[0];
        Account testHS2 = testHSs[1];

        // Contact will have multiple HS Prev Educations
        Previous_Education__c hsPrevEd = new Previous_Education__c(Contact__c = testCon.Id, Account__c = testHS1.Id);
        insert hsPrevEd; // this will set the contact's Last HS to testHS1
        ObjectService.wait(2000); // need to ensure the update timestamp on hsPrevEd2 is later than the timestamp on hsPrevEd

        Previous_Education__c hsPrevEd2 = new Previous_Education__c(Contact__c = testCon.Id, Account__c = testHS2.Id);
        insert hsPrevEd2; // this will set the contact's Last HS to testHS2

        // Should update the contact's Last HS to testHS1
        Test.startTest();
        delete hsPrevEd2;
        Test.stopTest();

        // Retrieve updated contact
        testCon = [SELECT Id, Last_HS_Attended__c, Last_College_Attended__c FROM Contact WHERE Id = :testCon.Id];

        // Assert
        System.assertEquals(testHS1.Id, testCon.Last_HS_Attended__c);
        System.assertEquals(null, testCon.Last_College_Attended__c);
    }

    @isTest
    private static void testUpdateContactMultipleUnDelete() {
        // Retrieve setup data
        Contact testCon = [SELECT Id FROM Contact LIMIT 1];
        List<Account> testHSs = [SELECT Id FROM Account WHERE Institution_Type__c = 'HS'];
        Account testHS1 = testHSs[0];
        Account testHS2 = testHSs[1];

        // Contact will have multiple HS Prev Educations
        Previous_Education__c hsPrevEd = new Previous_Education__c(Contact__c = testCon.Id, Account__c = testHS1.Id);
        insert hsPrevEd; // this will set the contact's Last HS to testHS1
        ObjectService.wait(2000); // need to ensure the update timestamp on hsPrevEd2 is later than the timestamp on hsPrevEd

        Previous_Education__c hsPrevEd2 = new Previous_Education__c(Contact__c = testCon.Id, Account__c = testHS2.Id);
        insert hsPrevEd2; // this will set the contact's Last HS to testHS2

        delete hsPrevEd2; // this will set the contact's Last HS to testHS1

        // Should update the contact's Last HS to testHS2
        Test.startTest();
        undelete hsPrevEd2;
        Test.stopTest();

        // Retrieve updated contact
        testCon = [SELECT Id, Last_HS_Attended__c, Last_College_Attended__c FROM Contact WHERE Id = :testCon.Id];

        // Assert
        System.assertEquals(testHS2.Id, testCon.Last_HS_Attended__c);
        System.assertEquals(null, testCon.Last_College_Attended__c);
    }

    @isTest
    private static void testLastHighSchoolAttended() {
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

        System.Assert(
            LastRuleType == 'Last Attended High School',
            'Rule did not assign correctly by rule type Last High School Attended'
        );
    }

    @isTest
    private static void testLastCollegeAttended() {
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

        System.Assert(
            LastRuleType == 'Last Attended College, Type ' + Opp.Type,
            'Rule did not assign correctly by rule type Last College Attended'
        );
    }
}