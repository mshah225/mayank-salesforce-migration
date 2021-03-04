public class MassHashUpdateBatch {
    public MassHashUpdateBatch() {
        Database.executeBatch(new SubscriberHashUpdateBatch());
        Database.executeBatch(new SubscriptionHashUpdateBatch());
        Database.executeBatch(new LeadHashUpdateBatch());
        Database.executeBatch(new ContactHashUpdateBatch());
        Database.executeBatch(new CampaignHashUpdateBatch());
    }
}
