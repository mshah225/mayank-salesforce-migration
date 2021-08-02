@isTest
public with sharing class LeadDeleterTest {
    @TestSetup
    static void setup() {
        Lead l = new Lead(
            LastName = 'TestLead',
            FirstName = 'LeadDeleterTest',
            Company = 'TestLead',
            Email = 'LeadDeleterTest.TestLead@test.test',
            LeadSource = 'Email',
            Type__c = 'First Time Freshman'
        );
        insert l;
    }

    @isTest
    private static void testScramble() {
        Lead l = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
        LeadDeleter deleter = new LeadDeleter(l);
        Lead scrambled = (Lead)deleter.scrambleFields();
        Test.stopTest();

        System.assertEquals(l.Id, scrambled.Id);
    }

    @isTest
    private static void testToString() {
        Lead l = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
        LeadDeleter deleter = new LeadDeleter(l);
        String csvStr = deleter.toCsvString();
        Test.stopTest();

        System.assertEquals(l.Id + '\n', csvStr);
    }
}
