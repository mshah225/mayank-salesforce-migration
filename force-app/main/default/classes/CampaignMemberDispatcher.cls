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
        CampaignMemberService cms = new CampaignMemberService(newList, oldMap);
        cms.beforeInsert();
    }
    public void beforeUpdate() {
        CampaignMemberService cms = new CampaignMemberService(newList, oldMap);
        cms.beforeUpdate();
    }
    public void beforeDelete() {
        CampaignMemberService cms = new CampaignMemberService(oldList, oldMap);
        cms.beforeDelete();
    }
    public void afterInsert() {
        CampaignMemberService cms = new CampaignMemberService(newList, oldMap);
        cms.afterInsert();

        AutoSubscriberService autoSubService = new AutoSubscriberService(newList, 'CampaignMember');
        autoSubService.processCampaignMemberRecords();
    }
    public void afterUpdate() {
        CampaignMemberService cms = new CampaignMemberService(newList, oldMap);
        cms.afterUpdate();
    }
    public void afterDelete() {
        CampaignMemberService cms = new CampaignMemberService(oldList, oldMap);
        cms.afterDelete();
    }
    public void afterUndelete() {
    }
}
