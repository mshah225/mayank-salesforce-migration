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
        // Prevent empty values
        if (FeatureFlagService.isEnabled('Portal Email Trigger', 'Default Subject'))
            PortalEmailService.verifySubject(newList);
        if (FeatureFlagService.isEnabled('Portal Email Trigger', 'Cancel Empty'))
            PortalEmailService.verifyMessageText(newList);

        // Set template and from address
        if (FeatureFlagService.isEnabled('Portal Email Trigger', 'Set From Address and Template, Advisors'))
            PortalEmailService.setFromAndTemplateForAdvisorEmails(newList);
        if (FeatureFlagService.isEnabled('Portal Email Trigger', 'Set From Address, Coaches'))
            PortalEmailService.setFromAddressForCoachEmails(newList);
    }
    public void beforeUpdate() {
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
        // Create Email records
        if (FeatureFlagService.isEnabled('Portal Email Trigger', 'Create Corresponding EmailMessages'))
            PortalEmailService.createEmailMessages(newList);
    }
    public void afterUpdate() {
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
