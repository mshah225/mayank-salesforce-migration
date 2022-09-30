public without sharing class TerritoryAssignmentPreviousEducation {
    public static Boolean assignTerritoryDone = false;
    List<Previous_Education__c> peTriggerList;

    public TerritoryAssignmentPreviousEducation(List<Previous_Education__c> peTriggerList) {
        this.peTriggerList = peTriggerList;
    }

    public void assignTerritory() {
        if (assignTerritoryDone)
            return;
        assignTerritoryDone = true;

        // Get all contact ids for these Previous Educations
        Set<Id> contactIdSet = new Set<Id>();
        for (Previous_Education__c PE : peTriggerList)
            contactIdSet.add(PE.Contact__c);

        // If these Previous Educations had some contact lookups - we need to update the territory assignment for their Opportunities
        if (!contactIdSet.isEmpty()) {
            List<Opportunity> oppList = new List<Opportunity>(
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

            for (Opportunity o : oppList) {
                o.Territory_Assignment_Required__c = true;
                oppToUpdate.add(o);
            }

            if (!oppToUpdate.isEmpty())
                TerritoryAssignmentService.updateOpportunityList(oppToUpdate);
        }
    }
}
