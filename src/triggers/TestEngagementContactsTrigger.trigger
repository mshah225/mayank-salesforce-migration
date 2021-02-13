trigger TestEngagementContactsTrigger on Test_Engagement_Contacts__c(after insert, after update) {
    TriggerFactory.createAndExecuteHandler(TestEngagementContactsHandler.class);
}
