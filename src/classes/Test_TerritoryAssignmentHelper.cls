@istest
private without sharing class Test_TerritoryAssignmentHelper{  

private static testMethod void testAccountGeomarketCodeAssignment(){ 
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1]; 

    Account HS = new Account();
    HS.Name = 'Test High School';
    insert HS;
    
    Contact Con = new Contact();
    Con.FirstName = 'TestFirstName';
    Con.LastName = 'TestLastName';
    Con.MailingPostalCode = '90210';
    Con.Geomarket_Code__c = 'CA-01';
    Insert Con;
    
    Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];    
    
    Key_Value__c KV = new Key_Value__c();
    KV.Geomarket_ZIP__c = '85287';
    KV.Geomarket_Code__c = 'GM-01';
    insert KV;
    
    Opportunity Opp = new Opportunity();
    Opp.Name = 'Test Opp';
    Opp.Contact__c = Con.Id;
    Opp.AccountId = Con.AccountID;
    Opp.StageName = 'Prospect';
    Opp.CloseDate = date.today() + 365;
    Opp.Type = 'First Time Freshman';
    Opp.OwnerId = TestUser.Id;
    //Opp.Territory_Assignment_UserID__c = TestUser.Id;
    insert Opp;

    TerritoryAssignmentHelper.accountTADone = false;

    Test.startTest();
        HS.ShippingPostalCode = '85287';
        HS.Territory_Manager__c = TestUser.Id;
        update HS;
        String AccountGeoCodeAfterUpdate = [SELECT Id,Geomarket_Code__c FROM Account WHERE Id =: HS.Id LIMIT 1].Geomarket_Code__c;
    Test.stopTest();

    System.Debug('Account Geomarket Code after update: '+ AccountGeoCodeAfterUpdate + ', Key Value Geomarket Code: ' + KV.Geomarket_Code__c );
    System.Assert(AccountGeoCodeAfterUpdate == KV.Geomarket_Code__c,'Account Geomarket Code did not match by ZIP code');
} 


