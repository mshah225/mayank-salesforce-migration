public with sharing class CampusVisitController {
    @AuraEnabled(cacheable=True)
    public static List<CampaignMember> getCampaignMembers(String recordId, List<String> searchStatus){

        List<CampaignMember> campaignMembersToDisplay = [
            SELECT Name, Id, LeadOrContactID__c, Type, Contact.MailingState, Status, Number_of_Guests__c, Number_of_Attendees__c
            FROM CampaignMember
            WHERE Status IN: searchStatus AND CampaignId =: recordId
            LIMIT 1000
        ];

        return campaignMembersToDisplay;
    }

    @AuraEnabled
    public static List<CampaignMember> searchCampaignMembers(String searchString, List<String> searchStatus, String recordId){
        if (searchString == null || searchString.length() < 2) {
            searchString = '';
        }
        searchString = '%' + searchString + '%';

        List<CampaignMember> campaignMembersToDisplay = [
            SELECT Name, Id, LeadOrContactID__c, Type, Contact.MailingState, Status, Number_of_Guests__c, Number_of_Attendees__c
            FROM CampaignMember
            WHERE Name LIKE: searchString AND Status IN: searchStatus AND CampaignId =: recordId
            LIMIT 1000
        ];

        System.debug(campaignMembersToDisplay);

        return campaignMembersToDisplay;
    }

    @AuraEnabled
    public static void updateCampaignMembers(List<Id> campaignMemberIds){
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();

        for (Id memberId : campaignMemberIds) {
            CampaignMember cm = new CampaignMember();
            cm.Id = memberId;
            cm.Status = 'Sent';

            membersToUpdate.add(cm);
        }

        update membersToUpdate;
    } 
}