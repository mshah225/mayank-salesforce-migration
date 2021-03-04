@isTest
private class ASUBrandControllerTest {
    private static Contact testContact;
    private static ASUBrandController nav;
    private static Profile asuCommunityProfile;
    private static MyASUHelpController sc;
    private static User testUser;

    private static void setUp() {
        asuCommunityProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community'];

        List<Term__c> lstTerms = new List<Term__c>();

        Term__c termAC = new Term__c();
        Date sessionAStartDate = Date.today().adddays(30);
        termAC.Session_A_C_Start_Date__c = sessionAStartDate;
        termAC.Year__c = '2015';

        Term__c termB = new Term__c();
        Date sessionBStartDate = Date.today().adddays(40);
        termB.Session_B_Start_Date__c = sessionBStartDate;
        termB.Year__c = '2015';

        lstTerms.add(termAC);
        lstTerms.add(termB);

        insert lstTerms;

        List<Contact> listOfTestContacts = (new ContactFactory.DefaultContact()).create();

        testContact = listOfTestContacts[0];

        insert testContact;

        List<User> listOfTestUsers = (new UserFactory.DefaultUser()).create();
        testUser = listOfTestUsers[0];
        testUser.ProfileId = asuCommunityProfile.Id;
        testUser.ContactId = testContact.Id;

        insert testUser;

        List<Live_Agent_Button__c> buttonsToInsert = new List<Live_Agent_Button__c>();
        buttonsToInsert.add(new Live_Agent_Button__c(Name = 'Finances_Live_Chat'));
        buttonsToInsert.add(new Live_Agent_Button__c(Name = 'ASU_Services_Live_Chat'));
        buttonsToInsert.add(new Live_Agent_Button__c(Name = 'Technical_Support_Live_Chat'));

        insert buttonsToInsert;

        PageReference myASUHelp = Page.studentSC;
        Test.setCurrentPage(myASUHelp);
    }

    private static void setCookie(String cookieData) {
        String nullPath = null;
        Integer sessionCookie = -1;
        Boolean insecureCookie = false;

        Cookie linksCookie = new Cookie('navbarlinks', cookieData, nullPath, sessionCookie, insecureCookie);
        ApexPages.currentPage().setCookies(new List<Cookie>{ linksCookie });
    }

    @isTest
    private static void testInitWithoutURLParameters() {
        setUp();
        Test.startTest();
        System.runAs(testUser) {
            sc = new MyASUHelpController();
            nav = new ASUBrandController(sc);
            nav.init();
        }
        Test.stopTest();
        //System.assertEquals(nav.menuLinks, null);
    }

    @isTest
    private static void retrieveCookieDataFromURL() {
        setUp();
        Test.startTest();
        System.runAs(testUser) {
            sc = new MyASUHelpController();
            nav = new ASUBrandController(sc);
            ApexPages.currentPage()
                .getParameters()
                .put(
                    'navbar',
                    '{"navbarLinks":[' +
                    '{"Home":"https://webapp4-dev.asu.edu/myasu/student"},' +
                    '{"Finances":"https://webapp4-dev.asu.edu/myasu/student/finances"},' +
                    '{"Service Center":"https://webapp4-dev.asu.edu/myasu/student/servicecenter"},' +
                    '{"Campus Services":"https://webapp4-dev.asu.edu/myasu/student/campusservices"},' +
                    '{"Profile":"https://webapp4-dev.asu.edu/myasu/student/profile"}' +
                    ']}'
                );
            nav.init();
        }
        Test.stopTest();
        System.assertEquals(nav.menuLinks[0].name, 'Home');
        System.assertEquals(nav.menuLinks[0].url, 'https://webapp4-dev.asu.edu/myasu/student');

        System.assertEquals(nav.menuLinks[1].name, 'Finances');
        System.assertEquals(nav.menuLinks[1].url, 'https://webapp4-dev.asu.edu/myasu/student/finances');

        System.assertEquals(nav.menuLinks[2].name, 'Service Center');
        System.assertEquals(nav.menuLinks[2].url, 'https://webapp4-dev.asu.edu/myasu/student/servicecenter');

        System.assertEquals(nav.menuLinks[3].name, 'Campus Services');
        System.assertEquals(nav.menuLinks[3].url, 'https://webapp4-dev.asu.edu/myasu/student/campusservices');

        System.assertEquals(nav.menuLinks[4].name, 'Profile');
        System.assertEquals(nav.menuLinks[4].url, 'https://webapp4-dev.asu.edu/myasu/student/profile');
    }

    @isTest
    private static void testNullCookieDataInURL() {
        setUp();
        Test.startTest();
        System.runAs(testUser) {
            sc = new MyASUHelpController();
            nav = new ASUBrandController(sc);
            ApexPages.currentPage().getParameters().put('navbar', '{"navbarLinks":[]}');
            nav.init();
        }
        Test.stopTest();
        System.assertEquals(nav.menuLinks.isEmpty(), true);
    }
}
