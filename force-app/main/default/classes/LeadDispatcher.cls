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
        LeadService.setLeadAssignmentNumber(newList);
        LeadService.assignTerritory(newList, oldMap);
    }
    public void beforeUpdate() {
        LeadService.assignTerritory(newList, oldMap);
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
        LeadService.queueHashIdAssignment(newMap);
        LeadService.determineLeadsToConvert(newList, oldMap);
    }
    public void afterUpdate() {
        LeadService.determineLeadsToConvert(newList, oldMap);
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}