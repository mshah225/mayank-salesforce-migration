public with sharing class CampaignDispatcher implements TriggerDispatcherInterface {
    private static final Boolean debug = false; // Toggle debug error reporting
    private List<Campaign> newList; // trigger.new
    private Map<Id, Campaign> newMap; // trigger.newMap
    private List<Campaign> oldList; // trigger.old
    private Map<Id, Campaign> oldMap; // trigger.oldMap

    public CampaignDispatcher(
        List<Campaign> newList,
        Map<Id, Campaign> newMap,
        List<Campaign> oldList,
        Map<Id, Campaign> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void afterInsert() {
        List<Id> campaignId = new List<Id>();
        for (Campaign thisCampaign : newList) {
            campaignId.add(thisCampaign.Id);
        }
        CampaignService.setHashId(campaignId);
    }

    public void beforeInsert() {
        if (FeatureFlagService.isEnabled('Campaign Trigger', 'Autoset Start Time'))
            CampaignService.setPrintableStartTime(newList, oldMap);
        if (FeatureFlagService.isEnabled('Campaign Trigger', 'Autoset End Time'))
            CampaignService.setPrintableEndTime(newList, oldMap);
        if (FeatureFlagService.isEnabled('Campaign Trigger', 'Autoset Registration Time'))
            CampaignService.setPrintableRegistrationTime(newList, oldMap);
    }
    public void beforeUpdate() {
        if (FeatureFlagService.isEnabled('Campaign Trigger', 'Autoset Start Time'))
            CampaignService.setPrintableStartTime(newList, oldMap);
        if (FeatureFlagService.isEnabled('Campaign Trigger', 'Autoset End Time'))
            CampaignService.setPrintableEndTime(newList, oldMap);
        if (FeatureFlagService.isEnabled('Campaign Trigger', 'Autoset Registration Time'))
            CampaignService.setPrintableRegistrationTime(newList, oldMap);
    }
    public void beforeDelete() {
    }
    public void afterUpdate() {
    }
    public void afterUndelete() {
    }
    public void afterDelete() {
    }
}
