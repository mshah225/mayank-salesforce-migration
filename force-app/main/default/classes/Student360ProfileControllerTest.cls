@isTest
private class Student360ProfileControllerTest {
    @TestSetup
    private static void createTestData() {
        ContactFactory.DefaultContact contactBuilder = new ContactFactory.DefaultContact();
        Contact student360ProfileContact = (Contact) contactBuilder.create()[0];
        student360ProfileContact.EmplId__c = getStudent360ProfileContactEmplId();
        student360ProfileContact.ASURite_ID__c = getStudent360ProfileContactAsurite();
        insert student360ProfileContact;

        insert new StudentTerm__c(CurrTerm__c = '2000', PrevTerm__c = '1000', NextTerm__c = '3000');

        insert new Term__c(Name = 'Test 2000', PeopleSoft_Code__c = '2000', Year__c = '2019', Aid_Year__c = '2000');

        insert new Financial_Aid_Package__c(
            Aid_Year__c = '2000',
            Contact__c = student360ProfileContact.Id,
            EFC_Range__c = 'Moderate'
        );

        insert new Student_Program_Plan__c(Contact__c = student360ProfileContact.Id, Career__c = 'Undergraduate');
        insert new Student_Program_Plan__c(Contact__c = student360ProfileContact.Id, Career__c = 'Graduate');
        insert new Student_Program_Plan__c(
            Contact__c = student360ProfileContact.Id,
            Career__c = 'Graduate',
            Status__c = 'Active in Program',
            Primary_Flag__c = true,
            Requirement_Term__c = '2000'
        );

        UserFactory.DefaultUser userBuilder = new UserFactory.DefaultUser();
        User testUser1 = (User) userBuilder.create()[0];
        testUser1.FederationIdentifier = 'te_FedId1@admin.asu.edu';
        User testUser2 = (User) userBuilder.create()[0];
        testUser2.FederationIdentifier = 'te_FedId2@admin.asu.edu';
        List<User> exampleUsers = new List<User>();
        exampleUsers.add(testUser1);
        exampleUsers.add(testUser2);
        insert exampleUsers;
    }

    @isTest
    private static void testInit() {
        PageReference student360Profile = Page.Student360Profile;
        Student360ProfileController controller;
        Test.setCurrentPage(student360Profile);

        // With no Id
        controller = new Student360ProfileController();
        controller.init();

        // With ContactId
        student360Profile.getParameters().put('contactId', getStudent360ProfileContactId());
        controller = new Student360ProfileController();
        controller.init();
        System.assertEquals(getStudent360ProfileContactId(), controller.theContact.Id);

        // With EmplId
        student360Profile.getParameters().put('contactId', getStudent360ProfileContactEmplId());
        controller = new Student360ProfileController();
        controller.init();
        System.assertEquals(getStudent360ProfileContactId(), controller.theContact.Id);
    }

    @isTest
    private static void financialNeedLevelDisplaySuccess() {
        PageReference student360Profile = Page.Student360Profile;
        student360Profile.getParameters().put('contactId', getStudent360ProfileContactId());
        Test.setCurrentPage(student360Profile);

        Student360ProfileController controller = new Student360ProfileController();
        controller.init();

        System.assertEquals('2000', controller.getAidYear());
        System.assertEquals('Moderate', controller.financialAidPackage.EFC_Range__c);
    }

    @IsTest
    private static void getWICHE() {
        Contact testContact = new Contact(FirstName = 'Super', LastName = 'Gary', EMPLID__c = '1234567890');
        Database.insert(testContact);

        Student_Group__c testGroup = new Student_Group__c(
            SG_Contact__c = testContact.Id,
            SG_PeopleSoft_Code__c = 'WRGP',
            SG_Status__c = true
        );
        Database.insert(testGroup);

        Test.startTest();
        Test.setCurrentPage(Page.Student360Profile);
        ApexPages.currentPage().getParameters().put('contactId', testContact.Id);
        Student360ProfileController profile = new Student360ProfileController();
        profile.init();
        Boolean result = profile.getWICHE();
        Test.stopTest();

        System.assert(result, 'WICHE was not detected correctly');
    }

