@isTest
private class SuccessPortal_MainPageController_Tests {

    public static Success_POD__c successPOD;
    public static User userCoachUser;
    public static User userCoachLead;
    public static User userCoachManager;
    public static User userCoachAdmin;
    public static User userAdvisorUser;
    public static User userAdvisorLead;
    public static User userAdvisorManager;
    public static User userAdvisorAdmin;
    public static Contact userStudent;
    public static Success_Resource__c successCoachUser;
    public static Success_Resource__c successCoachLead;
    public static Success_Resource__c successCoachManager;
    public static Success_Resource__c successCoachAdmin;
    public static Success_Resource__c successAdvisorUser;
    public static Success_Resource__c successAdvisorLead;
    public static Success_Resource__c successAdvisorManager;
    public static Success_Resource__c successAdvisorAdmin;
    public static Success_Student__c successStudent;
    public static SuccessPortal_MainPageController pag;
    public static Case caseCoach1;
    public static Case caseCoach2;
    public static Case caseCoach3;
    public static Case caseAdvisor1;
    public static Case caseAdvisor2;
    public static Case caseAdvisor3;
    public static List<Case> proactiveCases = new List<Case>();
    public static CaseComment caseComments;
    public static Task caseTasks;
    public static Engagement__c e1;
    public static Engagement__c e2;
    public static Engagement__c e3;
    public static Engagement_Contact__c ec;
    public static Engagement_Planned_Message__c epm1;
    public static Engagement_Planned_Message__c epm2;
    public static Engagement_Planned_Message__c epm3;
    public static Engagement_Message__c em;
    public static String taskRecordTypeId;
    public static String contactRecordTypeId;
    public static String engagementAdvisorRecordTypeId;
    public static String engagementCoachRecordTypeId;

