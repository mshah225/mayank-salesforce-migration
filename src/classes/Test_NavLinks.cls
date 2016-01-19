@isTest
private class Test_NavLinks
{
    private static Contact testContact;
    private static NavLinks nav;
    private static Profile p;
    private static ServiceCenter sc;
    private static User testUser;

    private static void setUp()
    {
        p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'ASU Community'
        ];

        Term__c termAC = new Term__c();
        Date dT = Date.today().adddays(30);
        termAC.Session_A_C_Start_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
        termAC.Year__c = '2015';

        insert termAC;

        Term__c termB = new Term__c();
        dT = Date.today().adddays(40);
        termB.Session_B_Start_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
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
        testUser.ProfileId = p.Id;
        testUser.ContactId = testContact.Id;

        insert testUser;

        PageReference serviceCenter = Page.studentSC;
        Test.setCurrentPage(serviceCenter);
    }

    @isTest static void testInitNoParm()
    {
        setUp();
        Test.startTest();
        System.runAs(testUser)
        {
            sc = new ServiceCenter();
            nav = new Navlinks(sc);
            nav.init();
        }

        Test.stopTest();
    }

    @isTest static void testInitParm()
    {
        setUp();
        Test.startTest();
        System.runAs(testUser)
        {
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
            System.debug('merf linkList map ' + nav.linkList);
        }

        Test.stopTest();
    }

    @isTest static void testConstructors()
    {
        setUp();
        Test.startTest();
        System.runAs(testUser)
        {
            sc = new ServiceCenter();
            Navlinks scNav = new Navlinks(sc);
            Contact testContact2 = ContactService.createTestContact();
            ApexPages.StandardController stanContoller = new ApexPages.StandardController(testContact);
            NavLinks standardNav = new Navlinks(stanContoller);
        }

        Test.stopTest();
    }
}
