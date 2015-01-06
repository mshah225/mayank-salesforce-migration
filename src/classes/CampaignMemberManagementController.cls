/*
* Name: CampaignMemberManagementController
* Written by: Mathew Ruff
* Date Created: Nov 6 2014
* 
* Last Updated: Dec 16 2014
* What was Changed: Added External ID to Interest Search.
*/

public class CampaignMemberManagementController {

    public CampaignMemberManagementController(ApexPages.StandardController controller) { }

    public List<CampaignMember> eventList;
    public List<CampaignMember> interestList;
    public List<CampaignMember> scholarList;
    public List<CampaignMember> cohortList;
    public List<CampaignMember> oSourceList;
    public List<CampaignMember> markCommList;
    public List<Campaign> eventSearchResults;
    public List<Campaign> interestSearchResults;
    public String eSearchString { get;set; }
    public String iSearchString { get;set; }
    public Id elId { get;set; }
    public Id intId { get;set; }
    public Id contId = [SELECT Id FROM Contact WHERE Id = :ApexPages.currentPage().getParameters().get('id')].Id;
    CampaignMember camMemInterest;
    
    public Id getContId() {
        if(contId != null) {
            return contId;
        }
        else {
            return null;
        }
    }
           
    
    public void setCampaignMemberInterest(CampaignMember camMemInterest) {
        this.camMemInterest = camMemInterest;
    }

    public CampaignMember getCampaignMemberInterest() {
        if(camMemInterest == null) camMemInterest = new CampaignMember();
        return camMemInterest;
    }        
    
    //Event tab.
    public List<CampaignMember> getEventList() {
        //Test with: ?id=003J0000013ymYtIAI returns two values for dataTable
        Id eventRecId = [SELECT Id FROM RecordType WHERE Name = 'Event'].Id;
        Id eossRecId = [SELECT Id FROM RecordType WHERE Name = 'EOSS Event'].Id;
        eventList = [SELECT Id, Campaign.Name, Campaign.Type, Campaign.Requested__c, Campaign.Interest_PeopleSoft_Major__c, Campaign.Event_Start_Date__c, Number_Of_Guests__c, Status, Last_Member_Status_Change__c FROM CampaignMember WHERE ContactId = :ApexPages.currentPage().getParameters().get('id') AND (Campaign.RecordTypeId = :eventRecId OR Campaign.RecordTypeId = :eossRecId) LIMIT 40];
        if(eventList != null) {
            return eventList;
        }
        else {
            return null;
        }
    }
    
    public void doEventSearch() {
        Id eventRecId = [SELECT Id FROM RecordType WHERE Name = 'Event'].Id;
        Id eossRecId = [SELECT Id FROM RecordType WHERE Name = 'EOSS Event'].Id;
        String eSearchQuery = 'SELECT Id, Name, Type, Category__c, Event_Start_Date__c, Event_Start_Time__c, Campus_Location__c, Event_Location__c, RecordTypeId FROM Campaign WHERE (Name LIKE \'%' + String.escapeSingleQuotes(eSearchString) + '%\' OR Type LIKE \'%' + String.escapeSingleQuotes(eSearchString) + '%\' OR Category__c LIKE \'%' + String.escapeSingleQuotes(eSearchString) + '%\') AND (Campaign.RecordTypeId = :eventRecId OR Campaign.RecordTypeId = :eossRecId) AND IsActive = true ORDER BY Name ASC LIMIT 40';
        eventSearchResults = Database.query(eSearchQuery);
    }
    
    public List<Campaign> getEventSearchResults() {
        return eventSearchResults;
    }    
    
    //Interest tab.
    public List<CampaignMember> getInterestList() {
        //Test with: ?id=003J0000013ymYtIAI returns two values for dataTable
        Id intRecId = [SELECT Id FROM RecordType WHERE Name = 'Interest'].Id;
        interestList = [SELECT Id, Campaign.Name, Campaign.Type, Campaign.Requested__c, Campaign.Interest_PeopleSoft_Major__c, Status, Last_Member_Status_Change__c FROM CampaignMember WHERE Campaign.RecordTypeId = :intRecId AND ContactId = :ApexPages.currentPage().getParameters().get('id') LIMIT 40];
        if(interestList != null) {
            return interestList;
        }
        else {
            return null;
        }
    }
    
