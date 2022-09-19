public class CampaignMemberDispatcher implements TriggerDispatcherInterface {
    private List<CampaignMember> newList;
    private Map<Id, CampaignMember> newMap;
    private List<CampaignMember> oldList;
    private Map<Id, CampaignMember> oldMap;

    public CampaignMemberDispatcher(
        List<CampaignMember> newList,
        Map<Id, CampaignMember> newMap,
        List<CampaignMember> oldList,
        Map<Id, CampaignMember> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        CampaignMemberService cms = new CampaignMemberService(newList, oldMap);
        if (!CampaignMemberService.ranCampaignMembersUpdatePrimary) {
            cms.updateLastMemberStatusChange();
            cms.processingBefore();
            cms.addInTriggerToContactAndLeadMap();
            if (!cms.isMembersByContactsEmpty()) {
                cms.processContacts();
            }
            if (!cms.isMembersByLeadsEmpty()) {
                cms.processLeads();
            }
        }
        cms.markAffectedMembersPrimaryAndOpportunties();
    }

    public void beforeUpdate() {
        CampaignMemberService cms = new CampaignMemberService(newList, oldMap);
        if (!CampaignMemberService.ranCampaignMembersUpdatePrimary) {
            cms.updateLastMemberStatusChange();
            cms.processingBefore();
            cms.addInTriggerToContactAndLeadMap();
            if (!cms.isMembersByContactsEmpty()) {
                cms.processContacts();
            }
            if (!cms.isMembersByLeadsEmpty()) {
                cms.processLeads();
            }
        }
        cms.markAffectedMembersPrimaryAndOpportunties();
    }

    public void beforeDelete() {
        CampaignMemberService cms = new CampaignMemberService(oldList, oldMap);
        if (!CampaignMemberService.ranCampaignMembersUpdatePrimary) {
            cms.processingBefore();

            if (!cms.isMembersByContactsEmpty()) {
                cms.processContacts();
            }
            if (!cms.isMembersByLeadsEmpty()) {
                cms.processLeads();
            }
        }
    }

    public void afterInsert() {
        CampaignMemberService cms = new CampaignMemberService(newList, oldMap);
        cms.assignNationalMeritFlag(newMap.keySet());
        List<CampaignMember> campaignMembersToUpdate = cms.setPrimaryInterestOnCampaignMembers();
        cms.updateOpportunities();
        cms.updateLeads();
        cms.updateCampaignMembers(campaignMembersToUpdate);
        cms.clearDataAfter();

        AutoSubscriberService autoSubService = new AutoSubscriberService(newList, 'CampaignMember');
        autoSubService.processCampaignMemberRecords();
    }

    public void afterUpdate() {
        CampaignMemberService cms = new CampaignMemberService(newList, oldMap);
        cms.assignNationalMeritFlag(newMap.keySet());
        List<CampaignMember> campaignMembersToUpdate = cms.setPrimaryInterestOnCampaignMembers();
        cms.updateOpportunities();
        cms.updateLeads();
        cms.updateCampaignMembers(campaignMembersToUpdate);
        cms.clearDataAfter();
    }

    public void afterDelete() {
        CampaignMemberService cms = new CampaignMemberService(oldList, oldMap);
        cms.assignNationalMeritFlag(oldMap.keySet());
        List<CampaignMember> campaignMembersToUpdate = cms.setPrimaryInterestOnCampaignMembers();
        cms.updateOpportunities();
        cms.updateLeads();
        cms.updateCampaignMembers(campaignMembersToUpdate);
        cms.clearDataAfter();
    }
    public void afterUndelete() {
    }
}