    @IsTest
    private static void getAccelerated() {
        Contact testContact = new Contact(FirstName = 'Super', LastName = 'Gary', EMPLID__c = '1234567890');
        Database.insert(testContact);

        Student_Group__c testGroup = new Student_Group__c(
            SG_Contact__c = testContact.Id,
            SG_PeopleSoft_Code__c = 'GRAI',
            SG_Status__c = true
        );
        Database.insert(testGroup);

        Test.startTest();
        Test.setCurrentPage(Page.Student360Profile);
        ApexPages.currentPage().getParameters().put('contactId', testContact.Id);
        Student360ProfileController profile = new Student360ProfileController();
        profile.init();
        Boolean result = profile.getAccelerated();
        Test.stopTest();

        System.assert(result, 'Accelerated  was not detected correctly');
    }

    @IsTest
    private static void testGetPSAdvisorNotes() {
        String jsonAdvisorNotes =
            '[' +
            '{' +
            '"CREATEOPRID__c":"te_FedId1", ' +
            '"DisplayUrl":"www.exampleurl1.example", ' +
            '"NAME__c":"example1 name"' +
            '}, ' +
            '{' +
            '"CREATEOPRID__c":"te_FedId2", ' +
            '"DisplayUrl":"www.exampleurl2.example", ' +
            '"NAME__c":"example2 name"' +
            '}, ' +
            '{' +
            '"CREATEOPRID__c":"te_FedId1", ' +
            '"DisplayUrl":"www.exampleurl3.example", ' +
            '"NAME__c":"example3 name"' +
            '}' +
            ']';

        List<Student360ProfileController.AdvisingNoteWrapper> allNotes = Student360ProfileController.getPSAdvisorNotes(
            'testEmplId',
            jsonAdvisorNotes
        );

        System.assertEquals(3, allNotes.size());
        System.assertEquals('www.exampleurl1.example', allNotes[0].note.DisplayUrl);
        System.assertEquals('www.exampleurl2.example', allNotes[1].note.DisplayUrl);
        System.assertEquals('www.exampleurl3.example', allNotes[2].note.DisplayUrl);
    }

    @IsTest
    private static void testGetComments() {
        String jsonComments =
            '[' +
            '{' +
            '"COMNT_ID__c":"te_9900990099_1", ' +
            '"DisplayUrl":"www.exampleurl1.example", ' +
            '"NAME__c":"example1 name", ' +
            '"COMMENTS__c":"example1 comments"' +
            '}, ' +
            '{' +
            '"COMNT_ID__c":"te_9900990099_2", ' +
            '"DisplayUrl":"www.exampleurl2.example", ' +
            '"NAME__c":"example2 name", ' +
            '"COMMENTS__c":"example2 comments"' +
            '}, ' +
            '{' +
            '"COMNT_ID__c":"te_9900990099_1", ' +
            '"DisplayUrl":"www.exampleurl3.example", ' +
            '"NAME__c":"example3 name", ' +
            '"COMMENTS__c":"example3 comments"' +
            '}' +
            ']';

        List<Student360ProfileController.CommentWrapper> allComments = Student360ProfileController.getComments(
            'testEmplId',
            jsonComments
        );

        System.assertEquals(3, allComments.size());
        System.assertEquals('example1 comments', allComments[0].comment.COMMENTS__c);
        System.assertEquals('example2 comments', allComments[1].comment.COMMENTS__c);
        System.assertEquals('example3 comments', allComments[2].comment.COMMENTS__c);
    }