private static testMethod void testContactGeomarketCodeAssignment(){ 
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

    Contact Con = new Contact();
    Con.FirstName = 'TestFirstName';
    Con.LastName = 'TestLastName';
    Con.MailingPostalCode = '90210';
    Con.Geomarket_Code__c = 'CA-01';
    Insert Con;

    Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];    
    
    Key_Value__c KVContact = new Key_Value__c();
    KVContact.Geomarket_ZIP__c = '90210';
    KVContact.Geomarket_Code__c = 'CA-01';
    insert KVContact;

    Key_Value__c KVHS = new Key_Value__c();
    KVHS.Geomarket_ZIP__c = '84108';
    KVHS.Geomarket_Code__c = 'UT-01';
    insert KVHS;
    
    Key_Value__c KVCollege = new Key_Value__c();
    KVCollege.Geomarket_ZIP__c = '85287';
    KVCollege.Geomarket_Code__c = 'AZ-01';
    insert KVCollege;
    
    Account HS = new Account();
    HS.Name = 'Test High School';
    HS.ShippingPostalCode = '84108';
    HS.Geomarket_Code__c = 'UT-01';
    insert HS;
    
    Account College = new Account();
    College.Name = 'Test College School';
    College.ShippingPostalCode = '85287';
    College.Geomarket_Code__c = 'AZ-01';
    insert College;

    Opportunity Opp = new Opportunity();
    Opp.Name = 'Test Opp';
    Opp.Contact__c = Con.Id;
    Opp.AccountId = Con.AccountId;
    Opp.StageName = 'Prospect';
    Opp.CloseDate = date.today() + 365;
    Opp.Type = 'First Time Freshman';
    //Commented out until territory assignment goes live with owner. 
    //Opp.OwnerId = TestUser.Id;
    //Opp.Territory_Assignment_UserID__c = TestUser.Id;

    Test.startTest();
        insert Opp;
        String ContactGeoCodeAfterUpdate = [SELECT Id,Geomarket_Code__c FROM Contact WHERE Id = :Con.Id LIMIT 1].Geomarket_Code__c;    

        // Fire Account Trigger to set Account.Geomarketcode__c        
        HS.ShippingPostalCode = '84108';
        HS.Geomarket_Code__c = 'UT-01';
        update HS;

        Con.Last_HS_Attended__c = HS.Id;
        update Con;

        Opp.Type = 'First Time Freshman';
        Opp.Territory_Assignment_Required__c = true;
        update Opp;
        String ContactHSGeoCodeAfterUpdate = [SELECT Id,Geomarket_Code__c FROM Contact WHERE Id = :Con.Id LIMIT 1].Geomarket_Code__c;
        
        Opp.Type = 'Transfer';
        update Opp;

        Con.Last_HS_Attended__c = null;
        Con.Last_College_Attended__c = College.Id;
        update Con;
        
        Opp.Type = 'Transfer';
        Opp.Territory_Assignment_Required__c = true;
        update Opp;
        String ContactCollegeGeoCodeAfterUpdate = [SELECT Id,Geomarket_Code__c FROM Contact WHERE Id = :Con.Id LIMIT 1].Geomarket_Code__c;        

    Test.stopTest();

    System.Debug('Contact Geomarket Code after update: '+ ContactGeoCodeAfterUpdate + ', Key Value Contact Geomarket Code: ' + KVContact.Geomarket_Code__c);
    System.Assert(ContactGeoCodeAfterUpdate == KVContact.Geomarket_Code__c,'Contact Geomarket Code did not match by ZIP code');

    System.Debug('Contact High School Geomarket Code after update: '+ ContactHSGeoCodeAfterUpdate + ', Key Value Contact High School Geomarket Code: ' + KVHS.Geomarket_Code__c);    
    System.Assert(ContactHSGeoCodeAfterUpdate == KVHS.Geomarket_Code__c,'Contact Geomarket Code did not match by Last Attended High School Geomarket Code');

    System.Debug('Contact College Geomarket Code after update: '+ ContactCollegeGeoCodeAfterUpdate + ', Key Value Contact College Geomarket Code: ' + KVCollege.Geomarket_Code__c );    
    System.Assert(ContactCollegeGeoCodeAfterUpdate == KVCollege.Geomarket_Code__c,'Contact Geomarket Code did not match by Last Attended College Geomarket Code');
} 



private static testMethod void testFreshmanScholar(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    Contact Con = new Contact();
    Con.FirstName = 'TestFirstName';
    Con.LastName = 'TestLastName';
    Insert Con;

    Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];    
    
    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.Rule_Type__c = 'Freshman Scholar';
    Atar1.Opportunity_Type__c = 'First Time Freshman';
    //Atar1.National_Scholarship__c = 'Flinn Finalist';
    Atar1.User__c = TestUser.Id;
    insert Atar1;
    
    Opportunity Opp = new Opportunity();
    Opp.Name = 'Test Opp';
    Opp.StageName = 'Prospect';
    Opp.Type = 'test';
    Opp.CloseDate = date.today() + 365;
    Opp.Contact__c = Con.Id;
    Opp.AccountId = Con.AccountId;
    insert Opp;
    
    Test.startTest();
        Opp.Type = 'First Time Freshman';
        Opp.Potential_National_Scholar__c = true;
        update Opp;
    Test.stopTest();

    String LastRuleType = [SELECT Id,Territory_Assignment_Last_Rule_Type__c FROM Opportunity WHERE Id = :Opp.Id LIMIT 1].Territory_Assignment_Last_Rule_Type__c;
    System.Debug('Opportunity Details: ' + Opp);
    System.Debug('Last Rule Type: ' + LastRuleType);
    System.Assert(LastRuleType  == 'Freshman Scholar','Rule did not assign correctly by rule type Freshman Scholar: ' + LastRuleType);

}