    public void doInterestSearch() {
        Id intRecId = [SELECT Id FROM RecordType WHERE Name = 'Interest'].Id;
        String iSearchQuery = 'SELECT Id, Name, Type, Campaign_External_ID__c FROM Campaign WHERE (Name LIKE \'%' + String.escapeSingleQuotes(iSearchString) + '%\' OR Type LIKE \'%' + String.escapeSingleQuotes(iSearchString) + '%\') AND Campaign.RecordTypeId = :intRecId AND IsActive = true ORDER BY Name ASC LIMIT 40';
        interestSearchResults = Database.query(iSearchQuery);
    }
    
    public List<Campaign> getInterestSearchResults() {
        return interestSearchResults;
    }    
    
    //Scholarship tab.
    public List<CampaignMember> getScholarList() {
        Id schRecId = [SELECT Id FROM RecordType WHERE Name = 'Scholarship'].Id;
        scholarList = [SELECT Id, Campaign.Name, Campaign.Type, Amount__c, Award_Date__c, Letter_Date__c, Status, Last_Member_Status_Change__c FROM CampaignMember WHERE ContactId = :ApexPages.currentPage().getParameters().get('id') AND Campaign.RecordTypeId = :schRecId LIMIT 40];
        return scholarList;
    }    
    
    //Cohort tab.
    public List<CampaignMember> getCohortList() {
        Id cohRecId = [SELECT Id FROM RecordType WHERE Name = 'Cohort'].Id;
        cohortList = [SELECT Id, Campaign.Name, Campaign.Type, Campaign.Requested__c, Status, Last_Member_Status_Change__c FROM CampaignMember WHERE ContactId = :ApexPages.currentPage().getParameters().get('id') AND Campaign.RecordTypeId = :cohRecId LIMIT 40];
        return cohortList;
    }
        
    //Other Sources tab.
    public List<CampaignMember> getoSourceList() {
        Id sourceRecId = [SELECT Id FROM RecordType WHERE Name = 'Other Source'].Id;
        oSourceList = [SELECT Id, Campaign.Name, Campaign.Type, Campaign.Requested__c, Status, Last_Member_Status_Change__c FROM CampaignMember WHERE ContactId = :ApexPages.currentPage().getParameters().get('id') AND Campaign.RecordTypeId = :sourceRecId LIMIT 40];
        return oSourceList;
    }
    
    //Marketing/Communications tab.
    public List<CampaignMember> getMarkCommList() {
        Id markCommRecid = [SELECT Id FROM RecordType WHERE Name = 'Communication'].Id;
        markCommList = [SELECT Id, Campaign.Name, Campaign.Type, Campaign.Requested__c, Status, Last_Member_Status_Change__c FROM CampaignMember WHERE ContactId = :ApexPages.currentPage().getParameters().get('id') AND Campaign.RecordTypeId = :markCommRecId LIMIT 40];
        return markCommList;
    }    
    
    //Add to event button
    public PageReference AddToEvent() { 
        
        PageReference addToEvent = new PageReference('/00v/e?c_id=' + elId + '&parent_id=' + contId + '&retURL=%2F' + contId);
        addToEvent.setRedirect(true);
        return addToEvent;
    }
    
    //Add Interest button
    public void AddInterest() { 
        getCampaignMemberInterest();

        camMemInterest.Id = null;
        camMemInterest.LeadId = null;
        camMemInterest.CampaignId = intId;
        camMemInterest.ContactId = contId;
        camMemInterest.Status = 'Interested';
        
        insert camMemInterest;
        System.Debug('Inserted an Interest Campaign Member');
        System.Debug(camMemInterest);
    }    
}