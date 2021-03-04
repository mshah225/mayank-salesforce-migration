@isTest
private class BatchApplyIerPrivacyTest {
    @isTest
    private static void BatchIerCampaignPrivacyChange() {
        Group testGroup = TestDataFactory.createTestGroupAndQueue(
            new List<String>{ 'Subscription__c', 'et4ae5__IndividualEmailResult__c', 'et4ae5__Business_Unit__c' }
        );
        List<Subscription__c> subscriptions = TestDataFactory.createTestSubscriptions(1);
        for (Subscription__c subscription : subscriptions) {
            subscription.OwnerId = testGroup.Id;
            subscription.Subscriber_Private_in_Salesforce__c = true;
        }
        insert subscriptions;

        List<Campaign> campaigns = CampaignService.createTestCampaignOfType(1, 'Communication');
        for (Campaign c : campaigns) {
            c.Subscription__c = subscriptions[0].Id;
            c.IER_Privacy__c = 'Override as Public';
        }
        insert campaigns;

        List<et4ae5__Business_Unit__c> buList = TestDataFactory.createBusinessUnits(1);
        for (et4ae5__Business_Unit__c bu : buList) {
            bu.IER_Private_in_Salesforce__c = false;
        }
        insert buList;

        List<et4ae5__SendDefinition__c> sdList = TestDataFactory.createEmailSends(1, 'Send Definition');
        for (et4ae5__SendDefinition__c sd : sdList) {
            sd.et4ae5__Business_Unit__c = buList[0].Id;
            sd.et4ae5__Campaign__c = campaigns[0].Id;
        }
        insert sdList;

        List<Contact> contacts = ContactService.createTestContacts(5);
        insert contacts;

        List<et4ae5__IndividualEmailResult__c> ierList = TestDataFactory.createTestIERs(contacts, sdList);
        Set<Id> iersUnderTest = new Set<Id>();
        for (et4ae5__IndividualEmailResult__c ier : ierList) {
            iersUnderTest.add(ier.Id);
        }
        insert ierList;

        for (et4ae5__IndividualEmailResult__c ier : [
            SELECT Id, OwnerId, Apex_Owner_Should_Be__c
            FROM et4ae5__IndividualEmailResult__c
            WHERE Id IN :iersUnderTest
        ]) {
            System.assertEquals(ier.OwnerId, ier.Apex_Owner_Should_Be__c, 'OwnerId was not initially set as expected');
        }

        for (Campaign c : campaigns) {
            c.IER_Privacy__c = 'Override as Private to Subscription Queue';
        }
        update campaigns;

        Test.startTest();
        BatchApplyIerPrivacy batch = new BatchApplyIerPrivacy();
        Database.executeBatch(batch);
        Test.stopTest();

        for (et4ae5__IndividualEmailResult__c ier : [
            SELECT Id, OwnerId, Apex_Owner_Should_Be__c
            FROM et4ae5__IndividualEmailResult__c
            WHERE Id IN :iersUnderTest
        ]) {
            System.assertEquals(ier.OwnerId, ier.Apex_Owner_Should_Be__c, 'OwnerId was not re-set as expected');
        }
    }

