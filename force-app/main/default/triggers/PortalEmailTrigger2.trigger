trigger PortalEmailTrigger2 on Portal_Email__c(
    after delete,
    after insert,
    after undelete,
    after update,
    before delete,
    before insert,
    before update
) {
    PortalEmailDispatcher dispatcher = new PortalEmailDispatcher(
        Trigger.new,
        Trigger.newMap,
        Trigger.old,
        Trigger.oldMap
    );

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            dispatcher.beforeInsert();
        }
        if (Trigger.isUpdate) {
            dispatcher.beforeUpdate();
        }
        if (Trigger.isDelete) {
            dispatcher.beforeDelete();
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            dispatcher.afterInsert();
        }
        if (Trigger.isUpdate) {
            dispatcher.afterUpdate();
        }
        if (Trigger.isDelete) {
            dispatcher.afterDelete();
        }
        if (Trigger.isUndelete) {
            dispatcher.afterUndelete();
        }
    }
}
