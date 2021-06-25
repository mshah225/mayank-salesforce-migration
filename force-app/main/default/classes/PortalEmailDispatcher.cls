public class PortalEmailDispatcher implements IDispatch {
    private static Map<Id, Portal_Email__c> newPortalEmails; // trigger.newMap
    private static Map<Id, Portal_Email__c> oldPortalEmails; // trigger.oldMap

    public PortalEmailDispatcher(Map<Id, Portal_Email__c> newMap, Map<Id, Portal_Email__c> oldMap) {
        newPortalEmails = newMap;
        oldPortalEmails = oldMap;
    }

    public void afterInsert() {
        PortalEmailService.setFromAddress(newPortalEmails);
    }

    public void beforeInsert() {
        PortalEmailService.verifiySubject(Trigger.New);
        PortalEmailService.verifyMessageText(Trigger.New);
    }

    //Required by Dispatcher Interface
    public void beforeUpdate() {
    }
    public void beforeDelete() {
    }
    public void afterUpdate() {
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
