public with sharing class CampusVisitController {
    @AuraEnabled(cacheable=True)
    public static List<CampaignMember> getCampaignMembers(){
        return [
            SELECT Name, Id, LeadOrContactID__c, Type, Contact.MailingState, Status, Number_of_Guests__c, Number_of_Attendees__c
            FROM CampaignMember
            LIMIT 1000
        ];
    }

    @AuraEnabled
    public static List<CampaignMember> searchCampaignMembers(String searchString, List<String> searchStatus){
        if (searchString == null || searchString.length() < 2) {
            searchString = '';
        }
        searchString = '%' + searchString + '%';
        return [
            SELECT Name, Id, LeadOrContactID__c, Type, Contact.MailingState, Status, Number_of_Guests__c, Number_of_Attendees__c
            FROM CampaignMember
            WHERE Name LIKE: searchString AND Status IN: searchStatus
            LIMIT 1000
        ];
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