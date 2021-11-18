public without sharing class TerritoryAssignmentRule {
    public static Boolean assignTerritoryDone = false;

    public void assignTerritory() {
        if (assignTerritoryDone) {
            return;
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            Map<ID, Territory_Assignment_Rule__c> tarOldMap = (Map<ID, Territory_Assignment_Rule__c>) Trigger.oldMap;

            for (Territory_Assignment_Rule__c tar : (List<Territory_Assignment_Rule__c>) Trigger.New) {
                if (tar.User__c != null && tarOldMap.get(tar.Id).User__c != tar.User__c) {
                    tar.Defer_Territory_Assignment__c = true;
                    tar.Previous_User_ID__c = tarOldMap.get(tar.Id).User__c;
                }
            }
        }

        assignTerritoryDone = true;
    }
}
