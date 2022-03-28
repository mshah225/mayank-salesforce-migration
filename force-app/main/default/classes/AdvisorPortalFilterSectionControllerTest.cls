@IsTest
private class AdvisorPortalFilterSectionControllerTest {
    private static final String testUserAlias = 'testUsr1';

    /**
     * Test data is setup in setup as follows
     *
     * 2 users
     * +-------------------+-------------+
     * |     FirstName     |  LastName   |
     * +-------------------+-------------+
     * | Test User Richard |  McKinnon   |
     * +-------------------+-------------+
     *
     *
     * 6 campuses
     * +---------------+-------------+
     * |     Name      | GradEnabled |
     * +---------------+-------------+
     * |     CAMP1     |    true     |
     * |     CAMP2     |    true     |
     * |     CAMP3     |    true     |
     * |     CAMP4     |    true     |
     * |     CAMP5     |    false    |
     * |     CAMP6     |    false    |
     * +---------------+-------------+
     *
     *
     * 20 contacts
     * +-------------+-------------+--------------------+-----------------+------------------+
     * |  FirstName  |  LastName   |  Persistence Date  |  Outlook Score  |  Outlook Change  |
     * +-------------+-------------+--------------------+-----------------+------------------+
     * |   Ryan      |  Castelli   |  TODAY - 7d        |        1        |         1        |
     * |   Chase     |  Burgess    |  TODAY - 4d        |        2        |         1        |
     * |   Morgan    |  Strauss    |  TODAY - 7d        |        3        |         1        |
     * |   Ben       |  Hellsig    |  TODAY - 4d        |        4        |         1        |
     * |   Marisa    |  Barilla    |  TODAY - 4d        |        5        |         0        |
     * |   Sarah     |  Durisek    |  TODAY - 1d        |        6        |         0        |
     * |   James     |  Bair       |  TODAY - 1d        |        6        |         0        |
     * |   Zachary   |  Noeller    |  TODAY - 1d        |        7        |         0        |
     * |   Morgan    |  Diegel     |  TODAY - 7d        |        7        |        -1        |
     * |   Aaron     |  Assaf      |  TODAY - 6d        |        8        |        -1        |
     * |   Simon     |  Kirksey    |  TODAY - 6d        |        9        |        -1        |
     * |   Sean      |  Phillips   |  TODAY - 7d        |        10       |        -1        |
     * |   Anna      |  Phillips   |                    |                 |                  |
     * |   Carl      |  Porter     |                    |                 |                  |
     * |   Devin     |  McCain     |                    |                 |                  |
     * |   Anya      |  Simms      |                    |                 |                  |
     * |   Corey     |  Nickolette |                    |                 |                  |
     * |   Maddy     |  Thomas     |                    |                 |                  |
     * |   Charlie   |  DorseyWard |                    |                 |                  |
     * |   Mitch     |  Keane      |                    |                 |                  |
     * +-------------+-------------+--------------------+-----------------+------------------+
     *
     *
     * 24 Student Program Plans, and other related objects
     * +----------------------+----------+----------+-----------+----------+---------+-------+-------------+-----------+-------------+------------+------------+-----------+------------------------+
     * |         Who          |  Career  |  Campus  |  AcadLvl  |  StuGrp  |  Major  |  Res  |  DegreeLvl  |  AcadPro  |  SchoolDep  |  AcadPlan  |  AdmitTrm  |  ReqTerm  |   SpecialPopulations   |
     * +----------------------+----------+----------+-----------+----------+---------+-------+-------------+-----------+-------------+------------+------------+-----------+------------------------+
     * |   Ryan Castelli      |   UGRAD  |  CAMP1   |  Freshman |  STGRP1  | COMPSCI |  NRES |             |           |             |            |            |           |                        |
     * |   Chase Burgess      |   UGRAD  |  CAMP1   |  Freshman |  STGRP2  | BUSNESS |  NRES |             |           |             |            |            |           |                        |
     * |   Morgan Strauss     |   UGRAD  |  CAMP2   |  Sophmore |  STGRP3  | AEROSPC |  RES  |             |           |             |            |            |           |                        |
     * |   Ben Hellsig        |   UGRAD  |  CAMP2   |  Freshman |  STGRP1  | BUSNESS |  RES  |             |           |             |            |            |           |                        |
     * |   Marisa Barilla     |   UGRAD  |  CAMP3   |  Sophmore |  STGRP2  | PREMED  |  NRES |             |           |             |            |            |           |                        |
     * |   Sarah Durisek      |   UGRAD  |  CAMP3   |  Junior   |  STGRP4  | PREMED  |  RES  |             |           |             |            |            |           |                        |
     * |   James Bair         |   UGRAD  |  CAMP4   |  Sophmore |  STGRP3  | TVFILM  |  INT  |             |           |             |            |            |           |                        |
     * |   ZacharY Noeller    |   UGRAD  |  CAMP4   |  Junior   |  STGRP2  | TVFILM  |  NRES |             |           |             |            |            |           |                        |
     * |   Morgan Diegel      |   UGRAD  |  CAMP5   |  Senior   |  STGRP1  | COMPSCI |  INT  |             |           |             |            |            |           |                        |
     * |   Aaron Assaf        |   UGRAD  |  CAMP5   |  Senior   |  STGRP1  | ELECENG |  INT  |             |           |             |            |            |           |                        |
     * |   Simon Kirksey      |   UGRAD  |  CAMP6   |  Junior   |  STGRP4  | PURMATH |  NRES |             |           |             |            |            |           |                        |
     * |   Sean Phillips      |   UGRAD  |  CAMP6   |  Graduate |  STGRP4  | TVFILM  |  RES  |             |           |             |            |            |           |                        |
     * |   Anna Phillips      |   GRAD   |  CAMP1   |           |          |         |       |   Masters   |  IRAAFUL  |             |  ELECENG   |    2161    |    2201   |  4+1 Accel, ApplGrd    |
     * |   Carl Porter        |   GRAD   |  CAMP1   |           |          |         |       |  Doctorate  |  IRAAFUL  |             |  CIVLENG   |    2201    |    2241   |  4+1 Intl Accel        |
     * |   Devin McCain       |   LAW    |  CAMP1   |           |          |         |       |   Masters   |  LAW      |             |  LAWYER    |    2191    |    2231   |                        |
     * |   Devin McCain       |   LAW    |  CAMP5   |           |          |         |       | Certificate |  LAW      |             |  JUDGE     |    2191    |    2231   |                        |
     * |   Anya Simms         |   GRAD   |  CAMP2   |           |          |         |       |  Doctorate  |  SCL_SOC  |             |  SOCWORK   |    2201    |    2241   |  ProvAd, ConCur        |
     * |   Anya Simms         |   GRAD   |  CAMP2   |           |          |         |       |  Doctorate  |  WP_CAR   |             |  BUSNESS   |    2204    |    2244   |  ProvAd, ConCur        |
     * |   Corey Nickolette   |   GRAD   |  CAMP2   |           |          |         |       |   Masters   |  CRONKITE |             |  TVFILM    |    2167    |    2207   |  Format, RegHold       |
     * |   Maddy Thomas       |   GRAD   |  CAMP3   |           |          |         |       | Non-Degree  |  IRAAFUL  |             |  COMPSCI   |    2144    |    2184   |  Mayo, Cintana, ConCur |
     * |   Maddy Thomas       |   GRAD   |  CAMP3   |           |          |         |       | Non-Degree  |  CRONKITE |             |  JOURNAL   |    2147    |    2187   |  Mayo, Cintana, ConCur |
     * |   Maddy Thomas       |   GRAD   |  CAMP4   |           |          |         |       | Non-Degree  |  PREMED   |             |  PREMED    |    2141    |    2181   |  Mayo, Cintana, ConCur |
     * |   Charlie DorseyWard |   GRAD   |  CAMP4   |           |          |         |       |   Masters   |  WP_CAR   |             |  BUSNESS   |    2191    |    2231   |  Veteran, Cintana      |
     * |   Mitch Keane        |   GRAD   |  CAMP4   |           |          |         |       | Certificate |  CRONKITE |             |  TVFILM    |    2107    |    2147   |  Veteran, ApplGrd      |
     * +----------------------+----------+----------+-----------+----------+---------+-------+-------------+-----------+-------------+------------+------------+-----------+------------------------+
     *
     *
     * We setup case categories of "Watchlist Cases"
     * +------------------------+------------------------+
     * |          Name          |         Parent         |
     * +------------------------+------------------------+
     * |  ASU Advisor Outreach  |                        |
     * |  Watchlist             |  ASU Advisor Outreach  |
     * +------------------------+------------------------+
     *
     * and 4 other case catgories
     * +---------+
     * |   Name  |
     * +---------+
     * |  CAT-1  |
     * |  CAT-2  |
     * |  CAT-3  |
     * |  CAT-4  |
     * +---------+
     *
     *
     * 7 cases
     * +----------------------+-------------+----------------------------------+----------+------------------+------------+
     * |         Who          |  Subject    |                Status            |  Owner   |  Follow Up Date  |  Category  |
     * +----------------------+-------------+----------------------------------+----------+------------------+------------+
     * |  Ryan Castelli       |  New car    |  New                             | McKinnon |  TODAY - 5d      |  CAT-1     |
     * |  Ryan Castelli       |  Found bug  |  Busy Signal                     | McKinnon |  TODAY - 9d      |  CAT-1     |
     * |  Ryan Castelli       |  Send help  |  Customer Replied                | McKinnon |  TODAY - 10d     |  CAT-2     |
     * |  Ryan Castelli       |  Ant man    |  Email Sent                      | McKinnon |  TODAY - 2d      |  CAT-2     |
     * |  Maddy Thomas        |  Enrollment |  Outreach Required               | McKinnon |  TODAY - 2d      |  CAT-3     |
     * |  Corey Nickolette    |  Enrollment |  Outreach Required - Transferred | McKinnon |  TODAY - 1d      |  CAT-3     |
     * |  Anna Phillips       |  Bee girl   |  Email Sent                      | McKinnon |  TODAY - 1d      |  CAT-4     |
     * +----------------------+-------------+----------------------------------+----------+------------------+------------+
     */
    @TestSetup
    public static void setup() {
        createAdvisorStudent(createAdvisorPod());

        // Common date obejcts
        Date tMinus1d = System.today().addDays(-1);
        Date tMinus2d = System.today().addDays(-2);
        Date tMinus3d = System.today().addDays(-3);
        Date tMinus4d = System.today().addDays(-4);
        Date tMinus5d = System.today().addDays(-5);
        Date tMinus6d = System.today().addDays(-6);
        Date tMinus7d = System.today().addDays(-7);
        Date tMinus8d = System.today().addDays(-8);
        Date tMinus9d = System.today().addDays(-9);
        Date tMinus10d = System.today().addDays(-10);
        Date tPlus1d = System.today().addDays(1);
        Date tPlus2d = System.today().addDays(2);
        Date tPlus3d = System.today().addDays(3);
        Date tPlus4d = System.today().addDays(4);
        Date tPlus5d = System.today().addDays(5);
        Date tPlus6d = System.today().addDays(6);
        Date tPlus7d = System.today().addDays(7);
        Date tPlus8d = System.today().addDays(8);
        Date tPlus9d = System.today().addDays(9);
        Date tPlus10d = System.today().addDays(10);

        // Test user
        User testUser = new User(
            FirstName = 'Test User Richard',
            LastName = 'McKinnon',
            Email = 'richard.mckinnon@test.asu.edu',
            Username = 'richard.mckinnon@test.asu.edu',
            Alias = testUserAlias,
            ProfileId = RecordIdHelper.getProfileId('ASU Read Only'),
            TimeZoneSidKey = 'America/Phoenix',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = null
        );
        insert testUser;

        // // Make a test group
        // Group testGroup = new Group(Name = 'TestGroupName1', Type = 'Queue');

        // // And make the queues
        // List<QueueSobject> testQueues = new List<QueueSobject>();
        // testQueues.add(new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Success_Pod__c'));
        // testQueues.add(new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Case'));
        // System.runAs(new User(Id = UserInfo.getUserId())) {
        //     insert testQueues;
        // }

        // and their success pod
        Success_Pod__c testSuccessPod = new Success_Pod__c(
            OwnerId = testUser.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor'),
            Primary_Email__c = testUser.Email,
            Name = 'Test Pod ',
            Committee__c = 'tp'
        );
        insert testSuccessPod;

        // And 6 locations
        Location__c testCampus1 = newLocation('camp1', '0011221101', true);
        Location__c testCampus2 = newLocation('camp2', '0011221102', true);
        Location__c testCampus3 = newLocation('camp3', '0011221103', true);
        Location__c testCampus4 = newLocation('camp4', '0011221104', true);
        Location__c testCampus5 = newLocation('camp5', '0011221105', false);
        Location__c testCampus6 = newLocation('camp6', '0011221106', false);
        insert new List<Location__c>{ testCampus1, testCampus2, testCampus3, testCampus4, testCampus5, testCampus6 };

        // 16 terms
        List<Term__c> testTerms = new List<Term__c>();
        Term__c term2107 = newTerm('2107');
        testTerms.add(term2107);
        Term__c term2141 = newTerm('2141');
        testTerms.add(term2141);
        Term__c term2144 = newTerm('2144');
        testTerms.add(term2144);
        Term__c term2147 = newTerm('2147');
        testTerms.add(term2147);
        Term__c term2161 = newTerm('2161');
        testTerms.add(term2161);
        Term__c term2167 = newTerm('2167');
        testTerms.add(term2167);
        Term__c term2181 = newTerm('2181');
        testTerms.add(term2181);
        Term__c term2184 = newTerm('2184');
        testTerms.add(term2184);
        Term__c term2187 = newTerm('2187');
        testTerms.add(term2187);
        Term__c term2191 = newTerm('2191');
        testTerms.add(term2191);
        Term__c term2201 = newTerm('2201');
        testTerms.add(term2201);
        Term__c term2204 = newTerm('2204');
        testTerms.add(term2204);
        Term__c term2207 = newTerm('2207');
        testTerms.add(term2207);
        Term__c term2231 = newTerm('2231');
        testTerms.add(term2231);
        Term__c term2241 = newTerm('2241');
        testTerms.add(term2241);
        Term__c term2244 = newTerm('2244');
        testTerms.add(term2244);
        Term__c term2844 = newTerm('2844');
        testTerms.add(term2844);
        insert testTerms;

        // Lots of contacts
        List<Contact> testContacts = new List<Contact>();
        Contact ryanCastelli = newContact('Ryan', 'Castelli');
        testContacts.add(ryanCastelli);
        Contact chaseBurgess = newContact('Chase', 'Burgess');
        testContacts.add(chaseBurgess);
        Contact morganStrauss = newContact('Morgan', 'Strauss');
        testContacts.add(morganStrauss);
        Contact benHellsig = newContact('Ben', 'Hellsig');
        testContacts.add(benHellsig);
        Contact marisaBarilla = newContact('Marisa', 'Barilla');
        testContacts.add(marisaBarilla);
        Contact sarahDurisek = newContact('Sarah', 'Durisek');
        testContacts.add(sarahDurisek);
        Contact jamesBair = newContact('James', 'Bair');
        testContacts.add(jamesBair);
        Contact zacharyNoeller = newContact('Zachary', 'Noeller');
        testContacts.add(zacharyNoeller);
        Contact morganDiegel = newContact('Morgan', 'Diegel');
        testContacts.add(morganDiegel);
        Contact aaronAssaf = newContact('Aaron', 'Assaf');
        testContacts.add(aaronAssaf);
        Contact simonKirksey = newContact('Simon', 'Kirksey');
        testContacts.add(simonKirksey);
        Contact seanPhillips = newContact('Sean', 'Phillips');
        testContacts.add(seanPhillips);
        Contact annaPhillips = newContact('Anna', 'Phillips');
        testContacts.add(annaPhillips);
        Contact carlPorter = newContact('Carl', 'Porter');
        testContacts.add(carlPorter);
        Contact devinMcCain = newContact('Devin', 'McCain');
        testContacts.add(devinMcCain);
        Contact anyaSimms = newContact('Anya', 'Simms');
        testContacts.add(anyaSimms);
        Contact coreyNickolette = newContact('Corey', 'Nickolette');
        testContacts.add(coreyNickolette);
        Contact maddyThomas = newContact('Maddy', 'Thomas');
        testContacts.add(maddyThomas);
        Contact charlieDorseyWard = newContact('Charlie', 'DorseyWard');
        testContacts.add(charlieDorseyWard);
        Contact mitchKeane = newContact('Mitch', 'Keane');
        testContacts.add(mitchKeane);
        insert testContacts;

        // Add success students for all of them
        List<Success_Student__c> testSuccessStudents = new List<Success_Student__c>();
        Success_Student__c ryanCastelliStudent = newSuccessStudent(ryanCastelli, testSuccessPod);
        testSuccessStudents.add(ryanCastelliStudent);
        Success_Student__c chaseBurgessStudent = newSuccessStudent(chaseBurgess, testSuccessPod);
        testSuccessStudents.add(chaseBurgessStudent);
        Success_Student__c morganStraussStudent = newSuccessStudent(morganStrauss, testSuccessPod);
        testSuccessStudents.add(morganStraussStudent);
        Success_Student__c benHellsigStudent = newSuccessStudent(benHellsig, testSuccessPod);
        testSuccessStudents.add(benHellsigStudent);
        Success_Student__c marisaBarillaStudent = newSuccessStudent(marisaBarilla, testSuccessPod);
        testSuccessStudents.add(marisaBarillaStudent);
        Success_Student__c sarahDurisekStudent = newSuccessStudent(sarahDurisek, testSuccessPod);
        testSuccessStudents.add(sarahDurisekStudent);
        Success_Student__c jamesBairStudent = newSuccessStudent(jamesBair, testSuccessPod);
        testSuccessStudents.add(jamesBairStudent);
        Success_Student__c zacharyNoellerStudent = newSuccessStudent(zacharyNoeller, testSuccessPod);
        testSuccessStudents.add(zacharyNoellerStudent);
        Success_Student__c morganDiegelStudent = newSuccessStudent(morganDiegel, testSuccessPod);
        testSuccessStudents.add(morganDiegelStudent);
        Success_Student__c aaronAssafStudent = newSuccessStudent(aaronAssaf, testSuccessPod);
        testSuccessStudents.add(aaronAssafStudent);
        Success_Student__c simonKirkseyStudent = newSuccessStudent(simonKirksey, testSuccessPod);
        testSuccessStudents.add(simonKirkseyStudent);
        Success_Student__c seanPhillipsStudent = newSuccessStudent(seanPhillips, testSuccessPod);
        testSuccessStudents.add(seanPhillipsStudent);
        Success_Student__c annaPhillipsStudent = newSuccessStudent(annaPhillips, testSuccessPod);
        testSuccessStudents.add(annaPhillipsStudent);
        Success_Student__c carlPorterStudent = newSuccessStudent(carlPorter, testSuccessPod);
        testSuccessStudents.add(carlPorterStudent);
        Success_Student__c devinMcCainStudent = newSuccessStudent(devinMcCain, testSuccessPod);
        testSuccessStudents.add(devinMcCainStudent);
        Success_Student__c anyaSimmsStudent = newSuccessStudent(anyaSimms, testSuccessPod);
        testSuccessStudents.add(anyaSimmsStudent);
        Success_Student__c coreyNickoletteStudent = newSuccessStudent(coreyNickolette, testSuccessPod);
        testSuccessStudents.add(coreyNickoletteStudent);
        Success_Student__c maddyThomasStudent = newSuccessStudent(maddyThomas, testSuccessPod);
        testSuccessStudents.add(maddyThomasStudent);
        Success_Student__c charlieDorseyWardStudent = newSuccessStudent(charlieDorseyWard, testSuccessPod);
        testSuccessStudents.add(charlieDorseyWardStudent);
        Success_Student__c mitchKeaneStudent = newSuccessStudent(mitchKeane, testSuccessPod);
        testSuccessStudents.add(mitchKeaneStudent);
        insert testSuccessStudents;

        // And make Persistence Outlooks for those that need persistence data
        List<Persistence_Outlook__c> testPersistenceOutlooks = new List<Persistence_Outlook__c>();
        Persistence_Outlook__c ryanCastelliPersistenceOutlook = newPersistenceOutlook(ryanCastelli, tMinus7d, 1, 1);
        testPersistenceOutlooks.add(ryanCastelliPersistenceOutlook);
        Persistence_Outlook__c chaseBurgessPersistenceOutlook = newPersistenceOutlook(chaseBurgess, tMinus4d, 2, 1);
        testPersistenceOutlooks.add(chaseBurgessPersistenceOutlook);
        Persistence_Outlook__c morganStraussPersistenceOutlook = newPersistenceOutlook(morganStrauss, tMinus7d, 3, 1);
        testPersistenceOutlooks.add(morganStraussPersistenceOutlook);
        Persistence_Outlook__c benHellsigPersistenceOutlook = newPersistenceOutlook(benHellsig, tMinus4d, 4, 1);
        testPersistenceOutlooks.add(benHellsigPersistenceOutlook);
        Persistence_Outlook__c marisaBarillaPersistenceOutlook = newPersistenceOutlook(marisaBarilla, tMinus4d, 5, 0);
        testPersistenceOutlooks.add(marisaBarillaPersistenceOutlook);
        Persistence_Outlook__c sarahDurisekPersistenceOutlook = newPersistenceOutlook(sarahDurisek, tMinus1d, 6, 0);
        testPersistenceOutlooks.add(sarahDurisekPersistenceOutlook);
        Persistence_Outlook__c jamesBairPersistenceOutlook = newPersistenceOutlook(jamesBair, tMinus1d, 6, 0);
        testPersistenceOutlooks.add(jamesBairPersistenceOutlook);
        Persistence_Outlook__c zacharyNoellerPersistenceOutlook = newPersistenceOutlook(zacharyNoeller, tMinus1d, 7, 0);
        testPersistenceOutlooks.add(zacharyNoellerPersistenceOutlook);
        Persistence_Outlook__c morganDiegelPersistenceOutlook = newPersistenceOutlook(morganDiegel, tMinus7d, 7, 1);
        testPersistenceOutlooks.add(morganDiegelPersistenceOutlook);
        Persistence_Outlook__c aaronAssafPersistenceOutlook = newPersistenceOutlook(aaronAssaf, tMinus6d, 8, -1);
        testPersistenceOutlooks.add(aaronAssafPersistenceOutlook);
        Persistence_Outlook__c simonKirkseyPersistenceOutlook = newPersistenceOutlook(simonKirksey, tMinus6d, 9, -1);
        testPersistenceOutlooks.add(simonKirkseyPersistenceOutlook);
        Persistence_Outlook__c seanPhillipsPersistenceOutlook = newPersistenceOutlook(seanPhillips, tMinus7d, 10, -1);
        testPersistenceOutlooks.add(seanPhillipsPersistenceOutlook);
        insert testPersistenceOutlooks;

        // And program plans for each
        List<Student_Program_Plan__c> testStudentProgramPlans = new List<Student_Program_Plan__c>();
        Student_Program_Plan__c ryanCastelliProgramPlan = new Student_Program_Plan__c(
            Contact__c = ryanCastelli.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus1.Id,
            Cohort__c = 'freshman',
            Plan_Code__c = 'COMPSCI',
            Residency__c = 'Non-Resident'
        );
        testStudentProgramPlans.add(ryanCastelliProgramPlan);
        Student_Program_Plan__c chaseBurgessProgramPlan = new Student_Program_Plan__c(
            Contact__c = chaseBurgess.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus1.Id,
            Cohort__c = 'freshman',
            Plan_Code__c = 'BUSNESS',
            Residency__c = 'Non-Resident'
        );
        testStudentProgramPlans.add(chaseBurgessProgramPlan);
        Student_Program_Plan__c morganStraussProgramPlan = new Student_Program_Plan__c(
            Contact__c = morganStrauss.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus2.Id,
            Cohort__c = 'sophmore',
            Plan_Code__c = 'AEROSPC',
            Residency__c = 'Resident'
        );
        testStudentProgramPlans.add(morganStraussProgramPlan);
        Student_Program_Plan__c benHellsigProgramPlan = new Student_Program_Plan__c(
            Contact__c = benHellsig.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus2.Id,
            Cohort__c = 'freshman',
            Plan_Code__c = 'BUSNESS',
            Residency__c = 'Non-Resident'
        );
        testStudentProgramPlans.add(benHellsigProgramPlan);
        Student_Program_Plan__c marisaBarillaProgramPlan = new Student_Program_Plan__c(
            Contact__c = marisaBarilla.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus3.Id,
            Cohort__c = 'sophmore',
            Plan_Code__c = 'PREMED',
            Residency__c = 'Non-Resident'
        );
        testStudentProgramPlans.add(marisaBarillaProgramPlan);
        Student_Program_Plan__c sarahDurisekProgramPlan = new Student_Program_Plan__c(
            Contact__c = sarahDurisek.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus3.Id,
            Cohort__c = 'junior',
            Plan_Code__c = 'PREMED',
            Residency__c = 'Resident'
        );
        testStudentProgramPlans.add(sarahDurisekProgramPlan);
        Student_Program_Plan__c jamesBairProgramPlan = new Student_Program_Plan__c(
            Contact__c = jamesBair.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus4.Id,
            Cohort__c = 'sophmore',
            Plan_Code__c = 'TVFILM',
            Residency__c = 'International'
        );
        testStudentProgramPlans.add(jamesBairProgramPlan);
        Student_Program_Plan__c zacharyNoellerProgramPlan = new Student_Program_Plan__c(
            Contact__c = zacharyNoeller.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus4.Id,
            Cohort__c = 'junior',
            Plan_Code__c = 'TVFILM',
            Residency__c = 'Non-Resident'
        );
        testStudentProgramPlans.add(zacharyNoellerProgramPlan);
        Student_Program_Plan__c morganDiegelProgramPlan = new Student_Program_Plan__c(
            Contact__c = morganDiegel.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus5.Id,
            Cohort__c = 'senior',
            Plan_Code__c = 'COMPSCI',
            Residency__c = 'International'
        );
        testStudentProgramPlans.add(morganDiegelProgramPlan);
        Student_Program_Plan__c aaronAssafProgramPlan = new Student_Program_Plan__c(
            Contact__c = aaronAssaf.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus5.Id,
            Cohort__c = 'senior',
            Plan_Code__c = 'ELECENG',
            Residency__c = 'International'
        );
        testStudentProgramPlans.add(aaronAssafProgramPlan);
        Student_Program_Plan__c simonKirkseyProgramPlan = new Student_Program_Plan__c(
            Contact__c = simonKirksey.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus6.Id,
            Cohort__c = 'junior',
            Plan_Code__c = 'PURMATH',
            Residency__c = 'Non-Resident'
        );
        testStudentProgramPlans.add(simonKirkseyProgramPlan);
        Student_Program_Plan__c seanPhillipsProgramPlan = new Student_Program_Plan__c(
            Contact__c = seanPhillips.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus6.Id,
            Cohort__c = 'graduate',
            Plan_Code__c = 'TVFILM',
            Residency__c = 'Resident'
        );
        testStudentProgramPlans.add(seanPhillipsProgramPlan);
        Student_Program_Plan__c annaPhillipsProgramPlan = new Student_Program_Plan__c(
            Contact__c = annaPhillips.Id,
            Career__c = 'Graduate',
            Campus__c = testCampus1.Id,
            Plan_Type_Text__c = 'MAJ',
            Education_Level__c = '17',
            Program_Code__c = 'IRAAFUL',
            Plan_Code__c = 'ELECENG',
            Admit_Term__c = term2161.Id,
            Requirement_Term__c = '2201'
        );
        testStudentProgramPlans.add(annaPhillipsProgramPlan);
        Student_Program_Plan__c carlPorterProgramPlan = new Student_Program_Plan__c(
            Contact__c = carlPorter.Id,
            Career__c = 'Graduate',
            Campus__c = testCampus1.Id,
            Plan_Type_Text__c = 'MAJ',
            Education_Level__c = '21',
            Program_Code__c = 'IRAAFUL',
            Plan_Code__c = 'CIVLENG',
            Admit_Term__c = term2201.Id,
            Requirement_Term__c = '2241'
        );
        testStudentProgramPlans.add(carlPorterProgramPlan);
        Student_Program_Plan__c devinMcCainProgramPlan1 = new Student_Program_Plan__c(
            Contact__c = devinMcCain.Id,
            Career__c = 'Law',
            Campus__c = testCampus1.Id,
            Plan_Type_Text__c = 'MAJ',
            Education_Level__c = '17',
            Program_Code__c = 'LAW',
            Plan_Code__c = 'LAWYER',
            Admit_Term__c = term2191.Id,
            Requirement_Term__c = '2231'
        );
        testStudentProgramPlans.add(devinMcCainProgramPlan1);
        Student_Program_Plan__c devinMcCainProgramPlan2 = new Student_Program_Plan__c(
            Contact__c = devinMcCain.Id,
            Career__c = 'Law',
            Campus__c = testCampus5.Id,
            Plan_Type_Text__c = 'CER',
            Program_Code__c = 'LAW',
            Plan_Code__c = 'JUDGE',
            Admit_Term__c = term2191.Id,
            Requirement_Term__c = '2231'
        );
        testStudentProgramPlans.add(devinMcCainProgramPlan2);
        Student_Program_Plan__c anyaSimmsProgramPlan1 = new Student_Program_Plan__c(
            Contact__c = anyaSimms.Id,
            Career__c = 'Graduate',
            Campus__c = testCampus2.Id,
            Plan_Type_Text__c = 'MAJ',
            Education_Level__c = '21',
            Program_Code__c = 'SCL_SOC',
            Plan_Code__c = 'SOCWORK',
            Admit_Term__c = term2201.Id,
            Requirement_Term__c = '2241'
        );
        testStudentProgramPlans.add(anyaSimmsProgramPlan1);
        Student_Program_Plan__c anyaSimmsProgramPlan2 = new Student_Program_Plan__c(
            Contact__c = anyaSimms.Id,
            Career__c = 'Graduate',
            Campus__c = testCampus2.Id,
            Plan_Type_Text__c = 'MAJ',
            Education_Level__c = '21',
            Program_Code__c = 'WP_CAR',
            Plan_Code__c = 'BUSNESS',
            Admit_Term__c = term2204.Id,
            Requirement_Term__c = '2244'
        );
        testStudentProgramPlans.add(anyaSimmsProgramPlan2);
        Student_Program_Plan__c coreyNickoletteProgramPlan = new Student_Program_Plan__c(
            Contact__c = coreyNickolette.Id,
            Career__c = 'Graduate',
            Campus__c = testCampus2.Id,
            Plan_Type_Text__c = 'MAJ',
            Education_Level__c = '17',
            Program_Code__c = 'CRONKITE',
            Plan_Code__c = 'TVFILM',
            Admit_Term__c = term2167.Id,
            Requirement_Term__c = '2207'
        );
        testStudentProgramPlans.add(coreyNickoletteProgramPlan);
        Student_Program_Plan__c maddyThomasProgramPlan1 = new Student_Program_Plan__c(
            Contact__c = maddyThomas.Id,
            Career__c = 'Graduate',
            Campus__c = testCampus3.Id,
            Plan_Type_Text__c = 'NDG',
            Program_Code__c = 'IRAAFUL',
            Plan_Code__c = 'COMPSCI',
            Admit_Term__c = term2144.Id,
            Requirement_Term__c = '2184'
        );
        testStudentProgramPlans.add(maddyThomasProgramPlan1);
        Student_Program_Plan__c maddyThomasProgramPlan2 = new Student_Program_Plan__c(
            Contact__c = maddyThomas.Id,
            Career__c = 'Graduate',
            Campus__c = testCampus3.Id,
            Plan_Type_Text__c = 'NDG',
            Program_Code__c = 'CRONKITE',
            Plan_Code__c = 'JOURNAL',
            Admit_Term__c = term2147.Id,
            Requirement_Term__c = '2187'
        );
        testStudentProgramPlans.add(maddyThomasProgramPlan2);
        Student_Program_Plan__c maddyThomasProgramPlan3 = new Student_Program_Plan__c(
            Contact__c = maddyThomas.Id,
            Career__c = 'Graduate',
            Campus__c = testCampus4.Id,
            Plan_Type_Text__c = 'NDG',
            Program_Code__c = 'PREMED',
            Plan_Code__c = 'PREMED',
            Admit_Term__c = term2141.Id,
            Requirement_Term__c = '2181'
        );
        testStudentProgramPlans.add(maddyThomasProgramPlan3);
        Student_Program_Plan__c charlieDorseyWardProgramPlan = new Student_Program_Plan__c(
            Contact__c = charlieDorseyWard.Id,
            Career__c = 'Graduate',
            Campus__c = testCampus4.Id,
            Plan_Type_Text__c = 'MAJ',
            Education_Level__c = '17',
            Program_Code__c = 'WP_CAR',
            Plan_Code__c = 'BUSNESS',
            Admit_Term__c = term2191.Id,
            Requirement_Term__c = '2231'
        );
        testStudentProgramPlans.add(charlieDorseyWardProgramPlan);
        Student_Program_Plan__c mitchKeaneProgramPlan = new Student_Program_Plan__c(
            Contact__c = mitchKeane.Id,
            Career__c = 'Graduate',
            Campus__c = testCampus4.Id,
            Plan_Type_Text__c = 'CER',
            Program_Code__c = 'CRONKITE',
            Plan_Code__c = 'TVFILM',
            Admit_Term__c = term2107.Id,
            Requirement_Term__c = '2147',
            Degree_Chkout_Stat_Code__c = 'GD', // applied to graduate code
            Status__c = 'Active in Program',
            Effective_Date__c = tMinus3d
        );
        testStudentProgramPlans.add(mitchKeaneProgramPlan);
        insert testStudentProgramPlans;

        // And let's add their student groups
        List<Student_Group__c> testStudentGroups = new List<Student_Group__c>();
        Student_Group__c ryanCastelliStudentGroup = newStudentGroup(ryanCastelli.Id, 'STGRP1');
        testStudentGroups.add(ryanCastelliStudentGroup);
        Student_Group__c chaseBurgessStudentGroup = newStudentGroup(chaseBurgess.Id, 'STGRP2');
        testStudentGroups.add(chaseBurgessStudentGroup);
        Student_Group__c morganStraussStudentGroup = newStudentGroup(morganStrauss.Id, 'STGRP3');
        testStudentGroups.add(morganStraussStudentGroup);
        Student_Group__c benHellsigStudentGroup = newStudentGroup(benHellsig.Id, 'STGRP1');
        testStudentGroups.add(benHellsigStudentGroup);
        Student_Group__c marisaBarillaStudentGroup = newStudentGroup(marisaBarilla.Id, 'STGRP2');
        testStudentGroups.add(marisaBarillaStudentGroup);
        Student_Group__c sarahDurisekStudentGroup = newStudentGroup(sarahDurisek.Id, 'STGRP4');
        testStudentGroups.add(sarahDurisekStudentGroup);
        Student_Group__c jamesBairStudentGroup = newStudentGroup(jamesBair.Id, 'STGRP3');
        testStudentGroups.add(jamesBairStudentGroup);
        Student_Group__c zacharyNoellerStudentGroup = newStudentGroup(zacharyNoeller.Id, 'STGRP2');
        testStudentGroups.add(zacharyNoellerStudentGroup);
        Student_Group__c morganDiegelStudentGroup = newStudentGroup(morganDiegel.Id, 'STGRP1');
        testStudentGroups.add(morganDiegelStudentGroup);
        Student_Group__c aaronAssafStudentGroup = newStudentGroup(aaronAssaf.Id, 'STGRP1');
        testStudentGroups.add(aaronAssafStudentGroup);
        Student_Group__c simonKirkseyStudentGroup = newStudentGroup(simonKirksey.Id, 'STGRP4');
        testStudentGroups.add(simonKirkseyStudentGroup);
        Student_Group__c seanPhillipsStudentGroup = newStudentGroup(seanPhillips.Id, 'STGRP4');
        testStudentGroups.add(seanPhillipsStudentGroup);
        // and add for grad students' special populations
        Student_Group__c annaPhillipsStudentGroup = newStudentGroup(annaPhillips.Id, 'GRAI');
        testStudentGroups.add(annaPhillipsStudentGroup);
        Student_Group__c carlPorterStudentGroup = newStudentGroup(carlPorter.Id, 'ADIP');
        testStudentGroups.add(carlPorterStudentGroup);
        Student_Group__c maddyThomasStudentGroup1 = newStudentGroup(maddyThomas.Id, 'ADAM');
        testStudentGroups.add(maddyThomasStudentGroup1);
        Student_Group__c maddyThomasStudentGroup2 = newStudentGroup(maddyThomas.Id, 'SRKY');
        testStudentGroups.add(maddyThomasStudentGroup2);
        Student_Group__c charlieDorseyWardStudentGroup1 = newStudentGroup(charlieDorseyWard.Id, 'SR1B');
        testStudentGroups.add(charlieDorseyWardStudentGroup1);
        Student_Group__c charlieDorseyWardStudentGroup2 = newStudentGroup(charlieDorseyWard.Id, 'SRSA');
        testStudentGroups.add(charlieDorseyWardStudentGroup2);
        Student_Group__c mitchKeaneStudentGroup = newStudentGroup(mitchKeane.Id, 'SR1D');
        testStudentGroups.add(mitchKeaneStudentGroup);
        insert testStudentGroups;

        // service indicators for provisional admits and registration holds
        List<Service_Indicator__c> testServiceIndicators = new List<Service_Indicator__c>();
        Service_Indicator__c anyaSimmsServiceIndicator = new Service_Indicator__c(
            SI_Contact__c = anyaSimms.Id,
            SI_Code__c = 'AD4',
            SI_Reason__c = 'PROV',
            SI_Positive_Service_Indicator__c = true,
            SI_Start_Term__c = term2107.Id,
            SI_End_Term__c = term2844.Id
        );
        testServiceIndicators.add(anyaSimmsServiceIndicator);
        Service_Indicator__c coreyNickoletteServiceIndicator = new Service_Indicator__c(
            SI_Contact__c = coreyNickolette.Id,
            Enrollment_Impact__c = true,
            SI_Positive_Service_Indicator__c = false,
            SI_Start_Term__c = term2107.Id,
            SI_End_Term__c = term2844.Id
        );
        testServiceIndicators.add(coreyNickoletteServiceIndicator);
        insert testServiceIndicators;

        // milestones for format students
        List<Student_Milestone__c> testStudentMilestones = new List<Student_Milestone__c>();
        Student_Milestone__c coreyNickoletteStudentMilestone = new Student_Milestone__c(
            Contact__c = coreyNickolette.Id,
            Milestone__c = 'GRFORMAT',
            Effdt__c = tMinus1d,
            Term_Required__c = term2844.Id
        );
        testStudentMilestones.add(coreyNickoletteStudentMilestone);
        insert testStudentMilestones;

        // And add programs/plan objects too
        List<Program__c> programs = new List<Program__c>();
        Program__c iraFultonProgram = newProgram('Ira A Fulton', 'IRAAFUL');
        programs.add(iraFultonProgram);
        Program__c lawProgram = new Program__c(Program_Code__c = 'LAW', Name = 'Law Program', Career__c = 'Law');
        programs.add(lawProgram);
        Program__c schoolOfSocialWorkProgram = newProgram('School of Social', 'SCL_SOC');
        programs.add(schoolOfSocialWorkProgram);
        Program__c wpCareyProgram = newProgram('W.P. Carey', 'WP_CAR');
        programs.add(wpCareyProgram);
        Program__c cronkiteProgram = newProgram('Walter Cronkite', 'CRONKITE');
        programs.add(cronkiteProgram);
        Program__c premedProgram = newProgram('Medical and Nursing', 'PREMED');
        programs.add(premedProgram);
        insert programs;

        List<Plan__c> plans = new List<Plan__c>();
        Plan__c elecEngPlan = newPlan('Electrical Engineering', iraFultonProgram.Id, 'ELECENG');
        plans.add(elecEngPlan);
        Plan__c civilEngPlan = newPlan('Civil Engineering', iraFultonProgram.Id, 'CIVLENG');
        plans.add(civilEngPlan);
        Plan__c lawyerPlan = newPlan('Practicing Law', lawProgram.Id, 'LAWYER');
        plans.add(lawyerPlan);
        Plan__c judgePlan = newPlan('Judgement Day', lawProgram.Id, 'JUDGE');
        plans.add(judgePlan);
        Plan__c socWorkPlan = newPlan('Social Work', schoolOfSocialWorkProgram.Id, 'SOCWORK');
        plans.add(socWorkPlan);
        Plan__c busnessPlan = newPlan('BEING YOUR OWN BOSS', wpCareyProgram.Id, 'BUSNESS');
        plans.add(busnessPlan);
        Plan__c tvfilmPlan = newPlan('Videography', cronkiteProgram.Id, 'TVFLIM');
        plans.add(tvfilmPlan);
        Plan__c compSciPlan = newPlan('Computer Science', iraFultonProgram.Id, 'COMPSCI');
        plans.add(compSciPlan);
        Plan__c journalPlan = newPlan('Journalism', cronkiteProgram.Id, 'JOURNAL');
        plans.add(journalPlan);
        Plan__c premedPlan = newPlan('Nursing', premedProgram.Id, 'PREMED');
        plans.add(premedPlan);
        insert plans;

        // Need to create cases - first make categories
        Case_Classification__c asuAdvisorOutreachFuncGrp = newFunctionalGroup('ASU Advisor Outreach');
        insert asuAdvisorOutreachFuncGrp;
        Case_Classification__c watchlistCategory = newCaseClassification('Watchlist', asuAdvisorOutreachFuncGrp.Id);
        Case_Classification__c category1 = newCaseClassification('CAT-1', null);
        Case_Classification__c category2 = newCaseClassification('CAT-2', null);
        Case_Classification__c category3 = newCaseClassification('CAT-3', null);
        Case_Classification__c category4 = newCaseClassification('CAT-4', null);
        insert new List<Case_Classification__c>{ watchlistCategory, category1, category2, category3, category4 };

        // And then the cases
        String caseRecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        List<Case> testCases = new List<Case>();
        Case testCase1 = new Case(
            ContactId = ryanCastelli.Id,
            Subject = 'New car',
            Status = 'New',
            CC_Category__c = category1.Id,
            Followup_Date__c = tPlus5d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase1);
        Case testCase2 = new Case(
            ContactId = ryanCastelli.Id,
            Subject = 'Found bug',
            Status = 'Busy Signal',
            CC_Category__c = category1.Id,
            Followup_Date__c = tPlus9d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase2);
        Case testCase3 = new Case(
            ContactId = ryanCastelli.Id,
            Subject = 'Send help',
            Status = 'Customer Replied',
            CC_Category__c = category2.Id,
            Followup_Date__c = tPlus10d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase3);
        Case testCase4 = new Case(
            ContactId = ryanCastelli.Id,
            Subject = 'Ant man',
            Status = 'Email Sent',
            CC_Category__c = category2.Id,
            Followup_Date__c = tPlus2d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase4);
        Case testCase5 = new Case(
            ContactId = maddyThomas.Id,
            Subject = 'Enrollment',
            Status = 'Outreach Required',
            CC_Category__c = category3.Id,
            Followup_Date__c = tPlus2d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase5);
        Case testCase6 = new Case(
            ContactId = coreyNickolette.Id,
            Subject = 'Enrollment',
            Status = 'Outreach Required - Transferred',
            CC_Category__c = category3.Id,
            Followup_Date__c = tPlus1d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase6);
        Case testCase7 = new Case(
            ContactId = annaPhillips.Id,
            Subject = 'Bee girl',
            Status = 'Email Sent',
            CC_Category__c = category4.Id,
            Followup_Date__c = tPlus1d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase7);

        insert testCases;
    }

