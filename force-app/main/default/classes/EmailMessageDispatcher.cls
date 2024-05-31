public class EmailMessageDispatcher implements TriggerDispatcherInterface {
    private List<EmailMessage> newList;
    private Map<Id, EmailMessage> newMap;
    private List<EmailMessage> oldList;
    private Map<Id, EmailMessage> oldMap;

    public EmailMessageDispatcher(
        List<EmailMessage> newList,
        Map<Id, EmailMessage> newMap,
        List<EmailMessage> oldList,
        Map<Id, EmailMessage> oldMap
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
        if (FeatureFlagService.isEnabled('Email Message Trigger', 'Update Case Status'))
            EmailMessageService.updateCasesFromEmailMessages(newList, oldMap);
    }
    public void afterUpdate() {
        if (FeatureFlagService.isEnabled('Email Message Trigger', 'Update Case Status'))
            EmailMessageService.updateCasesFromEmailMessages(newList, oldMap);
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
