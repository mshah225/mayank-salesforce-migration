public without sharing class PreviousEducationService {
    public static Boolean assignTerritoryDone = false;

    /**
     * Update the Previous Educations' Contacts' Last_HS_Attended__c and Last_College_Attended__c
     * This expects to run once ALL Previous Eductions are retrievable via SOQL (so in the AFTER triggers)
     */
    public static void updateContactsLastEducations(List<Previous_Education__c> prevEdList) {
        Set<Id> contactIdSet = new Set<Id>();
        Map<String, Previous_Education__c> mostRecentPrevEdsPerContactForHSAndCollege = new Map<String, Previous_Education__c>();
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();

        //Get all the contact IDs attached to the PEs we're looking at
        for (Previous_Education__c prevEd : prevEdList)
            contactIdSet.add(prevEd.Contact__c);

        if (contactIdSet.isEmpty())
            return; // none of the Prev Educations have contact lookups

        // Get all the previous educations for these contacts
        List<Previous_Education__c> allPrevEdForContacts = new List<Previous_Education__c>(
            [
                SELECT Id, Contact__c, Account__c, Institution_Type__c, CreatedDate, LastModifiedDate
                FROM Previous_Education__c
                WHERE Contact__c IN :contactIdSet
            ]
        );

        // Sort the PEs into a map by Contact ID (we have two entries for each contact, one for HS and one for College)
        // maps from "<ContactId>|<Type>" (either H or C for HS or college respectively) to the most recently modified
        // Previous_Education for that contact of that type
        for (Previous_Education__c prevEd : allPrevEdForContacts) {
            string mapKey = makeKey(prevEd);
            if (mapKey != null) {
                if (!mostRecentPrevEdsPerContactForHSAndCollege.containsKey(mapKey)) {
                    // don't have anything for this contact's high school or college yet
                    mostRecentPrevEdsPerContactForHSAndCollege.put(mapKey, prevEd);
                } else {
                    // already have a PrevEd for this contact's high school or college
                    Previous_Education__c curPrevEd = mostRecentPrevEdsPerContactForHSAndCollege.get(mapKey);
                    // use the new PrevEd IF its LastModifiedDate is more recent
                    if (curPrevEd.LastModifiedDate < prevEd.LastModifiedDate) {
                        mostRecentPrevEdsPerContactForHSAndCollege.put(mapKey, prevEd);
                    }
                }
            }
        }

        //Get data from all the contacts attached to the PEs
        Map<Id, Contact> contactMap = new Map<Id, Contact>(
            [SELECT Id, Last_HS_Attended__c, Last_College_Attended__c FROM Contact WHERE Id IN :contactIdSet]
        );

        // For each previous education we are changing - we need to potentially update its Contact
        for (Previous_Education__c prevEd : prevEdList) {
            // skip if this prev ed has no contact
            if (prevEd.Contact__c == null)
                continue;
            // otherwise let's get the details from this contact
            Contact thisContact = contactMap.get(prevEd.Contact__c);
            if (thisContact == null)
                continue;

            // Key to find most recent prevEd for this <ContactId>|<Type> pair
            String key = makeKey(prevEd);

            if (prevEd.Institution_Type__c == 'HS') {
                // For High school prevEducation
                if (
                    mostRecentPrevEdsPerContactForHSAndCollege.containsKey(key) &&
                    mostRecentPrevEdsPerContactForHSAndCollege.get(key).Id != thisContact.Last_HS_Attended__c
                ) {
                    // This contact's Last HS attended doesn't match the one on the most recent high school - so let's update it
                    Contact contactWithLastHSAttendedSet = new Contact(
                        Id = prevEd.Contact__c,
                        Last_HS_Attended__c = mostRecentPrevEdsPerContactForHSAndCollege.get(key).Account__c
                    );
                    ObjectService.updateSObjectInMap(contactsToUpdate, contactWithLastHSAttendedSet);
                }
            } else if (prevEd.Institution_Type__c == '2YR' || prevEd.Institution_Type__c == '4YR') {
                //Else, if this is a college prevEducation
                if (
                    mostRecentPrevEdsPerContactForHSAndCollege.containsKey(key) &&
                    mostRecentPrevEdsPerContactForHSAndCollege.get(key).Id != thisContact.Last_College_Attended__c
                ) {
                    // This contact's Last HS attended doesn't match the one on the most recent high school - so let's update it
                    Contact contactWithLastHSAttendedSet = new Contact(
                        Id = prevEd.Contact__c,
                        Last_College_Attended__c = mostRecentPrevEdsPerContactForHSAndCollege.get(key).Account__c
                    );
                    ObjectService.updateSObjectInMap(contactsToUpdate, contactWithLastHSAttendedSet);
                }
            }
        }

        if (!contactsToUpdate.isEmpty())
            update contactsToUpdate.values();
    }

    private static String makeKey(Previous_Education__c prevEd) {
        String key = '';

        if (prevEd.Contact__c == null)
            return null;

        key += prevEd.Contact__c;

        if (prevEd.Institution_Type__c == 'HS')
            key += '|H';
        else
            key += '|C';

        return key;
    }

    public static void assignTerritory(List<Previous_Education__c> newPreviousEducations) {
        if (assignTerritoryDone) {
            return;
        }

        // Get all contact ids for these Previous Educations
        Set<Id> contactIdSet = new Set<Id>();
        for (Previous_Education__c previousEducation : newPreviousEducations)
            contactIdSet.add(previousEducation.Contact__c);

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

            for (Opportunity opp : oppList) {
                opp.Territory_Assignment_Required__c = true;
                oppToUpdate.add(opp);
            }

            if (!oppToUpdate.isEmpty())
                TerritoryAssignmentService.updateOpportunityList(oppToUpdate);
        }
        assignTerritoryDone = true;
    }
}