    @IsTest
    private static void testSortClasses() {
        List<SortableClass> sortedClasses;
        String listOfClassesJSON =
            '[' +
            '{' +
            '"DisplayUrl":"www.exampleurl1.example", ' +
            '"CLASS_DESCR__c":"aaa Title 1", ' +
            '"CLASS_NBR__c":"bbb Class 2", ' +
            '"SSR_MTG_LOC_LONG__c":"ccc Location 3"' +
            '}, ' +
            '{' +
            '"DisplayUrl":"www.exampleurl2.example", ' +
            '"CLASS_DESCR__c":"bbb Title 2", ' +
            '"CLASS_NBR__c":"ccc Class 3", ' +
            '"SSR_MTG_LOC_LONG__c":"aaa Location 1"' +
            '}, ' +
            '{' +
            '"DisplayUrl":"www.exampleurl3.example", ' +
            '"CLASS_DESCR__c":"ccc Title 3", ' +
            '"CLASS_NBR__c":"aaa Class 1", ' +
            '"SSR_MTG_LOC_LONG__c":"bbb Location 2"' +
            '}' +
            ']';

        // Sort properly by Title
        sortedClasses = Student360ProfileController.sortClasses('Title', listOfClassesJSON, true);
        System.assertEquals(3, sortedClasses.size());
        System.assertEquals('www.exampleurl1.example', sortedClasses[0].classInfo.DisplayUrl);
        System.assertEquals('www.exampleurl2.example', sortedClasses[1].classInfo.DisplayUrl);
        System.assertEquals('www.exampleurl3.example', sortedClasses[2].classInfo.DisplayUrl);

        // Sort properly by Title Reversed
        sortedClasses = Student360ProfileController.sortClasses('Title', listOfClassesJSON, false);
        System.assertEquals(3, sortedClasses.size());
        System.assertEquals('www.exampleurl3.example', sortedClasses[0].classInfo.DisplayUrl);
        System.assertEquals('www.exampleurl2.example', sortedClasses[1].classInfo.DisplayUrl);
        System.assertEquals('www.exampleurl1.example', sortedClasses[2].classInfo.DisplayUrl);

        // Sort properly by Title
        sortedClasses = Student360ProfileController.sortClasses('Class', listOfClassesJSON, true);
        System.assertEquals(3, sortedClasses.size());
        System.assertEquals('www.exampleurl3.example', sortedClasses[0].classInfo.DisplayUrl);
        System.assertEquals('www.exampleurl1.example', sortedClasses[1].classInfo.DisplayUrl);
        System.assertEquals('www.exampleurl2.example', sortedClasses[2].classInfo.DisplayUrl);

        // Sort properly by Title
        sortedClasses = Student360ProfileController.sortClasses('Location', listOfClassesJSON, true);
        System.assertEquals(3, sortedClasses.size());
        System.assertEquals('www.exampleurl2.example', sortedClasses[0].classInfo.DisplayUrl);
        System.assertEquals('www.exampleurl3.example', sortedClasses[1].classInfo.DisplayUrl);
        System.assertEquals('www.exampleurl1.example', sortedClasses[2].classInfo.DisplayUrl);
    }

