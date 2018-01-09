trigger EmailSendTrigger on et4ae5__SendDefinition__c (after delete, after insert, after undelete, after update,
    before delete, before insert, before update) {

    EmailSendDispatcher dispatcher = new EmailSendDispatcher(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);

    if (trigger.isBefore) {
        if (trigger.isUpdate) {
            dispatcher.beforeUpdate();
        } else if (trigger.isInsert) {
            dispatcher.beforeInsert();
        }else if (trigger.isDelete) {
            dispatcher.beforeDelete();
        }
    } else if (trigger.isAfter) {
        if (trigger.isUpdate) {
            dispatcher.afterUpdate();
        } else if (trigger.isInsert) {
            dispatcher.afterInsert();
        } else if (trigger.isDelete) {
            dispatcher.afterDelete();
        } else if (trigger.isUnDelete) {
            dispatcher.afterUnDelete();
        }
    }
}