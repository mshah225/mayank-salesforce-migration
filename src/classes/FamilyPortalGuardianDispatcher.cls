public with sharing class FamilyPortalGuardianDispatcher implements IDispatch {
    private List<Family_Portal_Guardian__c> newList;
    private Map<Id, Family_Portal_Guardian__c> newMap;
    private List<Family_Portal_Guardian__c> oldList;
    private Map<Id, Family_Portal_Guardian__c> oldMap;

    public FamilyPortalGuardianDispatcher (List<Family_Portal_Guardian__c> newList, Map<Id, Family_Portal_Guardian__c> newMap, List<Family_Portal_Guardian__c> oldList, Map<Id, Family_Portal_Guardian__c> oldMap) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {}
    public void beforeUpdate() {}
    public void beforeDelete() {}

    public void afterInsert() {
        FamilyPortalGuardianDeduplicationService deduplicateGuardians = new FamilyPortalGuardianDeduplicationService(newList);
        System.enqueueJob(deduplicateGuardians);
    }

    public void afterUpdate() {}
    public void afterDelete() {}
    public void afterUndelete() {}
}