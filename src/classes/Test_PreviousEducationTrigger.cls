@istest
private with sharing class Test_PreviousEducationTrigger {
    // Need to update with the correct test user
    private static User TestUser;
    private static Account HS = new Account();
    private static Account College = new Account();

    @testSetup
    static void setup() {
        TestUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = TRUE LIMIT 1];
    }

    private static testMethod void testContactInsertFromPreviousEducationHS() {
        HS.Name = 'Test High School';
        HS.Institution_Type__c = 'HS';
        insert HS;

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        Con.Last_HS_Attended__c = null;
        Con.Last_College_Attended__c = null;
        insert Con;

        //Test inserting a High School. The trigger updates the contact accordingly.
        Previous_Education__c PEHS = new Previous_Education__c();
        PEHS.Contact__c = Con.Id;
        PEHS.Account__c = HS.Id;

        Test.startTest();
        insert PEHS;
        Test.stopTest();

        // Assertions
        Id HSId = [SELECT Last_HS_Attended__c FROM Contact WHERE Id = :Con.Id LIMIT 1].Last_HS_Attended__c;
        System.Assert(HSId == PEHS.Account__c, 'Contact Last High School Attended did not update correctly.');
    }

    private static testMethod void testContactInsertFromPreviousEducationCollege() {
        College.Name = 'Test College';
        College.Institution_Type__c = '4YR';
        insert College;

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        Con.Last_HS_Attended__c = null;
        Con.Last_College_Attended__c = null;
        insert Con;

        //Test Inserting a College. The trigger updates the contact accordingly.
        Previous_Education__c PEC = new Previous_Education__c();
        PEC.Contact__c = Con.Id;
        PEC.Account__c = College.Id;
        Test.startTest();
        insert PEC;
        Test.stopTest();

        Id CollegeId = [SELECT Last_College_Attended__c FROM Contact WHERE Id = :Con.Id LIMIT 1]
        .Last_College_Attended__c;
        System.Assert(CollegeId == PEC.Account__c, 'Contact Last College Attended did not update correctly.');
    }

    private static testMethod void testContactUpdateFromPreviousEducationHS() {
        HS.Name = 'Test High School';
        HS.Institution_Type__c = 'HS';
        insert HS;

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        Con.Last_HS_Attended__c = null;
        Con.Last_College_Attended__c = null;
        insert Con;

        //Test inserting a High School. The trigger updates the contact accordingly.
        Previous_Education__c PEHS = new Previous_Education__c();
        PEHS.Contact__c = Con.Id;
        PEHS.Account__c = HS.Id;

        insert PEHS;

        Test.startTest();
        update PEHS;
        Test.stopTest();

        // Assertions
        Id HSId = [SELECT Last_HS_Attended__c FROM Contact WHERE Id = :Con.Id LIMIT 1].Last_HS_Attended__c;
        System.Assert(HSId == PEHS.Account__c, 'Contact Last High School Attended did not update correctly.');
    }

    private static testMethod void testContactUpdateFromPreviousEducationCollege() {
        College.Name = 'Test College';
        College.Institution_Type__c = '4YR';
        insert College;

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        Con.Last_HS_Attended__c = null;
        Con.Last_College_Attended__c = null;
        insert Con;

        //Test Inserting a College. The trigger updates the contact accordingly.
        Previous_Education__c PEC = new Previous_Education__c();
        PEC.Contact__c = Con.Id;
        PEC.Account__c = College.Id;
        insert PEC;

        Test.startTest();
        update PEC;
        Test.stopTest();

        Id CollegeId = [SELECT Last_College_Attended__c FROM Contact WHERE Id = :Con.Id LIMIT 1]
        .Last_College_Attended__c;
        System.Assert(CollegeId == PEC.Account__c, 'Contact Last College Attended did not update correctly.');
    }
}
