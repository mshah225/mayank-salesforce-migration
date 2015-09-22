/*
* Name: SearchUsers.cls
* Written by: Mathew Ruff
* Date Created: Oct. 2nd 2014
* 
* Last Updated: Oct. 10 2014
* What was Changed: Added the Alias, ASU_User_Type__c, IsActive, and FederationIdentifier fields.
*/

public with sharing class SearchUsers {

    //Get our lists started
    List <User> uList = [SELECT Id, Name, Profile.Name, Contact.Name, ContactId, Contact.ASURite_Id__c, Alias, FederationIdentifier, ASU_User_Type__c, IsActive FROM User ORDER BY Name ASC LIMIT 50];
    public string searchString { get;set; }
    
    //Return the list to the page
    public List<User> getUList() {
        return uList;
    }
    
    //Take the user input and do a search
    public void search() {
        String searchQuery = 'SELECT Id, Name, Profile.Name, Contact.Name, ContactId, Contact.ASURite_Id__c, EmplId__c, Contact.EMPLID__c, Alias, FederationIdentifier, ASU_User_Type__c, IsActive FROM User WHERE Name LIKE \'%' + searchString + '%\' OR Profile.Name LIKE \'%' + searchString + '%\' OR Contact.Name LIKE \'%' + searchString + '%\' OR Contact.ASURite_Id__c LIKE \'%' + searchString + '%\' OR EmplId__c = :searchString OR Contact.EMPLID__c = :searchString OR Id = :searchString OR ContactId = :searchString OR Alias LIKE \'%' + searchString + '%\' OR FederationIdentifier LIKE \'%' + searchString + '%\' OR ASU_User_Type__c LIKE \'%' + searchString + '%\' ORDER BY Name ASC LIMIT 50';
        uList = Database.query(searchQuery);
    }
    
    //Remove user input from variable
    public void clear() {
        searchString = null;
        String searchQuery = 'SELECT Id, Name, Profile.Name, Contact.Name, ContactId, Contact.ASURite_Id__c, Alias, FederationIdentifier, ASU_User_Type__c, IsActive FROM User ORDER BY Name ASC LIMIT 50';
        uList = Database.query(searchQuery);
    } 
    
    //Do we have results? returns true/false
    public Boolean getNoResults() {
        if(uList.isEmpty()) {
            return true;
        }
        else if(!uList.isEmpty()) {
            return false;
        }
        return false;
    }
}