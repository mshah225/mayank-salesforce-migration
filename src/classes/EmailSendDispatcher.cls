public with sharing class EmailSendDispatcher implements IDispatch {
	private static Map<Id, et4ae5__SendDefinition__c> newEmailSends;
    private static Map<Id, et4ae5__SendDefinition__c> oldEmailSends;

    public EmailSendDispatcher (Map<Id, et4ae5__SendDefinition__c> newMap, Map<Id, et4ae5__SendDefinition__c> oldMap) {
        newEmailSends = newMap;
        oldEmailSends = oldMap;
    }

	public void beforeInsert() {
		EmailSendService.setCampaignLookup(Trigger.new);
	}

	public void beforeUpdate() {
		EmailSendService.setCampaignLookup(Trigger.new);
 	}

    //Required by Dispatcher Interface
    public void beforeDelete() { }
	public void afterInsert() { }
    public void afterUpdate() { }
    public void afterDelete() { }
    public void afterUndelete() { }
}