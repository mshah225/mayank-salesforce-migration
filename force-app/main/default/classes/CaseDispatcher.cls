public class CaseDispatcher implements TriggerDispatcherInterface {
    private List<Case> newList;
    private Map<Id, Case> newMap;
    private List<Case> oldList;
    private Map<Id, Case> oldMap;

    public CaseDispatcher(List<Case> newList, Map<Id, Case> newMap, List<Case> oldList, Map<Id, Case> oldMap) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        CaseService.assignClassificationsAndRecordType(newList, oldMap);
        CaseService.assignRecentGroupAndQueue(newList, oldMap);
        CaseService.processCaseAssociations(newList);
    }
    public void beforeUpdate() {
        CaseService.assignClassificationsAndRecordType(newList, oldMap);
        CaseService.assignRecentGroupAndQueue(newList, oldMap);
        CaseService.updateAccountIdFromContact(newList, oldMap);
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
        CaseService.forwardInsertedCaseEmail(newList, oldMap);
    }
    public void afterUpdate() {
        CaseService.forwardInsertedCaseEmail(newList, oldMap);
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}