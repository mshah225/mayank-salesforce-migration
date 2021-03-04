public without sharing class PreviousEducationHandler implements ITrigger {
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore() {
    }

    /**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */

    public void bulkAfter() {
        List<Contact> contactsToUpdate = new List<Contact>();
        Set<Id> hsContactsToUpdateIds = new Set<Id>();
        Set<Id> collegeContactsToUpdateIds = new Set<Id>();
        Map<string, Previous_Education__c> peMap = new Map<string, Previous_Education__c>();
        Set<Id> contactIdSet = new Set<Id>();

        List<Previous_Education__c> peTriggerList = new List<Previous_Education__c>();

        if (Trigger.IsDelete) {
            peTriggerList = (List<Previous_Education__c>) Trigger.old;
        } else {
            peTriggerList = (List<Previous_Education__c>) Trigger.new;
        }

        //Get all the contact IDs attached to the PEs we're looking at
        for (Previous_Education__c PE : peTriggerList) {
            contactIdSet.add(PE.Contact__c);
        }

        if (contactIdSet.size() > 0) {
            //Get all the PEs that share contacts with the PEs in the trigger
            List<Previous_Education__c> peList = new List<Previous_Education__c>(
                [
                    SELECT Id, Contact__c, Account__c, Institution_Type__c, CreatedDate, LastModifiedDate
                    FROM Previous_Education__c
                    WHERE Contact__c IN :contactIdSet
                ]
            );

            //Sort the PEs into a map by Contact ID (we have two entries for each contact, one for HS and one for College)
            for (Previous_Education__c pe : peList) {
                string mapKey;
                if (pe.Contact__c != null) {
                    if (pe.Institution_Type__c == 'HS') {
                        mapKey = pe.Contact__c + '|H';
                    } else {
                        mapKey = pe.Contact__c + '|C';
                    }

                    if (!peMap.containsKey(mapKey) || (peMap.get(mapKey).LastModifiedDate < pe.LastModifiedDate)) {
                        peMap.put(mapKey, pe);
                    }
                }
            }
        }

        //Get data from all the contacts attached to the PEs
        Map<Id, Contact> contactMap = new Map<Id, Contact>(
            [SELECT Id, Last_HS_Attended__c, Last_College_Attended__c FROM Contact WHERE Id IN :contactIdSet]
        );

        //For each PE in the trigger list
        for (Previous_Education__c PEsToUpdate : peTriggerList) {
            //Get the contact attached to this PE
            Contact thisContact = contactMap.get(PEsToUpdate.Contact__c);
            if (thisContact == null) {
                continue;
            }

            //If this PE is an HS PE and we're not already updating its contact
            if (PEsToUpdate.Institution_Type__c == 'HS' && !hsContactsToUpdateIds.contains(PEsToUpdate.Contact__c)) {
                //If this contact does not yet have a Last HS attended, assign it
                if (thisContact.Last_HS_Attended__c == null) {
                    thisContact.Last_HS_Attended__c = PEsToUpdate.Account__c;
                    ObjectService.addToListSafely(contactsToUpdate, thisContact);
                    hsContactsToUpdateIds.add(PEsToUpdate.Contact__c);
                } else if (
                    peMap.containsKey(thisContact.Id + '|H') &&
                    peMap.get(thisContact.Id + '|H').Id != thisContact.Last_HS_Attended__c
                ) {
                    //If this contact DOES have a Last HS attended, but it doesn't match the one on the PE, update it
                    thisContact.Last_HS_Attended__c = peMap.get(thisContact.Id + '|H').Account__c;
                    ObjectService.addToListSafely(contactsToUpdate, thisContact);
                }
            } else if (
                (PEsToUpdate.Institution_Type__c == '2YR' || PEsToUpdate.Institution_Type__c == '4YR') &&
                !collegeContactsToUpdateIds.contains(PEsToUpdate.Contact__c)
            ) {
                //Else, if this PE is a college PE and we're not already updating its contact
                //If the contact does not yet have a Last College attended, assign it
                if (thisContact.Last_College_Attended__c == null) {
                    thisContact.Last_College_Attended__c = PEsToUpdate.Account__c;
                    ObjectService.addToListSafely(contactsToUpdate, thisContact);
                    collegeContactsToUpdateIds.add(PEsToUpdate.Contact__c);
                } else if (
                    thisContact.Last_College_Attended__c == null ||
                    (peMap.containsKey(thisContact.Id + '|C') &&
                    peMap.get(thisContact.Id + '|C').Id != thisContact.Last_College_Attended__c)
                ) {
                    //If the contact DOES have a college attended, but it doesn't match the one on the PE, update it
                    thisContact.Last_College_Attended__c = peMap.get(thisContact.Id + '|C').Account__c;
                    ObjectService.addToListSafely(contactsToUpdate, thisContact);
                }
            }
        }

        //Update the contacts as needed
        if (contactsToUpdate.size() > 0) {
            update contactsToUpdate;
        }
    }

    /**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    public void beforeInsert(SObject so) {
    }

    /**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
    public void beforeUpdate(SObject oldSo, SObject so) {
    }

    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so) {
    }

    /**
     * beforeFinally
     *
     * This method is called at the end of the execution of a BEFORE trigger. Use this to finalize
     * any bulk operations for a BEFORE trigger.
     */

    public void beforeFinally() {
    }

    /**
     * afterInsert
     *
     * This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point.
     */
    public void afterInsert(SObject so) {
    }

    /**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     */
    public void afterUpdate(SObject oldSo, SObject so) {
    }

    /**
     * afterDelete
     *
     * This method is called iteratively for each record deleted during an AFTER
     * trigger.
     */
    public void afterDelete(SObject so) {
    }

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally() {
    }
}
