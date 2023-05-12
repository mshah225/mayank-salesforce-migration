trigger FinancialAidPackageTrigger on Financial_Aid_Package__c(
    after delete,
    after insert,
    after undelete,
    after update,
    before delete,
    before insert,
    before update
) {
    FinancialAidPackageDispatcher d = new FinancialAidPackageDispatcher(
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
        if (Trigger.isUndelete)
            d.afterUndelete();
    }
}
