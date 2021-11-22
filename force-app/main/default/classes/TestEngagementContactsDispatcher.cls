public with sharing class TestEngagementContactsDispatcher implements TriggerDispatcherInterface {
    private List<Test_Engagement_Contacts__c> newList;
    private Map<Id, Test_Engagement_Contacts__c> newMap;
    private List<Test_Engagement_Contacts__c> oldList;
    private Map<Id, Test_Engagement_Contacts__c> oldMap;

    public TestEngagementContactsDispatcher(
        List<Test_Engagement_Contacts__c> newList,
        Map<Id, Test_Engagement_Contacts__c> newMap,
        List<Test_Engagement_Contacts__c> oldList,
        Map<Id, Test_Engagement_Contacts__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
    }
    public void beforeUpdate() {
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
        TestEngagementContactsService.triggerER4AE5Utility();
        TestEngagementContactsService.updateEmailStatuses(newList);
    }
    public void afterUpdate() {
        TestEngagementContactsService.triggerER4AE5Utility();
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
