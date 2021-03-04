@isTest
public class CivitasControllerTest {
    @isTest
    public static void civitasWrapperFormat() {
        CivitasPersistenceController.civitasWrapper civitasWrapper = new CivitasPersistenceController.civitasWrapper(
            date.newInstance(2000, 12, 12),
            3,
            'High',
            true,
            'Test',
            'User',
            '1111111110',
            1,
            '0030W00003MVpD0',
            0
        );

        System.assertEquals(civitasWrapper.fullDate, '12/12/2000');
        System.assertEquals(civitasWrapper.name, 'Test User');
        System.assertEquals(civitasWrapper.outlookLevel, 3);

        civitasWrapper = new CivitasPersistenceController.civitasWrapper('TestTwo');
        System.assertEquals(civitasWrapper.name, 'TestTwo');
    }

    @isTest
    public static void getInformation() {
        Contact contactToTest = TestDataFactory.createContact('Test');
        contactToTest.EMPLID__c = '1001001000';
        insert contactToTest;

        List<Term__c> termstoAdd = new List<Term__c>();
        termstoAdd.add(
            new Term__c(
                Session_A_C_Start_Date__c = Date.today().addDays(-1),
                PeopleSoft_Code__c = '1111',
                Year__c = '' + Date.today().addDays(-1).year()
            )
        );
        termstoAdd.add(
            new Term__c(
                Session_A_C_Start_Date__c = Date.today(),
                PeopleSoft_Code__c = '2222',
                Year__c = '' + Date.today().year()
            )
        );
        termstoAdd.add(
            new Term__c(
                Session_A_C_Start_Date__c = Date.today().addDays(1),
                PeopleSoft_Code__c = '3333',
                Year__c = '' + Date.today().addDays(1).year()
            )
        );
        insert termsToAdd;

        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();
        currentTermData.PrevTerm__c = '1111';
        currentTermData.CurrTerm__c = '2222';
        currentTermData.NextTerm__c = '3333';
        upsert currentTermData;

        PageReference pageRef = new PageReference('/apex/StudentProfile?contactId=1001001000');
        Test.setCurrentPage(pageRef);
        CivitasPersistenceController cpc = new CivitasPersistenceController();
        String civitasInformation = cpc.getInfo;
        String result =
            'Name: ' +
            'Mister' +
            ' ' +
            'Test' +
            ' (' +
            '1001001000' +
            ') Persistence Level: No Data Available';
        System.assertEquals(civitasInformation, result);
    }

    @isTest
    public static void termData() {
        PageReference pageRef = new PageReference('/apex/StudentProfile?contactId=1001001000');
        Test.setCurrentPage(pageRef);

        List<Term__c> termstoAdd = new List<Term__c>();
        termstoAdd.add(
            new Term__c(
                Session_A_C_Start_Date__c = Date.today().addDays(-1),
                PeopleSoft_Code__c = '1111',
                Year__c = '' + Date.today().addDays(-1).year()
            )
        );
        termstoAdd.add(
            new Term__c(
                Session_A_C_Start_Date__c = Date.today(),
                PeopleSoft_Code__c = '2222',
                Year__c = '' + Date.today().year()
            )
        );
        termstoAdd.add(
            new Term__c(
                Session_A_C_Start_Date__c = Date.today().addDays(1),
                PeopleSoft_Code__c = '3333',
                Year__c = '' + Date.today().addDays(1).year()
            )
        );
        insert termsToAdd;

        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();
        currentTermData.PrevTerm__c = '1111';
        currentTermData.CurrTerm__c = '2222';
        currentTermData.NextTerm__c = '3333';
        upsert currentTermData;

        CivitasPersistenceController cpc = new CivitasPersistenceController();
    }
}
