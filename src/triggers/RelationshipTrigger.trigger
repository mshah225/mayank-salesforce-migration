trigger RelationshipTrigger on Relationship__c (after delete, after insert, after update,
before delete, before insert, before update) {
    //TriggerFactory.createAndExecuteHandler(RelationshipHandler.class);
    
    
    RelationshipDispatcher d = new RelationshipDispatcher();
    
    if (trigger.isBefore) {
        if (trigger.isUpdate) d.beforeUpdate();
        if (trigger.isInsert) d.beforeInsert();
        if (trigger.isDelete) d.beforeDelete();
    }
    if (trigger.isAfter) {
        if (trigger.isUpdate) d.afterUpdate();
        if (trigger.isInsert) d.afterInsert();
        if (trigger.isDelete) d.afterDelete();
        if (trigger.isUnDelete) d.afterUnDelete();
    }
}