public without sharing class TerritoryAssignmentRuleDispatcher implements TriggerDispatcherInterface {
    private List<Territory_Assignment_Rule__c> newList;
    private Map<Id, Territory_Assignment_Rule__c> newMap;
    private List<Territory_Assignment_Rule__c> oldList;
    private Map<Id, Territory_Assignment_Rule__c> oldMap;

    public TerritoryAssignmentRuleDispatcher(
        List<Territory_Assignment_Rule__c> newList,
        Map<Id, Territory_Assignment_Rule__c> newMap,
        List<Territory_Assignment_Rule__c> oldList,
        Map<Id, Territory_Assignment_Rule__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
    }

    public void beforeUpdate() {
        TerritoryAssignmentRule ta = new TerritoryAssignmentRule();
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
