trigger SubscriberTrigger on Subscriber__c (after delete, after insert, after undelete, after update,
    before delete, before insert, before update) {

    SubscriberDispatcher d = new SubscriberDispatcher(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);

    if(TriggerRecursionCheck.FirstRunCheck(1)) {

        if (trigger.isBefore) {

            if (trigger.isInsert) {
                d.beforeInsert();
            }
        }
    }

    if(TriggerRecursionCheck.FirstRunCheck(2)) {

        if (trigger.isAfter) {

            if (trigger.isUpdate) {
                d.afterUpdate();
            }
            if (trigger.isInsert) {
                d.afterInsert();
            }
            if (trigger.isUnDelete) {
                d.afterUnDelete();
            }
        }
    }
}
