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
        CampaignMemberService service = new CampaignMemberService();
        service.processNewMembers(newList);
    }
    public void beforeUpdate() {
        CampaignMemberService service = new CampaignMemberService();
        service.processOldMembers(newList, newMap, oldList);
    }
    public void beforeDelete() {
        CampaignMemberService service = new CampaignMemberService();
        service.processAffectedMembers(oldList);
    }
    public void afterInsert() {
        CampaignMemberService service = new CampaignMemberService();
        service.updateRelatedRecords(newMap, newList);
    }
    public void afterUpdate() {
        CampaignMemberService service = new CampaignMemberService();
        service.updateRelatedRecords(newMap);
    }
    public void afterDelete() {
        CampaignMemberService service = new CampaignMemberService();
        service.updateRelatedRecords(oldMap);
    }
    public void afterUndelete() {
    }
}
