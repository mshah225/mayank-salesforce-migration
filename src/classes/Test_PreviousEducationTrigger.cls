@istest
private with sharing class Test_PreviousEducationTrigger{  

// Need to update with the correct test user
User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];  

private static testMethod void testContactUpdateFromPreviousEducation() { 
        
    Account HS = new Account();
    HS.Name = 'Test High School';
    HS.Institution_Type__c = 'HS';
    insert HS;

    Account College = new Account();
    College.Name = 'Test College';
    College.Institution_Type__c = '4YR';
    insert College;
    
    Contact Con = new Contact();
    Con.FirstName = 'TestFirstName';
    Con.LastName = 'TestLastName';
    Con.Last_HS_Attended__c = null;
    Con.Last_College_Attended__c = null;
    insert Con;
    System.Debug('Contact ID = ' + Con.Id);
    
    Test.startTest();
        //Test inserting a High School. The trigger updates the contact accordingly. 
        Previous_Education__c PEHS = new Previous_Education__c();
        PEHS.Contact__c = Con.Id;
        PEHS.Account__c = HS.Id;
        insert PEHS;

        //Test Inserting a College. The trigger updates the contact accordingly. 
        Previous_Education__c PEC = new Previous_Education__c();
        PEC.Contact__c = Con.Id;
        PEC.Account__c = College.Id;
        insert PEC;
        
        //Updates added to make sure 100% of code lines are covered
        Update PEC;
        Update PEHS;
        
    Test.stopTest();
    
    // Assertions
    Id HSId = [SELECT Last_HS_Attended__c FROM Contact WHERE Id =: Con.Id LIMIT 1].Last_HS_Attended__c;
    System.Debug('HSId = ' + HSId + ' PEHS.Account__c = ' + PEHS.Account__c);    
    System.Assert(HSId == PEHS.Account__c,'Contact Last High School Attended did not update correctly.'); 

    Id CollegeId = [SELECT Last_College_Attended__c FROM Contact WHERE Id =: Con.Id LIMIT 1].Last_College_Attended__c;
    System.Debug('CollegeId = ' + CollegeId + ' PEC.Account__c = ' + PEC.Account__c);
    System.Assert(CollegeId == PEC.Account__c,'Contact Last College Attended did not update correctly.');  
} 
}