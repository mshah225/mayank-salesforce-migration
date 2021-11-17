trigger TerritoryAssignmentRuleTrigger on Territory_Assignment_Rule__c(before update) {
    TerritoryAssignmentRule ta = new TerritoryAssignmentRule();
    ta.assignTerritories();
}
