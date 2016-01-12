/**
 * Created by aesanch2 on 12/31/15.
 */

public class CampaignService
{
    /**
    * Generates a test campaign.
    * @param String name
    * @param Id recordType
    * @return Campaign testCampaign
    */
    public static Campaign createTestCampaign(String name, Id recordType)
    {
        Campaign testCampaign = new Campaign();

        testCampaign.Name = name;
        testCampaign.CampaignMemberRecordTypeId = recordType;
        testCampaign.IsActive = true;
        testCampaign.Status = 'Planned';

        return testCampaign;
    }
}