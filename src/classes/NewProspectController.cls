public class NewProspectController {

// ASU New Prospect Page Controller
// Author: CedarCrestone
// Created 1/29/2014
// Last Updated 04/30/2014

Public String searchFirstName {get;set;}
Public String searchLastName {get;set;}
Public String searchLeadEmail {get;set;}
Public String searchPhone {get;set;}

Public Id AccId;

Public Boolean IsDuplicateContact = false;
Public String DuplicateContactName;
Public Id DuplicateContactId;
Public Id DuplicateAccountId;

Contact contact;
Opportunity opportunity;
Task task;

public void setContact(Contact contact){
    this.contact = contact;
}
public void setOpportunity(Opportunity opportunity){
    this.opportunity = opportunity;
}

public void setTask(Task task){
    this.task = task;
}

public Contact getContact(){
    if(contact == null) contact= new Contact(); 
    return contact;
} 

public Opportunity getOpportunity() {
    if(opportunity == null) opportunity = new Opportunity();
    return opportunity;
}

public Task getTask() {
    if(task == null) task = new Task();
    return task;
}
    
Public PageReference save() {
    List<User> sfAdminUserList = new List<User>([SELECT Id FROM User Where LastName = 'Admin' AND FirstName = 'Salesforce' AND Profile.Name = 'System Administrator']);

    // Create Contact
    if (sfAdminUserList.size()>0) {
      contact.OwnerId = sfAdminUserList[0].Id;
    }
    if (contact != null) {
        searchFirstName = contact.FirstName;
        searchLastname = contact.LastName;
        searchLeadEmail = contact.Lead_Email__c;
    }
    LIST <Contact> DuplicateContacts = [SELECT Id, AccountId, FirstName, LastName 
                                        FROM Contact 
                                        WHERE FirstName = :searchFirstName  
                                        AND LastName = :searchLastName  
                                        AND Email = :searchLeadEmail
                                        ORDER BY CreatedDate ASC];    


    if (DuplicateContacts.size()>0){
        DuplicateContactName = DuplicateContacts[0].FirstName + ' ' + DuplicateContacts[0].LastName;
        DuplicateContactId = DuplicateContacts[0].Id;
        DuplicateAccountId = DuplicateContacts[0].AccountId;
        IsDuplicateContact = true;
    }
    if (IsDuplicateContact == false){
        contact.silverpop__Sync_to_Silverpop_Chk__c = true;
        insert contact;
    }

    // Create Opportunity
    Datetime DatePreString = Datetime.now();
    String TodayString = DatePreString.format('yyyy-MM-dd');
    
    if (sfAdminUserList.size()>0) {
        opportunity.OwnerId = sfAdminUserList[0].Id;
    }
    if (DuplicateContacts.size()>0 && IsDuplicateContact == true){
        opportunity.Contact__c = DuplicateContactId;  
        opportunity.Name = DuplicateContactName + TodayString; 
        AccId = DuplicateAccountId;
    }
    else {
        opportunity.Contact__c = contact.Id;
        opportunity.Name = Contact.FirstName + ' ' + Contact.LastName + '-' + TodayString; 
        AccId = [SELECT AccountId FROM Contact WHERE Id = :Contact.Id][0].AccountId;
        opportunity.AccountId = AccId;
    }
    if(AccId != null){
        opportunity.AccountId = AccId;
    } 
    opportunity.CloseDate = Date.Today()+365;
    insert opportunity;

    // Create Task
    task.WhatId = opportunity.Id;
    task.WhoId = contact.Id;
    task.Status = 'Completed';
    task.ActivityDate = Date.today();
    // Only create the task if the user enters a description.
    if (task.Description != null){
        insert task;
    }
    PageReference pgRef = new PageReference('/' + opportunity.Id); 
    pgRef.setRedirect(true);
    return pgRef;    
}
}