    @isTest
    private static void BatchIerBusinessUnitPrivacyChange() {
        Group testGroup = TestDataFactory.createTestGroupAndQueue(
            new List<String>{ 'Subscription__c', 'et4ae5__IndividualEmailResult__c', 'et4ae5__Business_Unit__c' }
        );
        List<Subscription__c> subscriptions = TestDataFactory.createTestSubscriptions(1);
        for (Subscription__c subscription : subscriptions) {
            subscription.OwnerId = testGroup.Id;
            subscription.IER_Private_in_Salesforce__c = true;
        }
        insert subscriptions;

        List<Campaign> campaigns = CampaignService.createTestCampaignOfType(1, 'Communication');
        for (Campaign c : campaigns) {
            c.Subscription__c = subscriptions[0].Id;
            c.IER_Privacy__c = 'Override as Public';
        }
        insert campaigns;

        List<et4ae5__Business_Unit__c> buList = TestDataFactory.createBusinessUnits(1);
        for (et4ae5__Business_Unit__c bu : buList) {
            bu.IER_Private_in_Salesforce__c = false;
        }
        insert buList;

        List<et4ae5__SendDefinition__c> sdList = TestDataFactory.createEmailSends(1, 'Send Definition');
        for (et4ae5__SendDefinition__c sd : sdList) {
            sd.et4ae5__Business_Unit__c = buList[0].Id;
            sd.et4ae5__Campaign__c = campaigns[0].Id;
        }
        insert sdList;

        List<Contact> contacts = ContactService.createTestContacts(5);
        insert contacts;

        List<et4ae5__IndividualEmailResult__c> ierList = TestDataFactory.createTestIERs(contacts, sdList);
        insert ierList;

        for (et4ae5__IndividualEmailResult__c ier : [
            SELECT Id, OwnerId, Apex_Owner_Should_Be__c
            FROM et4ae5__IndividualEmailResult__c
        ]) {
            System.assertEquals(ier.OwnerId, ier.Apex_Owner_Should_Be__c, 'OwnerId was not initially set as expected');
        }

        for (et4ae5__Business_Unit__c bu : buList) {
            bu.OwnerId = testGroup.Id;
            bu.IER_Private_in_Salesforce__c = true;
        }
        update buList;

        Test.startTest();
        BatchApplyIerPrivacy batch = new BatchApplyIerPrivacy();
        Database.executeBatch(batch);
        Test.stopTest();

        for (et4ae5__IndividualEmailResult__c ier : [
            SELECT Id, OwnerId, Apex_Owner_Should_Be__c
            FROM et4ae5__IndividualEmailResult__c
        ]) {
            System.assertEquals(ier.OwnerId, ier.Apex_Owner_Should_Be__c, 'OwnerId was not re-set as expected');
        }
    }

    @isTest
    private static void BatchIerSubscriptionPrivacyChange() {
        Group testGroup = TestDataFactory.createTestGroupAndQueue(
            new List<String>{ 'Subscription__c', 'et4ae5__IndividualEmailResult__c', 'et4ae5__Business_Unit__c' }
        );
        List<Subscription__c> subscriptions = TestDataFactory.createTestSubscriptions(1);
        insert subscriptions;

        List<Campaign> campaigns = CampaignService.createTestCampaignOfType(1, 'Communication');
        for (Campaign c : campaigns) {
            c.Subscription__c = subscriptions[0].Id;
            c.IER_Privacy__c = 'Override as Public';
        }
        insert campaigns;

        List<et4ae5__Business_Unit__c> buList = TestDataFactory.createBusinessUnits(1);
        for (et4ae5__Business_Unit__c bu : buList) {
            bu.IER_Private_in_Salesforce__c = false;
        }
        insert buList;

        List<et4ae5__SendDefinition__c> sdList = TestDataFactory.createEmailSends(1, 'Send Definition');
        for (et4ae5__SendDefinition__c sd : sdList) {
            sd.et4ae5__Business_Unit__c = buList[0].Id;
            sd.et4ae5__Campaign__c = campaigns[0].Id;
        }
        insert sdList;

        List<Contact> contacts = ContactService.createTestContacts(5);
        insert contacts;

        List<et4ae5__IndividualEmailResult__c> ierList = TestDataFactory.createTestIERs(contacts, sdList);
        insert ierList;

        for (et4ae5__IndividualEmailResult__c ier : [
            SELECT Id, OwnerId, Apex_Owner_Should_Be__c
            FROM et4ae5__IndividualEmailResult__c
        ]) {
            System.assertEquals(ier.OwnerId, ier.Apex_Owner_Should_Be__c, 'OwnerId was not initially set as expected');
        }

        for (Subscription__c subscription : subscriptions) {
            subscription.OwnerId = testGroup.Id;
            subscription.IER_Private_in_Salesforce__c = true;
        }
        update subscriptions;

        Test.startTest();
        BatchApplyIerPrivacy batch = new BatchApplyIerPrivacy();
        Database.executeBatch(batch);
        Test.stopTest();

        for (et4ae5__IndividualEmailResult__c ier : [
            SELECT Id, OwnerId, Apex_Owner_Should_Be__c
            FROM et4ae5__IndividualEmailResult__c
        ]) {
            System.assertEquals(ier.OwnerId, ier.Apex_Owner_Should_Be__c, 'OwnerId was not re-set as expected');
        }
    }
}
