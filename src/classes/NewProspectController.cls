/* 
*  ASU New Prospect Page Controller
*  Author: CedarCrestone
*  Created: 1/29/2014
*  Last Updated: 1/30/2015
*  Who updated: Mat Ruff
*  What was updated: Default record type changed to Graduate Prospect upon insertion.
*/

public with sharing class NewProspectController {
    public String searchFirstName {get;set;}
    public String searchLastName {get;set;}
    public String searchLeadEmail {get;set;}
    public String searchPhone {get;set;}
    public List<SelectOption> options;
    public Id oppGradProsId = [SELECT Id FROM RecordType WHERE Name = 'Graduate Prospect'].Id;

    public Id AccId;
    
    public Boolean IsDuplicateContact = false;
    public String DuplicateContactName;
    public Id DuplicateContactId;
    public Id DuplicateAccountId;
    
    Contact contact;
    Opportunity opportunity;
    Task task;
    
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

    public void setContact(Contact contact){
        this.contact = contact;
    }
    
    public void setOpportunity(Opportunity opportunity){
        this.opportunity = opportunity;
    }
    
    public void setTask(Task task){
        this.task = task;
    }

    public List<SelectOption> getOptions() {
        options = new List<SelectOption>();
        Id rt = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' and name ='Graduate Prospect'].Id;
        Schema.DescribeFieldResult fieldResult = Schema.sObjectType.Opportunity.fields.Type;
        List<Schema.PicklistEntry> ple = fieldResult.picklistValues;
        options.add(new SelectOption('', '--Select--'));

        for(Schema.PicklistEntry p : ple)
        {
            if(p.active) {
                if((p.getValue() == 'Masters') || (p.getValue() == 'Doctoral') || (p.getValue() == 'Juris Doctor') || (p.getValue() == 'Certificate') || (p.getValue() == 'Non-Degree')) {
                    options.add(new SelectOption(p.getLabel(), p.getValue()));
                }
            }
        }
        return options;
    }
        
    //Inserts fields to object and redirects user to new Opportunity.
    Public PageReference save() {
        if(opportunity.Type == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You must select an Opportunity type.'));
            return null;
        }
    
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
        opportunity.RecordTypeId = oppGradProsId;
        opportunity.StageName = 'Prospect';
        opportunity.Career__c = 'Graduate';
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
    
    
    //Inserts fields to object and refreshes page for new input.
    Public PageReference saveAndNew() {
        if(opportunity.Type == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You must select an Opportunity type.'));
            return null;
        }
    
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
        opportunity.RecordTypeId = oppGradProsId;
        opportunity.StageName = 'Prospect';
        opportunity.Career__c = 'Graduate';
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
        PageReference pgRef = ApexPages.currentPage(); 
        pgRef.setRedirect(true);
        return pgRef;    
    }
}