@isTest
private with sharing class PreviousEducationTriggerTest {
    @TestSetup
    private static void setup() {
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
    private static void testUpdateContactMultipleInsertLastHS() {
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
    private static void testUpdateContactMultipleUpdateLastHS() {
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
}
