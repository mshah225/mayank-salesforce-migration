@isTest
private class SuccessPortal_ChatHistoryPage_Tests {
    
    public static Success_POD__c successPOD;
    public static User userCoachUser;
    public static User userCoachLead;
    public static User userCoachManager;
    public static User userCoachAdmin;
    public static Contact userStudent;
    public static Success_Resource__c successCoachUser;
    public static Success_Resource__c successCoachLead;
    public static Success_Resource__c successCoachManager;
    public static Success_Resource__c successCoachAdmin;
    public static Success_Student__c successStudentForUser;
    public static Success_Student__c successStudentForLead;
    public static Success_Student__c successStudentForManager;
    public static Success_Student__c successStudentForAdmin;
    public static SuccessPortal_ChatHistoryPageController pag;
    public static String contactRecordTypeId;
    
    @isTest static void testPageLoad_BadParams()
    {
        createCoachTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='coachu'];
        System.RunAs(u1){ 
                System.debug('running as coach user');
                PageReference pageRef = Page.SuccessPortal_ChatHistoryPage;
                Test.setCurrentPage(pageRef);     

                pag = new SuccessPortal_ChatHistoryPageController(); 
                ApexPages.CurrentPage().getParameters().put('resourceASURiteId', 'coachu');
                pag.resourceASURiteId = 'coachu';
                ApexPages.CurrentPage().getParameters().put('studentASURiteId', 'jdoe1');
                pag.studentASURiteId = 'jdoe1';
                ApexPages.CurrentPage().getParameters().put('startDate', 'xxxxx');
                pag.startdate = '2016-08-01';
                ApexPages.CurrentPage().getParameters().put('startDateSrch','xxxxx');
                pag.startDate = '2016-09-09';
                ApexPages.CurrentPage().getParameters().put('endDateSrch','xxxxx');
                pag.endDate = '2016-09-09';
                ApexPages.CurrentPage().getParameters().put('isTest', 'true');
                pag.isTest = true;
                pag.init();
        }
        Test.StopTest();
    }
    
    @isTest static void testPageLoad_User()
    {
        createCoachTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='coachu'];
        System.RunAs(u1){ 
                System.debug('running as coach user');
                PageReference pageRef = Page.SuccessPortal_ChatHistoryPage;
                Test.setCurrentPage(pageRef);     

                pag = new SuccessPortal_ChatHistoryPageController(); 
                ApexPages.CurrentPage().getParameters().put('resourceASURiteId', 'coachu');
                pag.resourceASURiteId = 'coachu';
                ApexPages.CurrentPage().getParameters().put('studentASURiteId', 'jdoe1');
                pag.studentASURiteId = 'jdoe1';
                ApexPages.CurrentPage().getParameters().put('startDate', '2016-08-01');
                pag.startdate = '2016-08-01';
                ApexPages.CurrentPage().getParameters().put('isTest', 'true');
                pag.isTest = true;
                pag.init();
        }
        Test.StopTest();
    }
    
    @isTest static void testPageLoad_Lead()
    {
        createCoachTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='coachl'];
        System.RunAs(u1){ 
                System.debug('running as coach lead');
                PageReference pageRef = Page.SuccessPortal_ChatHistoryPage;
                Test.setCurrentPage(pageRef);     

                pag = new SuccessPortal_ChatHistoryPageController(); 
                ApexPages.CurrentPage().getParameters().put('resourceASURiteId', 'coachl');
                pag.resourceASURiteId = 'coachl';
                ApexPages.CurrentPage().getParameters().put('studentASURiteId', 'jdoe1');
                pag.studentASURiteId = 'jdoe1';
                ApexPages.CurrentPage().getParameters().put('startDate', '2016-08-01');
                pag.startdate = '2016-08-01';
                ApexPages.CurrentPage().getParameters().put('isTest', 'true');
                pag.isTest = true;
                pag.init();
        }
        Test.StopTest();
    }
    
    @isTest static void testPageLoad_Manager()
    {
        createCoachTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='coachm'];
        System.RunAs(u1){ 
                System.debug('running as coach manager');
                PageReference pageRef = Page.SuccessPortal_ChatHistoryPage;
                Test.setCurrentPage(pageRef);     

                pag = new SuccessPortal_ChatHistoryPageController(); 
                ApexPages.CurrentPage().getParameters().put('resourceASURiteId', 'coachm');
                pag.resourceASURiteId = 'coachm';
                ApexPages.CurrentPage().getParameters().put('studentASURiteId', 'jdoe1');
                pag.studentASURiteId = 'jdoe1';
                ApexPages.CurrentPage().getParameters().put('startDate', '2016-08-01');
                pag.startdate = '2016-08-01';
                ApexPages.CurrentPage().getParameters().put('isTest', 'true');
                pag.isTest = true;
                pag.init();
        }
        Test.StopTest();
    }
    
    @isTest static void testPageLoad_Admin()
    {
        createCoachTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='coacha'];
        System.RunAs(u1){ 
                System.debug('running as coach admin');
                PageReference pageRef = Page.SuccessPortal_ChatHistoryPage;
                Test.setCurrentPage(pageRef);     

                pag = new SuccessPortal_ChatHistoryPageController(); 
                ApexPages.CurrentPage().getParameters().put('resourceASURiteId', 'coacha');
                pag.resourceASURiteId = 'coacha';
                ApexPages.CurrentPage().getParameters().put('studentASURiteId', 'jdoe1');
                pag.studentASURiteId = 'jdoe1';
                ApexPages.CurrentPage().getParameters().put('startDate', '2016-08-01');
                pag.startdate = '2016-08-01';
                ApexPages.CurrentPage().getParameters().put('isTest', 'true');
                pag.isTest = true;
                pag.init();
        }
        Test.StopTest();
    }
    
    @isTest static void testPageLoad_ManagerShadow()
    {
        createCoachTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='coachm'];
        System.RunAs(u1){ 
                System.debug('running as coach manager');
                PageReference pageRef = Page.SuccessPortal_ChatHistoryPage;
                Test.setCurrentPage(pageRef);     

                pag = new SuccessPortal_ChatHistoryPageController(); 
                ApexPages.CurrentPage().getParameters().put('resourceASURiteId', 'coachu');
                pag.resourceASURiteId = 'coachm';
                ApexPages.CurrentPage().getParameters().put('studentASURiteId', 'jdoe1');
                pag.studentASURiteId = 'jdoe1';
                ApexPages.CurrentPage().getParameters().put('startDate', '2016-08-01');
                pag.startdate = '2016-08-01';
                ApexPages.CurrentPage().getParameters().put('isTest', 'true');
                pag.isTest = true;
                pag.init();
        }
        Test.StopTest();
    }
    
    static private void createCoachTestData()
    {
        //Coach POD RT
        String podCoachRecordTypeId = '';
        List<RecordType> rectype1 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'Coach' AND SobjectType = 'Success_POD__c'];
        if(rectype1.size()>0)podCoachRecordTypeId=rectype1[0].Id;
        
        //Profile RT
        Id profileId = [SELECT Id FROM Profile WHERE Name ='System Administrator'].Id;

        //Contact RT
        contactRecordTypeId = '';
        List<RecordType> rectype3 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'External_Mastered' AND SobjectType = 'Contact'];
        if(rectype3.size()>0)contactRecordTypeId=rectype3[0].Id;

        //Coach RT
        String coachResourceRecordTypeId = '';
        List<RecordType> rectype7 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'Coach' AND SobjectType = 'Success_Resource__c'];
        if(rectype7.size()>0)coachResourceRecordTypeId=rectype7[0].Id;
        
        //create pod
        successPOD = new Success_POD__c();
        successPOD.RecordTypeId = podCoachRecordTypeId;
        successPOD.Name = 'Coach POD';
        insert successPOD;
        
        //create coach user
        userCoachUser = new User();
        userCoachUser.Lastname = 'coach';
        userCoachUser.Alias = 'coachu';
        userCoachUser.Email = 'thecoachuser@asu.edu.xyz';
        userCoachUser.Username = 'thecoachuser@asu.edu.xyz';
        userCoachUser.TimeZoneSidKey = 'America/Phoenix';
        userCoachUser.LocaleSidKey = 'en_US';
        userCoachUser.EmailEncodingKey = 'ISO-8859-1';
        userCoachUser.ProfileId = profileId;
        userCoachUser.LanguageLocaleKey = 'en_US';
        insert userCoachUser;
        
        //create coach lead
        userCoachLead = new User();
        userCoachLead.Lastname = 'coach';
        userCoachLead.Alias = 'coachl';
        userCoachLead.Email = 'thecoachlead@asu.edu.xyz';
        userCoachLead.Username = 'thecoachlead@asu.edu.xyz';
        userCoachLead.TimeZoneSidKey = 'America/Phoenix';
        userCoachLead.LocaleSidKey = 'en_US';
        userCoachLead.EmailEncodingKey = 'ISO-8859-1';
        userCoachLead.ProfileId = profileId;
        userCoachLead.LanguageLocaleKey = 'en_US';
        insert userCoachLead;
        
        //create coach manager
        userCoachManager = new User();
        userCoachManager.Lastname = 'coach';
        userCoachManager.Alias = 'coachm';
        userCoachManager.Email = 'thecoachmanager@asu.edu.xyz';
        userCoachManager.Username = 'thecoachmanager@asu.edu.xyz';
        userCoachManager.TimeZoneSidKey = 'America/Phoenix';
        userCoachManager.LocaleSidKey = 'en_US';
        userCoachManager.EmailEncodingKey = 'ISO-8859-1';
        userCoachManager.ProfileId = profileId;
        userCoachManager.LanguageLocaleKey = 'en_US';
        insert userCoachManager;
        
        //create coach admin
        userCoachAdmin = new User();
        userCoachAdmin.Lastname = 'coach';
        userCoachAdmin.Alias = 'coacha';
        userCoachAdmin.Email = 'thecoachadmin@asu.edu.xyz';
        userCoachAdmin.Username = 'thecoachadmin@asu.edu.xyz';
        userCoachAdmin.TimeZoneSidKey = 'America/Phoenix';
        userCoachAdmin.LocaleSidKey = 'en_US';
        userCoachAdmin.EmailEncodingKey = 'ISO-8859-1';
        userCoachAdmin.ProfileId = profileId;
        userCoachAdmin.LanguageLocaleKey = 'en_US';
        insert userCoachAdmin;
        
        //create success coach user
        successCoachUser = new Success_Resource__c();
        successCoachUser.Resource__c = userCoachUser.Id;
        successCoachUser.RecordTypeId = coachResourceRecordTypeId;
        successCoachUser.Role__c = 'User';
        successCoachUser.AgentID__c = '12345';
        successCoachUser.Success_POD__c = successPOD.Id;
        successCoachUser.IsActive__c = true;
        insert successCoachUser;
        
        //create success coach lead
        successCoachLead = new Success_Resource__c();
        successCoachLead.Resource__c = userCoachLead.Id;
        successCoachLead.RecordTypeId = coachResourceRecordTypeId;
        successCoachLead.Role__c = 'Lead';
        successCoachLead.AgentID__c = '12345';
        successCoachLead.Success_POD__c = successPOD.Id;
        successCoachLead.IsActive__c = true;
        insert successCoachLead;
        
        //create success coach manager
        successCoachManager = new Success_Resource__c();
        successCoachManager.Resource__c = userCoachManager.Id;
        successCoachManager.RecordTypeId = coachResourceRecordTypeId;
        successCoachManager.Role__c = 'Manager';
        successCoachManager.AgentID__c = '12345';
        successCoachManager.Success_POD__c = successPOD.Id;
        successCoachManager.IsActive__c = true;
        insert successCoachManager;
        
        //create success coach admin
        successCoachAdmin = new Success_Resource__c();
        successCoachAdmin.Resource__c = userCoachAdmin.Id;
        successCoachAdmin.RecordTypeId = coachResourceRecordTypeId;
        successCoachAdmin.Role__c = 'Admin';
        successCoachAdmin.AgentID__c = '12345';
        successCoachAdmin.Success_POD__c = successPOD.Id;
        successCoachAdmin.IsActive__c = true;
        insert successCoachAdmin;
        
        //create student
        userStudent = new Contact();
        userStudent.RecordTypeId = contactRecordTypeId;
        userStudent.Firstname = 'John';
        userStudent.Lastname = 'Doe';
        userStudent.Email = 'john.doe@asu.edu.xyz';
        userStudent.ASURITE_ID__c = 'jdoe1';
        userStudent.Hidden_Selected__c = true;
        userStudent.EMPLID__c = '8888';
        insert userStudent;
        
        //create success student for Coach User
        successStudentforUser = new Success_Student__c();
        successStudentforUser.Student__c = userStudent.Id;
        successStudentforUser.Success_Resource__c = successCoachUser.Id;
        successStudentforUser.Success_POD__c = successPOD.Id;
        insert successStudentforUser;
        
        //create success student for Coach Lead
        successStudentforLead = new Success_Student__c();
        successStudentforLead.Student__c = userStudent.Id;
        successStudentforLead.Success_Resource__c = successCoachLead.Id;
        successStudentforLead.Success_POD__c = successPOD.Id;
        insert successStudentforLead;
        
        //create success student for Coach Manager
        successStudentforManager = new Success_Student__c();
        successStudentforManager.Student__c = userStudent.Id;
        successStudentforManager.Success_Resource__c = successCoachManager.Id;
        successStudentforManager.Success_POD__c = successPOD.Id;
        insert successStudentforManager;
       
        //create success student for Coach Admin
        successStudentforAdmin = new Success_Student__c();
        successStudentforAdmin.Student__c = userStudent.Id;
        successStudentforAdmin.Success_Resource__c = successCoachAdmin.Id;
        successStudentforAdmin.Success_POD__c = successPOD.Id;
        insert successStudentforAdmin;
       
    }
    
}