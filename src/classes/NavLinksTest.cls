@isTest
private class NavLinksTest {
    private static Contact testContact;
    private static NavLinks nav;
    private static Profile asuCommunityProfile;
    private static ServiceCenter sc;
    private static User testUser;

    private static void setUp() {
        asuCommunityProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'ASU Community'
        ];

        Term__c termAC = new Term__c();
        Date sessionAStartDate = Date.today().adddays(30);
        termAC.Session_A_C_Start_Date__c = sessionAStartDate;
        termAC.Year__c = '2015';

        insert termAC;

        Term__c termB = new Term__c();
        Date sessionBStartDate = Date.today().adddays(40);
        termB.Session_B_Start_Date__c = sessionBStartDate;
        termB.Year__c = '2015';

        insert termB;

        Service_Center_Maintenance__c scm = new Service_Center_Maintenance__c(
            Name = 'The Test Message',
            Displayed__c = true,
            Message__c = 'There is maintenance'
        );

        insert scm;

        testContact = ContactService.createTestContact();

        insert testContact;

        testUser = UserService.createTestUser();
        testUser.ProfileId = asuCommunityProfile.Id;
        testUser.ContactId = testContact.Id;

        insert testUser;

        PageReference serviceCenter = Page.studentSC;
        Test.setCurrentPage(serviceCenter);
    }

    private static void setCookie(String cookieData) {
        Cookie linksCookie = new Cookie('navbarlinks',cookieData,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{linksCookie});    
    }
    
    @isTest 
    private static void testInitWithoutURLParameters() {
        setUp();
        Test.startTest();
        System.runAs(testUser) {
            sc = new ServiceCenter();
            nav = new Navlinks(sc);
            nav.init();
        }
        Test.stopTest();
        System.assertEquals(nav.links, null);
    }

    @isTest 
    private static void retrieveCookieDataFromURL() {
        setUp();
        Test.startTest();
        System.runAs(testUser) {
            sc = new ServiceCenter();
            nav = new NavLinks(sc);
            ApexPages.currentPage().getParameters().put('asuriteId', 'aesanch2');
            ApexPages.currentPage().getParameters().put('time', '1417811918');
            ApexPages.currentPage().getParameters().put('signature',
                'a8539563d36219e592c3376dae079d38887cc9af8374d74929bdf48bb655b93f');
            ApexPages.currentPage().getParameters().put('navbar',
                '{"navbarLinks":[{"Home":"https://webapp4-dev.asu.edu/myasu/student"},' +
                '{"Finances":"https://webapp4-dev.asu.edu/myasu/student/finances"},' +
                '{"Service Center":"https://webapp4-dev.asu.edu/myasu/student/servicecenter"},' +
                '{"Campus Services":"https://webapp4-dev.asu.edu/myasu/student/campusservices"},' +
                '{"Profile":"https://webapp4-dev.asu.edu/myasu/student/profile"}]}');
            nav.init();
        }
        Test.stopTest();
        System.assertEquals(nav.linkList[0].name,'Home');
        System.assertEquals(nav.linkList[1].name,'Finances');
        System.assertEquals(nav.linkList[2].name,'Service Center');
        System.assertEquals(nav.linkList[3].name,'Campus Services');
        System.assertEquals(nav.linkList[4].name,'Profile');
    }
    
     @isTest
    private static void testNullCookieDataInURL() {
        setUp();
        Test.startTest();
        System.runAs(testUser) {
            sc = new ServiceCenter();
            nav = new NavLinks(sc);
            ApexPages.currentPage().getParameters().put('asuriteId', 'aesanch2');
            ApexPages.currentPage().getParameters().put('time', '1417811918');
            ApexPages.currentPage().getParameters().put('signature',
                'a8539563d36219e592c3376dae079d38887cc9af8374d74929bdf48bb655b93f');
            ApexPages.currentPage().getParameters().put('navbar', '{"navbarLinks":');
            nav.init();
        }
        Test.stopTest();
        System.assertEquals(nav.links, '');
    }
    
    
    @isTest
    private static void retrieveCookieFromPage() {
        setUp();
        Test.startTest();
        System.runAs(testUser) {
            sc = new ServiceCenter();
            nav = new NavLinks(sc);
            ApexPages.currentPage().getParameters().put('asuriteId', 'aesanch2');
            ApexPages.currentPage().getParameters().put('time', '1417811918');
            ApexPages.currentPage().getParameters().put('signature',
                'a8539563d36219e592c3376dae079d38887cc9af8374d74929bdf48bb655b93f');
            String links = '[{"Home":"https://webapp4-dev.asu.edu/myasu/student"},' +
                '{"Finances":"https://webapp4-dev.asu.edu/myasu/student/finances"},' +
                '{"Service Center":"https://webapp4-dev.asu.edu/myasu/student/servicecenter"},' +
                '{"Campus Services":"https://webapp4-dev.asu.edu/myasu/student/campusservices"},' +
                '{"Profile":"https://webapp4-dev.asu.edu/myasu/student/profile"}]';
            setCookie(links);
            nav.init();
        }
        Test.stopTest();
        System.assertEquals(nav.linkList[0].name,'Home');
        System.assertEquals(nav.linkList[1].name,'Finances');
        System.assertEquals(nav.linkList[2].name,'Service Center');
        System.assertEquals(nav.linkList[3].name,'Campus Services');
        System.assertEquals(nav.linkList[4].name,'Profile');
    }
    
     @isTest
    private static void retrieveNullCookieFromPage() {
        setUp();
        Test.startTest();
        System.runAs(testUser) {
            sc = new ServiceCenter();
            nav = new NavLinks(sc);
            ApexPages.currentPage().getParameters().put('asuriteId', 'aesanch2');
            ApexPages.currentPage().getParameters().put('time', '1417811918');
            ApexPages.currentPage().getParameters().put('signature',
                'a8539563d36219e592c3376dae079d38887cc9af8374d74929bdf48bb655b93f');
            String links = '[]';
            setCookie(links);
            nav.init();
        }
        Test.stopTest();
        System.assertEquals(nav.linkList.isEmpty(), true);
    }
    
    @isTest 
    private static void testConstructors() {
        setUp();
        Test.startTest();
        System.runAs(testUser) {
            sc = new ServiceCenter();
            Navlinks scNav = new Navlinks(sc);
            ApexPages.StandardController stanContoller = new ApexPages.StandardController(testContact);
            NavLinks standardNav = new Navlinks(stanContoller);
        }
        Test.stopTest();
    }
}