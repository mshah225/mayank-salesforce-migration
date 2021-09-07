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
        CampaignMemberHandler cms = new CampaignMemberHandler(newList, oldMap);
        cms.beforeInsert();
    }
    public void beforeUpdate() {
        CampaignMemberHandler cms = new CampaignMemberHandler(newList, oldMap);
        cms.beforeUpdate();
    }
    public void beforeDelete() {
        CampaignMemberHandler cms = new CampaignMemberHandler(oldList, oldMap);
        cms.beforeDelete();
    }
    public void afterInsert() {
        CampaignMemberHandler cms = new CampaignMemberHandler(newList, oldMap);
        cms.afterInsert();

        AutoSubscriberService autoSubService = new AutoSubscriberService(newList, 'CampaignMember');
        autoSubService.processCampaignMemberRecords();
    }
    public void afterUpdate() {
        CampaignMemberHandler cms = new CampaignMemberHandler(newList, oldMap);
        cms.afterUpdate();
    }
    public void afterDelete() {
        CampaignMemberHandler cms = new CampaignMemberHandler(oldList, oldMap);
        cms.afterDelete();
    }
    public void afterUndelete() {
    }
}
