@isTest
public with sharing class AutoSubscriberServiceTest {
    @TestSetup
    private static void setup() {
        Contact c = new Contact(FirstName = 'AutoSubscriberHelperTest', LastName = 'TestContact');
        insert c;
    }

    @isTest
    private static void testProcessStudentProgramPlanRecords() {
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
        AutoSubscriberService service = new AutoSubscriberService(
            new List<Student_Program_Plan__c>{ testPlan },
            'Student_Program_Plan'
        );
        service.processStudentProgramPlanRecords();
        Test.stopTest();

        System.assertEquals(subscriberSetting.Subscriptions_To_Add__c.split(',').size(), service.results.size());
    }

    @isTest
    private static void testProcessCampaignMemberRecords() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Auto_Subscriber_Setting__mdt subscriberSetting = [
            SELECT Subscriptions_To_Add__c
            FROM Auto_Subscriber_Setting__mdt
            WHERE Active__c = TRUE AND Related_Object__r.DeveloperName = 'CampaignMember'
        ];

        Account acc = new Account(Name = 'Arizona State University', Type = 'HS');
        insert acc;

        Opportunity testOppo = new Opportunity(
            Contact__c = c.Id,
            Career__c = 'Undergraduate',
            AccountId = acc.Id,
            Name = 'TestOppo',
            StageName = 'TestOppo',
            CloseDate = Date.newInstance(2023, 9, 12)
        );
        insert testOppo;

        Campaign testCampaign = new Campaign(
            Name = 'TestCampaign',
            RecordTypeId = IDHelper.getRecordTypeId('Campaign', 'EOSS_Event')
        );
        insert testCampaign;

        CampaignMember testCMember = new CampaignMember(ContactId = c.Id, CampaignId = testCampaign.Id);

        Test.startTest();
        AutoSubscriberService service = new AutoSubscriberService(
            new List<CampaignMember>{ testCMember },
            'CampaignMember'
        );
        service.processCampaignMemberRecords();
        Test.stopTest();

        System.assertEquals(subscriberSetting.Subscriptions_To_Add__c.split(',').size(), service.results.size());
    }
}
