public with sharing class IndividualEmailResultDispatcher implements IDispatch {
    private List<et4ae5__IndividualEmailResult__c> newList;
    private Map<Id, et4ae5__IndividualEmailResult__c> newMap;
    private List<et4ae5__IndividualEmailResult__c> oldList;
    private Map<Id, et4ae5__IndividualEmailResult__c> oldMap;

    public IndividualEmailResultDispatcher(
        List<et4ae5__IndividualEmailResult__c> newList,
        Map<Id, et4ae5__IndividualEmailResult__c> newMap,
        List<et4ae5__IndividualEmailResult__c> oldList,
        Map<Id, et4ae5__IndividualEmailResult__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        for (et4ae5__IndividualEmailResult__c ier : newList) {
            if (
                ier.OwnerId != ier.Apex_Owner_Should_Be__c ||
                ier.Private_in_Salesforce__c != Boolean.valueOf(ier.Apex_Private_in_Salesforce_Should_Be__c)
            ) {
                IndividualEmailResultService.enforceOwnerPolicies(ier);
            }
        }
    }

    public void beforeUpdate() {
        for (et4ae5__IndividualEmailResult__c ier : newList) {
            if (
                ier.OwnerId != ier.Apex_Owner_Should_Be__c ||
                ier.Private_in_Salesforce__c != Boolean.valueOf(ier.Apex_Private_in_Salesforce_Should_Be__c)
            ) {
                IndividualEmailResultService.enforceOwnerPolicies(ier);
            }
        }
    }

    //Required by Dispatcher Interface
    public void beforeDelete() {
    }
    public void afterInsert() {
    }
    public void afterUpdate() {
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
