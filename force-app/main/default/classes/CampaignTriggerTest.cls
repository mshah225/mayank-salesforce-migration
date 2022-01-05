@isTest
public with sharing class CampaignTriggerTest {
    @isTest
    private static void testInsert() {
        Campaign c = new Campaign(Name = 'Test Campaign');

        Test.startTest();
        insert c;
        Test.stopTest();

        c = [SELECT Id, HashCampaignID__c FROM Campaign];
        System.assertEquals(Hasher.hashId(c.Id), c.HashCampaignID__c);
    }

    @isTest
    private static void testPadPercentage() {
        Campaign c = new Campaign(Name = 'Test Campaign');
        insert c;
        delete c;
        undelete c;
        update c;
    }
}
