@isTest
public with sharing class SilverpopDeleterTest {
    @TestSetup
    private static void setup() {
        Silverpop__Silverpop_Email_Campaign_Link__c sp = new Silverpop__Silverpop_Email_Campaign_Link__c();
        insert sp;
    }

    @isTest
    private static void testScramble() {
        Silverpop__Silverpop_Email_Campaign_Link__c sp = [
            SELECT Id
            FROM Silverpop__Silverpop_Email_Campaign_Link__c
            LIMIT 1
        ];

        Test.startTest();
        SilverpopDeleter deleter = new SilverpopDeleter(sp);
        Silverpop__Silverpop_Email_Campaign_Link__c scrambled = (Silverpop__Silverpop_Email_Campaign_Link__c) deleter.scrambleFields();
        Test.stopTest();

        System.assertEquals(sp.Id, scrambled.Id);
    }

    @isTest
    private static void testToString() {
        Silverpop__Silverpop_Email_Campaign_Link__c sp = [
            SELECT Id
            FROM Silverpop__Silverpop_Email_Campaign_Link__c
            LIMIT 1
        ];

        Test.startTest();
        SilverpopDeleter deleter = new SilverpopDeleter(sp);
        String csvStr = deleter.toCsvString();
        Test.stopTest();

        System.assertEquals(sp.Id + '\n', csvStr);
    }
}
