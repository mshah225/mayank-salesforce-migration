public class OpportunityDispatcher implements TriggerDispatcherInterface {
    private List<Opportunity> newList;
    private Map<Id, Opportunity> newMap;
    private List<Opportunity> oldList;
    private Map<Id, Opportunity> oldMap;

    public OpportunityDispatcher(
        List<Opportunity> newList,
        Map<Id, Opportunity> newMap,
        List<Opportunity> oldList,
        Map<Id, Opportunity> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        OpportunityService.populateNullContactsFromAccounts(newList);
        OpportunityService.insertCollegePlan(newList);
        OpportunityService.assignTerritory(newList, oldMap);
    }
    public void beforeUpdate() {
        OpportunityService.updateCollegeIfPlanChanged(newList, oldMap);
        OpportunityService.assignTerritory(newList, oldMap);
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