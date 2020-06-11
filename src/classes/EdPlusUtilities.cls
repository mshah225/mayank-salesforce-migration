/**
 * File Name: EdPlusUtilities
 * Description: Helper for EdPlus cross-org sharing work
 * Author: Carl Hussey
 * Created: 04/22/2020
 */
public with sharing class EdPlusUtilities {
    /**
     * Given a MDM GUID, return all external ContactIds
     */
    public static List<Id> GetExternalContacts(String ContactId) {
        String guid = ContactIdToGUID(ContactId);
        List<CrossOrgShareUtilities.CrosswalkGetWrapper> crosswalk = CrossOrgShareUtilities.GetCrosswalkRecords(guid);
        List<Id> Contacts = new List<Id>();
        Contacts = CrossOrgShareUtilities.CrosswalkToIDList(crosswalk);

        return Contacts;
    }

    /**
     * Given a ContactId, lookup the MDM GUID
     */
    public static String ContactIdToGUID(Id ContactId) {
        String guid = [SELECT SSB_CRMSYSTEM_ACCT_ID__c FROM Contact WHERE Id = :ContactId LIMIT 1].SSB_CRMSYSTEM_ACCT_ID__c;

        return guid;
    }

    /**
     * Track usage of Cross Org Initiative
     */
    @AuraEnabled
    public static void TrackUsage(ID actorId, String action, String relatedRecord) {
        EntCrossOrgUsageStats__c newTracking = new EntCrossOrgUsageStats__c();
        newTracking.Actor_Id__c = actorId;
        newTracking.Action__c = action;
        newTracking.Related_Record_Id__c = relatedRecord;

        insert newTracking;
    }
}
