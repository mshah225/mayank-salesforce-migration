@isTest
public with sharing class StudentProgramPlanTriggerTest {
    @TestSetup
    static void setup() {
        Contact c = new Contact(FirstName = 'AutoSubscriberHelperTest', LastName = 'TestContact');
        insert c;
    }

    @isTest
    private static void testAutoSubscribing() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Auto_Subscriber_Setting__mdt subscriberSetting = [
            SELECT Subscriptions_To_Add__c
            FROM Auto_Subscriber_Setting__mdt
            WHERE Active__c = TRUE AND Related_Object__r.DeveloperName = 'Student_Program_Plan'
        ];

        Student_Program_Plan__c testPlan = new Student_Program_Plan__c(
            Contact__c = c.Id,
            Career__c = 'Graduate',
            Status__c = 'Active In Program'
        );

        Test.startTest();
        insert testPlan;
        Test.stopTest();

        List<String> settingSubcriptionIds = subscriberSetting.Subscriptions_To_Add__c.split(',');
        List<Subscription__c> subscriptionObjs = [SELECT Id FROM Subscription__c WHERE Id IN :settingSubcriptionIds];
        List<Subscriber__c> subscriberObjs = [
            SELECT Contact__c, Subscription__c
            FROM Subscriber__c
            WHERE Subscription__c IN :settingSubcriptionIds AND Contact__c = :c.Id
        ];

        // For each subscription object in this org that matches one of the Ids set in Auto_Subscriber_Setting__mdt
        // check if a subscriber was created
        // If the Ids don't match any subscriptions in this org (because this org doesn't have the correct subscription objects)
        // then this will not assert anything - which is fine
        for (Subscription__c subscriptionObj : subscriptionObjs) {
            Boolean found = false;
            for (Subscriber__c subcriberObj : subscriberObjs) {
                if (subcriberObj.Subscription__c == subscriptionObj.Id) {
                    found = true;
                    break;
                }
            }
            System.assert(found, 'Could not find subscriber object corresponding to subscription in setting');
        }
    }

    @isTest
    private static void testCoverage() {
        // Just edit/delete/undelete the Student_Program_Plan__c objects
        // all here since these have no expected behavior
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        Student_Program_Plan__c testPlan = new Student_Program_Plan__c(
            Contact__c = c.Id,
            Career__c = 'Graduate',
            Status__c = 'Active In Program'
        );

        insert testPlan;

        testPlan.Career__c = 'Undergraduate';

        Test.startTest();
        update testPlan;
        delete testPlan;
        undelete testPlan;
        Test.stopTest();
    }
}
