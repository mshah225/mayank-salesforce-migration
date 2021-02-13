trigger TerritoryAssignmentRuleTrigger on Territory_Assignment_Rule__c(before update) {
    TerritoryAssignmentHelper tah = new TerritoryAssignmentHelper();
    tah.TerritoryAssignmentRuleTA();
}
