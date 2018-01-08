public class RelationshipDispatcher implements IDispatch {

    /**
     * Contains business logic to process before inserting relationships
     */
    public void beforeInsert() {
        if(!RelationshipService.verifyTwoPrimary(Trigger.new)) {
            for(Integer i = 0; i < Trigger.new.size(); i ++) {
                Trigger.new[i].addError(Label.PrimaryRelationshipError);
            }
        }
    }
    
    /**
     * Contains business logic to process after inserting relationships
     */
    public void afterInsert() {
        RelationshipService.createReciprocal(Trigger.New);
        RelationshipService.updateContacts(Trigger.New);
    }
    
    /**
     * Contains business logic to process before updating relationships
     */
    public void beforeUpdate() {
        if(!RelationshipService.checkChanges(Trigger.Old, Trigger.New)) {
            for(Integer i = 0; i < Trigger.new.size(); i ++) {
                Trigger.new[i].addError(Label.PrimaryRelationshipError);
            }    
        }
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
    public void beforeDelete() {}
}