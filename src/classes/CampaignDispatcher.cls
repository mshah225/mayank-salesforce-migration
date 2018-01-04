public with sharing class CampaignDispatcher implements IDispatch {
    private static final boolean debug = false; // Toggle debug error reporting
    private static Map<Id,Campaign> newAttachments; // trigger.new
    private static Map<Id,Campaign> oldAttachments; // trigger.oldMap
    private static Map<Id,Case> casesToUpdate; // Map of cases that need to be updated based on business logic
    
    public CampaignDispatcher (Map<Id,Campaign> newMap, Map<Id,Campaign> oldMap) {
        newAttachments = newMap;
        oldAttachments = oldMap;
    }
    
    public void afterInsert() { 
    	List<Id> campaignId = new List<Id>();
        for(sObject s : Trigger.New) {
            campaignId.add(s.Id);
        }
        CampaignService.setHashId(campaignId);
    }
    
    public void beforeInsert() { }
    public void beforeUpdate() { }
    public void beforeDelete() { }
    public void afterUpdate() { }
    public void afterUndelete() { }
    public void afterDelete() { }

}