public class LeadDispatcher implements TriggerDispatcherInterface {
    private List<Lead> newList;
    private Map<Id, Lead> newMap;
    private List<Lead> oldList;
    private Map<Id, Lead> oldMap;

    public LeadDispatcher(List<Lead> newList, Map<Id, Lead> newMap, List<Lead> oldList, Map<Id, Lead> oldMap) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        TerritoryAssignmentLead ta = new TerritoryAssignmentLead();
        ta.assignTerritory();
    }
    public void beforeUpdate() {
        TerritoryAssignmentLead ta = new TerritoryAssignmentLead();
        ta.assignTerritory();
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
