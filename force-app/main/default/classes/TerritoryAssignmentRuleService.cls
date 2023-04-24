public without sharing class TerritoryAssignmentRuleService {
    public static Boolean assignTerritoryDone = false;

    public static void deferTerritoryReassignments(
        List<Territory_Assignment_Rule__c> newList,
        Map<ID, Territory_Assignment_Rule__c> tarOldMap
    ) {
        if (assignTerritoryDone)
            return;

        for (Territory_Assignment_Rule__c tar : newList) {
            if (tar.User__c != null && tarOldMap.get(tar.Id).User__c != tar.User__c) {
                tar.Defer_Territory_Assignment__c = true;
                tar.Previous_User_ID__c = tarOldMap.get(tar.Id).User__c;
            }
        }

        assignTerritoryDone = true;
    }
}