private static testMethod void testInternational(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    
    Contact Con = new Contact();
    Con.FirstName = 'TestFirstName';
    Con.LastName = 'TestLastName';
    Insert Con;
 
    Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];    

    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.Rule_Type__c = 'International';
    Atar1.International__c = true;
    Atar1.User__c = TestUser.Id;
    insert Atar1;
    
    Opportunity Opp = new Opportunity();
    Opp.Name = 'Test Opp';
    Opp.StageName = 'Prospect';
    Opp.Type = 'First Time Freshman';
    Opp.CloseDate = date.today() + 365;
    Opp.Contact__c = Con.Id;
    Opp.AccountId = Con.AccountId;
    insert Opp;
            
    Test.startTest();
        Opp.International_Student__c = true;
        update Opp;
    Test.stopTest();

    String LastRuleType = [SELECT Id,Territory_Assignment_Last_Rule_Type__c FROM Opportunity WHERE Id = :Opp.Id LIMIT 1].Territory_Assignment_Last_Rule_Type__c;
    System.Debug('Opportunity Details: ' + Opp);
    System.Debug('Last Rule Type: ' + LastRuleType);
    System.Assert(LastRuleType == 'International','Rule did not assign correctly by rule type International');

}

private static testMethod void testLocation(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    
    Contact Con = new Contact();
    Con.FirstName = 'TestFirstName';
    Con.LastName = 'TestLastName';
    Insert Con;

    Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];    
    
    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.Rule_Type__c = 'Location';
    Atar1.User__c = TestUser.Id;
    Atar1.Location__c = 'Lake Havasu';
    insert Atar1;
    
    
    Location__c LakeHavasu = new Location__c();
    LakeHavasu.Name = 'Lake Havasu';
    LakeHavasu.Location_Code__c = 'CALHC';
    insert LakeHavasu;

    
    Opportunity Opp = new Opportunity();
    Opp.Name = 'Test Opp';
    Opp.StageName = 'Prospect';
    Opp.Type = 'First Time Freshman';
    Opp.CloseDate = date.today() + 365;
    Opp.Contact__c = Con.Id;
    Opp.AccountId = Con.AccountId;
    Opp.Location__c = LakeHavasu.Id;
            
    Test.startTest();
        insert Opp;
        //Opp.Location__c = LakeHavasu.Id;
        //update Opp;
    Test.stopTest();

    String LastRuleType = [SELECT Id,Territory_Assignment_Last_Rule_Type__c FROM Opportunity WHERE Id = :Opp.Id LIMIT 1].Territory_Assignment_Last_Rule_Type__c;
    System.Debug('Opportunity Details: ' + Opp);
    System.Debug('Last Rule Type: ' + LastRuleType);
    System.Assert(LastRuleType == 'Location - Lake Havasu','Rule did not assign correctly by rule type Lake Havasu: ' + LastRuleType);}

private static testMethod void testLastHighSchoolAttended(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    
    Account HS = new Account();
    HS.Name = 'Test High School';
    HS.Institution_Type__c = 'HS';
    HS.Territory_Manager__c = TestUser.Id;
    insert HS;
   
    Contact Con = new Contact();
    Con.FirstName = 'TestFirstName';
    Con.LastName = 'TestLastName';
    Con.Email = 'test@test.com';
    //Con.Last_HS_Attended__c = HS.Id;
    insert Con;

    Previous_Education__c pe = new Previous_Education__c();
    pe.Contact__c = Con.Id;
    pe.Account__c = HS.Id;
    insert pe;

    Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];    
    
    Opportunity Opp = new Opportunity();
    Opp.Name = 'Test Opp';
    Opp.Contact__c = Con.Id;
    Opp.AccountId = Con.AccountId;
    Opp.StageName = 'Prospect';
    Opp.Type = 'Test';
    Opp.CloseDate = date.today() + 365;
    insert Opp;
    
    Test.startTest();
        Opp.Type = 'First Time Freshman';
        update Opp;
    Test.stopTest();
    
    String LastRuleType = [SELECT Id,Territory_Assignment_Last_Rule_Type__c FROM Opportunity WHERE Id = :Opp.Id LIMIT 1].Territory_Assignment_Last_Rule_Type__c;
    System.Debug('Opportunity Details: ' + Opp);
    System.Debug('Last Rule Type: ' + LastRuleType);
    System.Assert(LastRuleType == 'Last Attended High School','Rule did not assign correctly by rule type Last High School Attended');
}


