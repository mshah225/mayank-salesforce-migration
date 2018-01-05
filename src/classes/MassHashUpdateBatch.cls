global class MassHashUpdateBatch {
    
    public MassHashUpdateBatch () {
        SubscriberHashUpdateBatch tmpSubscriber = new SubscriberHashUpdateBatch();
        Id subscriberBatchProcessId = Database.executeBatch(tmpSubscriber);
        
        SubscriptionHashUpdateBatch tmpSubscription = new SubscriptionHashUpdateBatch();
        Id subscriptionBatchProcessId = Database.executeBatch(tmpSubscription);
        
        LeadHashUpdateBatch tmpLead = new LeadHashUpdateBatch();
        Id leadBatchProcessId = Database.executeBatch(tmpLead);
        
        ContactHashUpdateBatch tmpContact = new ContactHashUpdateBatch();
        Id contactBatchProcessId = Database.executeBatch(tmpContact);
        
        CampaignHashUpdateBatch tmpCampaign = new CampaignHashUpdateBatch();
        Id campaignBatchProcessId = Database.executeBatch(tmpCampaign);
    }
}