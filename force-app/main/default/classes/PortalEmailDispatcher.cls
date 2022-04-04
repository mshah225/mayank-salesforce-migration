public class PortalEmailDispatcher implements TriggerDispatcherInterface {
    private List<Portal_Email__c> newList;
    private Map<Id, Portal_Email__c> newMap;
    private List<Portal_Email__c> oldList;
    private Map<Id, Portal_Email__c> oldMap;

    public PortalEmailDispatcher(
        List<Portal_Email__c> newList,
        Map<Id, Portal_Email__c> newMap,
        List<Portal_Email__c> oldList,
        Map<Id, Portal_Email__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        PortalEmailService.verifySubject(newList);
        PortalEmailService.verifyMessageText(newList);
    }
    public void beforeUpdate() {
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
        PortalEmailService.setFromAddress(newMap);
    }
    public void afterUpdate() {
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