private static testMethod void testLastCollegeAttended(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    
    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.User__c = TestUser.Id;
    Atar1.Rule_Type__c = 'Default User';
    Atar1.Opportunity_Type__c = 'First Time Freshman';
    Insert Atar1;  
    
    Territory_Assignment_Rule__c Atar2 = new Territory_Assignment_Rule__c();
    Atar2.User__c = TestUser.Id;
    Atar2.Rule_Type__c = 'Default User';
    Atar2.Opportunity_Type__c = 'Transfer';
    Insert Atar2;  
    
    Territory_Assignment_Rule__c Atar3 = new Territory_Assignment_Rule__c();
    Atar3.User__c = TestUser.Id;
    Atar3.Rule_Type__c = 'Default User';
    Atar3.Opportunity_Type__c = 'Non-Degree';
    Insert Atar3;  
    
    Territory_Assignment_Rule__c Atar4 = new Territory_Assignment_Rule__c();
    Atar4.User__c = TestUser.Id;
    Atar4.Rule_Type__c = 'Default User';
    Atar4.Opportunity_Type__c = 'Readmission';
    Insert Atar4;  
    
    Territory_Assignment_Rule__c Atar5 = new Territory_Assignment_Rule__c();
    Atar5.User__c = TestUser.Id;
    Atar5.Rule_Type__c = 'Default User';
    Atar5.Opportunity_Type__c = 'Law';
    Insert Atar5;      
    
    Territory_Assignment_Rule__c Atar6 = new Territory_Assignment_Rule__c();
    Atar6.User__c = TestUser.Id;
    Atar6.Rule_Type__c = 'Default User';
    Atar6.Opportunity_Type__c = 'Graduate';
    Insert Atar6;     
    
    Territory_Assignment_Rule__c Atar7 = new Territory_Assignment_Rule__c();
    Atar7.User__c = TestUser.Id;
    Atar7.Rule_Type__c = 'Default User';
    Atar7.Opportunity_Type__c = 'Non-Degree';
    Insert Atar7;  
    
    Account College= new Account();
    College.Name = 'Test College';
    College.Institution_Type__c = '4YR';
    College.Territory_Manager__c = TestUser.Id;
    insert College;
   
    Contact Con = new Contact();
    Con.FirstName = 'TestFirstName';
    Con.LastName = 'TestLastName';
    Con.Email = 'test@test.com';
    //Con.Last_College_Attended__c = College.Id;
    insert Con;

    Previous_Education__c pe = new Previous_Education__c();
    pe.Contact__c = Con.Id;
    pe.Account__c = College.Id;
    insert pe;


    Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];    
    
    Opportunity Opp = new Opportunity();
    Opp.Name = 'Test Opp';
    Opp.Contact__c = Con.Id;
    Opp.AccountId = Con.AccountId;
    Opp.StageName = 'Prospect';
    Opp.Type = 'Test';
    Opp.CloseDate = date.today() + 365;
    insert Opp;
    
    Test.startTest();
        Opp.Type = 'First Time Freshman';
        update Opp;
        Opp.Type = 'Transfer';
        update Opp;

        //Opp.Type = 'Readmission';
        //update Opp;
        //Opp.Type = 'Graduate';
        //update Opp;
        //Opp.Type = 'Law';
        //update Opp;
        //Opp.Type = 'Non-Degree';
        //update Opp;    
    

    Test.stopTest();
    
    String LastRuleType = [SELECT Id,Territory_Assignment_Last_Rule_Type__c FROM Opportunity WHERE Id = :Opp.Id LIMIT 1].Territory_Assignment_Last_Rule_Type__c;
    System.Debug('Opportunity Details: ' + Opp);
    System.Debug('Last Rule Type: ' + LastRuleType);
    System.Assert(LastRuleType == 'Last Attended College, Type ' + Opp.Type,'Rule did not assign correctly by rule type Last College Attended');
}  
      
