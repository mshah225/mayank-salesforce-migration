@isTest(seeAllData = true)
private class ChatterAutoAddUserTest {
    
    private static Set<Id> userIdRec;
    private static Set<Id> userIdService;
    private static Set<Id> userIdKnow;
    
    static testMethod void setUpRec() {
        
        Id recProfileId = [SELECT Id FROM Profile WHERE Name = 'ASU Recruiting User' LIMIT 1].Id;
        
        User testUserRec = new User();
        testUserRec.FirstName = 'Chatter';
        testUserRec.LastName = 'TestuserRec'; 
        testUserRec.ProfileId = recProfileId;
        testUserRec.Username = 'chattestuserRec@test.com.dev';
        testUserRec.Email = 'chattestuser@test.com';
        testUserRec.Alias = 'chattes3';
        testUserRec.CommunityNickname = 'chattest';
        testUserRec.TimeZoneSidKey = 'America/Phoenix';
        testUserRec.LocaleSidKey = 'en_US';
        testUserRec.EmailEncodingKey = 'ISO-8859-1';
        testUserRec.LanguageLocaleKey = 'en_US';
        insert testUserRec;
        
        system.debug('Rec User Created');

        userIdRec = new Set<Id>();
        userIdRec.add(testUserRec.Id);
    }
    
    static testMethod void setUpServ() {
    
        Id servProfileId = [SELECT Id FROM Profile WHERE Name LIKE 'ASU Service%' LIMIT 1].Id;
        
        User testUserServ = new User();
        testUserServ.FirstName = 'Chatter';
        testUserServ.LastName = 'TestuserService'; 
        testUserServ.ProfileId = servProfileId;
        testUserServ.Username = 'chattestuserservice@test.com.dev';
        testUserServ.Email = 'chattestuser@test.com';
        testUserServ.Alias = 'chattes4';
        testUserServ.CommunityNickname = 'chattestservice';
        testUserServ.TimeZoneSidKey = 'America/Phoenix';
        testUserServ.LocaleSidKey = 'en_US';
        testUserServ.EmailEncodingKey = 'ISO-8859-1';
        testUserServ.LanguageLocaleKey = 'en_US';
        insert testUserServ;
        
        system.debug('Service User Created');
        
        userIdService = new Set<Id>();
        userIdService.add(testUserServ.Id);
    }
    
    static testMethod void setUpKnow() {
    
        Id knowProfileId = [SELECT Id FROM Profile WHERE Name = 'ASU Knowledge User' LIMIT 1].Id;
        
        User testUserKnow = new User();
        testUserKnow.FirstName = 'Chatter';
        testUserKnow.LastName = 'TestuserKnow'; 
        testUserKnow.ProfileId = knowProfileId;
        testUserKnow.Username = 'chattestuserKnow@test.com.dev';
        testUserKnow.Email = 'chattestuser@test.com';
        testUserKnow.Alias = 'chattes5';
        testUserKnow.CommunityNickname = 'chattestKnow';
        testUserKnow.TimeZoneSidKey = 'America/Phoenix';
        testUserKnow.LocaleSidKey = 'en_US';
        testUserKnow.EmailEncodingKey = 'ISO-8859-1';
        testUserKnow.LanguageLocaleKey = 'en_US';
        insert testUserKnow;
        
        system.debug('Knowledge User Created');

        userIdKnow = new Set<Id>();
        userIdKnow.add(testUserKnow.Id);
    }
    
    static testMethod void testAutoAdd() {
        setUpRec();  
        setUpServ(); 
        setUpKnow(); 
        Test.startTest();
        ChatterAutoAddUsers.AddToServiceGroup(userIdRec);
        ChatterAutoAddUsers.AddToServiceGroup(userIdService);
        ChatterAutoAddUsers.AddToServiceGroup(userIdKnow);
        Test.stopTest();
    }
}