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
     * 10 cases
     * +----------------------+-------------+----------------------------------+----------+------------------+----------------+------------+
     * |         Who          |  Subject    |                Status            |  Owner   |  Follow Up Date  |  Created Date  |  Category  |
     * +----------------------+-------------+----------------------------------+----------+------------------+----------------+------------+
     * |  Ryan Castelli       |  New car    |  New                             | McKinnon |  TODAY + 5d      |  TODAY - 5d    |  CAT-1     |
     * |  Ryan Castelli       |  Found bug  |  Busy Signal                     | McKinnon |  TODAY + 9d      |  TODAY - 9d    |  CAT-1     |
     * |  Ryan Castelli       |  Send help  |  Customer Replied                | McKinnon |  TODAY + 10d     |  TODAY - 10d   |  CAT-2     |
     * |  Ryan Castelli       |  Ant man    |  Email Sent                      | McKinnon |  TODAY + 2d      |  TODAY - 2d    |  CAT-2     |
     * |  Chase Burgess       |  Battery    |  New                             | McKinnon |  TODAY + 2d      |  TODAY - 2d    |  CAT-4     |
     * |  Ben Hellsig         |  Tailwind   |  New                             | McKinnon |  TODAY + 2d      |  TODAY - 2d    |  CAT-4     |
     * |  Marisa Barilla      |  Paperclip  |  New                             | McKinnon |  TODAY + 2d      |  TODAY - 2d    |  CAT-4     |
     * |  Sarah Durisek       |  Enrollment |  Outreach Required               | McKinnon |  TODAY + 2d      |  TODAY - 2d    |  CAT-3     |
     * |  James Bair          |  Enrollment |  Outreach Required - Transferred | McKinnon |  TODAY + 1d      |  TODAY - 1d    |  CAT-3     |
     * |  Morgan Diegel       |  Bee girl   |  Email Sent                      | McKinnon |  TODAY + 1d      |  TODAY - 1d    |  CAT-4     |
     * |  Morgan Diegel       |  Spyglass   |  New                             | McKinnon |  TODAY + 1d      |  TODAY - 1d    |  Watchlist |
     * +----------------------+-------------+----------------------------------+----------+------------------+----------------+------------+
     */
    @TestSetup
    public static void setup() {
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
        anyaSimms.PS_Preferred_First_Name__c = 'Anastasia';
        anyaSimms.EmplId__c = '1200889090';
        anyaSimms.ASURite_ID__c = 'asimms4';
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
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'COMPSCI',
            Plan_Description__c = 'Computer Science',
            Residency__c = 'Non-Resident'
        );
        testStudentProgramPlans.add(ryanCastelliProgramPlan);
        Student_Program_Plan__c chaseBurgessProgramPlan = new Student_Program_Plan__c(
            Contact__c = chaseBurgess.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus1.Id,
            Cohort__c = 'freshman',
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'BUSNESS',
            Plan_Description__c = 'Business Boss',
            Residency__c = 'Non-Resident'
        );
        testStudentProgramPlans.add(chaseBurgessProgramPlan);
        Student_Program_Plan__c morganStraussProgramPlan = new Student_Program_Plan__c(
            Contact__c = morganStrauss.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus2.Id,
            Cohort__c = 'sophmore',
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'AEROSPC',
            Plan_Description__c = 'Aerospace Engineering',
            Residency__c = 'Resident'
        );
        testStudentProgramPlans.add(morganStraussProgramPlan);
        Student_Program_Plan__c benHellsigProgramPlan = new Student_Program_Plan__c(
            Contact__c = benHellsig.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus2.Id,
            Cohort__c = 'freshman',
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'BUSNESS',
            Plan_Description__c = 'Business Boss',
            Residency__c = 'Non-Resident'
        );
        testStudentProgramPlans.add(benHellsigProgramPlan);
        Student_Program_Plan__c marisaBarillaProgramPlan = new Student_Program_Plan__c(
            Contact__c = marisaBarilla.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus3.Id,
            Cohort__c = 'sophmore',
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'PREMED',
            Plan_Description__c = 'Premedical',
            Residency__c = 'Non-Resident'
        );
        testStudentProgramPlans.add(marisaBarillaProgramPlan);
        Student_Program_Plan__c sarahDurisekProgramPlan = new Student_Program_Plan__c(
            Contact__c = sarahDurisek.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus3.Id,
            Cohort__c = 'junior',
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'PREMED',
            Plan_Description__c = 'Premedical',
            Residency__c = 'Resident'
        );
        testStudentProgramPlans.add(sarahDurisekProgramPlan);
        Student_Program_Plan__c jamesBairProgramPlan = new Student_Program_Plan__c(
            Contact__c = jamesBair.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus4.Id,
            Cohort__c = 'sophmore',
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'TVFILM',
            Plan_Description__c = 'Videography',
            Residency__c = 'International'
        );
        testStudentProgramPlans.add(jamesBairProgramPlan);
        Student_Program_Plan__c zacharyNoellerProgramPlan = new Student_Program_Plan__c(
            Contact__c = zacharyNoeller.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus4.Id,
            Cohort__c = 'junior',
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'TVFILM',
            Plan_Description__c = 'Videography',
            Residency__c = 'Non-Resident'
        );
        testStudentProgramPlans.add(zacharyNoellerProgramPlan);
        Student_Program_Plan__c morganDiegelProgramPlan = new Student_Program_Plan__c(
            Contact__c = morganDiegel.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus5.Id,
            Cohort__c = 'senior',
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'COMPSCI',
            Plan_Description__c = 'Computer Science',
            Residency__c = 'International'
        );
        testStudentProgramPlans.add(morganDiegelProgramPlan);
        Student_Program_Plan__c aaronAssafProgramPlan = new Student_Program_Plan__c(
            Contact__c = aaronAssaf.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus5.Id,
            Cohort__c = 'senior',
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'ELECENG',
            Plan_Description__c = 'Electrical Engineering',
            Residency__c = 'International'
        );
        testStudentProgramPlans.add(aaronAssafProgramPlan);
        Student_Program_Plan__c simonKirkseyProgramPlan = new Student_Program_Plan__c(
            Contact__c = simonKirksey.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus6.Id,
            Cohort__c = 'junior',
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'PURMATH',
            Plan_Description__c = 'Absoluti Mathematica',
            Residency__c = 'Non-Resident'
        );
        testStudentProgramPlans.add(simonKirkseyProgramPlan);
        Student_Program_Plan__c seanPhillipsProgramPlan = new Student_Program_Plan__c(
            Contact__c = seanPhillips.Id,
            Career__c = 'Undergraduate',
            Campus__c = testCampus6.Id,
            Cohort__c = 'graduate',
            Plan_Type_Text__c = 'MAJ',
            Plan_Code__c = 'TVFILM',
            Plan_Description__c = 'Videography',
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
            CreatedDate = tMinus5d,
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
            CreatedDate = tMinus9d,
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
            CreatedDate = tMinus10d,
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
            CreatedDate = tMinus2d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase4);
        Case testCase5 = new Case(
            ContactId = chaseBurgess.Id,
            Subject = 'Battery',
            Status = 'New',
            CC_Category__c = category4.Id,
            Followup_Date__c = tPlus2d,
            CreatedDate = tMinus2d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase5);
        Case testCase6 = new Case(
            ContactId = benHellsig.Id,
            Subject = 'Tailwind',
            Status = 'New',
            CC_Category__c = category4.Id,
            Followup_Date__c = tPlus2d,
            CreatedDate = tMinus2d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase6);
        Case testCase7 = new Case(
            ContactId = marisaBarilla.Id,
            Subject = 'Paperclip',
            Status = 'New',
            CC_Category__c = category4.Id,
            Followup_Date__c = tPlus2d,
            CreatedDate = tMinus2d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase7);
        Case testCase8 = new Case(
            ContactId = sarahDurisek.Id,
            Subject = 'Enrollment',
            Status = 'Outreach Required',
            CC_Category__c = category3.Id,
            Followup_Date__c = tPlus2d,
            CreatedDate = tMinus2d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase8);
        Case testCase9 = new Case(
            ContactId = jamesBair.Id,
            Subject = 'Enrollment',
            Status = 'Outreach Required - Transferred',
            CC_Category__c = category3.Id,
            Followup_Date__c = tPlus1d,
            CreatedDate = tMinus1d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase9);
        Case testCase10 = new Case(
            ContactId = morganDiegel.Id,
            Subject = 'Bee girl',
            Status = 'Email Sent',
            CC_Category__c = category4.Id,
            Followup_Date__c = tPlus1d,
            CreatedDate = tMinus1d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase10);
        Case testCase11 = new Case(
            ContactId = morganDiegel.Id,
            Subject = 'Spyglass',
            Status = 'New',
            CC_Functional_Group__c = asuAdvisorOutreachFuncGrp.Id,
            CC_Category__c = watchlistCategory.Id,
            Followup_Date__c = tPlus1d,
            CreatedDate = tMinus1d,
            OwnerId = testUser.Id,
            RecordTypeId = caseRecordTypeId
        );
        testCases.add(testCase11);

        insert testCases;
    }

    @isTest
    private static void testGetResidencyOptions() {
        Test.startTest();
        Map<String, String> options = AdvisorPortalFilterSectionController.getPicklistValues(
            'Student_Program_Plan__c',
            'Residency__c'
        );
        Test.stopTest();

        System.assert(!options.isEmpty(), 'There should be SOME residency options.');
        System.assert(options.keySet().contains('Resident'), 'Residency options should contain "Resident".');
        System.assert(options.keySet().contains('Non-Resident'), 'Residency options should contain "Non-Resident".');
        System.assert(options.keySet().contains('International'), 'Residency options should contain "International".');
    }

    @IsTest
    static void testGetCaseStatusOptions() {
        List<Advisor_Portal_Case_Status__mdt> validStatuses = [
            SELECT Label, Value__c
            FROM Advisor_Portal_Case_Status__mdt
            WHERE Active__c = TRUE
            ORDER BY Label ASC
        ];

        Test.startTest();
        Map<String, String> caseStatusMap = AdvisorPortalFilterSectionController.getCaseStatusSettings();
        Test.stopTest();

        System.assertEquals(
            validStatuses.size(),
            caseStatusMap.size(),
            'Controller should have returned values for the Case Status picklist based upon the custom metadata type.'
        );
        for (Advisor_Portal_Case_Status__mdt status : validStatuses) {
            System.assert(
                caseStatusMap.keySet().contains(status.Label),
                'Ensure the picklist map contains all statuses.'
            );
        }
    }

    @IsTest
    private static void testGetCaseSubjectPicklistValues() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<Case> testCases = [SELECT Id, Subject FROM Case WHERE OwnerId = :testUser.Id];

        // Act
        Test.startTest();
        Map<String, String> subjectMap = AdvisorPortalFilterSectionController.getCaseSubjectPicklistValues(
            new List<String>{ testUser.Id }
        );
        Test.stopTest();

        for (Case c : testCases) {
            System.assert(
                subjectMap.keySet().contains(c.Subject),
                'Should contain all subjects that this user has cases for'
            );
        }
    }

    @IsTest
    private static void testGetCaseCategoryPicklistValues() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<Case> testCases = [
            SELECT Id, CC_Category__r.Name
            FROM Case
            WHERE
                OwnerId = :testUser.Id
                AND RecordTypeId = :RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach')
        ];

        Test.startTest();
        Map<String, String> classificationMap = AdvisorPortalFilterSectionController.getCaseClassificationPicklistValues(
            new List<String>{ testUser.Id }
        );
        Test.stopTest();

        for (Case c : testCases) {
            System.assert(
                classificationMap.keySet().contains(c.CC_Category__r.Name),
                'Should contain all categories that this user has cases for'
            );
        }
    }

    @isTest
    private static void testGetCampusPicklistValues() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<Location__c> ugradCampuses = [SELECT Name FROM Location__c];
        List<Location__c> gradCampuses = [SELECT Name FROM Location__c WHERE Graduate_Enabled__c = TRUE];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'GRD';

        Test.startTest();
        Map<String, String> campusMap = AdvisorPortalFilterSectionController.getCampusValues(JSON.serialize(filter));

        Map<String, String> campusMap2 = AdvisorPortalFilterSectionController.getCampusValues(JSON.serialize(filter2));
        Test.stopTest();

        System.assertEquals(ugradCampuses.size(), campusMap.size(), 'Should contain correct number of campuses');
        for (Location__c l : ugradCampuses) {
            System.assert(campusMap.keySet().contains(l.Name), 'Should contain all locations');
        }

        System.assertEquals(gradCampuses.size(), campusMap2.size(), 'Should contain correct number of campuses');
        for (Location__c l : gradCampuses) {
            System.assert(campusMap2.keySet().contains(l.Name), 'Should contain all grad locations');
        }
    }

    @IsTest
    private static void testGetAcademicProgramPicklistValues() {
        List<Program__c> testPrograms = [SELECT Id, Name, Program_Code__c FROM Program__c WHERE Career__c = 'Graduate'];

        Test.startTest();
        Map<String, String> programMap = AdvisorPortalFilterSectionController.getAcademicProgramPicklistValues();
        Test.stopTest();

        for (Program__c p : testPrograms) {
            String expectedKey = p.Name;
            System.assert(
                programMap.keySet().contains(expectedKey),
                'Should contain all active programs (which is ALL programs for our test data) but "' +
                expectedKey +
                '" is missing from ' +
                programMap.keySet()
            );
        }
    }

    @IsTest
    private static void testGetAcademicPlanPicklistValues() {
        List<Plan__c> testPlans = [
            SELECT Id, Name, Plan_Code__c, Program__r.Program_Code__c
            FROM Plan__c
            WHERE Program__r.Career__c = 'Graduate'
        ];

        Test.startTest();
        Map<String, String> planMap = AdvisorPortalFilterSectionController.getAcademicPlanPicklistValues('{}');
        Map<String, String> limitedPlanMap = AdvisorPortalFilterSectionController.getAcademicPlanPicklistValues(
            '{"academicProgram":"IRAAFUL"}'
        );
        Test.stopTest();

        for (Plan__c p : testPlans) {
            String expectedKey = p.Plan_Code__c + ' / ' + p.Name;
            System.assert(
                planMap.keySet().contains(expectedKey),
                'Should contain all active plans (which is ALL plans for our test data) but "' +
                expectedKey +
                '" is missing from ' +
                planMap.keySet()
            );

            if (p.Program__r.Program_Code__c == 'IRAAFUL') {
                System.assert(
                    limitedPlanMap.keySet().contains(expectedKey),
                    'Should contain only plans under the IRAAFUL program and it is missing "' +
                    expectedKey +
                    '" from ' +
                    limitedPlanMap.keySet()
                );
            } else {
                System.assert(
                    !limitedPlanMap.keySet().contains(expectedKey),
                    'Should contain only plans under the IRAAFUL program but it contains "' +
                    expectedKey +
                    '" in ' +
                    limitedPlanMap.keySet()
                );
            }
        }
    }

    @IsTest
    private static void testFilterUndergraduate() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c != 'Graduate'
            GROUP BY Contact__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'AllCasesState';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);
    }

    @IsTest
    private static void testFilterGraduate() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c = 'Graduate'
            GROUP BY Contact__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'GRD';
        filter.caseTypeState = 'AllCasesState';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);
    }

    @IsTest
    private static void testFilterName() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        // Search name
        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'GRD';
        filter.caseTypeState = 'AllCasesState';
        filter.studentString = 'Anya Simms';

        // Search preferred name
        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'GRD';
        filter2.caseTypeState = 'AllCasesState';
        filter2.studentString = 'Anastasia Simms';

        // Search emplid
        AdvisorPortalFilter filter3 = new AdvisorPortalFilter();
        filter3.career = 'GRD';
        filter3.caseTypeState = 'AllCasesState';
        filter3.studentString = '1200889090';

        // Search asurite
        AdvisorPortalFilter filter4 = new AdvisorPortalFilter();
        filter4.career = 'GRD';
        filter4.caseTypeState = 'AllCasesState';
        filter4.studentString = 'asimms4';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );
        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        String resultsJSON3 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter3)
        );
        String resultsJSON4 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter4)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );
        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );
        List<AdvisorPortalContact> results3 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON3,
            List<AdvisorPortalContact>.class
        );
        List<AdvisorPortalContact> results4 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON4,
            List<AdvisorPortalContact>.class
        );

        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals('Anya Simms', results[0].portalContact.Name, 'Should get second test contact');

        System.assertEquals(1, results2.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals('Anya Simms', results2[0].portalContact.Name, 'Should get second test contact');

        System.assertEquals(1, results3.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals('Anya Simms', results3[0].portalContact.Name, 'Should get second test contact');

        System.assertEquals(1, results4.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals('Anya Simms', results4[0].portalContact.Name, 'Should get second test contact');
    }

    @IsTest
    private static void testFilterCampus() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c != 'Graduate' AND Campus__r.Location_Code__c = '0011221101'
            GROUP BY Contact__c
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c != 'Graduate' AND Campus__r.Location_Code__c IN ('0011221101', '0011221102')
            GROUP BY Contact__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'AllCasesState';
        filter.campus = '0011221101';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'AllCasesState';
        filter2.campus = '0011221101;0011221102';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @IsTest
    private static void testFilterAcademicLevel() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c != 'Graduate' AND Cohort__c = 'Freshman'
            GROUP BY Contact__c
        ];
        List<AggregateResult> expectedStudents2 = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c != 'Graduate' AND Cohort__c IN ('Freshman', 'Junior')
            GROUP BY Contact__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'AllCasesState';
        filter.academicLevel = 'Freshman';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'AllCasesState';
        filter2.academicLevel = 'Freshman;Junior';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @IsTest
    private static void testFilterStudentGroup() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT SG_Contact__c ContactId__alias
            FROM Student_Group__c
            WHERE SG_PeopleSoft_Code__c = 'STGRP1'
            GROUP BY SG_Contact__c
        ];
        List<AggregateResult> expectedStudents2 = [
            SELECT SG_Contact__c ContactId__alias
            FROM Student_Group__c
            WHERE SG_PeopleSoft_Code__c = 'STGRP2'
            GROUP BY SG_Contact__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'AllCasesState';
        filter.studentGroupCode = 'STGRP1';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'AllCasesState';
        filter2.studentGroupCode = 'STGRP2';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @IsTest
    private static void testFilterMajor() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c != 'Graduate' AND Plan_Code__c = 'COMPSCI'
            GROUP BY Contact__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'AllCasesState';
        filter.major = 'COMPSCI';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'AllCasesState';
        filter2.major = 'Computer Science';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results2.size());
        assertCorrectReturned(expectedStudents, results2);
    }

    @isTest
    private static void testFilterDegreeLevel() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c = 'Graduate' AND Plan_Type_Text__c = 'MAJ' AND Education_Level__c = '17'
            GROUP BY Contact__c
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE
                Career__c = 'Graduate'
                AND ((Plan_Type_Text__c = 'MAJ'
                AND Education_Level__c = '17')
                OR Plan_Type_Text__c = 'CER')
            GROUP BY Contact__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'GRD';
        filter.caseTypeState = 'AllCasesState';
        filter.degreeLevel = 'masters';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'GRD';
        filter2.caseTypeState = 'AllCasesState';
        filter2.degreeLevel = 'masters;certificate';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @isTest
    private static void testFilterAcademicProgram() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c = 'Graduate' AND Program_Code__c = 'IRAAFUL'
            GROUP BY Contact__c
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c = 'Graduate' AND Program_Code__c IN ('IRAAFUL', 'PREMED')
            GROUP BY Contact__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'GRD';
        filter.caseTypeState = 'AllCasesState';
        filter.academicProgram = 'IRAAFUL';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'GRD';
        filter2.caseTypeState = 'AllCasesState';
        filter2.academicProgram = 'IRAAFUL;PREMED';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @isTest
    private static void testFilterSchoolDepartment() {
        // Needs to be written after Integrations pulls in this data
    }

    @isTest
    private static void testFilterAcademicPlan() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c = 'Graduate' AND Plan_Code__c = 'TVFILM'
            GROUP BY Contact__c
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c = 'Graduate' AND Plan_Code__c IN ('BUSNESS', 'TVFILM')
            GROUP BY Contact__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'GRD';
        filter.caseTypeState = 'AllCasesState';
        filter.academicPlan = 'TVFILM';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'GRD';
        filter2.caseTypeState = 'AllCasesState';
        filter2.academicPlan = 'BUSNESS;TVFILM';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @isTest
    private static void testFilterAdmitTerm() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE
                Career__c = 'Graduate'
                AND (Admit_Term__r.PeopleSoft_Code__c <= '2187'
                OR Requirement_Term__c <= '2187')
                AND (Admit_Term__r.PeopleSoft_Code__c >= '2144'
                OR Requirement_Term__c >= '2144')
            GROUP BY Contact__c
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE
                Career__c = 'Graduate'
                AND (Admit_Term__r.PeopleSoft_Code__c <= '2191'
                OR Requirement_Term__c <= '2191')
            GROUP BY Contact__c
        ];

        List<AggregateResult> expectedStudents3 = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE
                Career__c = 'Graduate'
                AND (Admit_Term__r.PeopleSoft_Code__c >= '2191'
                OR Requirement_Term__c >= '2191')
            GROUP BY Contact__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'GRD';
        filter.caseTypeState = 'AllCasesState';
        filter.admitTermFrom = '2144';
        filter.admitTermTo = '2187';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'GRD';
        filter2.caseTypeState = 'AllCasesState';
        filter2.admitTermTo = '2191';

        AdvisorPortalFilter filter3 = new AdvisorPortalFilter();
        filter3.career = 'GRD';
        filter3.caseTypeState = 'AllCasesState';
        filter3.admitTermFrom = '2191';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );

        String resultsJSON3 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter3)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results3 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON3,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);

        System.assert(!expectedStudents3.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents3.size(), results3.size());
        assertCorrectReturned(expectedStudents3, results3);
    }

    @IsTest
    private static void testFilterResidency() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c != 'Graduate' AND Residency__c = 'International'
            GROUP BY Contact__c
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE Career__c != 'Graduate' AND Residency__c IN ('Resident', 'International')
            GROUP BY Contact__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'AllCasesState';
        filter.residency = 'International';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'AllCasesState';
        filter2.residency = 'Resident;International';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @IsTest
    private static void testFilterCaseStatus() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                Status = 'Email Sent'
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                Status IN ('Email Sent', 'Busy Signal')
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'ProactiveCasesState';
        filter.caseStatus = 'Email Sent';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'ProactiveCasesState';
        filter2.caseStatus = 'Email Sent;Busy Signal';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @IsTest
    private static void testFilterCaseCategory() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                CC_Category__r.Name = 'CAT-3'
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                CC_Category__r.Name IN ('CAT-4', 'CAT-3')
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'ProactiveCasesState';
        filter.caseCategory = 'CAT-3';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'ProactiveCasesState';
        filter2.caseCategory = 'CAT-4;CAT-3';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @IsTest
    private static void testFilterCaseSubject() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                Subject = 'Tailwind'
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                Subject IN ('Tailwind', 'Bee girl')
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'ProactiveCasesState';
        filter.caseSubject = 'Tailwind';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'ProactiveCasesState';
        filter2.caseSubject = 'Tailwind;Bee girl';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @IsTest
    private static void testFilterOutlookScore() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                ContactId IN (
                    SELECT Contact__c
                    FROM Persistence_Outlook__c
                    WHERE Curr_Cont_Prediction_Level__c IN (0, 1, 2, 3)
                )
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                ContactId IN (
                    SELECT Contact__c
                    FROM Persistence_Outlook__c
                    WHERE Curr_Cont_Prediction_Level__c IN (0, 1, 2, 3, 4, 5)
                )
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'ProactiveCasesState';
        filter.outlookScore = 'very low';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'ProactiveCasesState';
        filter2.outlookScore = 'very low;low';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @IsTest
    private static void testFilterOutlookChange() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                Contact.Most_Recent_Outlook_Change_Direction__c = 1
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                Contact.Most_Recent_Outlook_Change_Direction__c IN (1, 0)
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'ProactiveCasesState';
        filter.outlookChange = 'up';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'ProactiveCasesState';
        filter2.outlookChange = 'down;up';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @IsTest
    private static void testFilterCaseCount() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT ContactId ContactId__alias, COUNT(Id)
            FROM Case
            WHERE ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
            HAVING COUNT(Id) = 1
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT ContactId ContactId__alias, COUNT(Id)
            FROM Case
            WHERE ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
            HAVING COUNT(Id) = 4
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'ProactiveCasesState';
        filter.caseCount = '1';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'ProactiveCasesState';
        filter2.caseCount = '4';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @IsTest
    private static void testFilterCreatedDate() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        Datetime startOftMinus3d = System.now().addDays(-3);
        startOftMinus3d = startOftMinus3d.addHours(-1 * startOftMinus3d.hour())
            .addMinutes(-1 * startOftMinus3d.minute())
            .addSeconds(-1 * startOftMinus3d.second());
        Datetime endOftMinus3d = System.now().addDays(-3);
        endOftMinus3d = endOftMinus3d.addSeconds(60 - 1 * endOftMinus3d.second())
            .addMinutes(60 - 1 * endOftMinus3d.minute())
            .addHours(24 - 1 * endOftMinus3d.hour());
        Datetime startOftMinus9d = System.now().addDays(-9);
        startOftMinus9d = startOftMinus9d.addHours(-1 * startOftMinus9d.hour())
            .addMinutes(-1 * startOftMinus9d.minute())
            .addSeconds(-1 * startOftMinus9d.second());
        Datetime endOftMinus9d = System.now().addDays(-9);
        endOftMinus9d = endOftMinus9d.addSeconds(60 - 1 * endOftMinus9d.second())
            .addMinutes(60 - 1 * endOftMinus9d.minute())
            .addHours(24 - 1 * endOftMinus9d.hour());

        List<AggregateResult> expectedStudents = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                CreatedDate <= :endOftMinus3d
                AND CreatedDate >= :startOftMinus9d
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                CreatedDate >= :startOftMinus3d
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        List<AggregateResult> expectedStudents3 = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                CreatedDate <= :endOftMinus3d
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        // Offset datetimes for timezone - AdvisorPortalFilterSectionController expects the date to be the date in Arizona
        // and then converts it to GMT for comparing to CreatedDate
        startOftMinus3d = startOftMinus3d.addHours(-7);
        endOftMinus3d = endOftMinus3d.addHours(-7);
        startOftMinus9d = startOftMinus9d.addHours(-7);
        endOftMinus9d = endOftMinus9d.addHours(-7);

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'ProactiveCasesState';
        filter.createdFromDate = startOftMinus9d.format('yyyy-MM-dd');
        filter.createdToDate = endOftMinus3d.format('yyyy-MM-dd');

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'ProactiveCasesState';
        filter2.createdFromDate = startOftMinus3d.format('yyyy-MM-dd');

        AdvisorPortalFilter filter3 = new AdvisorPortalFilter();
        filter3.career = 'UGRD';
        filter3.caseTypeState = 'ProactiveCasesState';
        filter3.createdToDate = endOftMinus3d.format('yyyy-MM-dd');

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );

        String resultsJSON3 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter3)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results3 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON3,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);

        System.assert(!expectedStudents3.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents3.size(), results3.size());
        assertCorrectReturned(expectedStudents3, results3);
    }

    @IsTest
    private static void testFilterFollowupDate() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        Date tPlus3d = System.today().addDays(3);
        Date tPlus9d = System.today().addDays(9);

        List<AggregateResult> expectedStudents = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                Followup_Date__c <= :tPlus9d
                AND Followup_Date__c >= :tPlus3d
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                Followup_Date__c >= :tPlus3d
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        List<AggregateResult> expectedStudents3 = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                Followup_Date__c <= :tPlus3d
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'ProactiveCasesState';
        filter.followUpFromDate = String.valueof(tPlus3d);
        filter.followUpToDate = String.valueof(tPlus9d);

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'ProactiveCasesState';
        filter2.followUpFromDate = String.valueof(tPlus3d);

        AdvisorPortalFilter filter3 = new AdvisorPortalFilter();
        filter3.career = 'UGRD';
        filter3.caseTypeState = 'ProactiveCasesState';
        filter3.followUpToDate = String.valueof(tPlus3d);

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );

        String resultsJSON3 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter3)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results3 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON3,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);

        System.assert(!expectedStudents3.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents3.size(), results3.size());
        assertCorrectReturned(expectedStudents3, results3);
    }

    @IsTest
    private static void testFilterPersistanceChangeDate() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        Date tMinus4d = System.today().addDays(-4);
        Date tMinus6d = System.today().addDays(-6);

        List<AggregateResult> expectedStudents = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
                AND ContactId IN (
                    SELECT Contact__c
                    FROM Persistence_Outlook__c
                    WHERE Change_Date__c >= :tMinus6d AND Change_Date__C <= :tMinus4d
                )
            GROUP BY ContactId
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
                AND ContactId IN (SELECT Contact__c FROM Persistence_Outlook__c WHERE Change_Date__c >= :tMinus4d)
            GROUP BY ContactId
        ];

        List<AggregateResult> expectedStudents3 = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
                AND ContactId IN (SELECT Contact__c FROM Persistence_Outlook__c WHERE Change_Date__C <= :tMinus4d)
            GROUP BY ContactId
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'ProactiveCasesState';
        filter.persistenceFromDate = String.valueof(tMinus6d);
        filter.persistenceToDate = String.valueof(tMinus4d);

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'ProactiveCasesState';
        filter2.persistenceFromDate = String.valueof(tMinus4d);

        AdvisorPortalFilter filter3 = new AdvisorPortalFilter();
        filter3.career = 'UGRD';
        filter3.caseTypeState = 'ProactiveCasesState';
        filter3.persistenceToDate = String.valueof(tMinus4d);

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );

        String resultsJSON3 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter3)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results3 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON3,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);

        System.assert(!expectedStudents3.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents3.size(), results3.size());
        assertCorrectReturned(expectedStudents3, results3);
    }

    @IsTest
    private static void testFilterAllStudents() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT Student__c ContactId__alias
            FROM Success_Student__c
            WHERE Student__c IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY Student__c
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT Student__c ContactId__alias
            FROM Success_Student__c
            WHERE Student__c IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c = 'Graduate')
            GROUP BY Student__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'AllCasesState';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'GRD';
        filter2.caseTypeState = 'AllCasesState';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
    }

    @IsTest
    private static void testFilterWatchlistCases() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT ContactId ContactId__alias
            FROM Case
            WHERE
                CC_Category__r.Name = 'Watchlist'
                AND ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c WHERE Career__c != 'Graduate')
            GROUP BY ContactId
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'WatchlistCasesState';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        assertCorrectReturned(expectedStudents, results);
    }

    @IsTest
    static void testMutlipleFiltersAtOnce() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        List<AggregateResult> expectedStudents = [
            SELECT ContactId ContactId__alias, COUNT(Id)
            FROM Case
            WHERE Subject = 'Found bug' AND Contact.Name = 'Ryan Castelli'
            GROUP BY ContactId
            HAVING COUNT(Id) = 1
        ];

        List<AggregateResult> expectedStudents2 = [
            SELECT Contact__c ContactId__alias
            FROM Student_Program_Plan__c
            WHERE
                Career__c != 'Graduate'
                AND Cohort__c = 'Junior'
                AND Contact__c IN (SELECT SG_Contact__c FROM Student_Group__c WHERE SG_PeopleSoft_Code__c = 'STGRP4')
            GROUP BY Contact__c
        ];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.career = 'UGRD';
        filter.caseTypeState = 'ProactiveCasesState';
        filter.studentString = 'Ryan Castelli';
        filter.caseSubject = 'Found bug';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.career = 'UGRD';
        filter2.caseTypeState = 'AllCasesState';
        filter2.academicLevel = 'Junior';
        filter2.studentGroupCode = 'STGRP4';

        Test.startTest();
        String resultsJSON = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter)
        );

        String resultsJSON2 = AdvisorPortalFilterSectionController.getFilteredCases(
            new List<Id>{ testUser.Id },
            JSON.serialize(filter2)
        );
        Test.stopTest();

        List<AdvisorPortalContact> results = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON,
            List<AdvisorPortalContact>.class
        );

        List<AdvisorPortalContact> results2 = (List<AdvisorPortalContact>) JSON.deserialize(
            resultsJSON2,
            List<AdvisorPortalContact>.class
        );

        System.assert(!expectedStudents.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents.size(), results.size());
        System.assertEquals(1, results[0].cases.size());
        assertCorrectReturned(expectedStudents, results);

        System.assert(!expectedStudents2.isEmpty(), 'Should have some matches - otherwise the test is pointless');
        System.assertEquals(expectedStudents2.size(), results2.size());
        assertCorrectReturned(expectedStudents2, results2);
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

    private static void assertCorrectReturned(
        List<AggregateResult> aggreagteStudentProgramPlans,
        List<AdvisorPortalContact> advisorPortalContacts
    ) {
        for (AggregateResult expectedStudent : aggreagteStudentProgramPlans) {
            boolean found = false;
            for (AdvisorPortalContact retrievedResult : advisorPortalContacts) {
                if (retrievedResult.portalContact.Id == expectedStudent.get('ContactId__alias'))
                    found = true;
            }
            if (!found) {
                System.assert(
                    false,
                    'Missing contact from results.  ' +
                    expectedStudent.get('ContactId__alias') +
                    ' was expected but not returned.'
                );
            }
        }
    }
}
