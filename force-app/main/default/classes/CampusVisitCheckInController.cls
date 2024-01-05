public with sharing class CampusVisitCheckInController {
    public CampusVisitCheckInController() {

    }

    @AuraEnabled(cacheable=true)
    public static CampaignMember getCampaignMember(String recordId) {
        if (recordId == null) {
            return null;
        }

        CampaignMember cm = [
            SELECT Campaign.Name, Status, Campaign.Event_Start_Time__c, Campaign.Event_Start_Date__c, Name, Badge_Name__c, Contact.MailingState, 
            Opportunity__r.Career__c, Opportunity__r.Type, Opportunity__r.StageName, Number_of_Guests__c, Number_of_Attendees__c, Academic_Session__c, 
            Comments__c, Barrett_Session__c, Housing_Tour__c, Additional_Tour_Information__c, Opportunity__r.Current_Location__c,
            Opportunity__r.College__c, Opportunity__r.Plan__c, Opportunity__r.Barrett_Application_Status__c
            FROM CampaignMember
            WHERE Id =: recordId
            LIMIT 1
        ];

        return cm;
    }
}