    @IsTest
    static void testGetPicklistValues() {
        Test.startTest();
        Map<String, String> picklistValuesMap = AdvisorPortalFilterSectionController.getPicklistValues(
            'Student_Program_Plan__c',
            'Residency__c'
        );
        Test.stopTest();

        System.assert(
            picklistValuesMap.size() > 0,
            'Controller should have returned values for the Residency picklist.'
        );
        System.assert(
            picklistValuesMap.keySet().contains('Resident'),
            'Ensure the picklist map contains at least one valid picklist value.'
        );
    }

    @IsTest
    static void testGetCaseStatusOptions() {
        Test.startTest();
        Map<String, String> caseStatusMap = AdvisorPortalFilterSectionController.getCaseStatusSettings();
        Test.stopTest();

        System.assert(
            caseStatusMap.size() > 0,
            'Controller should have returned values for the Case Status picklist based upon the custom metadata type.'
        );
        System.assert(
            caseStatusMap.keySet().contains('In Progress'),
            'Ensure the picklist map contains at least one valid picklist value.'
        );
    }

    @IsTest
    private static void testCaseSubjectPicklistValues() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        String queueId = [SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Case' LIMIT 1].QueueId;

        List<Case> testCases = createCases(3);
        Integer i = 0;
        for (Case c : testCases) {
            c.ContactId = testContact.Id;
            c.Subject = 'Subject ' + i;
            c.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
            c.OwnerId = queueId;
            i++;
        }
        insert testCases;

        // Act
        Test.startTest();
        Map<String, String> subjectMap = AdvisorPortalFilterSectionController.getCaseSubjectPicklistValues(
            new List<String>{ queueId }
        );
        Test.stopTest();

        // Assert
        System.assertEquals(3, subjectMap.size(), 'Three subjects should have been found.');
    }

