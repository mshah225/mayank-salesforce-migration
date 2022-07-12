public without sharing class TerritoryAssignmentPreviousEducation {
    public static Boolean assignTerritoryDone = false;

    public void assignTerritory() {
        if (assignTerritoryDone) {
            return;
        }
        assignTerritoryDone = true;

        List<Previous_Education__c> peTriggerList = new List<Previous_Education__c>();
        Set<Id> contactIdSet = new Set<Id>();

        if (Trigger.IsDelete) {
            peTriggerList = (List<Previous_Education__c>) Trigger.old;
        } else {
            peTriggerList = (List<Previous_Education__c>) Trigger.new;
        }

        for (Previous_Education__c PE : peTriggerList) {
            contactIdSet.add(PE.Contact__c);
        }

        if (contactIdSet.size() > 0 && (Trigger.IsInsert || Trigger.isUpdate || Trigger.isDelete)) {
            List<Opportunity> opp = new List<Opportunity>(
                [
                    SELECT
                        Id,
                        Contact__c,
                        Account.Name,
                        Account.Institution_Type__c,
                        Account.Territory_Manager__c,
                        Type,
                        OwnerId
                    FROM Opportunity
                    WHERE Contact__c IN :contactIdSet
                ]
            );

            List<Opportunity> oppToUpdate = new List<Opportunity>();

            for (Opportunity o : opp) {
                o.Territory_Assignment_Required__c = true;
                oppToUpdate.add(o);
            }

            if (oppToUpdate.size() > 0) {
                TerritoryAssignmentService.updateOpportunityList(oppToUpdate);
            }
        }
    }
}
