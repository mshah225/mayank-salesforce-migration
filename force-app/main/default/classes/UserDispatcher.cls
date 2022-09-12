public with sharing class UserDispatcher implements TriggerDispatcherInterface {
    private List<User> newList;
    private Map<Id, User> newMap;
    private List<User> oldList;
    private Map<Id, User> oldMap;

    public UserDispatcher(List<User> newList, Map<Id, User> newMap, List<User> oldList, Map<Id, User> oldMap) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
        UserService.populateRoles(newList);
        UserService.populateContactsUsingAsurite(newList);
    }
    public void beforeUpdate() {
        UserService.populateRoles(newList);
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
        UserChatterGroupHandler.handleChatterGroups(newList);
    }
    public void afterUpdate() {
        UserChatterGroupHandler.handleChatterGroups(newList);
        new UserDeprovisionOrganizer(oldMap, newList).deprovisionUsersAfterUpdate();
    }
    public void afterDelete() {
        UserChatterGroupHandler.handleChatterGroups(newList);
    }
    public void afterUndelete() {
        UserChatterGroupHandler.handleChatterGroups(newList);
    }
}
