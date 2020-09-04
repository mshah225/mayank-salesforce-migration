@isTest
private class Test_ViewAllCasesController {
    private static User testUser;
    static void setup() {
        Term__c termAC = new Term__c();
        Date dTac = Date.today().adddays(365);
        Date dTb = Date.today().adddays(405);
        termAC.Session_A_C_Start_Date__c = date.newinstance(dTac.year(), dTac.month(), dTac.day());
        String ACYear = String.valueOf(dTac.year());
        termAC.Year__c = ACYear;
        insert termAC;

        Term__c termB = new Term__c();
        termB.Session_B_Start_Date__c = date.newinstance(dTb.year(), dTb.month(), dTb.day());
        String BYear = String.valueOf(dTb.year());
        termB.Year__c = BYear;
        insert termB;

        Contact testContact = ContactService.createTestContact();
        insert testContact;

        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        testUser = (User) userCreator.create(1)[0];
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
        testUser.ContactId = testContact.Id;
        insert testUser;

        List<Case> testCases = CaseService.createTestCases(10, testContact);

        // Set the first three testCases to closed
        Integer i = 0;
        for (Case c : testCases) {
            if (i < 3) {
                c.Status = 'New';
                i++;
            } else {
                c.Status = 'Closed: Resolved';
            }
        }

        insert testCases;
    }

    @isTest
    static void testGetAllClosedCases() {
        setup();
        PageReference viewAllCasesPage = Page.viewAllCases;
        Test.setCurrentPage(viewAllCasesPage);
        MyASUHelpController sc;
        ViewAllCasesController vac;
        List<Case> closedCases = null;

        Test.startTest();
        System.runAs(testUser) {
            vac = new ViewAllCasesController();

            closedCases = vac.getAllClosedCases();
        }
        Test.stopTest();

        System.assertEquals(7, closedCases.size());
    }
}