private static testMethod void testGeomarketCode(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    
    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.Rule_Type__c = 'Geomarket';
    Atar1.User__c = TestUser.Id;
    Atar1.Geomarket__c = 'AZ-01';
    Atar1.Opportunity_Type__c = 'First Time Freshman';
    insert Atar1;
    
    Key_Value__c KVContact = new Key_Value__c();
    KVContact.Geomarket_ZIP__c = '85123';
    KVContact.Geomarket_Code__c = 'AZ-01';
    insert KVContact;    
    
    Contact Con = new Contact();
    Con.FirstName = 'TestFirstName';
    Con.LastName = 'TestLastName';
    Con.Email = 'test@test.com';
    Con.MailingPostalCode = '85123';
    Con.Geomarket_Code__c = 'AZ-01';
    insert Con;
 
    Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];    

    Opportunity Opp = new Opportunity();
    Opp.Name = 'Test Opp';
    Opp.StageName = 'Prospect';
    Opp.Type = 'First Time Freshman';
    Opp.CloseDate = date.today() + 365;
    Opp.Contact__c = Con.Id;
    Opp.AccountId = Con.AccountId;
            
    Test.startTest();
        insert Opp;
    Test.stopTest();

    String LastRuleType = [SELECT Id,Territory_Assignment_Last_Rule_Type__c FROM Opportunity WHERE Id = :Opp.Id LIMIT 1].Territory_Assignment_Last_Rule_Type__c;
    System.Debug('Opportunity Details: ' + Opp);
    System.Debug('Last Rule Type: ' + LastRuleType);
    System.Assert(LastRuleType == 'Geomarket, Type ' + Opp.Type, 'Rule did not assign correctly by rule type Geomarket');
}

private static testMethod void testState(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    
    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.Rule_Type__c = 'State';
    Atar1.User__c = TestUser.Id;
    Atar1.Assignment_By_State__c = 'Arizona';
    Atar1.Opportunity_Type__c = 'First Time Freshman';
    insert Atar1;
    
    Contact Con = new Contact();
    Con.FirstName = 'TestFirstName';
    Con.LastName = 'TestLastName';
    Con.Email = 'test@test.com';
    Con.MailingCountry = 'United States';
    insert Con;

    Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];    
    
    Opportunity Opp = new Opportunity();
    Opp.Name = 'Test Opp';
    Opp.StageName = 'Prospect';
    Opp.Type = 'First Time Freshman';
    Opp.CloseDate = date.today() + 365;
    Opp.Contact__c = Con.Id;
    Opp.AccountId = Con.AccountId;
    insert Opp;
            
    Test.startTest();
        Con.MailingState = 'Arizona';
        update Con;
        //Opp.Territory_Assignment_Required__c = true;
        //update Opp;
       
    Test.stopTest();

    String LastRuleType = [SELECT Id,Territory_Assignment_Last_Rule_Type__c FROM Opportunity WHERE Id = :Opp.Id LIMIT 1].Territory_Assignment_Last_Rule_Type__c;
    System.Debug('Opportunity Details: ' + Opp);
    System.Debug('Last Rule Type: ' + LastRuleType);
    System.Assert(LastRuleType == 'State, ' + Con.MailingState + ', Type ' + Opp.Type,'Rule did not assign correctly by rule type State: ' + LastRuleType);
}  


private static testMethod void testDefaultUser(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    
    Contact Con = new Contact();
    Con.FirstName = 'TestFirstName';
    Con.LastName = 'TestLastName';
    Insert Con;    

    Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];    
    
    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.Rule_Type__c = 'Default User';
    Atar1.User__c = TestUser.Id;
    Atar1.Opportunity_Type__c = 'First Time Freshman';
    insert Atar1;
    
    Opportunity Opp = new Opportunity();
    Opp.Name = 'Test Opp';
    Opp.StageName = 'Prospect';
    Opp.Type = 'First Time Freshman';
    Opp.CloseDate = date.today() + 365;
    Opp.Contact__c = Con.Id;
    Opp.AccountId = Con.AccountId;
    //insert Opp;
            
    Test.startTest();
        insert Opp;
        //Opp.Type = 'Transfer';
        //update Opp;
        //Opp.Type = 'Readmission';
        //update Opp;
        
        //Opp.Type = 'Graduate';
        //update Opp;
        //Opp.Type = 'Law';
        //update Opp;
        //Opp.Type = 'Non-Degree';
        //update Opp;        
        //Opp.Type = 'First Time Freshman';
        //update Opp;
        

    Test.stopTest();

    String LastRuleType = [SELECT Id,Territory_Assignment_Last_Rule_Type__c FROM Opportunity WHERE Id = :Opp.Id LIMIT 1].Territory_Assignment_Last_Rule_Type__c;
    System.Debug('Opportunity Details: ' + Opp);
    System.Debug('Last Rule Type: ' + LastRuleType);
    System.Assert(LastRuleType == 'Default User','Rule did not assign correctly by rule type Default User: ' + LastRuleType);

} 


