public with sharing class IndividualEmailResultDispatcher implements IDispatch {
    private static Map<Id, et4ae5__IndividualEmailResult__c> newIERs;
    private static Map<Id, et4ae5__IndividualEmailResult__c> oldIERs;

    public IndividualEmailResultDispatcher (Map<Id, et4ae5__IndividualEmailResult__c> newMap, Map<Id, et4ae5__IndividualEmailResult__c> oldMap) {
        // Commented out; current functionality does not require these values
        /*
        newIERs = newMap;
        oldIERs = oldMap;
        */
    }

    public void beforeInsert() {
        IndividualEmailResultService.enforceOwnerPolicies(Trigger.new);
    }

    public void beforeUpdate() {
        IndividualEmailResultService.enforceOwnerPolicies(Trigger.new);
    }

    //Required by Dispatcher Interface
    public void beforeDelete() { }
    public void afterInsert() { }
    public void afterUpdate() { }
    public void afterDelete() { }
    public void afterUndelete() { }
}