    @IsTest
    private static void testCaseCategoryPicklistValues() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        List<Case> testCases = createCases(3);
        Integer i = 0;
        for (Case c : testCases) {
            c.ContactId = testContact.Id;
            c.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
            i++;
        }
        insert testCases;

        CaseClassificationFactory caseClassificationsMaker = new CaseClassificationFactory();
        List<Case_Classification__c> classifications = caseClassificationsMaker.createAndInsertSetOfAdvisorOutreachCaseClassification();
        Id functionalGroupId = classifications[0].Id;
        Id categoryWatchlistId = classifications[2].Id;

        update new List<Case_Classification__c>{
            new Case_Classification__c(Id = categoryWatchlistId, Name = 'Watchlist'),
            new Case_Classification__c(Id = functionalGroupId, Name = 'ASU Advisor Outreach')
        };

        String queueId = [SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Case' LIMIT 1].QueueId;

        CaseFactory.AdvisorOutreachCase watchlistCaseMaker = new CaseFactory.AdvisorOutreachCase(
            UserInfo.getUserId(),
            RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach'),
            'Outreach Required',
            functionalGroupId,
            categoryWatchlistId,
            testContact.Id,
            null
        );
        Case caseToFind = (Case) watchlistCaseMaker.create(1)[0];
        caseToFind.Subject = 'Test Subject';
        caseToFind.Followup_Date__c = System.today().addDays(10);
        caseToFind.ownerId = queueId;
        insert caseToFind;

        // Act
        Test.startTest();
        Map<String, String> classificationMap = AdvisorPortalFilterSectionController.getCaseClassificationPicklistValues(
            new List<String>{ queueId }
        );
        Test.stopTest();

        // Assert
        System.assertEquals(1, classificationMap.size(), 'The one Case Category should have been found.');
    }

