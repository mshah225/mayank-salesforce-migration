public class RelationshipDispatcher implements IDispatch {
    /**
     * Contains business logic to process after inserting relationships
     */
    public void afterInsert() {
        RelationshipService.createReciprocal(Trigger.New);
    }
    
    /**
     * Contains business logic to process after updating relationships
     */
    public void afterUpdate() {
        if (checkRecursive.runCount < 1) {
          RelationshipService.updateReciprocal(Trigger.New);   
        }
    }
    
    /**
     * Contains business logic to process after deleting relationships
     */
    public void afterDelete() {
            RelationshipService.deleteReciprocal(Trigger.Old);
    }
    
    public void afterUndelete() {}
    public void beforeInsert() {}
    public void beforeUpdate() {}
    public void beforeDelete() {}
}