private static testMethod void testInactiveUser(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    //User InactiveUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = false LIMIT 1];

    Profile saProfile = [select id from profile where name='System Administrator'];

    User InactiveUser = new User();
    InactiveUser.FirstName = 'Test';
    InactiveUser.LastName = 'Name';
    InactiveUser.CompanyName = 'Test Company';
    InactiveUser.MobilePhone = '123-456-7890';
    InactiveUser.Username = 'testUser-Inactive@test.test';
    InactiveUser.Email = 'testUser-Inactive@test.test';
    InactiveUser.Alias = 'testXX';
    InactiveUser.CommunityNickname = 'test1';
    InactiveUser.TimeZoneSidKey = 'America/New_York';
    InactiveUser.LocaleSidKey = 'en_US';
    InactiveUser.EmailEncodingKey = 'UTF-8';
    InactiveUser.ProfileId = saProfile.Id;
    InactiveUser.LanguageLocaleKey = 'en_US';
    InactiveUser.IsActive = false;
    insert InactiveUser;   
  
    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.Rule_Type__c = 'Default User';
    Atar1.User__c = TestUser.Id;
    Atar1.Opportunity_Type__c = 'First Time Freshman';
    insert Atar1;

    Account HS = new Account();
    HS.Name = 'Test High School';
    HS.Institution_Type__c = 'HS';
    HS.Territory_Manager__c = InactiveUser.Id;
    insert HS;
   
    Contact Con = new Contact();
    Con.FirstName = 'TestFirstName';
    Con.LastName = 'TestLastName';
    Con.Email = 'test@test.com';
    Con.Last_HS_Attended__c = HS.Id;
    insert Con;

    Previous_Education__c pe = new Previous_Education__c();
    pe.Contact__c = Con.Id;
    pe.Account__c = HS.Id;
    insert pe;

    Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];    
    
    Opportunity Opp = new Opportunity();
    Opp.Name = 'Test Opp';
    Opp.Contact__c = Con.Id;
    Opp.AccountId = Con.AccountId;
    Opp.StageName = 'Prospect';
    Opp.Type = 'First Time Freshman';
    Opp.CloseDate = date.today() + 365;

    
    Test.startTest();
        insert Opp;
    Test.stopTest();
    
    Opportunity OppAfterInsert = [SELECT Id,Territory_Assignment_Last_Rule_Type__c,OwnerId FROM Opportunity WHERE Id = :Opp.Id LIMIT 1];
    System.Debug('Opportunity Details: ' + OppAfterInsert);
    System.Debug('Last Rule Type: ' + OppAfterInsert.Territory_Assignment_Last_Rule_Type__c);
    System.Assert(OppAfterInsert.OwnerId ==TestUser.Id);
    System.Assert(OppAfterInsert.Territory_Assignment_Last_Rule_Type__c == 'Inactive Territory Manager','Did not correctly identify inactive User: ' + OppAfterInsert.Territory_Assignment_Last_Rule_Type__c);

} 

private static testMethod void testLeadFreshmanScholar(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    
    List<Lead> leadList = new List<Lead>();
    for (Integer i=0;i<1;i++) {
        Lead l = new Lead(LastName='LName'+i, 
                          FirstName='FName'+i,
                          Company='Company', 
                          Email='test'+i+'@test.test', 
                          LeadSource='Email',
                          Potential_National_Scholar__c=true,
                          Type__c='First Time Freshman');
        leadList.add(l);
    }

    
    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.Rule_Type__c = 'Freshman Scholar';
    Atar1.User__c = TestUser.Id;
    Atar1.Opportunity_Type__c = 'Freshman Scholar';
    insert Atar1;
    
            
    Test.startTest();
        insert leadList;    

    Test.stopTest();

    List<Lead> newLeadList = new List<Lead>([SELECT Id, Type__c, Territory_Assignment_Last_Rule_Type__c FROM Lead WHERE Id = :leadList[0].Id LIMIT 1]);
    System.Debug('Lead Details: ' + leadList[0]);
    System.Debug('Last Rule Type: ' + newLeadList[0].Territory_Assignment_Last_Rule_Type__c);
    System.Assert(newLeadList[0].Territory_Assignment_Last_Rule_Type__c == 'Freshman Scholar','Rule did not assign correctly by rule type Freshman Scholar');

} 

