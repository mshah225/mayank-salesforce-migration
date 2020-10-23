public class FamilyPortalStudentDispatcher implements IDispatch {
    private List<Family_Portal_Student__c> newList;
    private Map<Id, Family_Portal_Student__c> newMap;
    private List<Family_Portal_Student__c> oldList;
    private Map<Id, Family_Portal_Student__c> oldMap;

    public FamilyPortalStudentDispatcher(
        List<Family_Portal_Student__c> newList,
        Map<Id, Family_Portal_Student__c> newMap,
        List<Family_Portal_Student__c> oldList,
        Map<Id, Family_Portal_Student__c> oldMap
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
        FamilyPortalStudentDeduplicationService deduplicateStudents = new FamilyPortalStudentDeduplicationService(
            newList
        );
        System.enqueueJob(deduplicateStudents);
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