    @IsTest
    private static void testNoFilter() {
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = createContact('test-contact-ap-r1');
        Contact testContact2 = createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

    @IsTest
    private static void testNoFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );

        System.assertEquals(2, results.size(), 'Should get 2 contact-case wrapper returned');
        Integer countCases = 0;
        for (AdvisorPortalContact apContact : results) {
            countCases += apContact.cases.size();
        }
        System.assertEquals(5, countCases, 'Should get 5 total cases returned');
    }

    @IsTest
    private static void testNameFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.studentString = 'Mister test-contact-ap-r2';
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact2.Id, results[0].portalContact.Id, 'Should get second test contact');

        filter.studentString = '0011221100';
        results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact1.Id, results[0].portalContact.Id, 'Should get first test contact');

        filter.studentString = 'testid_1';
        results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact2.Id, results[0].portalContact.Id, 'Should get second test contact');
    }

    @IsTest
    private static void testCampusFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.campus = testCampus2.Location_Code__c;

        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact2.Id, results[0].portalContact.Id, 'Should get second test contact');
    }

    @IsTest
    private static void testAcademicLevelFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.academicLevel = 'test-cohort-1';

        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact1.Id, results[0].portalContact.Id, 'Should get first test contact');

        filter.academicLevel = 'test-cohort-1;test-cohort-2';
        results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(2, results.size(), 'Should get 2 contact-case wrapper returned');
    }

    @IsTest
    private static void testStudentGroupFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.studentGroupCode = 'testapr1';

        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact1.Id, results[0].portalContact.Id, 'Should get first test contact');
    }

    @IsTest
    private static void testMajorFilter() {
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = createContact('test-contact-ap-r1');
        Contact testContact2 = createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        Student_Program_Plan__c studentProgramPlan1 = new Student_Program_Plan__c(
            Contact__c = testContact1.Id,
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'test-code-ap-r1'
        );
        Student_Program_Plan__c studentProgramPlan2 = new Student_Program_Plan__c(
            Contact__c = testContact2.Id,
            Plan_Type_Text__c = 'MAJ',
            Plan_Description__c = 'test-description-ap-r2'
        );

        insert new List<Student_Program_Plan__c>{ studentProgramPlan1, studentProgramPlan2 };

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.major = 'test-code-ap-r1';

        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact1.Id, results[0].portalContact.Id, 'Should get first test contact');

        filter.major = 'test-description-ap-r2';
        results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact2.Id, results[0].portalContact.Id, 'Should get second test contact');
    }

    @IsTest
    private static void testResidencyFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.residency = 'International';

        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact1.Id, results[0].portalContact.Id, 'Should get first test contact');
    }

    @IsTest
    private static void testCaseStatusFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.caseStatus = 'Outreach Required';
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(2, results.size(), 'Should get 2 contact-case wrapper returned');
        Integer caseCount = 0;
        for (AdvisorPortalContact apContact : results) {
            caseCount += apContact.cases.size();
        }
        System.assertEquals(2, caseCount, 'Should get 2 total cases');
    }

    @IsTest
    private static void testCaseCategoryFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.caseCategory = 'test-category-ap-r1';
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(2, results.size(), 'Should get 2 contact-case wrapper returned');
        Integer caseCount = 0;
        for (AdvisorPortalContact apContact : results) {
            caseCount += apContact.cases.size();
        }
        System.assertEquals(3, caseCount, 'Should get 3 total cases');
    }

    @IsTest
    private static void testCaseSubjectFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.caseSubject = 'test-subject-ap-r1';
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(2, results.size(), 'Should get 2 contact-case wrapper returned');
        Integer caseCount = 0;
        for (AdvisorPortalContact apContact : results) {
            caseCount += apContact.cases.size();
        }
        System.assertEquals(3, caseCount, 'Should get 3 total cases');
    }

    @IsTest
    private static void testOutlookScoreFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.outlookScore = 'low';
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact1.Id, results[0].portalContact.Id, 'Should get first test contact');
    }

    @IsTest
    private static void testOutlookChangeFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.outlookChange = 'down';
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact2.Id, results[0].portalContact.Id, 'Should get second test contact');
    }

    @IsTest
    private static void testCaseCountFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.caseCount = '2';
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact1.Id, results[0].portalContact.Id, 'Should get first test contact');
    }

    @IsTest
    private static void testCreatedDateFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.createdFromDate = System.now().addDays(-3).format('yyyy-MM-dd');
        filter.createdToDate = System.now().addDays(-1).format('yyyy-MM-dd');
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact2.Id, results[0].portalContact.Id, 'Should get second test contact');
        Integer caseCount = 0;
        for (AdvisorPortalContact apContact : results) {
            caseCount += apContact.cases.size();
        }
        System.assertEquals(2, caseCount, 'Should get 2 total cases');
    }

    @IsTest
    private static void testFollowupDateFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.followUpFromDate = String.valueof(System.today());
        filter.followUpToDate = String.valueof(System.today().addDays(2));
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(2, results.size(), 'Should get 2 contact-case wrapper returned');
        Integer caseCount = 0;
        for (AdvisorPortalContact apContact : results) {
            caseCount += apContact.cases.size();
        }
        System.assertEquals(2, caseCount, 'Should get 2 total cases');
    }

    @IsTest
    private static void testPersistanceChangeDateFilter() {
        // Can't really check because impossible to change Change_Date__c field
    }

    @IsTest
    private static void testAllStudentsFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getAllContactsAndRespectiveCases(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(2, results.size(), 'Should get 2 contact-case wrapper returned');
        Integer caseCount = 0;
        for (AdvisorPortalContact apContact : results) {
            caseCount += apContact.cases.size();
        }
        System.assertEquals(3, caseCount, 'Should get 3 total cases');
    }

    @IsTest
    private static void testWatchlistCasesFilter() {
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = createContact('test-contact-ap-r1');
        Contact testContact2 = createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case_Classification__c parent = new Case_Classification__c(
            Name = 'ASU Advisor Outreach',
            Active__c = true,
            Visible__c = true,
            Record_Types_String__c = 'wer',
            RecordTypeId = Schema.SObjectType.Case_Classification__c.getRecordTypeInfosByName()
                .get('Functional Group')
                .getRecordTypeId()
        );
        insert parent;

        Case_Classification__c testClassification1 = new Case_Classification__c(
            Name = 'Watchlist',
            Active__c = true,
            Visible__c = true,
            Parent__c = parent.Id,
            RecordTypeId = Schema.SObjectType.Case_Classification__c.getRecordTypeInfosByName()
                .get('Category')
                .getRecordTypeId()
        );

        insert new List<Case_Classification__c>{ testClassification1 };

        Case testCase1 = createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.CC_Functional_Group__c = parent.Id;
        testCase1.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.CC_Functional_Group__c = parent.Id;
        testCase2.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.CC_Functional_Group__c = parent.Id;
        testCase3.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.CC_Functional_Group__c = parent.Id;
        testCase4.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.CC_Functional_Group__c = parent.Id;
        testCase5.RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        testCase1.CC_Category__c = testClassification1.Id;
        testCase3.CC_Category__c = testClassification1.Id;
        testCase5.CC_Category__c = testClassification1.Id;

        update new List<Case>{ testCase1, testCase3, testCase5 };

        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.caseTypeState = 'WatchlistCasesState';
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(2, results.size(), 'Should get 2 contact-case wrapper returned');
        Integer caseCount = 0;
        for (AdvisorPortalContact apContact : results) {
            caseCount += apContact.cases.size();
        }
        System.assertEquals(3, caseCount, 'Should get 3 total cases');
    }

    @IsTest
    static void testMutlipleFiltersAtOnce() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.studentString = 'Mister test-contact-ap-r2';
        filter.caseSubject = 'test-subject-ap-r1';
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact2.Id, results[0].portalContact.Id, 'Should get second test contact');
        Integer caseCount = 0;
        for (AdvisorPortalContact apContact : results) {
            caseCount += apContact.cases.size();
        }
        System.assertEquals(2, caseCount, 'Should get 2 total cases');
    }

    @IsTest
    private static void testFiltersAndAllStudents() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.studentString = 'Mister test-contact-ap-r2';
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getAllContactsAndRespectiveCases(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 2 contact-case wrapper returned');
        Integer caseCount = 0;
        for (AdvisorPortalContact apContact : results) {
            caseCount += apContact.cases.size();
        }
        System.assertEquals(3, caseCount, 'Should get 3 total cases');
    }

    @IsTest
    static void testFilterStudentGroups() {
        AdvisorPortalFilter filter1 = new AdvisorPortalFilter();
        filter1.career = 'UGRD';
        filter1.studentGroupCode = 'testgrp-r1';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.studentGroupCode = 'testgrp-r2';

        // Act
        Test.startTest();
        Set<Id> results1 = AdvisorPortalFilterSectionController.filterStudentGroups(
            filter1,
            new Set<Id>{ listOfContacts[0].Id, listOfContacts[1].Id }
        );
        Set<Id> results2 = AdvisorPortalFilterSectionController.filterStudentGroups(
            filter2,
            new Set<Id>{ listOfContacts[0].Id, listOfContacts[1].Id }
        );
        Test.stopTest();

        // Assert
        System.assertEquals(2, results1.size());
        System.assertEquals(1, results2.size());
        System.assert(results1.contains(listOfContacts[0].Id), 'The first contact has an active TESTGRP-r1 plan.');
        System.assert(results1.contains(listOfContacts[1].Id), 'The second contact has an active TESTGRP-r1 plan.');
        System.assert(results2.contains(listOfContacts[0].Id), 'The first contact has an active TESTGRP-r2 plan.');
        System.assert(
            !results2.contains(listOfContacts[1].Id),
            'The second contact does not have an active TESTGRP-r2 plan.'
        );
    }

    @IsTest
    static void testFilterStudentPlans() {
        AdvisorPortalFilter filter1 = new AdvisorPortalFilter();
        filter1.career = 'UGRD';
        filter1.academicLevel = 'senior;junior';
        filter1.campus = 'TEST-R1;TEST-R2';
        filter1.residency = 'resident;international';
        filter1.major = 'computer';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.major = 'law';

        AdvisorPortalFilter filter3 = new AdvisorPortalFilter();
        filter3.career = 'GRD';

        // Act
        Test.startTest();
        Set<Id> results1 = AdvisorPortalFilterSectionController.filterStudentPlans(
            filter1,
            new Set<Id>{ listOfContacts[0].Id, listOfContacts[1].Id }
        );
        Set<Id> results2 = AdvisorPortalFilterSectionController.filterStudentPlans(
            filter2,
            new Set<Id>{ listOfContacts[0].Id, listOfContacts[1].Id }
        );
        Set<Id> results3 = AdvisorPortalFilterSectionController.filterStudentPlans(
            filter3,
            new Set<Id>{ listOfContacts[0].Id, listOfContacts[1].Id }
        );
        Test.stopTest();

        // Assert
        System.assertEquals(1, results1.size());
        System.assert(
            !results1.contains(listOfContacts[0].Id),
            'The first contact should not be in the first set of results.'
        );
        System.assert(
            results1.contains(listOfContacts[1].Id),
            'The second contact should be in the first set of results.'
        );

        System.assertEquals(1, results2.size());
        System.assert(
            !results2.contains(listOfContacts[0].Id),
            'The first contact should not be in the second set of results.'
        );
        System.assert(
            results2.contains(listOfContacts[1].Id),
            'The second contact should be in the second set of results.'
        );

        System.assertEquals(1, results3.size());
        System.assert(
            results3.contains(listOfContacts[0].Id),
            'The first contact should be in the third set of results.'
        );
        System.assert(
            !results3.contains(listOfContacts[1].Id),
            'The second contact should not be in the third set of results.'
        );
    }

    private static Location__c newLocation(String name, String code, Boolean gradEnabled) {
        return new Location__c(Location_Code__c = code, Name = name, Graduate_Enabled__c = gradEnabled);
    }

    private static Term__c newTerm(String code) {
        Term__c term = new Term__c(PeopleSoft_Code__c = code);

        String constructedYear = '';
        if (code.substring(0, 1) == '1')
            constructedYear += '19';
        else
            constructedYear += '20';

        constructedYear += code.substring(1, 3);

        term.Year__c = constructedYear;

        return term;
    }

    private static Contact newContact(String firstName, String lastName) {
        return new Contact(FirstName = firstName, LastName = lastName);
    }

    private static Persistence_Outlook__c newPersistenceOutlook(
        Contact con,
        Date changeDate,
        Integer predLevel,
        Integer changeDir
    ) {
        return new Persistence_Outlook__c(
            Contact__c = con.Id,
            Change_Date__c = changeDate,
            Curr_Cont_Prediction_Level__c = predLevel,
            Change_Direction__c = changeDir
        );
    }

    private static Student_Group__c newStudentGroup(Id contactId, String studentGrp) {
        return new Student_Group__c(
            SG_Contact__c = contactId,
            SG_PeopleSoft_Code__c = studentGrp,
            SG_Status__c = true,
            SG_Effective_Date__c = System.today()
        );
    }

    private static Program__c newProgram(String name, String code) {
        return new Program__c(Name = name, Program_Code__c = code, Career__c = 'Graduate');
    }

    private static Plan__c newPlan(String name, Id programId, String code) {
        return new Plan__c(
            Name = name,
            Plan_Code__c = code,
            Program__c = programId,
            Plan_Status__c = true,
            Plan_Effective_Date__c = System.today()
        );
    }

    private static Case_Classification__c newFunctionalGroup(String name) {
        return new Case_Classification__c(
            Name = name,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
        );
    }

    private static Case_Classification__c newCaseClassification(String name, String parentId) {
        Case_Classification__c classification = new Case_Classification__c(
            Name = name,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Category')
        );

        if (parentId != null)
            classification.Parent__c = parentId;

        return classification;
    }

    private static Success_Student__c newSuccessStudent(Contact con, Success_Pod__c pod) {
        return new Success_Student__c(
            Is_Active__c = true,
            Success_Pod__c = pod.Id,
            Student__c = con.Id,
            Coaching_Student__c = false
        );
    }
}
