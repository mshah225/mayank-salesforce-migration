trigger SubscriberTrigger on Subscriber__c (after delete, after insert, after undelete, after update,
    before delete, before insert, before update) {

    SubscriberDispatcher d = new SubscriberDispatcher(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);

    if(TriggerRecursionChecker.BeforeTriggerFirstRunCheck()) {

        if (trigger.isBefore) {

            if (trigger.isInsert) {
                d.beforeInsert();
            }
        }
    }

    if(TriggerRecursionChecker.AfterTriggerFirstRunCheck()) {

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