    @IsTest
    private static void testSortExams() {
        List<SortableCreditByExam> sortedExams;
        String listOfExamsJSON =
            '[' +
            '{' +
            '"DisplayUrl":"www.exampleurl1.example", ' +
            '"TITLE__c":"aaa Title 1", ' +
            '"SCORE__c":"222.22", ' +
            '"COURSE_TITLE__c":"ccc Course Title 3"' +
            '}, ' +
            '{' +
            '"DisplayUrl":"www.exampleurl2.example", ' +
            '"TITLE__c":"bbb Title 2", ' +
            '"SCORE__c":"111.11", ' +
            '"COURSE_TITLE__c":"aaa Course Title 1"' +
            '}, ' +
            '{' +
            '"DisplayUrl":"www.exampleurl3.example", ' +
            '"TITLE__c":"ccc Title 3", ' +
            '"SCORE__c":"333.33", ' +
            '"COURSE_TITLE__c":"bbb Course Title 2"' +
            '}' +
            ']';

        List<PS_ASU_SP_TRNSFR_V__x> listOfExams = (List<PS_ASU_SP_TRNSFR_V__x>) JSON.deserialize(
            listOfExamsJSON,
            List<PS_ASU_SP_TRNSFR_V__x>.class
        );

        // Sort properly by Title
        sortedExams = Student360ProfileController.sortExams('Title', listOfExams, true);
        System.assertEquals(3, sortedExams.size());
        System.assertEquals('www.exampleurl1.example', sortedExams[0].examInfo.DisplayUrl);
        System.assertEquals('www.exampleurl2.example', sortedExams[1].examInfo.DisplayUrl);
        System.assertEquals('www.exampleurl3.example', sortedExams[2].examInfo.DisplayUrl);

        // Sort properly by Title Reversed
        sortedExams = Student360ProfileController.sortExams('Title', listOfExams, false);
        System.assertEquals(3, sortedExams.size());
        System.assertEquals('www.exampleurl3.example', sortedExams[0].examInfo.DisplayUrl);
        System.assertEquals('www.exampleurl2.example', sortedExams[1].examInfo.DisplayUrl);
        System.assertEquals('www.exampleurl1.example', sortedExams[2].examInfo.DisplayUrl);

        // Sort properly by Title
        sortedExams = Student360ProfileController.sortExams('Score', listOfExams, true);
        System.assertEquals(3, sortedExams.size());
        System.assertEquals('www.exampleurl3.example', sortedExams[0].examInfo.DisplayUrl);
        System.assertEquals('www.exampleurl1.example', sortedExams[1].examInfo.DisplayUrl);
        System.assertEquals('www.exampleurl2.example', sortedExams[2].examInfo.DisplayUrl);

        // Sort properly by Title
        sortedExams = Student360ProfileController.sortExams('Course Title', listOfExams, true);
        System.assertEquals(3, sortedExams.size());
        System.assertEquals('www.exampleurl2.example', sortedExams[0].examInfo.DisplayUrl);
        System.assertEquals('www.exampleurl3.example', sortedExams[1].examInfo.DisplayUrl);
        System.assertEquals('www.exampleurl1.example', sortedExams[2].examInfo.DisplayUrl);
    }

