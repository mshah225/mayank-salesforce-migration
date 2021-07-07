@isTest
public class CampaignFactory extends TestFactory {
    public static final Campaign DEFAULT_CAMPAIGN = new Campaign(Name = 'Test Campaign');

    public CampaignFactory(Campaign testCampaign) {
        super(testCampaign);
    }
}
