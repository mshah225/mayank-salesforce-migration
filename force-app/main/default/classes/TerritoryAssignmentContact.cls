public without sharing class TerritoryAssignmentContact {
    public static Boolean assignTerritoryDone = false;

    public void assignTerritory() {
        if (assignTerritoryDone) {
            return;
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            Set<Id> contactIdsWithTAChanges = new Set<Id>();
            Map<Id, Contact> oldContactMap = (Map<Id, Contact>) Trigger.oldMap;
            List<Opportunity> oppList;

            for (Contact c : (List<Contact>) Trigger.new) {
                if (c.MailingState != oldContactMap.get(c.Id).MailingState) {
                    contactIdsWithTAChanges.add(c.Id);
                }
            }

            oppList = new List<Opportunity>(
                [
                    SELECT Id, Territory_Assignment_Required__c
                    FROM Opportunity
                    WHERE Contact__c IN :contactIdsWithTAChanges
                ]
            );

            if (oppList.size() > 0) {
                for (Opportunity o : oppList) {
                    o.Territory_Assignment_Required__c = true;
                }
                TerritoryAssignmentService.updateOpportunityList(oppList);
                assignTerritoryDone = true;
            }
        }
    }
}