private static testMethod void testLeadInternational(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    
    List<Lead> leadList = new List<Lead>();
    for (Integer i=0;i<1;i++) {
        Lead l = new Lead(LastName='LName'+i, 
                          FirstName='FName'+i,
                          Company='Company', 
                          Email='test'+i+'@test.test', 
                          LeadSource='Email',
                          Type__c='First Time Freshman',
                          International_Student__c = true);
        leadList.add(l);
    }

    
    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.Rule_Type__c = 'International';
    Atar1.User__c = TestUser.Id;
    insert Atar1;
    
            
    Test.startTest();
        insert leadList;    

    Test.stopTest();

    List<Lead> newLeadList = new List<Lead>([SELECT Id, Type__c, Territory_Assignment_Last_Rule_Type__c FROM Lead WHERE Id = :leadList[0].Id LIMIT 1]);
    System.Debug('Lead Details: ' + leadList[0]);
    System.Debug('Last Rule Type: ' + newLeadList[0].Territory_Assignment_Last_Rule_Type__c);
    System.Assert(newLeadList[0].Territory_Assignment_Last_Rule_Type__c == 'International','Rule did not assign correctly by rule type Default User');

} 


private static testMethod void testLeadLastInstitution(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

   Key_Value__c KVHS = new Key_Value__c();
    KVHS.Geomarket_ZIP__c = '84108';
    KVHS.Geomarket_Code__c = 'UT-01';
    insert KVHS;
    
    //Key_Value__c KVCollege = new Key_Value__c();
    //KVCollege.Geomarket_ZIP__c = '85287';
    //KVCollege.Geomarket_Code__c = 'AZ-01';
    //insert KVCollege;
    
    Account HS = new Account();
    HS.Name = 'Test High School';
    HS.ShippingPostalCode = '84108';
    HS.Geomarket_Code__c = 'UT-01';
    HS.Institution_Type__c = 'HS';
    HS.Territory_Manager__c = TestUser.Id;
    insert HS;

    List<Lead> leadList = new List<Lead>();
    for (Integer i=0;i<1;i++) {
        Lead l = new Lead(LastName='LName'+i, 
                          FirstName='FName'+i,
                          Company='Company', 
                          Email='test'+i+'@test.test', 
                          LeadSource='Email',
                          Type__c='First Time Freshman',
                          Last_Institution_Attended__c = HS.id);
        leadList.add(l);
    }

    
    //Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    //Atar1.Rule_Type__c = 'International';
    //Atar1.User__c = TestUser.Id;
    //insert Atar1;
    
            
    Test.startTest();
        insert leadList;    

    Test.stopTest();

    List<Lead> newLeadList = new List<Lead>([SELECT Id, Type__c, Territory_Assignment_Last_Rule_Type__c, OwnerId FROM Lead WHERE Id = :leadList[0].Id LIMIT 1]);
    System.Debug('Lead Details: ' + leadList[0]);
    System.Debug('Last Rule Type: ' + newLeadList[0].Territory_Assignment_Last_Rule_Type__c);
    System.Assert(newLeadList[0].Territory_Assignment_Last_Rule_Type__c == 'Last Institution Attended','Rule did not assign correctly by rule type Last Institution Attended');
    System.Assert(newLeadList[0].OwnerId == testUser.Id, 'Territory Assignment did not assign Owner correctly for Lead/Last Institution');
} 

