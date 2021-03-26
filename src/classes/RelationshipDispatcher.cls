public class RelationshipDispatcher implements IDispatch {
    private List<Relationship__c> newList;
    private List<Relationship__c> oldList;
    private Map<Id, Relationship__c> newMap;
    private Map<Id, Relationship__c> oldMap;

    public RelationshipDispatcher(
        List<Relationship__c> newList,
        Map<Id, Relationship__c> newMap,
        List<Relationship__c> oldList,
        Map<Id, Relationship__c> oldMap
    ) {
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
    }

    /**
     * Contains business logic to process before inserting relationships
     */
    public void beforeInsert() {
    }

    /**
     * Contains business logic to process before updating relationships
     */
    public void beforeUpdate() {
    }

    public void beforeDelete() {
    }

    /**
     * Contains business logic to process after inserting relationships
     */
    public void afterInsert() {
        RelationshipService.createReciprocal(newList);
        RelationshipService.insertCreatedByProfileName(newList);
    }

    /**
     * Contains business logic to process after updating relationships
     */
    public void afterUpdate() {
        if (CheckRecursion.runCount < 1) {
            RelationshipService.updateReciprocal(newList);
        }
    }

    /**
     * Contains business logic to process after deleting relationships
     */
    public void afterDelete() {
        RelationshipService.deleteReciprocal(oldList);
    }

    public void afterUndelete() {
    }
}
