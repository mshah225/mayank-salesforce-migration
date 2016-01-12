/**
 * Created by aesanch2 on 12/31/15.
 */

public class CampaignMemberService
{
    /**
    * Generates a campaign member for a scanbiz created contact
    * @param Id contactId
    * @param Id campaignId
    * @return CampaignMember member
    */
    public static CampaignMember createScanbizCampaignMember(Id contactId, Id campaignId)
    {
        CampaignMember member = new CampaignMember();

        member.CampaignId = campaignId;
        member.ContactId = contactId;

        return member;
    }
}