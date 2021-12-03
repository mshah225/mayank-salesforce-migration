@isTest
public with sharing class AutoSubscriberFilterHelperTest {
    @TestSetup
    static void setup() {
        Contact c = new Contact(FirstName = 'AutoSubscriberFilterHelperTest', LastName = 'TestContact');
        insert c;

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
            RecordTypeId = RecordIdHelper.getRecordTypeId('Campaign', 'EOSS_Event')
        );
        insert testCampaign;

        CampaignMember testCMember = new CampaignMember(ContactId = c.Id, CampaignId = testCampaign.Id);
        insert testCMember;
    }

    @isTest
    private static void testPassFilterProgramPlan() {
        Student_Program_Plan__c testPlan = new Student_Program_Plan__c(
            Career__c = 'Graduate',
            Status__c = 'Active In Program'
        );

        Test.startTest();
        Boolean result = AutoSubscriberFilterHelper.filterProgramPlan('Graduate_College', testPlan);
        Test.stopTest();

        System.assert(result);
    }

    @isTest
    private static void testFailFilterProgramPlan() {
        Student_Program_Plan__c testPlanWrongMethod = new Student_Program_Plan__c();
        Student_Program_Plan__c testPlanWrongCareer = new Student_Program_Plan__c(Career__c = 'Undergraduate');
        Student_Program_Plan__c testPlanWrongStatus = new Student_Program_Plan__c(
            Career__c = 'Graduate',
            Status__c = 'Not Active In Program'
        );
        Student_Program_Plan__c testPlanWrongPlanCode1 = new Student_Program_Plan__c(
            Career__c = 'Graduate',
            Status__c = 'Active In Program',
            Plan_Code__c = 'PRISEPGR'
        );
        Student_Program_Plan__c testPlanWrongPlanCode2 = new Student_Program_Plan__c(
            Career__c = 'Graduate',
            Status__c = 'Active In Program',
            Plan_Code__c = 'GRPLUS'
        );
        Student_Program_Plan__c testPlanWrongPlanCode3 = new Student_Program_Plan__c(
            Career__c = 'Graduate',
            Status__c = 'Active In Program',
            Plan_Code__c = 'CONTAINS_GERT'
        );
        Student_Program_Plan__c testPlanWrongPlanDesc = new Student_Program_Plan__c(
            Career__c = 'Graduate',
            Status__c = 'Active In Program',
            Plan_Description__c = 'CONTAINS_UG'
        );

        Test.startTest();
        Boolean resultWrongMethod = AutoSubscriberFilterHelper.filterProgramPlan('WRONG_METHOD', testPlanWrongMethod);
        Boolean resultWrongCareer = AutoSubscriberFilterHelper.filterProgramPlan(
            'Graduate_College',
            testPlanWrongCareer
        );
        Boolean resultWrongStatus = AutoSubscriberFilterHelper.filterProgramPlan(
            'Graduate_College',
            testPlanWrongStatus
        );
        Boolean resultWrongPlanCode1 = AutoSubscriberFilterHelper.filterProgramPlan(
            'Graduate_College',
            testPlanWrongPlanCode1
        );
        Boolean resultWrongPlanCode2 = AutoSubscriberFilterHelper.filterProgramPlan(
            'Graduate_College',
            testPlanWrongPlanCode2
        );
        Boolean resultWrongPlanCode3 = AutoSubscriberFilterHelper.filterProgramPlan(
            'Graduate_College',
            testPlanWrongPlanCode3
        );
        Boolean resultWrongPlanDesc = AutoSubscriberFilterHelper.filterProgramPlan(
            'Graduate_College',
            testPlanWrongPlanDesc
        );
        Test.stopTest();

        System.assert(!resultWrongMethod);
        System.assert(!resultWrongCareer);
        System.assert(!resultWrongStatus);
        System.assert(!resultWrongPlanCode1);
        System.assert(!resultWrongPlanCode2);
        System.assert(!resultWrongPlanCode3);
        System.assert(!resultWrongPlanDesc);
    }

    @isTest
    private static void testPassFilterCampaignMember() {
        CampaignMember testCMember = [SELECT Id, CampaignId, ContactId FROM CampaignMember LIMIT 1];

        Test.startTest();
        AutoSubscriberHelper helper = new AutoSubscriberHelper('');
        helper.setCampaignAndOpportunityInformation(new List<CampaignMember>{ testCMember });
        Boolean result = AutoSubscriberFilterHelper.filterCampaignMember('Access_Asu', testCMember);
        Test.stopTest();

        System.assert(result);
    }

    @isTest
    private static void testFailFilterCampaignMember() {
        CampaignMember testCMember = [SELECT Id, CampaignId, ContactId FROM CampaignMember LIMIT 1];

        CampaignMember testCMemberWrongMethod = new CampaignMember();
        CampaignMember testCMemberWrongCampaignId = new CampaignMember();
        CampaignMember testCMemberWrongContactId = new CampaignMember(CampaignId = testCMember.CampaignId);

        Test.startTest();
        AutoSubscriberHelper helper = new AutoSubscriberHelper('');
        helper.setCampaignAndOpportunityInformation(new List<CampaignMember>{ testCMember });
        Boolean resultWrongMethod = AutoSubscriberFilterHelper.filterCampaignMember(
            'WRONG_METHOD',
            testCMemberWrongMethod
        );
        Boolean resultWrongCampaignId = AutoSubscriberFilterHelper.filterCampaignMember(
            'Access_Asu',
            testCMemberWrongCampaignId
        );
        Boolean resultWrongContactId = AutoSubscriberFilterHelper.filterCampaignMember(
            'Access_Asu',
            testCMemberWrongContactId
        );
        Test.stopTest();

        System.assert(!resultWrongMethod);
        System.assert(!resultWrongCampaignId);
        System.assert(!resultWrongContactId);
    }
}
