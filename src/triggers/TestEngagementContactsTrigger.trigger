trigger TestEngagementContactsTrigger on Test_Engagement_Contacts__c (after insert, after update) {
    et4ae5.triggerUtility.automate('Test_Engagement_Contacts__c');
    TriggerFactory.createAndExecuteHandler(TestEngagementContactsHandler.class);
}