    @IsTest
    private static void testGetClassesData() {
        String classListJson =
            '[' +
            '{' +
            '"DisplayUrl":"www.exampleurl1.example", ' +
            '"STDNT_ENRL_STATUS__c":"E", ' +
            '"ENRL_STATUS_REASON__c":"ENRL",' +
            '"STRM__c":"example1 STRM__c",' +
            '"SESSION_CODE__c":"example1 SESSION_CODE__c",' +
            '"TERM_DESCR30__c":"example1 TERM_DESCR30__c"' +
            '}, ' +
            '{' +
            '"DisplayUrl":"www.exampleurl2.example", ' +
            '"STDNT_ENRL_STATUS__c":"X", ' +
            '"ENRL_STATUS_REASON__c":"ENRL",' +
            '"STRM__c":"example2 STRM__c",' +
            '"SESSION_CODE__c":"example2 SESSION_CODE__c",' +
            '"TERM_DESCR30__c":"example2 TERM_DESCR30__c"' +
            '},' +
            '{' +
            '"DisplayUrl":"www.exampleurl3.example", ' +
            '"STDNT_ENRL_STATUS__c":"E", ' +
            '"ENRL_STATUS_REASON__c":"XXXX",' +
            '"STRM__c":"example3 STRM__c",' +
            '"SESSION_CODE__c":"example3 SESSION_CODE__c",' +
            '"TERM_DESCR30__c":"example3 TERM_DESCR30__c"' +
            '},' +
            '{' +
            '"DisplayUrl":"www.exampleurl4.example", ' +
            '"STDNT_ENRL_STATUS__c":"X", ' +
            '"ENRL_STATUS_REASON__c":"XXXX",' +
            '"STRM__c":"example4 STRM__c",' +
            '"SESSION_CODE__c":"example4 SESSION_CODE__c",' +
            '"TERM_DESCR30__c":"example4 TERM_DESCR30__c"' +
            '}' +
            ']';
        String asrListJson =
            '[' +
            '{' +
            '"DisplayUrl":"www.exampleurl1.example", ' +
            '"STRM__c":"example1 STRM__c", ' +
            '"SESSION_CODE__c":"example1 SESSION_CODE__c", ' +
            '"CLASS_NBR__c":"example1 CLASS_NBR__c"' +
            '}, ' +
            '{' +
            '"DisplayUrl":"www.exampleurl2.example", ' +
            '"STRM__c":"example2 STRM__c", ' +
            '"SESSION_CODE__c":"example2 SESSION_CODE__c", ' +
            '"CLASS_NBR__c":"example2 CLASS_NBR__c"' +
            '}, ' +
            '{' +
            '"DisplayUrl":"www.exampleurl3.example", ' +
            '"STRM__c":"example3 STRM__c", ' +
            '"SESSION_CODE__c":"example3 SESSION_CODE__c", ' +
            '"CLASS_NBR__c":"example3 CLASS_NBR__c"' +
            '}' +
            ']';

        Student360ProfileController.ClassesWrapper classData = Student360ProfileController.getClassesData(
            classListJson,
            asrListJson
        );

        // Check asrListJson related
        System.assertEquals(3, classData.asrClasses.size());
        System.assert(classData.asrClasses.contains('example1 STRM__c|example1 SESSION_CODE__c|example1 CLASS_NBR__c'));
        System.assert(classData.asrClasses.contains('example2 STRM__c|example2 SESSION_CODE__c|example2 CLASS_NBR__c'));
        System.assert(classData.asrClasses.contains('example3 STRM__c|example3 SESSION_CODE__c|example3 CLASS_NBR__c'));

        // Check classListJson enrolled
        System.assertEquals(1, classData.enrolledClasses.size());
        System.assertEquals('www.exampleurl1.example', classData.enrolledClasses[0].DisplayUrl);

        // Check classListJson dropped
        System.assertEquals(3, classData.droppedClasses.size());
        System.assertEquals('www.exampleurl2.example', classData.droppedClasses[0].DisplayUrl);
        System.assertEquals('www.exampleurl3.example', classData.droppedClasses[1].DisplayUrl);
        System.assertEquals('www.exampleurl4.example', classData.droppedClasses[2].DisplayUrl);

        // Check classListJson classTerms
        System.assertEquals(5, classData.classTerms.size());
        System.assert(classData.classTerms.contains('example1 STRM__c|example1 TERM_DESCR30__c'));
        System.assert(classData.classTerms.contains('example2 STRM__c|example2 TERM_DESCR30__c'));
        System.assert(classData.classTerms.contains('example3 STRM__c|example3 TERM_DESCR30__c'));
        System.assert(classData.classTerms.contains('example4 STRM__c|example4 TERM_DESCR30__c'));
        System.assert(classData.classTerms.contains('All|All'));

        // Check classListJson classTerms
        System.assertEquals(5, classData.classTerms.size());
        System.assert(classData.classSessions.contains('example1 SESSION_CODE__c'));
        System.assert(classData.classSessions.contains('example2 SESSION_CODE__c'));
        System.assert(classData.classSessions.contains('example3 SESSION_CODE__c'));
        System.assert(classData.classSessions.contains('example4 SESSION_CODE__c'));
        System.assert(classData.classSessions.contains('All'));
    }

    private static String getStudent360ProfileContactEmplId() {
        return '1203436008';
    }
    private static String getStudent360ProfileContactId() {
        return [SELECT Id FROM Contact WHERE EmplId__c = :getStudent360ProfileContactEmplId() LIMIT 1].Id;
    }
    private static String getStudent360ProfileContactAsurite() {
        return 'test20test';
    }
}