public class CampaignMemberFactory extends TestFactory {
    public static final CampaignMember DEFAULT_CAMPAIGN_MEMBER = new CampaignMember(Status = 'Interested');

    public CampaignMemberFactory(CampaignMember testCampaignMember) {
        super(testCampaignMember);
    }

    public void setLeadOrContact(Sobject attachObject) {
        if (attachObject.getSObjectType().getDescribe().getName() == 'Contact') {
            this.setRelatedObject('ContactId', attachObject);
        } else if (attachObject.getSObjectType().getDescribe().getName() == 'Lead') {
            this.setRelatedObject('LeadId', attachObject);
        }
    }

    public CampaignMember createOne() {
        return (CampaignMember) this.create()[0];
    }
}
