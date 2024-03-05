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
            Opportunity__r.College__c, Opportunity__r.College__r.Name, Opportunity__r.Plan__c, Opportunity__r.Barrett_Application_Status__c, LeadOrContactID__c
            FROM CampaignMember
            WHERE Id =: recordId
            LIMIT 1
        ];

        if (cm.Opportunity__r.College__c != null) {
            Program__c collegeProgram = [
                SELECT Name
                FROM Program__c
                WHERE Id =: cm.Opportunity__r.College__c
            ];

            cm.Opportunity__r.College__r.Name = collegeProgram.Name;
        }

        return cm;
    }

    @AuraEnabled(cacheable=true)
    public static List<EventWrapper> getOtherEvents(String personId, String currentCampaignMemberId, Date eventDate) {

        List<CampaignMember> campaignMembersForDifferentEvents = [
            SELECT Id, Campaign.Name, Status, Campaign.Event_Start_Time__c
            FROM CampaignMember
            WHERE LeadOrContactID__c =: personId 
            AND Campaign.Event_Start_Date__c =: eventDate
            AND Id <>: currentCampaignMemberId
        ];

        List<EventWrapper> eventInfo = new List<EventWrapper>();

        for (CampaignMember cm: campaignMembersForDifferentEvents) {
            eventInfo.add(new EventWrapper(cm.Campaign.Name, cm.Status, cm.Campaign.Event_Start_Time__c));
        }

        return eventInfo;
    }

    @AuraEnabled
    public static Boolean saveCampaignMember(CampaignMember cm) {
        update cm;

        return true;
    }

    public class EventWrapper {
        @AuraEnabled public String eventName;
        @AuraEnabled public String eventMemberStatus;
        @AuraEnabled public String eventStartTime;

        public EventWrapper (String name, String status, String startTime) {
            eventName = name;
            eventMemberStatus = status;
            eventStartTime = startTime;
        }
    }
}