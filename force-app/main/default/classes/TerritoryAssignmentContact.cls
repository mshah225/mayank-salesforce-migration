public without sharing class TerritoryAssignmentContact {
    public static Boolean assignTerritoriesOnAfterUpdateDone = false;

    public void assignTerritoriesOnAfterUpdate(List<Contact> newContactList, Map<Id, Contact> oldContactMap) {
        if (assignTerritoriesOnAfterUpdateDone) {
            return;
        }

        Set<Id> contactIdsWithTAChanges = new Set<Id>();
        List<Opportunity> oppList;

        for (Contact c : newContactList) {
            if (c.MailingState != oldContactMap.get(c.Id).MailingState) {
                contactIdsWithTAChanges.add(c.Id);
            }
        }

        oppList = new List<Opportunity>(
            [SELECT Id, Territory_Assignment_Required__c FROM Opportunity WHERE Contact__c IN :contactIdsWithTAChanges]
        );

        if (oppList.size() > 0) {
            for (Opportunity o : oppList) {
                o.Territory_Assignment_Required__c = true;
            }
            TerritoryAssignmentService.updateOpportunityList(oppList);
            assignTerritoriesOnAfterUpdateDone = true;
        }
    }
}
