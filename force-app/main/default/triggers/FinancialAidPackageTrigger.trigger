trigger FinancialAidPackageTrigger on Financial_Aid_Package__c(
    after delete,
    after insert,
    after update,
    before delete,
    before insert,
    before update
) {
    TriggerFactory.createAndExecuteHandler(FinancialAidPackageHandler.class);
}
