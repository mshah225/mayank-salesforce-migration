public class CampaignMemberDispatcher implements IDispatch {
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
        CampaignMemberService.RelationWrapper wrapper = CampaignMemberService.getRelationships(newList);
        CampaignMemberService.populateLastMemberStatusChange(wrapper.originalCampaignMembersMap.values(), oldMap);
        CampaignMemberService.populateCampaignSecurities(
            wrapper.touchedCampaigns,
            wrapper.campaignIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet()
        );
        wrapper = CampaignMemberService.filterToProperCampaignMembers(wrapper);
        CampaignMemberService.MarkPrimaryWrapper markPrimaryContactWrapper = CampaignMemberService.processContacts(
            wrapper.contactIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet(),
            wrapper.contactIdToOpportunitiesMap
        );
        CampaignMemberService.MarkPrimaryWrapper markPrimaryLeadWrapper = CampaignMemberService.processLeads(
            wrapper.leadIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet(),
            wrapper.leadIdToLeadMap
        );
        CampaignMemberService.MarkPrimaryWrapper markPrimaryComboWrapper = new CampaignMemberService.MarkPrimaryWrapper(
            new List<CampaignMemberService.MarkPrimaryWrapper>{ markPrimaryContactWrapper, markPrimaryLeadWrapper }
        );
        CampaignMemberService.populatePrimaryOrNot(
            wrapper.originalCampaignMembersMap.values(),
            oldMap,
            markPrimaryComboWrapper.membersToMarkPrimaryIds,
            markPrimaryComboWrapper.membersToMarkNotPrimaryIds
        );
        CampaignMemberService.populateMemberOpportunities(
            wrapper.originalCampaignMembersMap.values(),
            wrapper.contactIdToOpportunitiesMap
        );
    }
    public void beforeUpdate() {
        CampaignMemberService.RelationWrapper wrapper = CampaignMemberService.getRelationships(newList);
        CampaignMemberService.populateLastMemberStatusChange(wrapper.originalCampaignMembersMap.values(), oldMap);
        CampaignMemberService.populateCampaignSecurities(
            wrapper.touchedCampaigns,
            wrapper.campaignIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet()
        );
        wrapper = CampaignMemberService.filterToProperCampaignMembers(wrapper);
        CampaignMemberService.MarkPrimaryWrapper markPrimaryContactWrapper = CampaignMemberService.processContacts(
            wrapper.contactIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet(),
            wrapper.contactIdToOpportunitiesMap
        );
        CampaignMemberService.MarkPrimaryWrapper markPrimaryLeadWrapper = CampaignMemberService.processLeads(
            wrapper.leadIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet(),
            wrapper.leadIdToLeadMap
        );
        CampaignMemberService.MarkPrimaryWrapper markPrimaryComboWrapper = new CampaignMemberService.MarkPrimaryWrapper(
            new List<CampaignMemberService.MarkPrimaryWrapper>{ markPrimaryContactWrapper, markPrimaryLeadWrapper }
        );
        CampaignMemberService.populatePrimaryOrNot(
            wrapper.originalCampaignMembersMap.values(),
            oldMap,
            markPrimaryComboWrapper.membersToMarkPrimaryIds,
            markPrimaryComboWrapper.membersToMarkNotPrimaryIds
        );
    }
    public void beforeDelete() {
        CampaignMemberService.RelationWrapper wrapper = CampaignMemberService.getRelationships(oldList);
        CampaignMemberService.populateLastMemberStatusChange(wrapper.originalCampaignMembersMap.values(), oldMap);
        CampaignMemberService.populateCampaignSecurities(
            wrapper.touchedCampaigns,
            wrapper.campaignIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet()
        );
        CampaignMemberService.processContacts(
            wrapper.contactIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet(),
            wrapper.contactIdToOpportunitiesMap
        );
        CampaignMemberService.processLeads(
            wrapper.leadIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet(),
            wrapper.leadIdToLeadMap
        );
    }
    public void afterInsert() {
        CampaignMemberService.RelationWrapper wrapper = CampaignMemberService.getRelationships(newList);
        CampaignMemberService.populateLastMemberStatusChange(wrapper.originalCampaignMembersMap.values(), oldMap);
        CampaignMemberService.populateCampaignSecurities(
            wrapper.touchedCampaigns,
            wrapper.campaignIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet()
        );
        wrapper = CampaignMemberService.filterToProperCampaignMembers(wrapper);
        CampaignMemberService.MarkPrimaryWrapper markPrimaryContactWrapper = CampaignMemberService.processContacts(
            wrapper.contactIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet(),
            wrapper.contactIdToOpportunitiesMap
        );
        CampaignMemberService.MarkPrimaryWrapper markPrimaryLeadWrapper = CampaignMemberService.processLeads(
            wrapper.leadIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet(),
            wrapper.leadIdToLeadMap
        );
        CampaignMemberService.MarkPrimaryWrapper markPrimaryComboWrapper = new CampaignMemberService.MarkPrimaryWrapper(
            new List<CampaignMemberService.MarkPrimaryWrapper>{ markPrimaryContactWrapper, markPrimaryLeadWrapper }
        );
        CampaignMemberService.populatePrimaryOrNot(
            wrapper.originalCampaignMembersMap.values(),
            oldMap,
            markPrimaryComboWrapper.relatedMembersToMarkPrimaryIds,
            markPrimaryComboWrapper.relatedMembersToMarkNotPrimaryIds
        );
        CampaignMemberService.updateRelatedRecords(wrapper);

        AutoSubscriberService autoSubService = new AutoSubscriberService(
            wrapper.originalCampaignMembersMap.values(),
            'CampaignMember'
        );
        autoSubService.processCampaignMemberRecords();
    }
    public void afterUpdate() {
        CampaignMemberService.RelationWrapper wrapper = CampaignMemberService.getRelationships(newList);
        CampaignMemberService.populateLastMemberStatusChange(wrapper.originalCampaignMembersMap.values(), oldMap);
        CampaignMemberService.populateCampaignSecurities(
            wrapper.touchedCampaigns,
            wrapper.campaignIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet()
        );
        wrapper = CampaignMemberService.filterToProperCampaignMembers(wrapper);
        CampaignMemberService.MarkPrimaryWrapper markPrimaryContactWrapper = CampaignMemberService.processContacts(
            wrapper.contactIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet(),
            wrapper.contactIdToOpportunitiesMap
        );
        CampaignMemberService.MarkPrimaryWrapper markPrimaryLeadWrapper = CampaignMemberService.processLeads(
            wrapper.leadIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet(),
            wrapper.leadIdToLeadMap
        );
        CampaignMemberService.MarkPrimaryWrapper markPrimaryComboWrapper = new CampaignMemberService.MarkPrimaryWrapper(
            new List<CampaignMemberService.MarkPrimaryWrapper>{ markPrimaryContactWrapper, markPrimaryLeadWrapper }
        );
        CampaignMemberService.populatePrimaryOrNot(
            wrapper.originalCampaignMembersMap.values(),
            oldMap,
            markPrimaryComboWrapper.relatedMembersToMarkPrimaryIds,
            markPrimaryComboWrapper.relatedMembersToMarkNotPrimaryIds
        );
        CampaignMemberService.updateRelatedRecords(wrapper);
    }
    public void afterDelete() {
        CampaignMemberService.RelationWrapper wrapper = CampaignMemberService.getRelationships(oldList);
        CampaignMemberService.populateLastMemberStatusChange(wrapper.originalCampaignMembersMap.values(), oldMap);
        CampaignMemberService.populateCampaignSecurities(
            wrapper.touchedCampaigns,
            wrapper.campaignIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet()
        );
        wrapper = CampaignMemberService.filterToProperCampaignMembers(wrapper);
        CampaignMemberService.MarkPrimaryWrapper markPrimaryContactWrapper = CampaignMemberService.processContacts(
            wrapper.contactIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet(),
            wrapper.contactIdToOpportunitiesMap
        );
        CampaignMemberService.MarkPrimaryWrapper markPrimaryLeadWrapper = CampaignMemberService.processLeads(
            wrapper.leadIdToCampaginMembers,
            wrapper.originalCampaignMembersMap.keySet(),
            wrapper.leadIdToLeadMap
        );
        CampaignMemberService.MarkPrimaryWrapper markPrimaryComboWrapper = new CampaignMemberService.MarkPrimaryWrapper(
            new List<CampaignMemberService.MarkPrimaryWrapper>{ markPrimaryContactWrapper, markPrimaryLeadWrapper }
        );
        CampaignMemberService.populatePrimaryOrNot(
            wrapper.originalCampaignMembersMap.values(),
            oldMap,
            markPrimaryComboWrapper.relatedMembersToMarkPrimaryIds,
            markPrimaryComboWrapper.relatedMembersToMarkNotPrimaryIds
        );
        CampaignMemberService.updateRelatedRecords(wrapper);
    }
    public void afterUndelete() {
    }
}
