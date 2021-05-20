public class AccountDispatcher implements TriggerDispatcherInterface {
    private List<Account> newList;
    private Map<Id, Account> newMap;
    private List<Account> oldList;
    private Map<Id, Account> oldMap;

    public AccountDispatcher(
        List<Account> newList,
        Map<Id, Account> newMap,
        List<Account> oldList,
        Map<Id, Account> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        TerritoryAssignmentHelper tah = new TerritoryAssignmentHelper();
        tah.AccountTA();
    }
    public void beforeUpdate() {
        TerritoryAssignmentHelper tah = new TerritoryAssignmentHelper();
        tah.AccountTA();
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
