public class FinancialAidPackageDispatcher implements TriggerDispatcherInterface {
    private List<Financial_Aid_Package__c> newList;
    private Map<Id, Financial_Aid_Package__c> newMap;
    private List<Financial_Aid_Package__c> oldList;
    private Map<Id, Financial_Aid_Package__c> oldMap;

    public FinancialAidPackageDispatcher(
        List<Financial_Aid_Package__c> newList,
        Map<Id, Financial_Aid_Package__c> newMap,
        List<Financial_Aid_Package__c> oldList,
        Map<Id, Financial_Aid_Package__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        FinancialAidPackageService.populateStatusTimeStamps(newList, oldMap);
    }
    public void beforeUpdate() {
        FinancialAidPackageService.populateStatusTimeStamps(newList, oldMap);
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
    }
    public void afterUpdate() {
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
