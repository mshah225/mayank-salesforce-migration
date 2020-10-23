public class FamilyPortalInterestDispatcher implements IDispatch {
    private List<Family_Portal_Guardian_Interest__c> newList;
    private Map<Id, Family_Portal_Guardian_Interest__c> newMap;
    private List<Family_Portal_Guardian_Interest__c> oldList;
    private Map<Id, Family_Portal_Guardian_Interest__c> oldMap;

    public FamilyPortalInterestDispatcher(
        List<Family_Portal_Guardian_Interest__c> newList,
        Map<Id, Family_Portal_Guardian_Interest__c> newMap,
        List<Family_Portal_Guardian_Interest__c> oldList,
        Map<Id, Family_Portal_Guardian_Interest__c> oldMap
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
    }
    public void afterUpdate() {
        FamilyPortalInterestDeduplicationService deduplicateGuardianInterests = new FamilyPortalInterestDeduplicationService(
            newList
        );
        System.enqueueJob(deduplicateGuardianInterests);
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
