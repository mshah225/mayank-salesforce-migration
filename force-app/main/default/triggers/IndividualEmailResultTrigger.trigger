trigger IndividualEmailResultTrigger on et4ae5__IndividualEmailResult__c(
    after delete,
    after insert,
    after undelete,
    after update,
    before delete,
    before insert,
    before update
) {
    IndividualEmailResultDispatcher dispatcher = new IndividualEmailResultDispatcher(
        Trigger.new,
        Trigger.newMap,
        Trigger.old,
        Trigger.oldMap
    );

    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            dispatcher.beforeUpdate();
        } else if (Trigger.isInsert) {
            dispatcher.beforeInsert();
        } else if (Trigger.isDelete) {
            dispatcher.beforeDelete();
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            dispatcher.afterUpdate();
        } else if (Trigger.isInsert) {
            dispatcher.afterInsert();
        } else if (Trigger.isDelete) {
            dispatcher.afterDelete();
        } else if (Trigger.isUndelete) {
            dispatcher.afterUndelete();
        }
    }
}
