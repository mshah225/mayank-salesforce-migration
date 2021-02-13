trigger AttachmentTrigger on Attachment(
    after delete,
    after insert,
    after undelete,
    after update,
    before delete,
    before insert,
    before update
) {
    AttachmentDispatcher d = new AttachmentDispatcher(Trigger.newMap, Trigger.oldMap);

    if (Trigger.isBefore) {
        if (Trigger.isUpdate)
            d.beforeUpdate();
        if (Trigger.isInsert)
            d.beforeInsert();
        if (Trigger.isDelete)
            d.beforeDelete();
    }
    if (Trigger.isAfter) {
        if (Trigger.isUpdate)
            d.afterUpdate();
        if (Trigger.isInsert)
            d.afterInsert();
        if (Trigger.isDelete)
            d.afterDelete();
        if (Trigger.isUnDelete)
            d.afterUnDelete();
    }
}
