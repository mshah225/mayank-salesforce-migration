trigger RelationshipTrigger on Relationship__c(after delete, after insert, after update, before delete, before insert, before update) {
    RelationshipDispatcher d = new RelationshipDispatcher(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

    if (trigger.isBefore) {
        if (trigger.isUpdate) {
            d.beforeUpdate();
        }
        if (trigger.isInsert) {
            d.beforeInsert();
        }
        if (trigger.isDelete) {
            d.beforeDelete();
        }
    }
    if (trigger.isAfter) {
        if (trigger.isUpdate) {
            d.afterUpdate();
        }
        if (trigger.isInsert) {
            d.afterInsert();
        }
        if (trigger.isDelete) {
            d.afterDelete();
        }
        if (trigger.isUndelete) {
            d.afterUndelete();
        }
    }
}
