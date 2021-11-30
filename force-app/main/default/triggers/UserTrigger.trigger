trigger UserTrigger on User(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    UserDispatcher d = new UserDispatcher(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            d.beforeInsert();
        }
        if (Trigger.isUpdate) {
            d.beforeUpdate();
        }
        if (Trigger.isDelete) {
            d.beforeDelete();
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            d.afterInsert();
        }
        if (Trigger.isUpdate) {
            d.afterUpdate();
        }
        if (Trigger.isDelete) {
            d.afterDelete();
        }
        if (Trigger.isUnDelete) {
            d.afterUnDelete();
        }
    }
}
