@isTest
public with sharing class SubscriberAutoSubscriptionServiceTest {
    @isTest
    private static void testProcessStudentProgramPlanRecords() {
        Contact c = new Contact(FirstName = 'SubscriberAutoSubscriptionServiceTest', LastName = 'TestContact');
        insert c;

        Subscriber_Auto_Subscription_Mapping__mdt subscriberSetting = [
            SELECT Subscriptions_To_Add__c
            FROM Subscriber_Auto_Subscription_Mapping__mdt
            WHERE Active__c = TRUE AND Related_Object__r.DeveloperName = 'Student_Program_Plan'
        ];

        Student_Program_Plan__c testPlan = new Student_Program_Plan__c(
            Contact__c = c.Id,
            Career__c = 'Graduate',
            Status__c = 'Active In Program'
        );

        Test.startTest();
        SubscriberAutoSubscriptionService service = new SubscriberAutoSubscriptionService(
            new List<Student_Program_Plan__c>{ testPlan },
            'Student_Program_Plan'
        );
        service.processStudentProgramPlanRecords();
        Test.stopTest();

        System.assertEquals(subscriberSetting.Subscriptions_To_Add__c.split(',').size(), service.results.size());
    }

    @isTest
    private static void testProcessCampaignMemberRecords() {
        Contact c = new Contact(FirstName = 'SubscriberAutoSubscriptionServiceTest', LastName = 'TestContact');
        insert c;

        Subscriber_Auto_Subscription_Mapping__mdt subscriberSetting = [
            SELECT Subscriptions_To_Add__c
            FROM Subscriber_Auto_Subscription_Mapping__mdt
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
            RecordTypeId = RecordIdHelper.getRecordTypeId('Campaign', 'EOSS_Event')
        );
        insert testCampaign;

        CampaignMember testCMember = new CampaignMember(ContactId = c.Id, CampaignId = testCampaign.Id);

        Test.startTest();
        SubscriberAutoSubscriptionService service = new SubscriberAutoSubscriptionService(
            new List<CampaignMember>{ testCMember },
            'CampaignMember'
        );
        service.processCampaignMemberRecords();
        Test.stopTest();

        System.assertEquals(subscriberSetting.Subscriptions_To_Add__c.split(',').size(), service.results.size());
    }

    @isTest
    private static void testProcessRelationshipRecords() {
        // Retrieve the Subscriber_Auto_Subscription_Mapping__mdt record
        Subscriber_Auto_Subscription_Mapping__mdt subscriberSetting = [
            SELECT Subscriptions_To_Add__c
            FROM Subscriber_Auto_Subscription_Mapping__mdt
            WHERE Active__c = TRUE AND Related_Object__r.DeveloperName = 'Relationship'
        ];

        // Create the Relationships__c custom setting records
        List<Relationships__c> settingsToCreate = new List<Relationships__c>();
        settingsToCreate.add(new Relationships__c(Name = 'Parent/Guardian', Reciprocal__c = 'Child'));
        settingsToCreate.add(new Relationships__c(Name = 'Child', Reciprocal__c = 'Parent/Guardian'));
        insert settingsToCreate;

        // Retrieve the RecordType for Relationship__c
        Id relationshipRecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Relationship__c' AND DeveloperName = 'Contact_to_Contact'
        ]
        .Id;

        // Create test Contacts
        List<Contact> contactsToCreate = new List<Contact>{
            new Contact(FirstName = 'Parent', LastName = 'Test'),
            new Contact(FirstName = 'Child', LastName = 'Test')
        };
        insert contactsToCreate;

        // Create test Relationship__c records with the correct Source__c
        List<Relationship__c> relsToCreate = new List<Relationship__c>{
            new Relationship__c(
                Contact__c = contactsToCreate[0].Id,
                Related_Contact__c = contactsToCreate[1].Id,
                Relationship_Type__c = 'Parent/Guardian',
                Active_Relationship__c = true,
                Relationship_Start_Date__c = Date.today(),
                RecordTypeId = relationshipRecordTypeId,
                Source__c = 'Access ASU Program',
                Source_Date__c = Date.today()
            )
        };
        insert relsToCreate;

        // Create the service and process the original relationships
        SubscriberAutoSubscriptionService service = new SubscriberAutoSubscriptionService(
            new List<sObject>{ relsToCreate[0] },
            'Relationship'
        );

        Test.startTest();
        service.processRelationshipRecords();
        Test.stopTest();

        // Verify that the expected number of subscribers were created
        Integer expectedSubscriberCount = subscriberSetting.Subscriptions_To_Add__c.split(',').size();
        List<Subscriber__c> subscribers = [SELECT Id FROM Subscriber__c WHERE Contact__c = :contactsToCreate[0].Id];
        System.assertEquals(
            expectedSubscriberCount,
            subscribers.size(),
            'The number of Subscriber__c records should match the expected count.'
        );
    }
}