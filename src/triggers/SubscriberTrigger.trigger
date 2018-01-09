trigger SubscriberTrigger on Subscriber__c (after delete, after insert, after undelete, after update,
    before delete, before insert, before update) {

    SubscriberDispatcher d = new SubscriberDispatcher(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);

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
        if (trigger.isUnDelete) {
            d.afterUnDelete();
        }
    }
}