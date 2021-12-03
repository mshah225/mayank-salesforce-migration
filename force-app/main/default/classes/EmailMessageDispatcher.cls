public with sharing class EmailMessageDispatcher implements TriggerDispatcherInterface {
    private static Map<Id, Case> casesToUpdate; // List of parent cases that need to be updated
    private static Map<Id, EmailMessage> newEmails; // trigger.new
    private static Map<Id, EmailMessage> oldEmails; // trigger.oldMap

    public EmailMessageDispatcher(Map<Id, EmailMessage> newMap, Map<Id, EmailMessage> oldMap) {
        newEmails = newMap;
        oldEmails = oldMap;
    }

    public void afterInsert() {
        casesToUpdate = EmailMessageService.getCasesFromEmailMessages(newEmails);
        system.debug('getCasesFromEmailMessages: ' + string.valueOf(casesToUpdate));

        if (casesToUpdate != null && casesToUpdate.size() > 0) {
            casesToUpdate = EmailMessageService.setAdvisorCaseStatus(casesToUpdate);

            system.debug('setAdvisorCaseStatus: ' + string.valueOf(casesToUpdate));

            if (casesToUpdate.size() > 0) {
                update casesToUpdate.values();
            }
        }
    }

    //Required by Dispatcher Interface
    public void beforeInsert() {
    }
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
