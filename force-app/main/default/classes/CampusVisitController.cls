public with sharing class CampusVisitController {
    @AuraEnabled(cacheable=True)
    public static List<CampaignMember> getCampaignMembers(){
        return [
            SELECT Name, Id, LeadOrContactID__c, Type, Contact.MailingState, Status, Number_of_Guests__c, Number_of_Attendees__c
            FROM CampaignMember
            LIMIT 1000
        ];
    }

    @AuraEnabled(cacheable=True)
    public static List<CampaignMember> searchCampaignMembers(String searchString){
        searchString = '%' + searchString + '%';
        return [
            SELECT Name, Id, LeadOrContactID__c, Type, Contact.MailingState, Status, Number_of_Guests__c, Number_of_Attendees__c
            FROM CampaignMember
            WHERE Name LIKE: searchString
            LIMIT 1000
        ];
    }

    /*@AuraEnabled
    public static void deleteContacts(List<Id> contactIds){
        if(contactIds.size() > 0 ){
            delete [SELECT Id FROM Contact WHERE Id in: contactIds];
        }
    } */
}