    @isTest static void testCoachPageLoad()
    {
        createCoachTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='coachu'];
        System.RunAs(u1){
                System.debug('running as coach user');
                PageReference pageRef = Page.SuccessPortal_MainPage;
                Test.setCurrentPage(pageRef);
                Case cs = new Case();
                ApexPages.standardController controller = new ApexPages.standardController(cs);

                pag = new SuccessPortal_MainPageController();
                pag.pageTitle = '';
                pag.init();

                pag.isCoachUser = true;

                pag.getViewAsUsers();
                pag.populateMyCaseSummaries();

                pag.populateCasesCount();
                pag.populateChatsCount();
                pag.populateEmailsCount();
                pag.populateSMSCount();
        }
        Test.StopTest();
    }

    @isTest static void testCoachProfileUpdate()
    {
        createCoachTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='coachu'];
        System.RunAs(u1){
                System.debug('running as coach user');
                PageReference pageRef = Page.SuccessPortal_MainPage;
                Test.setCurrentPage(pageRef);
                Case cs = new Case();
                ApexPages.standardController controller = new ApexPages.standardController(cs);

                pag = new SuccessPortal_MainPageController();
                pag.pageTitle = '';
                pag.init();

                pag.isCoachUser = true;

                pag.openPreferences();
                pag.populateCoachDetails();

         }
         Test.StopTest();
    }

    @isTest static void testCoachPopulateMyStudents()
    {
        createCoachTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='coachu'];
        System.RunAs(u1){
                System.debug('running as coach user');
                PageReference pageRef = Page.SuccessPortal_MainPage;
                Test.setCurrentPage(pageRef);
                Case cs = new Case();
                ApexPages.standardController controller = new ApexPages.standardController(cs);

                pag = new SuccessPortal_MainPageController();
                pag.pageTitle = '';
                pag.init();

                pag.isCoachUser = true;

                pag.selectPlannedMessage();
                pag.selectSMSText();
                ApexPages.CurrentPage().getParameters().put('selectedFollowupDate', string.valueOf(System.Today()));
                pag.selectFollowupDate();

                pag.populateMyPODList();

                runPopulateMyStudents();

                pag.getCasesAssigned();
         }
         Test.StopTest();
    }

    @isTest static void testCoachPopulateCases()
    {
        createCoachTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='coachu'];
        System.RunAs(u1){
                System.debug('running as coach user');
                PageReference pageRef = Page.SuccessPortal_MainPage;
                Test.setCurrentPage(pageRef);
                Case cs = new Case();
                ApexPages.standardController controller = new ApexPages.standardController(cs);

                pag = new SuccessPortal_MainPageController();
                pag.pageTitle = '';
                pag.init();

                pag.isCoachUser = true;

                runSelectStudent();

                ApexPages.CurrentPage().getParameters().put('selectedCaseSubject', 'My Students');
                pag.selectCaseSubject();

                ApexPages.CurrentPage().getParameters().put('selectedCaseSubject', 'All Open Cases');
                pag.selectCaseSubject();

                ApexPages.CurrentPage().getParameters().put('selectedCaseSubject', 'Drop/Withdrawn');
                pag.selectCaseSubject();

                ApexPages.CurrentPage().getParameters().put('selectedCaseSubject', 'My Watchlist');
                pag.selectCaseSubject();

                ApexPages.CurrentPage().getParameters().put('selectedCaseSubject', 'My Chats');
                pag.selectCaseSubject();

                ApexPages.CurrentPage().getParameters().put('selectedCaseSubject', 'My Open Proactive Cases');
                pag.selectCaseSubject();

         }
         Test.StopTest();
    }

    @isTest static void testCoachInsertStuff()
    {
        createCoachTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='coachu'];
        System.RunAs(u1){
                System.debug('running as coach user');
                PageReference pageRef = Page.SuccessPortal_MainPage;
                Test.setCurrentPage(pageRef);
                Case cs = new Case();
                ApexPages.standardController controller = new ApexPages.standardController(cs);

                pag = new SuccessPortal_MainPageController();
                pag.pageTitle = '';
                pag.init();

                pag.isCoachUser = true;

                pag.insertTask(pag.selectedContactId,'','Email','Ad Hoc Email','Description here','Pending','Normal');

                pag.insertEngagement('Email');
                pag.insertEngagementContact(successCoachUser.Id,e1.Id,pag.selectedContactId,pag.selectedCaseId,'Pending');
         }
         Test.StopTest();
    }

    @isTest static void testAdvisorInsertStuff()
    {
        createAdvisorTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='advisoru'];
        System.RunAs(u1){
                System.debug('running as advisor user');
                PageReference pageRef = Page.SuccessPortal_MainPage;
                Test.setCurrentPage(pageRef);
                Case cs = new Case();
                ApexPages.standardController controller = new ApexPages.standardController(cs);

                pag = new SuccessPortal_MainPageController();
                pag.pageTitle = '';
                pag.init();

                pag.isAdvisorUser = true;

                pag.insertTask(pag.selectedContactId,'','Email','Ad Hoc Email','Description here','Pending','Normal');

                pag.insertEngagement('Email');
                pag.insertEngagementContact(successAdvisorUser.Id,e1.Id,pag.selectedContactId,pag.selectedCaseId,'Pending');
         }
         Test.StopTest();
    }

    @isTest static void testCoachUpdateCase()
    {
        createCoachTestData();
        User u1 = [SELECT Id FROM User WHERE Alias='coachu'];
        System.RunAs(u1){
                System.debug('running as coach user');
                PageReference pageRef = Page.SuccessPortal_MainPage;
                Test.setCurrentPage(pageRef);
                Case cs = new Case();
                ApexPages.standardController controller = new ApexPages.standardController(cs);

                pag = new SuccessPortal_MainPageController();
                pag.pageTitle = '';
                pag.init();

                pag.isCoachUser = true;

                runSelectStudentCaseCoach();

                pag.getOutreachStatuses();
                pag.getStudentIntentions();
                pag.getReasonsNotReturning();
                pag.getTermReturning();
                pag.getPlannedMessages();
                pag.getwillReturnRisks();

				Test.StartTest();
                pag.selectedTaskId = '';
                pag.selectTask();
                runUpdateCase();
                pag.reloadAfterSave();
				Test.StopTest();
         }
    }

    @isTest static void testShadowCoach()
    {
        createCoachTestData();
        Test.StartTest();
        User m1 = [SELECT Id FROM User WHERE Alias='coachm'];
        System.RunAs(m1){
                System.debug('running as coach manager');
                PageReference pageRef = Page.SuccessPortal_MainPage;
                Test.setCurrentPage(pageRef);
                Case cs = new Case();
                ApexPages.standardController controller = new ApexPages.standardController(cs);

                pag = new SuccessPortal_MainPageController();
                pag.pageTitle = '';
                pag.init();

                pag.isCoachManager = true;

                runSelectShadowCoach();

                pag.getOutreachStatuses();
                pag.getStudentIntentions();
                pag.getReasonsNotReturning();
                pag.getTermReturning();
                pag.getPlannedMessages();

                pag.selectedTaskId = '';
                pag.selectTask();
                //runUpdateCases();
         }
         Test.StopTest();
    }

    @isTest static void testCoachPopulateStudentsLead()
    {
        createCoachTestData();
        Test.StartTest();

        User u1 = [SELECT Id FROM User WHERE Alias='coachl'];
        System.RunAs(u1){
            System.debug('running as coach lead');

            PageReference pageRef = Page.SuccessPortal_MainPage;
            Test.setCurrentPage(pageRef);

            pag = new SuccessPortal_MainPageController();
            pag.pageTitle = '';
            pag.init();

            pag.isCoachLead = true;

            //pag.advisorQueueId = userAdvisorManager.Id;

            pag.populateMyCaseSummaries();

            pag.populateMyPODList();

            runPopulateMyStudents();

            pag.populateMyWatchlist();

            pag.populateMyOpenCases();

            pag.populateMyChats();
        }

        Test.StopTest();
    }

    @isTest static void testCoachPopulateStudentsManager()
    {
        createCoachTestData();
        Test.StartTest();

        User u1 = [SELECT Id FROM User WHERE Alias='coachm'];
        System.RunAs(u1){
            System.debug('running as coach manager');

            PageReference pageRef = Page.SuccessPortal_MainPage;
            Test.setCurrentPage(pageRef);

            pag = new SuccessPortal_MainPageController();
            pag.pageTitle = '';
            pag.init();

            pag.isCoachManager = true;

            //pag.advisorQueueId = userAdvisorManager.Id;

            pag.populateMyCaseSummaries();

            pag.populateMyPODList();

            runPopulateMyStudents();

            pag.populateMyWatchlist();

            pag.populateMyOpenCases();

            pag.populateMyChats();
        }

        Test.StopTest();
    }

    @isTest static void testCoachPopulateStudentsAdmin()
    {
        createCoachTestData();
        Test.StartTest();

        User u1 = [SELECT Id FROM User WHERE Alias='coacha'];
        System.RunAs(u1){
            System.debug('running as coach admin');

            PageReference pageRef = Page.SuccessPortal_MainPage;
            Test.setCurrentPage(pageRef);

            pag = new SuccessPortal_MainPageController();
            pag.pageTitle = '';
            pag.init();

            pag.isCoachAdmin = true;

            //pag.advisorQueueId = userAdvisorManager.Id;

            pag.populateMyCaseSummaries();

            pag.populateMyPODList();

            runPopulateMyStudents();

            pag.populateMyWatchlist();

            pag.populateMyOpenCases();

            pag.populateMyChats();
        }

        Test.StopTest();
    }

    @isTest static void testAdvisorPopulateStudentsUser()
    {
        createAdvisorTestData();
        Test.StartTest();
         User u1 = [SELECT Id FROM User WHERE Alias='advisoru'];
         System.RunAs(u1){
            System.debug('running as advisor user');

            PageReference pageRef = Page.SuccessPortal_MainPage;
            Test.setCurrentPage(pageRef);

            pag = new SuccessPortal_MainPageController();
            pag.pageTitle = '';
            pag.init();

            pag.isAdvisorUser = true;

            pag.advisorQueueId = userAdvisorUser.Id;

            pag.populateMyCaseSummaries();

            pag.populateMyPODList();

            runPopulateMyStudents();

            pag.populateMyWatchlist();

            pag.populateMyOpenCases();

            pag.populateMyChats();
        }

        Test.StopTest();
    }

    @isTest static void testAdvisorPopulateStudentsLead()
    {
        // createAdvisorTestData();
        // Test.StartTest();
		//
        // User u1 = [SELECT Id FROM User WHERE Alias='advisorl'];
        // System.RunAs(u1){
        //     System.debug('running as advisor lead');
		//
        //     PageReference pageRef = Page.SuccessPortal_MainPage;
        //     Test.setCurrentPage(pageRef);
		//
        //     pag = new SuccessPortal_MainPageController();
        //     pag.pageTitle = '';
        //     pag.init();
        //
        //     pag.isAdvisorLead = true;
        //
        //     pag.advisorQueueId = userAdvisorLead.Id;
        //
        //     pag.populateMyCaseSummaries();
        //
        //     pag.populateMyPODList();
        //
        //     runPopulateMyStudents();
        //
        //     pag.populateMyWatchlist();
        //
        //     pag.populateMyOpenCases();
        //
        //     pag.populateMyChats();
        // }
        //
        // Test.StopTest();
    }

    @isTest static void testAdvisorPopulateStudentsManager()
    {
        createAdvisorTestData();
        Test.StartTest();

        User u1 = [SELECT Id FROM User WHERE Alias='advisorm'];
        System.RunAs(u1){
            System.debug('running as advisor manager');

            PageReference pageRef = Page.SuccessPortal_MainPage;
            Test.setCurrentPage(pageRef);

            pag = new SuccessPortal_MainPageController();
            pag.pageTitle = '';
            pag.init();

            pag.isAdvisorManager = true;

            pag.advisorQueueId = userAdvisorManager.Id;

            pag.populateMyCaseSummaries();

            pag.populateMyPODList();

            runPopulateMyStudents();

            pag.populateMyWatchlist();

            pag.populateMyOpenCases();

            pag.populateMyChats();
        }

        Test.StopTest();
    }

    @isTest static void testAdvisorPopulateStudentsAdmin()
    {
        createAdvisorTestData();
        Test.StartTest();

        User u1 = [SELECT Id FROM User WHERE Alias='advisora'];
        System.RunAs(u1){
            System.debug('running as advisor admin');

            PageReference pageRef = Page.SuccessPortal_MainPage;
            Test.setCurrentPage(pageRef);

            pag = new SuccessPortal_MainPageController();
            pag.pageTitle = '';
            pag.init();

            pag.isAdvisorAdmin = true;

            pag.advisorQueueId = userAdvisorAdmin.Id;

            pag.populateMyCaseSummaries();

            pag.populateMyPODList();

            runPopulateMyStudents();

            pag.populateMyWatchlist();

            pag.populateMyOpenCases();

            pag.populateMyChats();
        }

        Test.StopTest();
    }

    @isTest static void testAdvisorPopulateCases()
    {
        createAdvisorTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='advisoru'];
        System.RunAs(u1){
            System.debug('running as advisor');

            PageReference pageRef = Page.SuccessPortal_MainPage;
            Test.setCurrentPage(pageRef);

            pag = new SuccessPortal_MainPageController();
            pag.pageTitle = '';
            pag.init();

            pag.isAdvisorUser = true;

            pag.advisorQueueId = userAdvisorUser.Id;

            pag.populateMyCaseSummaries();

            pag.populateMyPODList();

            pag.populateMyWatchlist();

            pag.populateMyOpenCases();

            runSelectStudent();

            pag.getCasesAssigned();

            pag.selectedCaseSubject = 'All Open Cases';
            pag.populateCasesGrid();
            pag.selectedCaseSubject = 'Drop/Withdrawn';
            pag.populateCasesGrid();
            pag.selectedCaseSubject = 'My Watchlist';
            pag.populateCasesGrid();

            runSelectStudentCaseAdvisor();

        }
        Test.StopTest();
    }

    @istest static void testCallsToActionCoach()
    {
        createCoachTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='coachu'];
        System.RunAs(u1){
                System.debug('running as coach');
                PageReference pageRef = Page.SuccessPortal_MainPage;
                Test.setCurrentPage(pageRef);
                Case cs = new Case();
                ApexPages.standardController controller = new ApexPages.standardController(cs);

                pag = new SuccessPortal_MainPageController();
                pag.pageTitle = '';
                pag.init();

                pag.isCoachUser = true;

                runInsertAdHocCaseCoach();
                runInsertWatchlistCaseCoach();

                runPreviewEmail(null);
                runPreviewEmail(epm1.Id);

                runPreviewMassEmail(null);
                runPreviewMassEmail(epm1.Id);

                runMassEmail('');
                runMassEmail('studentsGrid');

                runMassSMS('');
                runMassSMS('studentsGrid');

                runSendMassEmail(null);
                runSendMassEmail(epm1.Id);

                runSendMassSMS('');
                runSendMassSMS('test');

                runSendSMS('');
                runSendSMS('Ad Hoc SMS');

                runSendEmail(null);
                runSendEmail(epm2.Id);

                runStartChat();

                runStartPhoneCall();

                runMassTransferCases();
                runSubmitMassTranferCases();
        }
        Test.StopTest();
    }

    @istest static void testCallsToActionAdvisor()
    {
        createAdvisorTestData();
        Test.StartTest();
        User u1 = [SELECT Id FROM User WHERE Alias='advisoru'];
        System.RunAs(u1){
                System.debug('running as advisor');
                PageReference pageRef = Page.SuccessPortal_MainPage;
                Test.setCurrentPage(pageRef);
                Case cs = new Case();
                ApexPages.standardController controller = new ApexPages.standardController(cs);

                pag = new SuccessPortal_MainPageController();
                pag.pageTitle = '';
                pag.init();

                pag.isAdvisorUser = true;

                runInsertAdHocCaseAdvisor();
                runInsertWatchlistCaseAdvisor();

        }
        Test.StopTest();
    }

    static private void createCoachTestData()
    {
        //Coach POD RT
        String podCoachRecordTypeId = '';
        List<RecordType> rectype1 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'Coach' AND SobjectType = 'Success_POD__c'];
        if(rectype1.size()>0)podCoachRecordTypeId=rectype1[0].Id;

        //Contact RT
        contactRecordTypeId = '';
        List<RecordType> rectype3 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'External_Mastered' AND SobjectType = 'Contact'];
        if(rectype3.size()>0)contactRecordTypeId=rectype3[0].Id;

        //Task RT
        taskRecordTypeId = '';
        List<RecordType> rectype4 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'Success_Layout_Type'];
        if(rectype4.size()>0)taskRecordTypeId=rectype4[0].Id;

        //Profile RT
        Id profileId = [SELECT Id FROM Profile WHERE Name ='System Administrator'].Id;

        //Coach Case RT
        String coachCaseRecordTypeId = '';
        List<RecordType> rectype5 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'ASU_Coach_Outreach' AND SobjectType = 'Case'];
        if(rectype5.size()>0)coachCaseRecordTypeId=rectype5[0].Id;

        //Coach RT
        String coachResourceRecordTypeId = '';
        List<RecordType> rectype7 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'Coach' AND SobjectType = 'Success_Resource__c'];
        if(rectype7.size()>0)coachResourceRecordTypeId=rectype7[0].Id;

        //Coach Engagement RT
        engagementCoachRecordTypeId = '';
        List<RecordType> rectype8 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'ASU_Coach_Outreach' AND SobjectType = 'Engagement__c'];
        if(rectype8.size()>0)engagementCoachRecordTypeId=rectype8[0].Id;

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

        //create success student
        successStudent = new Success_Student__c();
        successStudent.Student__c = userStudent.Id;
        successStudent.Success_Resource__c = successCoachUser.Id;
        successStudent.Success_POD__c = successPOD.Id;
        insert successStudent;

        //create coach case
        caseCoach1 = new Case();
        caseCoach1.RecordTypeId = coachCaseRecordTypeId;
        caseCoach1.Type = 'Coach Initiated';
        caseCoach1.Subject = 'Drop/Withdrawn';
        caseCoach1.Status = 'New';
        caseCoach1.Priority = 'Normal';
        caseCoach1.Followup_Date__c = System.today();
        caseCoach1.OwnerId = userCoachUser.Id;
        caseCoach1.ASR_Date__c = System.today();
        caseCoach1.ASR_Comments__c = 'comments here';
        caseCoach1.ASR_Reasons__c = 'reasons here';
        caseCoach1.ASR_Actions__c = 'actions here';
        caseCoach1.Recommended_Actions__c = 'address financial issues;adjust course balance';
        caseCoach1.Reasons_Not_Returning__c = 'Academic;Disqualified';
        insert caseCoach1;
        proactiveCases.add(caseCoach1);

        //create coach case
        caseCoach2 = new Case();
        caseCoach2.RecordTypeId = coachCaseRecordTypeId;
        caseCoach2.Type = 'Coach Initiated';
        caseCoach2.Subject = 'My Watchlist';
        caseCoach2.Status = 'New';
        caseCoach2.Priority = 'Normal';
        caseCoach2.Followup_Date__c = System.today();
        caseCoach2.OwnerId = userCoachUser.Id;
        caseCoach2.ASR_Date__c = System.today();
        caseCoach2.ASR_Comments__c = 'comments here';
        caseCoach2.ASR_Reasons__c = 'reasons here';
        caseCoach2.ASR_Actions__c = 'actions here';
        caseCoach2.Recommended_Actions__c = 'address financial issues;adjust course balance';
        caseCoach2.Reasons_Not_Returning__c = 'Academic;Disqualified';
        insert caseCoach2;
        proactiveCases.add(caseCoach2);

        //create coach case
        caseCoach3 = new Case();
        caseCoach3.RecordTypeId = coachCaseRecordTypeId;
        caseCoach3.Type = 'Coach Initiated';
        caseCoach3.Subject = 'My Chats';
        caseCoach3.Status = 'New';
        caseCoach3.Priority = 'Normal';
        caseCoach3.Followup_Date__c = System.today();
        caseCoach3.OwnerId = userCoachUser.Id;
        caseCoach3.ASR_Date__c = System.today();
        caseCoach3.ASR_Comments__c = 'comments here';
        caseCoach3.ASR_Reasons__c = 'reasons here';
        caseCoach3.ASR_Actions__c = 'actions here';
        caseCoach3.Recommended_Actions__c = 'address financial issues;adjust course balance';
        caseCoach3.Reasons_Not_Returning__c = 'Academic;Disqualified';
        insert caseCoach3;
        proactiveCases.add(caseCoach3);

        //create case comments
        caseComments = new CaseComment();
        caseComments.ParentId = caseCoach1.Id;
        caseComments.CommentBody = 'my new comment';
        insert caseComments;

        //create case tasks
        caseTasks = new Task();
        caseTasks.WhoId = userStudent.Id;
        caseTasks.WhatId = caseCoach1.Id;
        caseTasks.Subject = 'Email';
        caseTasks.ActivityDate = System.today();
        caseTasks.Status = 'Completed';
        caseTasks.Description = 'Sent thru the MC';
        caseTasks.Type = 'Email';
        insert caseTasks;

        //create engagement
        e1 = new Engagement__c();
        e1.RecordTypeId = engagementCoachRecordTypeId;
        e1.Engagement_Name__c = 'Ad Hoc Email Engagement';
        e1.Engagement_Type__c = 'Ad Hoc Email';
        insert e1;

        //create engagement
        e2 = new Engagement__c();
        e2.RecordTypeId = engagementCoachRecordTypeId;
        e2.Engagement_Name__c = 'Mass SMS Engagement';
        e2.Engagement_Type__c = 'Mass SMS Message';
        insert e2;

        //create engagement
        e3 = new Engagement__c();
        e3.RecordTypeId = engagementCoachRecordTypeId;
        e3.Engagement_Name__c = 'Ad Hoc SMS Engagement';
        e3.Engagement_Type__c = 'Ad Hoc SMS Message';
        insert e3;

        //create planned message
        epm1 = new Engagement_Planned_Message__c();
        epm1.Name__c = 'EPM 1';
        epm1.Message_Text__c = 'Copy here';
        epm1.Message_Type__c = 'Ad Hoc Email';
        epm1.Engagement__c = e1.Id;
        insert epm1;

        //create planned message
        epm2 = new Engagement_Planned_Message__c();
        epm2.Name__c = 'EPM 2';
        epm2.Message_Text__c = 'Copy here';
        epm2.Message_Type__c = 'Mass SMS Message';
        epm2.Engagement__c = e2.Id;
        insert epm2;

        //create planned message
        epm3 = new Engagement_Planned_Message__c();
        epm3.Name__c = 'EPM 3';
        epm3.Message_Text__c = 'Copy here';
        epm3.Message_Type__c = 'Ad Hoc SMS Message';
        epm3.Engagement__c = e3.Id;
        insert epm3;

        //create engagement contact
        ec = new Engagement_Contact__c();
        ec.Status__c ='Pending';
        ec.Expiration_Date__c = System.today();
        ec.Engagement__c = e1.Id;
        ec.Contact__c = userStudent.Id;
        insert ec;

        //create message
        em = new Engagement_Message__c();
        em.Status__c = 'Pending';
        em.Engagement_Contact__c = ec.Id;
        em.Engagement_Planned_Message__c = epm1.Id;
        em.Contact__c = userStudent.Id;
        insert em;

    }

    static private void createAdvisorTestData()
    {

        //Advisor POD RT
        String podAdvisorRecordTypeId = '';
        List<RecordType> rectype2 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'Advisor' AND SobjectType = 'Success_POD__c'];
        if(rectype2.size()>0)podAdvisorRecordTypeId=rectype2[0].Id;

        //Contact RT
        contactRecordTypeId = '';
        List<RecordType> rectype3 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'External_Mastered' AND SobjectType = 'Contact'];
        if(rectype3.size()>0)contactRecordTypeId=rectype3[0].Id;

        //Task RT
        taskRecordTypeId = '';
        List<RecordType> rectype4 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'Success_Layout_Type' AND SobjectType = 'Task'];
        if(rectype4.size()>0)taskRecordTypeId=rectype4[0].Id;

        //Profile RT
        Id profileId = [SELECT Id FROM Profile WHERE Name ='System Administrator'].Id;

        //Advisor Case RT
        String advisorCaseRecordTypeId = '';
        List<RecordType> rectype6 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'ASU_Advisor_Outreach' AND SobjectType = 'Case'];
        if(rectype6.size()>0)advisorCaseRecordTypeId=rectype6[0].Id;

        //Advisor RT
        String advisorResourceRecordTypeId = '';
        List<RecordType> rectype7 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'Advisor' AND SobjectType = 'Success_Resource__c'];
        if(rectype7.size()>0)advisorResourceRecordTypeId=rectype7[0].Id;

        //Advisor Engagement RT
        engagementAdvisorRecordTypeId = '';
        List<RecordType> rectype8 = [SELECT Id FROM RecordType WHERE DeveloperName =: 'ASU_Advisor_Outreach' AND SobjectType = 'Engagement__c'];
        if(rectype8.size()>0)engagementAdvisorRecordTypeId=rectype8[0].Id;

        //create advisor user
        userAdvisorUser = new User();
        userAdvisorUser.Lastname = 'advisor';
        userAdvisorUser.Alias = 'advisoru';
        userAdvisorUser.Email = 'theadvisoruser@asu.edu.xyz';
        userAdvisorUser.Username = 'theadvisoruser@asu.edu.xyz';
        userAdvisorUser.TimeZoneSidKey = 'America/Phoenix';
        userAdvisorUser.LocaleSidKey = 'en_US';
        userAdvisorUser.EmailEncodingKey = 'ISO-8859-1';
        userAdvisorUser.ProfileId = profileId;
        userAdvisorUser.LanguageLocaleKey = 'en_US';
        insert userAdvisorUser;

        //create advisor lead
        userAdvisorLead = new User();
        userAdvisorLead.Lastname = 'advisor';
        userAdvisorLead.Alias = 'advisorl';
        userAdvisorLead.Email = 'theadvisorlead@asu.edu.xyz';
        userAdvisorLead.Username = 'theadvisorlead@asu.edu.xyz';
        userAdvisorLead.TimeZoneSidKey = 'America/Phoenix';
        userAdvisorLead.LocaleSidKey = 'en_US';
        userAdvisorLead.EmailEncodingKey = 'ISO-8859-1';
        userAdvisorLead.ProfileId = profileId;
        userAdvisorLead.LanguageLocaleKey = 'en_US';
        insert userAdvisorLead;

        //create advisor manager
        userAdvisorManager = new User();
        userAdvisorManager.Lastname = 'advisor';
        userAdvisorManager.Alias = 'advisorm';
        userAdvisorManager.Email = 'theadvisormanager@asu.edu.xyz';
        userAdvisorManager.Username = 'theadvisormanager@asu.edu.xyz';
        userAdvisorManager.TimeZoneSidKey = 'America/Phoenix';
        userAdvisorManager.LocaleSidKey = 'en_US';
        userAdvisorManager.EmailEncodingKey = 'ISO-8859-1';
        userAdvisorManager.ProfileId = profileId;
        userAdvisorManager.LanguageLocaleKey = 'en_US';
        insert userAdvisorManager;

        //create advisor admin
        userAdvisorAdmin = new User();
        userAdvisorAdmin.Lastname = 'advisor';
        userAdvisorAdmin.Alias = 'advisora';
        userAdvisorAdmin.Email = 'theadvisoradmin@asu.edu.xyz';
        userAdvisorAdmin.Username = 'theadvisoradmin@asu.edu.xyz';
        userAdvisorAdmin.TimeZoneSidKey = 'America/Phoenix';
        userAdvisorAdmin.LocaleSidKey = 'en_US';
        userAdvisorAdmin.EmailEncodingKey = 'ISO-8859-1';
        userAdvisorAdmin.ProfileId = profileId;
        userAdvisorAdmin.LanguageLocaleKey = 'en_US';
        insert userAdvisorAdmin;

        //create pod
        successPOD = new Success_POD__c();
        successPOD.RecordTypeId = podAdvisorRecordTypeId;
        successPOD.Name = 'Advisor POD';
        successPOD.OwnerId = userAdvisorUser.Id;
        insert successPOD;

        //create success advisor user
        successAdvisorUser = new Success_Resource__c();
        successAdvisorUser.Resource__c = userAdvisorUser.Id;
        successAdvisorUser.RecordTypeId = advisorResourceRecordTypeId;
        successAdvisorUser.Role__c = 'User';
        successAdvisorUser.AgentID__c = '67890';
        successAdvisorUser.Success_POD__c = successPOD.Id;
        successAdvisorUser.Program_Code__c = 'UGES;UGLA';
        successAdvisorUser.IsActive__c = true;
        insert successAdvisorUser;

        //create success advisor lead
        successAdvisorLead = new Success_Resource__c();
        successAdvisorLead.Resource__c = userAdvisorLead.Id;
        successAdvisorLead.RecordTypeId = advisorResourceRecordTypeId;
        successAdvisorLead.Role__c = 'Lead';
        successAdvisorLead.AgentID__c = '67890';
        successAdvisorLead.Success_POD__c = successPOD.Id;
        successAdvisorLead.Program_Code__c = 'UGES;UGLA';
        successAdvisorLead.IsActive__c = true;
        insert successAdvisorLead;

        //create success advisor manager
        successAdvisorManager = new Success_Resource__c();
        successAdvisorManager.Resource__c = userAdvisorManager.Id;
        successAdvisorManager.RecordTypeId = advisorResourceRecordTypeId;
        successAdvisorManager.Role__c = 'Manager';
        successAdvisorManager.AgentID__c = '67890';
        successAdvisorManager.Success_POD__c = successPOD.Id;
        successAdvisorManager.Program_Code__c = 'UGES;UGLA';
        successAdvisorManager.IsActive__c = true;
        insert successAdvisorManager;

        //create success advisor admin
        successAdvisorAdmin = new Success_Resource__c();
        successAdvisorAdmin.Resource__c = userAdvisorAdmin.Id;
        successAdvisorAdmin.RecordTypeId = advisorResourceRecordTypeId;
        successAdvisorAdmin.Role__c = 'Admin';
        successAdvisorAdmin.AgentID__c = '67890';
        successAdvisorAdmin.Success_POD__c = successPOD.Id;
        successAdvisorAdmin.Program_Code__c = 'UGES;UGLA';
        successAdvisorAdmin.IsActive__c = true;
        insert successAdvisorAdmin;

        //create student
        userStudent = new Contact();
        userStudent.RecordTypeId = contactRecordTypeId;
        userStudent.Firstname = 'John';
        userStudent.Lastname = 'Doe';
        userStudent.Email = 'john.doe@asu.edu.xyz';
        userStudent.ASURITE_ID__c = 'jdoe1';
        userStudent.Hidden_Selected__c = true;
        insert userStudent;

        //create success student
        successStudent = new Success_Student__c();
        successStudent.Student__c = userStudent.Id;
        successStudent.Success_Resource__c = successAdvisorUser.Id;
        successStudent.Success_POD__c = successPOD.Id;
        insert successStudent;

        //create advisor case
        caseAdvisor1 = new Case();
        caseAdvisor1.RecordTypeId = advisorCaseRecordTypeId;
        caseAdvisor1.Type = 'Advisor Initiated';
        caseAdvisor1.Subject = 'Drop/Withdrawn';
        caseAdvisor1.Status = 'New';
        caseAdvisor1.Priority = 'Normal';
        caseAdvisor1.Followup_Date__c = System.today();
        caseAdvisor1.OwnerId = userAdvisorUser.Id;
        caseAdvisor1.ASR_Date__c = System.today();
        caseAdvisor1.ASR_Comments__c = 'comments here';
        caseAdvisor1.ASR_Reasons__c = 'reasons here';
        caseAdvisor1.ASR_Actions__c = 'actions here';
        caseAdvisor1.Recommended_Actions__c = 'address financial issues;adjust course balance';
        caseAdvisor1.Reasons_Not_Returning__c = 'Academic;Disqualified';
        insert caseAdvisor1;

        //create coach case
        caseAdvisor2 = new Case();
        caseAdvisor2.RecordTypeId = advisorCaseRecordTypeId;
        caseAdvisor2.Type = 'Advisor Initiated';
        caseAdvisor2.Subject = 'My Watchlist';
        caseAdvisor2.Status = 'New';
        caseAdvisor2.Priority = 'Normal';
        caseAdvisor2.Followup_Date__c = System.today();
        caseAdvisor2.OwnerId = userAdvisorUser.Id;
        caseAdvisor2.ASR_Date__c = System.today();
        caseAdvisor2.ASR_Comments__c = 'comments here';
        caseAdvisor2.ASR_Reasons__c = 'reasons here';
        caseAdvisor2.ASR_Actions__c = 'actions here';
        caseAdvisor2.Recommended_Actions__c = 'address financial issues;adjust course balance';
        caseAdvisor2.Reasons_Not_Returning__c = 'Academic;Disqualified';
        insert caseAdvisor2;

        //create coach case
        caseAdvisor3 = new Case();
        caseAdvisor3.RecordTypeId = advisorCaseRecordTypeId;
        caseAdvisor3.Type = 'Advisor Initiated';
        caseAdvisor3.Subject = 'Chat';
        caseAdvisor3.Status = 'New';
        caseAdvisor3.Priority = 'Normal';
        caseAdvisor3.Followup_Date__c = System.today();
        caseAdvisor3.OwnerId = userAdvisorUser.Id;
        caseAdvisor3.ASR_Date__c = System.today();
        caseAdvisor3.ASR_Comments__c = 'comments here';
        caseAdvisor3.ASR_Reasons__c = 'reasons here';
        caseAdvisor3.ASR_Actions__c = 'actions here';
        caseAdvisor3.Recommended_Actions__c = 'address financial issues;adjust course balance';
        caseAdvisor3.Reasons_Not_Returning__c = 'Academic;Disqualified';
        insert caseAdvisor3;

        //create engagement
        e1 = new Engagement__c();
        e1.RecordTypeId = engagementAdvisorRecordTypeId;
        e1.Engagement_Name__c = 'Ad Hoc Email Engagement';
        e1.Engagement_Type__c = 'Ad Hoc Email';
        insert e1;

        //create engagement
        e2 = new Engagement__c();
        e2.RecordTypeId = engagementAdvisorRecordTypeId;
        e2.Engagement_Name__c = 'Ad Hoc SMS Message';
        e2.Engagement_Type__c = 'Ad Hoc SMS Message';
        insert e2;

        //create engagement
        e3 = new Engagement__c();
        e3.RecordTypeId = engagementAdvisorRecordTypeId;
        e3.Engagement_Name__c = 'Ad Hoc SMS Engagement';
        e3.Engagement_Type__c = 'Ad Hoc SMS Message';
        insert e3;

        //create planned message
        epm1 = new Engagement_Planned_Message__c();
        epm1.Name__c = 'EPM 1';
        epm1.Message_Text__c = 'Copy here';
        epm1.Message_Type__c = 'Ad Hoc Email';
        epm1.Engagement__c = e1.Id;
        insert epm1;

        //create planned message
        epm2 = new Engagement_Planned_Message__c();
        epm2.Name__c = 'EPM 2';
        epm2.Message_Text__c = 'Copy here';
        epm2.Message_Type__c = 'Mass SMS Message';
        epm2.Engagement__c = e2.Id;
        insert epm2;

        //create planned message
        epm3 = new Engagement_Planned_Message__c();
        epm3.Name__c = 'EPM 3';
        epm3.Message_Text__c = 'Copy here';
        epm3.Message_Type__c = 'Ad Hoc SMS Message';
        epm3.Engagement__c = e3.Id;
        insert epm3;

        //create engagement contact
        ec = new Engagement_Contact__c();
        ec.Status__c ='Pending';
        ec.Expiration_Date__c = System.today();
        ec.Engagement__c = e1.Id;
        ec.Contact__c = userStudent.Id;
        insert ec;

        //create message
        em = new Engagement_Message__c();
        em.Status__c = 'Pending';
        em.Engagement_Contact__c = ec.Id;
        em.Engagement_Planned_Message__c = epm1.Id;
        em.Contact__c = userStudent.Id;
        insert em;

    }

    static private void runPopulateMyStudents()
    {
        pag.populateMyStudents();
    }

    static private void runInsertEmptyCaseSubject()
    {
        pag.selectedContactId = userStudent.Id;
        pag.newSubject= '';
        pag.newDescr = 'new descr';
        pag.userId = userCoachUser.Id;
        pag.insertCase();
    }

    static private void runInsertEmptyCaseDescr()
    {
        pag.selectedContactId = userStudent.Id;
        pag.newSubject= 'new subject';
        pag.newDescr = '';
        pag.userId = userCoachUser.Id;
        pag.insertCase();
    }

    static private void runInsertAdHocCaseCoach()
    {
        pag.selectedContactId = userStudent.Id;
        pag.newSubject= 'new subject';
        pag.newDescr = 'new descr';
        pag.userId = userCoachUser.Id;
        pag.insertCase();
    }

    static private void runInsertAdHocCaseAdvisor()
    {
        pag.selectedContactId = userStudent.Id;
        pag.newSubject= 'new subject';
        pag.newDescr = 'new descr';
        pag.userId = userAdvisorUser.Id;
        pag.insertCase();
    }

    static private void runInsertWatchlistCaseCoach()
    {
        pag.selectedContactId = userStudent.Id;
        pag.newSubject= 'My Watchlist';
        pag.newDescr = 'new descr';
        pag.userId = userCoachUser.Id;
        pag.insertWatchlistCase();
    }

    static private void runInsertWatchlistCaseAdvisor()
    {
        pag.selectedContactId = userStudent.Id;
        pag.newSubject= 'My Watchlist';
        pag.newDescr = 'new descr';
        pag.userId = userAdvisorUser.Id;
        pag.insertWatchlistCase();
    }

    static private void runUpdateCase()
    {
        pag.selectedCaseSubject = 'All My Students';
        pag.selectedCaseId = caseCoach3.Id;
        pag.selectedCaseComments = 'test';
        pag.selectCaseComments();
        pag.NewSubject = 'Not Enrolled';
        pag.selectNewSubject();
        pag.newDescr = 'new description';
        pag.selectNewDescription();
        pag.selectedCaseComments = 'new comments';
        pag.selectCaseComments();
        pag.selectedFollowupDate = System.today().addDays(-1);
        pag.updateCase();

        /*
        pag.selectedTermReturning = null;
        pag.selectedStudentIntention='Not returning temporarily';
        pag.updateCase();
        */
    }

    /*
    static private void runUpdateCases()
    {
        pag.otherProactiveCases = proactiveCases;
        pag.selectedOutreachStatus = 'New';
        pag.selectOutreachStatus();
        pag.selectedCaseComments = 'test';
        pag.selectCaseComments();

        pag.updateCases();
    }
    */

    static private void runSelectStudent()
    {
        pag.selectedContactId = userStudent.Id;
        pag.selectedContactASURiteId = userStudent.ASURite_Id__c;
        pag.selectedContactName = userStudent.FirstName + ' ' + userStudent.LastName;
        pag.selectedContactEmplId = userStudent.EMPLID__c;
        pag.selectedContactHomePhone = '111-111-1111';
        pag.selectedContactOtherPhone = '222-222-2222';
        pag.selectedContactMobilePhone = '333-333-3333';
        pag.selectedContactEmail = userStudent.Email;
        //form selections
        pag.selectedOutreachStatus = 'New';
        pag.selectOutreachStatus();
        pag.selectedStudentIntention = 'Will Enroll';
        pag.selectStudentIntention();
        ApexPages.CurrentPage().getParameters().put('selectedFollowupDateMonth', '06');
        ApexPages.CurrentPage().getParameters().put('selectedFollowupDateDay', '12');
        ApexPages.CurrentPage().getParameters().put('selectedFollowupDateYear', '2016');
        pag.selectedFollowupDate = System.today();
        ApexPages.CurrentPage().getParameters().put('selectedASRDate', string.valueOf(System.today()));
        ApexPages.CurrentPage().getParameters().put('selectedASRDateMonth', '06');
        ApexPages.CurrentPage().getParameters().put('selectedASRDateDay', '12');
        ApexPages.CurrentPage().getParameters().put('selectedASRDateYear', '2016');
        pag.selectedASRDate = System.today();
        ApexPages.CurrentPage().getParameters().put('selectedASRDate', string.valueOf(System.today()));
        ApexPages.CurrentPage().getParameters().put('selectedContactId', userStudent.Id);
        pag.selectStudent();
    }

    static private void runSelectShadowCoach()
    {
        ApexPages.CurrentPage().getParameters().put('selectedCoachUserId', caseCoach2.Id);
        pag.selectedCoachUserId = caseCoach2.Id;
        pag.selectCoachUserId();
    }

    static private void runSelectStudentCaseCoach()
    {
        List<string> ras = new List<string>();
        ras.add('seek academic support');
        ras.add('correct schedule');
        pag.selectedCaseId = caseCoach1.Id;
        pag.selectedContactId = userStudent.Id;
        pag.selectedContactASURiteId = userStudent.ASURite_Id__c;
        pag.selectedContactName = userStudent.FirstName + ' ' + userStudent.LastName;
        pag.selectedContactEmplId = userStudent.EMPLID__c;
        pag.selectedContactHomePhone = '111-111-1111';
        pag.selectedContactOtherPhone = '222-222-2222';
        pag.selectedContactMobilePhone = '333-333-3333';
        pag.selectedContactEmail = userStudent.Email;
        pag.selectedCaseSubject = caseCoach1.Subject;

        //form selections
        pag.selectedOutreachStatus = 'New';
        pag.selectOutreachStatus();
        pag.selectedStudentIntention = 'Will Enroll';
        pag.selectStudentIntention();
        ApexPages.CurrentPage().getParameters().put('selectedFollowupDateMonth', '06');
        ApexPages.CurrentPage().getParameters().put('selectedFollowupDateDay', '12');
        ApexPages.CurrentPage().getParameters().put('selectedFollowupDateYear', '2016');
        pag.selectedFollowupDate = System.today();
        ApexPages.CurrentPage().getParameters().put('selectedFollowupDate', string.valueOf(System.today()));
        ApexPages.CurrentPage().getParameters().put('selectedASRDateMonth', '06');
        ApexPages.CurrentPage().getParameters().put('selectedASRDateDay', '12');
        ApexPages.CurrentPage().getParameters().put('selectedASRDateYear', '2016');
        pag.selectedASRDate = System.today();
        ApexPages.CurrentPage().getParameters().put('selectedASRDate', string.valueOf(System.today()));
        pag.selectedCaseDescription = caseCoach1.Description;
        ApexPages.CurrentPage().getParameters().put('selectedRecommendedActions', 'seek academic support;correct schedule');
        pag.selectRecommendedActions();
        pag.selectReasonsNotReturning();
        pag.selectedTermReturning = '';
        pag.selectTermReturning();
        ApexPages.CurrentPage().getParameters().put('selectedWillReturnRisk', 'Financial');
        pag.selectWillReturnRisk();
        ApexPages.CurrentPage().getParameters().put('selectedWillReturnRiskOther', 'other text');
        pag.selectWillReturnRiskOther();
        //pag.selectStudentCase();
        pag.updateCase();

        pag.selectedCaseId = caseCoach1.Id;
        pag.selectedCaseComments = 'new comments';
        pag.insertCaseComments();
    }

    static private void runSelectStudentCaseAdvisor()
    {
        List<string> ras = new List<string>();
        ras.add('x');
        ras.add('y');
        pag.selectedCaseId = caseAdvisor1.Id;
        pag.selectedContactId = userStudent.Id;
        pag.selectedContactASURiteId = userStudent.ASURite_Id__c;
        pag.selectedContactName = userStudent.FirstName + ' ' + userStudent.LastName;
        pag.selectedContactEmplId = userStudent.EMPLID__c;
        pag.selectedContactHomePhone = '111-111-1111';
        pag.selectedContactOtherPhone = '222-222-2222';
        pag.selectedContactMobilePhone = '333-333-3333';
        pag.selectedContactEmail = userStudent.Email;
        pag.selectedCaseSubject = caseAdvisor1.Subject;
        pag.selectedOutreachStatus = 'New';
        pag.selectedStudentIntention = 'Will Enroll';
        ApexPages.CurrentPage().getParameters().put('selectedFollowupDateMonth', '06');
        ApexPages.CurrentPage().getParameters().put('selectedFollowupDateDay', '12');
        ApexPages.CurrentPage().getParameters().put('selectedFollowupDateYear', '2016');
        pag.selectedFollowupDate = System.today();
        ApexPages.CurrentPage().getParameters().put('selectedFollowupDate', string.valueOf(System.today()));
        pag.selectedASRDate = System.today();
        ApexPages.CurrentPage().getParameters().put('selectedASRDateMonth', '06');
        ApexPages.CurrentPage().getParameters().put('selectedASRDateDay', '12');
        ApexPages.CurrentPage().getParameters().put('selectedASRDateYear', '2016');
        pag.selectedASRDate = System.today();
        ApexPages.CurrentPage().getParameters().put('selectedASRDate', string.valueOf(System.today()));
        pag.selectedCaseDescription = caseAdvisor1.Description;
        ApexPages.CurrentPage().getParameters().put('selectedRecommendedActions', 'seek academic support;correct schedule');
        pag.selectRecommendedActions();
        ApexPages.CurrentPage().getParameters().put('selectedReasonsNotReturning', 'Academic;Health');
        pag.selectReasonsNotReturning();
        pag.selectedTermReturning = '';
        ApexPages.CurrentPage().getParameters().put('selectedCaseId', caseAdvisor1.Id);
        pag.selectStudentCase();
    }

    static private void runSelectCaseSubject(string subject)
    {
        pag.selectedCaseSubject = subject;
        pag.caseSelected = true;
        pag.contactSelected = false;
        pag.selectedContactId = '';
        pag.selectedContactASURiteId = '';
        pag.selectedContactName = '';
        pag.selectedContactEmplId = '';
        pag.selectedContactHomePhone = '';
        pag.selectedContactMobilePhone = '';
        pag.selectedContactOtherPhone = '';
        pag.selectedContactEmail = '';
        pag.selectCaseSubject();
     }

     static private void runPreviewEmail(string pmid)
     {
             pag.selectedPlannedMessage = pmid;
             pag.previewEmail();
     }

     static private void runPreviewMassEmail(string pmid)
     {
         pag.selectedPlannedMessage = pmid;
         pag.previewMassEmail();
     }

     static private void runMassEmail(string gridtype)
     {
         ApexPages.CurrentPage().getParameters().put('gridType', gridtype);
         pag.massEmailStudents();
     }

     static private void runMassSMS(string gridtype)
     {
         ApexPages.CurrentPage().getParameters().put('gridType', gridtype);
         pag.massSMSStudents();
     }

     static private void runSendMassSMS(string msg)
     {
        pag.selectedPlannedMessage = epm3.Id;
        pag.selectedSMSText = msg;
        pag.sendMassSMS();
     }

     static private void runSendMassEmail(string pmid)
     {
         pag.selectedCaseId = caseCoach1.Id;
         pag.selectedContactId = userStudent.Id;
         pag.selectedPlannedMessage = pmid;
         pag.sendMassEmail();
     }

     static private void runSendEmail(string pmid)
     {
         pag.selectedCaseId = caseCoach1.Id;
         pag.selectedContactId = userStudent.Id;
         pag.selectedPlannedMessage = pmid;
         pag.sendEmail();
     }

     static private void runSendSMS(string msg)
     {
         pag.selectedCaseId = caseCoach1.Id;
         pag.selectedContactId = userStudent.Id;
         pag.selectedSMSText = msg;
         pag.sendSMS();
     }

     static private void runStartChat()
     {
         pag.startChat();
     }

     static private void runStartPhoneCall()
     {
         pag.startPhoneCall();
     }

     static private void runMassTransferCases()
     {
         pag.massTransferCases();
     }

     static private void runSubmitMassTranferCases()
     {
        pag.selectedCaseId = caseCoach1.Id;
        pag.submitMassTransferCases();
     }

}