private static testMethod void testLeadGeoMarket(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    
    Key_Value__c KVLead = new Key_Value__c();
    KVLead.Geomarket_ZIP__c = '84108';
    KVLead.Geomarket_Code__c = 'UT-01';
    insert KVLead;

    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.Rule_Type__c = 'Geomarket';
    Atar1.Geomarket__c = 'UT-01';
    Atar1.Opportunity_Type__c = 'First Time Freshman';
    Atar1.User__c = TestUser.Id;
    insert Atar1;    

    List<Lead> leadList = new List<Lead>();
    for (Integer i=0;i<1;i++) {
        Lead l = new Lead(LastName='LName'+i, 
                          FirstName='FName'+i,
                          Company='Company',
                          PostalCode='84108', 
                          Email='test'+i+'@test.test', 
                          LeadSource='Email',
                          Type__c='First Time Freshman');
        leadList.add(l);
    }

            
    Test.startTest();
        insert leadList;    

    Test.stopTest();

    List<Lead> newLeadList = new List<Lead>([SELECT Id, Type__c, Territory_Assignment_Last_Rule_Type__c FROM Lead WHERE Id = :leadList[0].Id LIMIT 1]);
    System.Debug('Lead Details: ' + leadList[0]);
    System.Debug('Last Rule Type: ' + newLeadList[0].Territory_Assignment_Last_Rule_Type__c);
    System.Assert(newLeadList[0].Territory_Assignment_Last_Rule_Type__c == 'Geomarket, Type ' +  newLeadList[0].Type__c,'Rule did not assign correctly by rule type Lead/GeoMarket');

}


private static testMethod void testLeadState(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.Rule_Type__c = 'State';
    Atar1.Opportunity_Type__c = 'First Time Freshman';
    Atar1.Assignment_By_State__c = 'Texas';
    Atar1.User__c = TestUser.Id;
    insert Atar1;    

    List<Lead> leadList = new List<Lead>();
    for (Integer i=0;i<1;i++) {
        Lead l = new Lead(LastName='LName'+i, 
                          FirstName='FName'+i,
                          Company='Company',
                          State='Texas',
                          Country='United States', 
                          Email='test'+i+'@test.test', 
                          LeadSource='Email',
                          Type__c='First Time Freshman');
        leadList.add(l);
    }

            
    Test.startTest();
        insert leadList;    

    Test.stopTest();

    List<Lead> newLeadList = new List<Lead>([SELECT Id, Type__c, OwnerId, Territory_Assignment_Last_Rule_Type__c FROM Lead WHERE Id = :leadList[0].Id LIMIT 1]);
    System.Debug('Lead Details: ' + leadList[0]);
    System.Debug('Last Rule Type: ' + newLeadList[0].Territory_Assignment_Last_Rule_Type__c);
    System.Debug('Last Rule Type to Match: ' + 'State, Type ' + leadList[0].Type__c);
    System.Assert(newLeadList[0].Territory_Assignment_Last_Rule_Type__c == 'State, Type ' + leadList[0].Type__c,'Rule did not assign correctly by rule type Lead/State');
    //system.assert(newLeadList[0].OwnerId == testUser.Id, 'Rule did not assign correctly by rule type Lead/State');
} 

private static testMethod void testLeadDefaultUser(){
    User TestUser = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    
    List<Lead> leadList = new List<Lead>();
    for (Integer i=0;i<1;i++) {
        Lead l = new Lead(LastName='LName'+i, 
                          FirstName='FName'+i,
                          Company='Company', 
                          Email='test'+i+'@test.test', 
                          LeadSource='Email',
                          Type__c='First Time Freshman');
        leadList.add(l);
    }

    
    Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
    Atar1.Rule_Type__c = 'Default User';
    Atar1.User__c = TestUser.Id;
    Atar1.Opportunity_Type__c = 'First Time Freshman';
    insert Atar1;
    
            
    Test.startTest();
        insert leadList;    

    Test.stopTest();

    List<Lead> newLeadList = new List<Lead>([SELECT Id, Type__c, Territory_Assignment_Last_Rule_Type__c FROM Lead WHERE Id = :leadList[0].Id LIMIT 1]);
    System.Debug('Lead Details: ' + leadList[0]);
    System.Debug('Last Rule Type: ' + newLeadList[0].Territory_Assignment_Last_Rule_Type__c);
    System.Assert(newLeadList[0].Territory_Assignment_Last_Rule_Type__c == 'Default User','Rule did not assign correctly by rule type Default User');

} 


}