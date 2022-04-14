@isTest
public with sharing class CivitasPersistenceControllerTest {
    @TestSetup
    private static void setup() {
        StudentTerm__c term = new StudentTerm__c(
            CurrTerm__c = '2201',
            FutureTerm__c = '2207',
            NextTerm__c = '2204',
            PrevTerm__c = '2197'
        );
        insert term;

        Term__c prevTerm = new Term__c( // fall (previous year)
            Session_A_C_Start_Date__c = Date.newInstance(2019, 8, 1),
            Year__c = '2020',
            PeopleSoft_Code__c = term.PrevTerm__c
        );
        Term__c springTerm = new Term__c( // spring
            Session_A_C_Start_Date__c = Date.newInstance(2020, 1, 1),
            Year__c = '2020',
            PeopleSoft_Code__c = term.CurrTerm__c
        );
        Term__c summerTerm = new Term__c( // fall
            Session_A_C_Start_Date__c = Date.newInstance(2020, 5, 1),
            Year__c = '2020',
            PeopleSoft_Code__c = term.NextTerm__c
        );
        Term__c fallTerm = new Term__c( // fall
            Session_A_C_Start_Date__c = Date.newInstance(2020, 8, 1),
            Year__c = '2020',
            PeopleSoft_Code__c = term.FutureTerm__c
        );
        Term__c futureTerm = new Term__c( // spring (next year)
            Session_A_C_Start_Date__c = Date.newInstance(2021, 1, 1),
            Year__c = '2020',
            PeopleSoft_Code__c = '2211'
        );
        insert new List<Term__c>{ prevTerm, springTerm, summerTerm, fallTerm, futureTerm };

        Contact c = new Contact(
            FirstName = 'CivitasPersistenceControllerTestContact',
            LastName = 'TestContact',
            EMPLID__c = '123456'
        );
        insert c;

        Persistence_Outlook__c prevPO = new Persistence_Outlook__c(
            Contact__c = c.Id,
            Current_Level_Descr__c = 'testLevelDesc02',
            Snap_Date__c = Date.newInstance(2020, 3, 1),
            Current_Flag__c = true,
            Career_Segment__c = 'U',
            Change_Direction__c = 1,
            Curr_Cont_Prediction_Level__c = 4,
            Prev_Cont_Prediction_Level__c = 3,
            Online_Segment__c = 'T',
            Prediction_STRM__c = springTerm.Id,
            Change_Flg__c = true,
            Change_Date__c = Date.newInstance(2020, 3, 2)
        );
        Persistence_Outlook__c po = new Persistence_Outlook__c(
            Contact__c = c.Id,
            Current_Level_Descr__c = 'testLevelDesc03',
            Snap_Date__c = Date.newInstance(2020, 4, 1),
            Current_Flag__c = true,
            Career_Segment__c = 'U',
            Change_Direction__c = 1,
            Curr_Cont_Prediction_Level__c = 4,
            Prev_Cont_Prediction_Level__c = 3,
            Online_Segment__c = 'T',
            Prediction_STRM__c = springTerm.Id,
            Change_Flg__c = true,
            Change_Date__c = Date.newInstance(2020, 4, 2)
        );
        insert new List<Persistence_Outlook__c>{ prevPO, po };
    }

    @isTest
    private static void testControllerSpring() {
        Persistence_Outlook__c oldestPO = [
            SELECT Contact__c, Snap_Date__c
            FROM Persistence_Outlook__c
            ORDER BY Snap_Date__c ASC
            LIMIT 1
        ];
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        PageReference pageRef = Page.StudentProfile;
        pageRef.getParameters().put('contactId', c.Id.to15());
        Test.setCurrentPage(pageRef);
        Test.startTest();
        CivitasPersistenceController controller = new CivitasPersistenceController();
        Test.stopTest();

        System.assertEquals(oldestPO.Snap_Date__c.daysBetween(System.today()) + 1, controller.civitasData.size()); // One for each day between oldest PO and today
        System.assertEquals(5, controller.civitasData[0].allMonths.size());
        System.assertEquals('Jan', controller.civitasData[0].allMonths[0]);
        System.assertEquals('Feb', controller.civitasData[0].allMonths[1]);
        System.assertEquals('Mar', controller.civitasData[0].allMonths[2]);
        System.assertEquals('Apr', controller.civitasData[0].allMonths[3]);
        System.assertEquals('May', controller.civitasData[0].allMonths[4]);
        System.assertEquals(oldestPO.Contact__c, controller.civitasData[0].contactId);
        System.assertEquals('Spring', controller.civitasData[0].termInfo);
    }

    @isTest
    private static void testControllerSummer() {
        Persistence_Outlook__c oldestPO = [
            SELECT Id, Contact__c, Snap_Date__c
            FROM Persistence_Outlook__c
            ORDER BY Snap_Date__c ASC
            LIMIT 1
        ];
        // Update for testing in Summer
        Persistence_Outlook__c newestPO = [SELECT Id FROM Persistence_Outlook__c ORDER BY Snap_Date__c DESC LIMIT 1];
        StudentTerm__c term = [SELECT Id FROM StudentTerm__c LIMIT 1];
        oldestPO.Snap_Date__c = Date.newInstance(2020, 6, 1);
        newestPO.Snap_Date__c = Date.newInstance(2020, 7, 1);
        update new List<Persistence_Outlook__c>{ oldestPO, newestPO };
        update new StudentTerm__c(
            Id = term.Id,
            CurrTerm__c = '2204',
            FutureTerm__c = '2211',
            NextTerm__c = '2207',
            PrevTerm__c = '2201'
        );

        Contact c = [SELECT Id FROM Contact LIMIT 1];

        PageReference pageRef = Page.StudentProfile;
        pageRef.getParameters().put('contactId', c.Id.to15());
        Test.setCurrentPage(pageRef);
        Test.startTest();
        CivitasPersistenceController controller = new CivitasPersistenceController();
        Test.stopTest();

        System.assertEquals(oldestPO.Snap_Date__c.daysBetween(System.today()) + 1, controller.civitasData.size()); // One for each day between oldest PO and today
        System.assertEquals(4, controller.civitasData[0].allMonths.size());
        System.assertEquals('May', controller.civitasData[0].allMonths[0]);
        System.assertEquals('Jun', controller.civitasData[0].allMonths[1]);
        System.assertEquals('Jul', controller.civitasData[0].allMonths[2]);
        System.assertEquals('Aug', controller.civitasData[0].allMonths[3]);
        System.assertEquals(oldestPO.Contact__c, controller.civitasData[0].contactId);
        System.assertEquals('Summer', controller.civitasData[0].termInfo);
    }

    @isTest
    private static void testControllerFall() {
        Persistence_Outlook__c oldestPO = [
            SELECT Id, Contact__c, Snap_Date__c
            FROM Persistence_Outlook__c
            ORDER BY Snap_Date__c ASC
            LIMIT 1
        ];
        // Update for testing in Fall
        Persistence_Outlook__c newestPO = [SELECT Id FROM Persistence_Outlook__c ORDER BY Snap_Date__c DESC LIMIT 1];
        StudentTerm__c term = [SELECT Id FROM StudentTerm__c LIMIT 1];
        oldestPO.Snap_Date__c = Date.newInstance(2020, 10, 1);
        newestPO.Snap_Date__c = Date.newInstance(2020, 11, 1);
        update new List<Persistence_Outlook__c>{ oldestPO, newestPO };
        update new StudentTerm__c(
            Id = term.Id,
            CurrTerm__c = '2207',
            FutureTerm__c = '2214',
            NextTerm__c = '2211',
            PrevTerm__c = '2204'
        );

        Contact c = [SELECT Id FROM Contact LIMIT 1];

        PageReference pageRef = Page.StudentProfile;
        pageRef.getParameters().put('contactId', c.Id.to15());
        Test.setCurrentPage(pageRef);
        Test.startTest();
        CivitasPersistenceController controller = new CivitasPersistenceController();
        Test.stopTest();

        System.assertEquals(oldestPO.Snap_Date__c.daysBetween(System.today()) + 1, controller.civitasData.size()); // One for each day between oldest PO and today
        System.assertEquals(6, controller.civitasData[0].allMonths.size());
        System.assertEquals('Aug', controller.civitasData[0].allMonths[0]);
        System.assertEquals('Sep', controller.civitasData[0].allMonths[1]);
        System.assertEquals('Oct', controller.civitasData[0].allMonths[2]);
        System.assertEquals('Nov', controller.civitasData[0].allMonths[3]);
        System.assertEquals('Dec', controller.civitasData[0].allMonths[4]);
        System.assertEquals('Jan', controller.civitasData[0].allMonths[5]);
        System.assertEquals(oldestPO.Contact__c, controller.civitasData[0].contactId);
        System.assertEquals('Fall', controller.civitasData[0].termInfo);
    }

    @isTest
    private static void testGetInfoByContactId() {
        Contact c = [SELECT Id, FirstName, LastName, EMPLID__c FROM Contact LIMIT 1];

        PageReference pageRef = Page.StudentProfile;
        pageRef.getParameters().put('contactId', c.Id.to15());
        Test.setCurrentPage(pageRef);
        Test.startTest();
        CivitasPersistenceController controller = new CivitasPersistenceController();
        Test.stopTest();

        System.assert(controller.getInfo.contains(c.FirstName), 'String should contain First name');
        System.assert(controller.getInfo.contains(c.LastName), 'String should contain Last name');
        System.assert(controller.getInfo.contains(c.Id.to15()), 'String should contain Contact Id');
    }

    @isTest
    private static void testGetInfoByEmplId() {
        Contact c = [SELECT Id, FirstName, LastName, EMPLID__c FROM Contact LIMIT 1];

        PageReference pageRef = Page.StudentProfile;
        pageRef.getParameters().put('contactId', c.EMPLID__c);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        CivitasPersistenceController controller = new CivitasPersistenceController();
        Test.stopTest();

        System.assert(controller.getInfo.contains(c.FirstName), 'String should contain First name');
        System.assert(controller.getInfo.contains(c.LastName), 'String should contain Last name');
        System.assert(controller.getInfo.contains(c.EMPLID__c), 'String should contain Emplid');
    }

    @isTest
    private static void testGetInfoErrorUnsetId() {
        Test.setCurrentPage(Page.StudentProfile);
        Test.startTest();
        CivitasPersistenceController controller = new CivitasPersistenceController();
        Test.stopTest();

        System.assertEquals(Label.EMPLIDMissing, controller.getInfo);
    }

    @isTest
    private static void testGetInfoErrorInvalidId() {
        Contact c = [SELECT Id, FirstName, LastName, EMPLID__c FROM Contact LIMIT 1];

        PageReference pageRef = Page.StudentProfile;
        pageRef.getParameters().put('contactId', 'INVALID_ID');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        CivitasPersistenceController controller = new CivitasPersistenceController();
        Test.stopTest();

        System.assertEquals(Label.EMPLIDMissing, controller.getInfo);
    }

    @isTest
    private static void testMonthToText() {
        System.assertEquals('Jan', CivitasPersistenceController.monthToText(1));
        System.assertEquals('Feb', CivitasPersistenceController.monthToText(2));
        System.assertEquals('Mar', CivitasPersistenceController.monthToText(3));
        System.assertEquals('Apr', CivitasPersistenceController.monthToText(4));
        System.assertEquals('May', CivitasPersistenceController.monthToText(5));
        System.assertEquals('Jun', CivitasPersistenceController.monthToText(6));
        System.assertEquals('Jul', CivitasPersistenceController.monthToText(7));
        System.assertEquals('Aug', CivitasPersistenceController.monthToText(8));
        System.assertEquals('Sep', CivitasPersistenceController.monthToText(9));
        System.assertEquals('Oct', CivitasPersistenceController.monthToText(10));
        System.assertEquals('Nov', CivitasPersistenceController.monthToText(11));
        System.assertEquals('Dec', CivitasPersistenceController.monthToText(12));
        System.assertEquals('Dec', CivitasPersistenceController.monthToText(0));
        System.assertEquals('Error', CivitasPersistenceController.monthToText(13));
    }
    @isTest
    private static void testCivitasWrapperConstructors() {
        Contact c = [SELECT Id, FirstName, LastName, EMPLID__c FROM Contact LIMIT 1];

        CivitasPersistenceController.CivitasWrapper simpleWrapper = new CivitasPersistenceController.CivitasWrapper(
            'TestName'
        );
        System.assertEquals('TestName', simpleWrapper.name);

        CivitasPersistenceController.CivitasWrapper complexWrapper = new CivitasPersistenceController.CivitasWrapper(
            Date.newInstance(1980, 8, 21),
            4,
            'testCivitasLevelDesc',
            true,
            'TestFirstName',
            'TestLastName',
            '123456',
            21,
            c.Id,
            1
        );
        System.assertEquals('8/21/1980', complexWrapper.snapDate.format());
        System.assertEquals('123456', complexWrapper.empl);
        System.assertEquals(4, complexWrapper.outlookLevel);
        System.assertEquals('TestFirstName TestLastName', complexWrapper.name);
        System.assertEquals(c.Id, complexWrapper.contactId);
        System.assertEquals(1, complexWrapper.direction);
        System.assertEquals(1980, complexWrapper.year);
        System.assertEquals(21, complexWrapper.day);
        System.assertEquals('Aug 21', complexWrapper.dayDate);
        System.assertEquals('8/21/1980', complexWrapper.fullDate);
        System.assertEquals('testCivitasLevelDesc', complexWrapper.levelDesc);
        System.assertEquals('Y', complexWrapper.flag);

        CivitasPersistenceController.CivitasWrapper contactWrapper = new CivitasPersistenceController.CivitasWrapper(
            c,
            Date.newInstance(1980, 8, 21),
            4,
            'testCivitasLevelDesc',
            false,
            21,
            1
        );
        System.assertEquals('8/21/1980', contactWrapper.snapDate.format());
        System.assertEquals(c.EmplId__c, contactWrapper.empl);
        System.assertEquals(4, contactWrapper.outlookLevel);
        System.assertEquals(c.FirstName + ' ' + c.LastName, contactWrapper.name);
        System.assertEquals(c.Id, contactWrapper.contactId);
        System.assertEquals(1, contactWrapper.direction);
        System.assertEquals(1980, contactWrapper.year);
        System.assertEquals(21, contactWrapper.day);
        System.assertEquals('Aug 21', contactWrapper.dayDate);
        System.assertEquals('8/21/1980', contactWrapper.fullDate);
        System.assertEquals('testCivitasLevelDesc', contactWrapper.levelDesc);
        System.assertEquals('N', contactWrapper.flag);
    }
}
