public with sharing class AdvisorPortalController {
    private static final String ADVISOR_OUTREACH_RECORDTYPE = IdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

    /**
     * Assembles a list of AdvisorPortalContact wrappers from the provided view options (queue Ids/User Ids).
     *
     * @param allUserOptions, a string list of view options to find Success Student/Contacts with.
     * @return portalContacts, a list of AdvisorPortalContact wrappers to display.
     */
    @AuraEnabled
    public static List<AdvisorPortalContact> getPortalContactsForViewOptions(List<String> allUserOptions) {
        List<AdvisorPortalContact> portalContacts = new List<AdvisorPortalContact>();

        for (Contact contact : getContacts(getSuccessStudentContactIdsForViewOptions(allUserOptions))) {
            portalContacts.add(new AdvisorPortalContact(contact));
        }
        return portalContacts;
    }

    /**
     * Queries for Success_Students__c by their Success Pod Owner or current User using the provided view options.
     *
     * @param allUserOptions, a string list of view options to find Success Student/Contact Ids with.
     * @return successStudentContactIds, a set of Contact Ids filtered by Success Student using the provided view options.
     */
    public static Set<Id> getSuccessStudentContactIdsForViewOptions(List<Id> allUserOptions) {
        String queryWithAllCaseOwners = '';
        Set<Id> successStudentContactIds = new Set<Id>();

        queryWithAllCaseOwners += 'SELECT ContactId FROM Case WHERE ';
        queryWithAllCaseOwners += AdvisorPortalFilterHelper.getOwnerIdsForQuery();
        queryWithAllCaseOwners += ' AND IsClosed = FALSE';
        
        List<Case> listofCases = Database.query(queryWithAllCaseOwners);
        
        for (Case ownedCase : listofCases) {
            successStudentContactIds.add(ownedCase.ContactId);
        }

        for (Success_Student__c student : [
            SELECT Student__c
            FROM Success_Student__c
            WHERE (
                Success_Pod__r.OwnerId IN :allUserOptions
                AND Is_Active__c = TRUE
                AND Student__c NOT IN :successStudentContactIds
            )
            LIMIT 10000
        ]) {
            successStudentContactIds.add(student.Student__c);
        }
        return successStudentContactIds;
    }

    /**
     * Queries for and returns Contact records for the provided list of Ids.
     *
     * @param contactIdList, a list of Contact Ids to filter with.
     * @return a list of Contact records.
     */
    private static List<Contact> getContacts(Set<Id> contactIdList) {
        return [
            SELECT Id, Name, EMPLID__c, ASURite_ID__c, US_Citizen__c, Change_Date__c,
                Most_Recent_Outlook_Change_Direction__c, Curr_Cont_Prediction_Level__c
            FROM Contact
            WHERE Id IN :contactIdList
            ORDER BY Name
            LIMIT 10000
        ];
    }
}