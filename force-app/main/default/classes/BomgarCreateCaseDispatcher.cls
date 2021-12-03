public class BomgarCreateCaseDispatcher implements TriggerDispatcherInterface {
    private List<bomgar__BomgarWebEvent__c> newList;
    private Map<Id, bomgar__BomgarWebEvent__c> newMap;
    private List<bomgar__BomgarWebEvent__c> oldList;
    private Map<Id, bomgar__BomgarWebEvent__c> oldMap;

    public BomgarCreateCaseDispatcher(
        List<bomgar__BomgarWebEvent__c> newList,
        Map<Id, bomgar__BomgarWebEvent__c> newMap,
        List<bomgar__BomgarWebEvent__c> oldList,
        Map<Id, bomgar__BomgarWebEvent__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
    }
    public void beforeUpdate() {
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
        BomgarCreateCaseService.processEvents(newList);
    }
    public void afterUpdate() {
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
