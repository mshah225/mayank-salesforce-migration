public class OpportunityContactRoleDispatcher implements TriggerDispatcherInterface {
    private List<OpportunityContactRole> newList;
    private Map<Id, OpportunityContactRole> newMap;
    private List<OpportunityContactRole> oldList;
    private Map<Id, OpportunityContactRole> oldMap;

    public OpportunityContactRoleDispatcher(
        List<OpportunityContactRole> newList,
        Map<Id, OpportunityContactRole> newMap,
        List<OpportunityContactRole> oldList,
        Map<Id, OpportunityContactRole> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        OpportunityContactRoleService.checkUniqueKey(newList);
        OpportunityContactRoleService.verifyIsPrimaryTrue(newList);
    }
    public void beforeUpdate() {
        OpportunityContactRoleService.verifyIsPrimaryTrue(newList);
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