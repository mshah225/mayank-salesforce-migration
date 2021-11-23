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
        CaseHandler handler = new CaseHandler();
        handler.mapInsertedGroupIdsToNames(newList);
        handler.processCaseAssociations(newList);
    }
    public void beforeUpdate() {
        CaseHandler handler = new CaseHandler();
        handler.mapUpdatedGroupIdsToNames(newList, oldMap);
        handler.updateMostRecentFunctionalGroup(newMap, oldMap);
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
        CaseHandler handler = new CaseHandler();
        handler.forwardInsertedCaseEmail(newList);
    }
    public void afterUpdate() {
        CaseHandler handler = new CaseHandler();
        handler.forwardUpdatedCaseEmail(newMap, oldMap);
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
