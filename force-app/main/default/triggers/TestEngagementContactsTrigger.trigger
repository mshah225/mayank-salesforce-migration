trigger TestEngagementContactsTrigger on Test_Engagement_Contacts__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TestEngagementContactsDispatcher d = new TestEngagementContactsDispatcher(
        Trigger.new,
        Trigger.newMap,
        Trigger.old,
        Trigger.oldMap
    );

    if (Trigger.isBefore) {
        if (Trigger.isInsert)
            d.beforeInsert();
        if (Trigger.isUpdate)
            d.beforeUpdate();
        if (Trigger.isDelete)
            d.beforeDelete();
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert)
            d.afterInsert();
        if (Trigger.isUpdate)
            d.afterUpdate();
        if (Trigger.isDelete)
            d.afterDelete();
        if (Trigger.isUnDelete)
            d.afterUnDelete();
    }
}
