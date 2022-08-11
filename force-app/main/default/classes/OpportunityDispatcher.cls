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
    }
    public void beforeUpdate() {
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
