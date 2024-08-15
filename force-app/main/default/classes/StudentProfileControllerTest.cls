@isTest
private class StudentProfileControllerTest {
    @TestSetup
    private static void createTestData() {
        ContactFactory.DefaultContact contactBuilder = new ContactFactory.DefaultContact();
        Contact studentProfileContact = (Contact) contactBuilder.create()[0];
        studentProfileContact.EmplId__c = getStudentProfileContactEmplId();
        studentProfileContact.ASURite_ID__c = getStudentProfileContactAsurite();
        insert studentProfileContact;

        insert new StudentTerm__c(CurrTerm__c = '2000', PrevTerm__c = '1000', NextTerm__c = '3000');

        insert new Term__c(Name = 'Test 2000', PeopleSoft_Code__c = '2000', Year__c = '2019', Aid_Year__c = '2000');

        insert new Financial_Aid_Package__c(
            Aid_Year__c = '2000',
            Contact__c = studentProfileContact.Id,
            EFC_Range__c = 'Moderate'
        );

        insert new Student_Program_Plan__c(Contact__c = studentProfileContact.Id, Career__c = 'Undergraduate');
        insert new Student_Program_Plan__c(Contact__c = studentProfileContact.Id, Career__c = 'Graduate');
        insert new Student_Program_Plan__c(
            Contact__c = studentProfileContact.Id,
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

        // We use locations as a fallback to lookup campus name based on code if nice name isn't in payload from DPL
        insert new List<Location__c>{
            new Location__c(Name = 'Tempe', Location_Code__c = 'TEMPE', Location_Status__c = true),
            new Location__c(Name = 'West', Location_Code__c = 'WEST', Location_Status__c = true),
            new Location__c(Name = 'Poly', Location_Code__c = 'POLY', Location_Status__c = true)
        };

        // We use program/plan lookups from code to name for adivsing notes
        insert new List<Program__c>{
            new Program__c(Program_Code__c = 'GRES', Name = 'Ira A Fulton Engineering'),
            new Program__c(Program_Code__c = 'UGES', Name = 'Ira A Fulton Engineering')
        };
        insert new List<Plan__c>{
            new Plan__c(
                Plan_Code__c = 'ESCSEIMCS',
                Name = 'Comp Sci (Cybersecurity)',
                Plan_Status__c = true,
                Plan_Effective_Date__c = System.today()
            ),
            new Plan__c(
                Plan_Code__c = 'ESCSEBS',
                Name = 'Computer Science - BS',
                Plan_Status__c = true,
                Plan_Effective_Date__c = System.today()
            )
        };
    }

    @isTest
    private static void testInit() {
        PageReference studentProfile = Page.StudentProfile;
        StudentProfileController controller;
        Test.setCurrentPage(studentProfile);

        // With no Id
        controller = new StudentProfileController();
        controller.init();

        // With ContactId
        studentProfile.getParameters().put('contactId', getStudentProfileContactId());
        controller = new StudentProfileController();
        controller.init();
        System.assertEquals(getStudentProfileContactId(), controller.theContact.Id);

        // With EmplId
        studentProfile.getParameters().put('contactId', getStudentProfileContactEmplId());
        controller = new StudentProfileController();
        controller.init();
        System.assertEquals(getStudentProfileContactId(), controller.theContact.Id);
    }

    @isTest
    private static void financialNeedLevelDisplaySuccess() {
        PageReference studentProfile = Page.StudentProfile;
        studentProfile.getParameters().put('contactId', getStudentProfileContactId());
        Test.setCurrentPage(studentProfile);

        StudentProfileController controller = new StudentProfileController();
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
        Test.setCurrentPage(Page.StudentProfile);
        ApexPages.currentPage().getParameters().put('contactId', testContact.Id);
        StudentProfileController profile = new StudentProfileController();
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
        Test.setCurrentPage(Page.StudentProfile);
        ApexPages.currentPage().getParameters().put('contactId', testContact.Id);
        StudentProfileController profile = new StudentProfileController();
        profile.init();
        Boolean result = profile.getAccelerated();
        Test.stopTest();

        System.assert(result, 'Accelerated  was not detected correctly');
    }

    @isTest
    private static void testCreateCase() {
        String subjectIn = 'Hello World';
        String descriptionIn = 'Green Eggs and Ham';

        Contact testCon = [SELECT Id FROM Contact WHERE EMPLID__c = :getStudentProfileContactEmplId()];

        Case_Classification__c funcGrp = new Case_Classification__c(
            Name = 'Student Profile Create Case Func Grp',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
        );
        insert funcGrp;

        // Main test
        Test.startTest();
        String caseNum = StudentProfileController.createCase(
            descriptionIn,
            subjectIn,
            funcGrp.Id,
            getStudentProfileContactEmplId()
        );
        Test.stopTest();

        Assert.isTrue(caseNum != null, 'Expected case to be created');

        Case c = [
            SELECT Id, Subject, Description, ContactId, CC_Functional_Group__c
            FROM Case
            WHERE CaseNumber = :caseNum
        ];
        Assert.isTrue(c != null, 'Expected case to be created');

        Assert.areEqual(subjectIn, c.Subject);
        Assert.areEqual(descriptionIn, c.Description);
        Assert.areEqual(testCon.Id, c.ContactId);
        Assert.areEqual(funcGrp.Id, c.CC_Functional_Group__c);
    }

    @isTest
    private static void testGetEditMessages() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        Map<String, List<StudentProfileController.EditMessageWrapper>> wrap = StudentProfileController.getEditMessages(
            '1215721572'
        );
        Test.stopTest();
    }

    @isTest
    private static void testGetAwardStatusMap() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        Map<String, List<FinancialAidAwardWrapper.cls_term_awards>> wrap = StudentProfileController.getAwardStatusMap(
            '1215721572'
        );
        Test.stopTest();
    }

    @isTest
    private static void testGetChargeHistoryMap() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        Map<String, FinancialAidChargeHistoryWrapper.cls_charges> wrap = StudentProfileController.getChargeHistoryMap(
            '1215721572'
        );
        Test.stopTest();
    }

    @isTest
    private static void testGetFinancialAidAccountBalance() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        FinancialAidBalanceWrapper wrap = StudentProfileController.getFinancialAidAccountBalance('1215721572');
        Test.stopTest();
    }

    @isTest
    private static void testGetFinancialAidRefunds() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        FinancialAidRefundWrapper wrap = StudentProfileController.getFinancialAidRefunds('1215721572');
        Test.stopTest();
    }

    @isTest
    private static void testGetDepositStatus() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        DepositStatusWrapper wrap = StudentProfileController.getDepositStatus('1215721572');
        Test.stopTest();
    }

    @isTest
    private static void testGetRenewableAid() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        RenewableAidWrapper wrap = StudentProfileController.getRenewableAid('1215721572');
        Test.stopTest();
    }

    @isTest
    private static void testGetBookPayments() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        BookPaymentWrapper wrap = StudentProfileController.getBookPayments('1215721572');
        Test.stopTest();
    }

    @isTest
    private static void testGetTuitionResidencyStatus() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        TuitionResidencyWrapper tuitionWrapper = StudentProfileController.getTuitionResidencyStatus('1215721572');
        Test.stopTest();

        Assert.areEqual(1, tuitionWrapper.tuition_residency.size());
        Assert.areEqual('GRAD', tuitionWrapper.tuition_residency[0].acad_career);
        Assert.areEqual('Non-Resident', tuitionWrapper.tuition_residency[0].residency);
        Assert.areEqual('2207', tuitionWrapper.tuition_residency[0].effective_term);
        Assert.areEqual('2020-06-26', tuitionWrapper.tuition_residency[0].residency_dt);
        Assert.areEqual('ASU00', tuitionWrapper.tuition_residency[0].institution);
    }

    @IsTest
    private static void testGetAcademicProgress() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        Map<String, List<SAPWrapper.cls_sap>> acadProgressMp = StudentProfileController.getAcademicProgress(
            '1215721572'
        );
        Test.stopTest();

        // Two SAP (exlcude any before Aid_Year__c=2000 (based on StudentTerm__c and Term__c in setup))
        Assert.areEqual(2, acadProgressMp.size());

        // SAP for 2000
        Assert.isTrue(
            acadProgressMp.keySet().contains('2000'),
            'Should have SAP for the year 2000, but only has SAP for the years: ' + acadProgressMp.keySet()
        );
        Assert.areEqual(3, acadProgressMp.get('2000').size());
        Assert.areEqual('1997', acadProgressMp.get('2000')[0].term);
        Assert.areEqual('2001', acadProgressMp.get('2000')[1].term);
        Assert.areEqual('2004', acadProgressMp.get('2000')[2].term);

        // SAP for 2001
        Assert.isTrue(
            acadProgressMp.keySet().contains('2001'),
            'Should have SAP for the year 2001, but only has SAP for the years: ' + acadProgressMp.keySet()
        );
        Assert.areEqual(3, acadProgressMp.get('2001').size());
        Assert.areEqual('2007', acadProgressMp.get('2001')[0].term);
        Assert.areEqual('2011', acadProgressMp.get('2001')[1].term);
        Assert.areEqual('2011', acadProgressMp.get('2001')[2].term); // bug - but not fixing it on this ticket
    }

    @isTest
    private static void testGetTermClasses() {
        Contact testContact = new Contact(FirstName = 'Super', LastName = 'Gary', EMPLID__c = '1234567890');
        Database.insert(testContact);

        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        Map<String, StudentProfileController.TermClassesWrapper> termClassesMp = StudentProfileController.getTermClasses(
            '1234567890'
        );
        Test.stopTest();

        // One per term
        Assert.areEqual(2, termClassesMp.size());
        Assert.isTrue(termClassesMp.containsKey('2247'), 'Should have key for term of Fall 2024 (2247)');
        Assert.isTrue(termClassesMp.containsKey('2251'), 'Should have key for term of Spring 2025 (2251)');

        /****************** Fall 2024 ******************/
        Assert.areEqual(0, termClassesMp.get('2247').enrolledClasses.size());
        Assert.areEqual(1, termClassesMp.get('2247').droppedClasses.size());

        // Dropped ENG 101
        Assert.areEqual('Fall 2024', termClassesMp.get('2247').droppedClasses[0].termName);
        Assert.areEqual('2247', termClassesMp.get('2247').droppedClasses[0].termCode);
        Assert.areEqual('C', termClassesMp.get('2247').droppedClasses[0].session);
        Assert.areEqual('70860', termClassesMp.get('2247').droppedClasses[0].classNumber);
        Assert.areEqual('ENG 101', termClassesMp.get('2247').droppedClasses[0].catalogNumber);
        Assert.areEqual('First-Year Composition', termClassesMp.get('2247').droppedClasses[0].classTitle);
        Assert.areEqual('--', termClassesMp.get('2247').droppedClasses[0].topic);
        Assert.areEqual('3', termClassesMp.get('2247').droppedClasses[0].units);
        Assert.areEqual('DROP', termClassesMp.get('2247').droppedClasses[0].status);
        Assert.areEqual('Joel Salcido', termClassesMp.get('2247').droppedClasses[0].instructor);
        Assert.areEqual('Tu Th', termClassesMp.get('2247').droppedClasses[0].days);
        Assert.areEqual('07:30 AM - 08:45 AM', termClassesMp.get('2247').droppedClasses[0].times);
        Assert.areEqual('08/16/18 - 11/30/18', termClassesMp.get('2247').droppedClasses[0].dates);
        Assert.areEqual('Tempe', termClassesMp.get('2247').droppedClasses[0].location);
        Assert.areEqual('--', termClassesMp.get('2247').droppedClasses[0].grade);
        Assert.areEqual('--', termClassesMp.get('2247').droppedClasses[0].confOfParticipation);
        Assert.areEqual(false, termClassesMp.get('2247').droppedClasses[0].asr);
        Assert.areEqual(0, termClassesMp.get('2247').droppedClasses[0].asrList.size());
        Assert.areEqual(false, termClassesMp.get('2247').droppedClasses[0].enrolled);
        Assert.areEqual(false, termClassesMp.get('2247').droppedClasses[0].hasAcademicIntegrity);
        Assert.areEqual('--', termClassesMp.get('2247').droppedClasses[0].academicIntegrityGrade);

        // GPA and Credits
        Assert.areEqual('15.000', termClassesMp.get('2247').termEarnedUnits);
        Assert.areEqual('15.000', termClassesMp.get('2247').cumEarnedUnits);
        Assert.areEqual('3.84', termClassesMp.get('2247').termGpa);
        Assert.areEqual('3.84', termClassesMp.get('2247').cumGpa);

        /****************** Spring 2025 ******************/
        Assert.areEqual(2, termClassesMp.get('2251').enrolledClasses.size());
        Assert.areEqual(0, termClassesMp.get('2251').droppedClasses.size());

        // Enrolled CSE 548
        Assert.areEqual('Spring 2025', termClassesMp.get('2251').enrolledClasses[0].termName);
        Assert.areEqual('2251', termClassesMp.get('2251').enrolledClasses[0].termCode);
        Assert.areEqual('C', termClassesMp.get('2251').enrolledClasses[0].session);
        Assert.areEqual('27873', termClassesMp.get('2251').enrolledClasses[0].classNumber);
        Assert.areEqual('CSE 548', termClassesMp.get('2251').enrolledClasses[0].catalogNumber);
        Assert.areEqual('Adv Computer Network Security', termClassesMp.get('2251').enrolledClasses[0].classTitle);
        Assert.areEqual('--', termClassesMp.get('2251').enrolledClasses[0].topic);
        Assert.areEqual('3', termClassesMp.get('2251').enrolledClasses[0].units);
        Assert.areEqual('ENRL', termClassesMp.get('2251').enrolledClasses[0].status);
        Assert.areEqual('Abdulhakim Sabur\nRonald Dorn', termClassesMp.get('2251').enrolledClasses[0].instructor);
        Assert.areEqual('W', termClassesMp.get('2251').enrolledClasses[0].days);
        Assert.areEqual('10:30 AM - 11:45 AM', termClassesMp.get('2251').enrolledClasses[0].times);
        Assert.areEqual('01/10/22 - 04/29/22\n01/10/22 - 04/29/22', termClassesMp.get('2251').enrolledClasses[0].dates);
        Assert.areEqual('Tempe\niCourse', termClassesMp.get('2251').enrolledClasses[0].location);
        Assert.areEqual('A+', termClassesMp.get('2251').enrolledClasses[0].grade);
        Assert.areEqual('Y', termClassesMp.get('2251').enrolledClasses[0].confOfParticipation);
        Assert.areEqual(false, termClassesMp.get('2251').enrolledClasses[0].asr);
        Assert.areEqual(0, termClassesMp.get('2251').enrolledClasses[0].asrList.size());
        Assert.areEqual(true, termClassesMp.get('2251').enrolledClasses[0].enrolled);
        Assert.areEqual(false, termClassesMp.get('2251').enrolledClasses[0].hasAcademicIntegrity);
        Assert.areEqual('--', termClassesMp.get('2251').enrolledClasses[0].academicIntegrityGrade);

        // Enrolled CSE 515
        Assert.areEqual('Spring 2025', termClassesMp.get('2251').enrolledClasses[1].termName);
        Assert.areEqual('2251', termClassesMp.get('2251').enrolledClasses[1].termCode);
        Assert.areEqual('C', termClassesMp.get('2251').enrolledClasses[1].session);
        Assert.areEqual('79386', termClassesMp.get('2251').enrolledClasses[1].classNumber);
        Assert.areEqual('CSE 515', termClassesMp.get('2251').enrolledClasses[1].catalogNumber);
        Assert.areEqual('Multimedia and Web Databases', termClassesMp.get('2251').enrolledClasses[1].classTitle);
        Assert.areEqual('Simple Clips', termClassesMp.get('2251').enrolledClasses[1].topic);
        Assert.areEqual('3', termClassesMp.get('2251').enrolledClasses[1].units);
        Assert.areEqual('ENRL', termClassesMp.get('2251').enrolledClasses[1].status);
        Assert.areEqual(
            'K. Selcuk Candan\nSruthi Sathyamoorthy',
            termClassesMp.get('2251').enrolledClasses[1].instructor
        );
        Assert.areEqual('Tu Th', termClassesMp.get('2251').enrolledClasses[1].days);
        Assert.areEqual('10:30 AM - 11:45 AM', termClassesMp.get('2251').enrolledClasses[0].times);
        Assert.areEqual('01/10/22 - 04/29/22\n01/10/22 - 04/29/22', termClassesMp.get('2251').enrolledClasses[0].dates);
        Assert.areEqual('Tempe', termClassesMp.get('2251').enrolledClasses[1].location);
        Assert.areEqual('E', termClassesMp.get('2251').enrolledClasses[1].grade);
        Assert.areEqual('N', termClassesMp.get('2251').enrolledClasses[1].confOfParticipation);
        Assert.areEqual(true, termClassesMp.get('2251').enrolledClasses[1].asr);
        Assert.areEqual(1, termClassesMp.get('2251').enrolledClasses[1].asrList.size());
        Assert.areEqual('3', termClassesMp.get('2251').enrolledClasses[1].asrList[0].asrRptNo);
        Assert.areEqual('D', termClassesMp.get('2251').enrolledClasses[1].asrList[0].asrGrade);
        Assert.areEqual(
            'Contact instructor, Seek tutoring for this course, Meet with advisor',
            termClassesMp.get('2251').enrolledClasses[1].asrList[0].asrAction
        );
        Assert.areEqual(
            'Low quiz and/or exam score(s)',
            termClassesMp.get('2251').enrolledClasses[1].asrList[0].asrReason
        );
        Assert.areEqual('--', termClassesMp.get('2251').enrolledClasses[1].asrList[0].asrComment);
        Assert.areEqual(true, termClassesMp.get('2251').enrolledClasses[1].enrolled);
        Assert.areEqual(true, termClassesMp.get('2251').enrolledClasses[1].hasAcademicIntegrity);
        Assert.areEqual('XE', termClassesMp.get('2251').enrolledClasses[1].academicIntegrityGrade);

        // GPA for display
        Assert.areEqual('9.000', termClassesMp.get('2251').termEarnedUnits);
        Assert.areEqual('18.000', termClassesMp.get('2251').cumEarnedUnits);
        Assert.areEqual('4.22', termClassesMp.get('2251').termGpa);
        Assert.areEqual('4.00', termClassesMp.get('2251').cumGpa);
    }

    @IsTest
    private static void testGetTermClassesNotRunningError() {
        // Mock response
        StudentProfileCalloutMock mockCallout = new StudentProfileCalloutMock();
        mockCallout.dplRunning = false;
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Exception thrownError = null;

        // Main test
        Test.startTest();
        try {
            Map<String, StudentProfileController.TermClassesWrapper> termClassesMp = StudentProfileController.getTermClasses(
                '1234567890'
            );
        } catch (Exception ex) {
            thrownError = ex;
        }
        Test.stopTest();

        Assert.isInstanceOfType(
            thrownError,
            DataPotluck.DPLException.class,
            'Expected to throw an exception of type DataPotluck.DPLException, but actually threw ' +
            thrownError?.getTypeName()
        );
        Assert.isTrue(
            thrownError?.getMessage()?.contains('Not Found'),
            'Expected error message to contain "Not Found", but it instead said "' + thrownError?.getMessage() + '"'
        );
        // Error logged
        Case errorLoggerCase = [SELECT Id, Subject, Description FROM Case ORDER BY CreatedDate DESC LIMIT 1];
        Assert.isTrue(
            errorLoggerCase?.Subject?.contains('DataPotluck.DPLException'),
            'Expected error logger case for DataPotluck.DPLException, but subject instead said: "' +
                errorLoggerCase?.Subject +
                '"'
        );
    }

    @IsTest
    private static void testGetTermClassesNoPermsError() {
        // Mock response
        StudentProfileCalloutMock mockCallout = new StudentProfileCalloutMock();
        mockCallout.dplPermission = false;
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Exception thrownError = null;

        // Main test
        Test.startTest();
        try {
            Map<String, StudentProfileController.TermClassesWrapper> termClassesMp = StudentProfileController.getTermClasses(
                '1234567890'
            );
        } catch (Exception ex) {
            thrownError = ex;
        }
        Test.stopTest();

        Assert.isInstanceOfType(
            thrownError,
            DataPotluck.DPLException.class,
            'Expected to throw an exception of type DataPotluck.DPLException, but actually threw ' +
            thrownError?.getTypeName()
        );
        Assert.isTrue(
            thrownError?.getMessage()?.contains('unauthorized'),
            'Expected error message to contain "unauthorized", but it instead said "' + thrownError?.getMessage() + '"'
        );
        // Error logged
        Case errorLoggerCase = [SELECT Id, Subject, Description FROM Case ORDER BY CreatedDate DESC LIMIT 1];
        Assert.isTrue(
            errorLoggerCase?.Subject?.contains('DataPotluck.DPLException'),
            'Expected error logger case for DataPotluck.DPLException, but subject instead said: "' +
                errorLoggerCase?.Subject +
                '"'
        );
    }

    @IsTest
    private static void testGetComments() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        List<StudentProfileController.CommentWrapper> allComments = StudentProfileController.getComments('1215721572');
        Test.stopTest();

        // All 3 from comments API
        Assert.areEqual(3, allComments.size());

        // DESC date
        Long prevDt = null;
        for (StudentProfileController.CommentWrapper cmm : allComments) {
            Assert.isTrue(prevDt == null || cmm.commentDt < prevDt);
            prevDt = cmm.commentDt;
        }

        // Correct comment and metadata
        Assert.areEqual('0000000000', allComments[0].authorName);
        Assert.areEqual(null, allComments[0].authorUserId);
        Assert.areEqual(1612799284000L, allComments[0].commentDt);
        Assert.areEqual('COMMENT 3', allComments[0].comment);

        Assert.areEqual('Rowane Harris', allComments[1].authorName);
        Assert.areNotEqual(null, allComments[1].authorUserId);
        Assert.areEqual(1534252593000L, allComments[1].commentDt);
        Assert.areEqual('COMMENT 2', allComments[1].comment);

        Assert.areEqual('Carol Webber', allComments[2].authorName);
        Assert.areNotEqual(null, allComments[2].authorUserId);
        Assert.areEqual(1534179137000L, allComments[2].commentDt);
        Assert.areEqual('COMMENT 1', allComments[2].comment);
    }

    @IsTest
    private static void testGetCommentsNotRunningError() {
        // Mock response
        StudentProfileCalloutMock mockCallout = new StudentProfileCalloutMock();
        mockCallout.checklistApiRunning = false;
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Exception thrownError = null;

        // Main test
        Test.startTest();
        try {
            List<StudentProfileController.CommentWrapper> allComments = StudentProfileController.getComments(
                '1215721572'
            );
        } catch (Exception ex) {
            thrownError = ex;
        }
        Test.stopTest();

        Assert.isInstanceOfType(
            thrownError,
            StudentProfileChecklistComment.ChecklistAPIException.class,
            'Expected to throw an exception of type StudentProfileChecklistComment.ChecklistAPIException, but actually threw ' +
            thrownError?.getTypeName()
        );
        Assert.isTrue(
            thrownError?.getMessage()?.contains('503 Error, API is not running'),
            'Expected error message to contain "503 Error, API is not running", but it instead said "' +
                thrownError?.getMessage() +
                '"'
        );
        // Error logged
        Case errorLoggerCase = [SELECT Id, Subject, Description FROM Case ORDER BY CreatedDate DESC LIMIT 1];
        Assert.isTrue(
            errorLoggerCase?.Subject?.contains('StudentProfileChecklistComment.ChecklistAPIException'),
            'Expected error logger case for StudentProfileChecklistComment.ChecklistAPIException, but subject instead said: "' +
                errorLoggerCase?.Subject +
                '"'
        );
    }

    @IsTest
    private static void testGetCommentsNoPermsError() {
        // Mock response
        StudentProfileCalloutMock mockCallout = new StudentProfileCalloutMock();
        mockCallout.checklistApiPermission = false;
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Exception thrownError = null;

        // Main test
        Test.startTest();
        try {
            List<StudentProfileController.CommentWrapper> allComments = StudentProfileController.getComments(
                '1215721572'
            );
        } catch (Exception ex) {
            thrownError = ex;
        }
        Test.stopTest();

        Assert.isInstanceOfType(
            thrownError,
            StudentProfileChecklistComment.ChecklistAPIException.class,
            'Expected to throw an exception of type StudentProfileChecklistComment.ChecklistAPIException, but actually threw ' +
            thrownError?.getTypeName()
        );
        Assert.isTrue(
            thrownError?.getMessage()?.contains('Invalid Client'),
            'Expected error message to contain "Invalid Client", but it instead said "' +
                thrownError?.getMessage() +
                '"'
        );
        // Error logged
        Case errorLoggerCase = [SELECT Id, Subject, Description FROM Case ORDER BY CreatedDate DESC LIMIT 1];
        Assert.isTrue(
            errorLoggerCase?.Subject?.contains('StudentProfileChecklistComment.ChecklistAPIException'),
            'Expected error logger case for StudentProfileChecklistComment.ChecklistAPIException, but subject instead said: "' +
                errorLoggerCase?.Subject +
                '"'
        );
    }

    @IsTest
    private static void testGetAdvisingNotesComments() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        List<StudentProfileController.AdvisorNoteWrapper> allComments = StudentProfileController.getAdvisingNotes(
            '1215721572'
        );
        Test.stopTest();

        // 6, 3 from DPL, 3 from comments API
        Assert.areEqual(6, allComments.size());

        // DESC date
        Long prevDt = null;
        for (StudentProfileController.AdvisorNoteWrapper cmm : allComments) {
            Assert.isTrue(prevDt == null || cmm.commentDt < prevDt);
            prevDt = cmm.commentDt;
        }

        // From Checklist/Comments API
        Assert.areEqual('Kinberly Lopez Marquez', allComments[0].authorName);
        Assert.areNotEqual(null, allComments[0].authorUserId);
        Assert.areEqual('Ira A Fulton Engineering', allComments[0].programName);
        Assert.areEqual('Comp Sci (Cybersecurity)', allComments[0].planName);
        Assert.areEqual(1644150668000L, allComments[0].commentDt);
        Assert.areEqual('GRAD COMMENT 1', allComments[0].comment);

        Assert.areEqual('Kinberly Lopez Marquez', allComments[1].authorName);
        Assert.areNotEqual(null, allComments[1].authorUserId);
        Assert.areEqual('Ira A Fulton Engineering', allComments[1].programName);
        Assert.areEqual('Computer Science - BS', allComments[1].planName);
        Assert.areEqual(1644064268000L, allComments[1].commentDt);
        Assert.areEqual('GRAD COMMENT 2', allComments[1].comment);

        Assert.areEqual('0000000000', allComments[2].authorName);
        Assert.areEqual(null, allComments[2].authorUserId);
        Assert.areEqual('--', allComments[2].programName);
        Assert.areEqual('--', allComments[2].planName);
        Assert.areEqual(1643977868000L, allComments[2].commentDt);
        Assert.areEqual('GRAD COMMENT 3', allComments[2].comment);

        // From DPL
        Assert.areEqual('Wendy Gibson-Wright', allComments[3].authorName);
        Assert.areNotEqual(null, allComments[3].authorUserId);
        Assert.areEqual('Ira A Fulton Engineering', allComments[3].programName);
        Assert.areEqual('Comp Sci (Cybersecurity)', allComments[3].planName);
        Assert.areEqual(1615405105000L, allComments[3].commentDt);
        Assert.areEqual('DESCRIPTION 1', allComments[3].comment);

        Assert.areEqual('testnoname', allComments[4].authorName);
        Assert.areEqual(null, allComments[4].authorUserId);
        Assert.areEqual('--', allComments[4].programName);
        Assert.areEqual('--', allComments[4].planName);
        Assert.areEqual(1532984786000L, allComments[4].commentDt);
        Assert.areEqual('DESCRIPTION 3', allComments[4].comment);

        Assert.areEqual('Shawn Rudnick', allComments[5].authorName);
        Assert.areNotEqual(null, allComments[5].authorUserId);
        Assert.areEqual('Ira A Fulton Engineering', allComments[5].programName);
        Assert.areEqual('Computer Science - BS', allComments[5].planName);
        Assert.areEqual(1531945565000L, allComments[5].commentDt);
        Assert.areEqual('DESCRIPTION 2', allComments[5].comment);
    }

    @IsTest
    private static void testGetGuestAccess() {
        // Setup test contact for Guest EMPLID
        insert new Contact(
            FirstName = 'Anri',
            LastName = 'Guardia',
            Email = 'anri.guardia@test.test',
            EMPLID__c = '1228223297',
            ASURITE_ID__C = 'aguardi'
        );

        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        List<StudentProfileController.GuestAccessWrapper> gAccess = StudentProfileController.getGuestAccess(
            '1215721572'
        );
        Test.stopTest();

        // 7 from DPL, exclude with statusCode != AC and exclude one with no perms
        // +3 from checklist API
        Assert.areEqual(8, gAccess.size());

        // DESC date
        Long prevDt = null;
        for (StudentProfileController.GuestAccessWrapper ga : gAccess) {
            Assert.isTrue(prevDt == null || ga.commentTimestamp < prevDt);
            prevDt = ga.commentTimestamp;
        }

        // Correct comment and metadata
        Assert.areEqual('ASU_MYASU', gAccess[0].author);
        Assert.areEqual(1660898000000L, gAccess[0].commentTimestamp);
        Assert.areEqual(
            'CONSENT FOR ' + StudentProfileController.GUEST_ACCESS_CODE_MAP.get('HOUS') + ' TO --',
            gAccess[0].comment
        );

        Assert.areEqual('ASU_MYASU', gAccess[1].author);
        Assert.areEqual(1660806000000L, gAccess[1].commentTimestamp);
        Assert.areEqual(
            'My ASU GUEST ACCESS for ' +
                String.join(
                    new List<String>{
                        StudentProfileController.GUEST_ACCESS_CODE_MAP.get('ACAD'),
                        StudentProfileController.GUEST_ACCESS_CODE_MAP.get('ADMS'),
                        StudentProfileController.GUEST_ACCESS_CODE_MAP.get('FAID'),
                        StudentProfileController.GUEST_ACCESS_CODE_MAP.get('GRAD')
                    },
                    ', '
                ) +
                ' TO Rob',
            gAccess[1].comment
        );

        Assert.areEqual('ASU_MYASU', gAccess[2].author);
        Assert.areEqual(1660804000000L, gAccess[2].commentTimestamp);
        Assert.areEqual(
            'My ASU GUEST ACCESS for ' +
                String.join(
                    new List<String>{
                        StudentProfileController.GUEST_ACCESS_CODE_MAP.get('HOUS'),
                        StudentProfileController.GUEST_ACCESS_CODE_MAP.get('OTHR'),
                        StudentProfileController.GUEST_ACCESS_CODE_MAP.get('PERS'),
                        StudentProfileController.GUEST_ACCESS_CODE_MAP.get('PPLS'),
                        StudentProfileController.GUEST_ACCESS_CODE_MAP.get('TASK')
                    },
                    ', '
                ) +
                ' TO Anri Guardia',
            gAccess[2].comment
        );

        Assert.areEqual('ASU_MYASU', gAccess[3].author);
        Assert.areEqual(1660802000000L, gAccess[3].commentTimestamp);
        Assert.areEqual(
            'My ASU GUEST ACCESS for ' +
                StudentProfileController.GUEST_ACCESS_CODE_MAP.get('HOUS') +
                ' TO Arizona State University',
            gAccess[3].comment
        );

        Assert.areEqual('Anri Guardia', gAccess[4].author);
        Assert.areEqual(1660800000000L, gAccess[4].commentTimestamp);
        Assert.areEqual(
            'My ASU GUEST ACCESS for ' + StudentProfileController.GUEST_ACCESS_CODE_MAP.get('HOUS') + ' TO Father',
            gAccess[4].comment
        );

        Assert.areEqual('Anri Guardia', gAccess[5].author);
        Assert.areEqual(1644237068000L, gAccess[5].commentTimestamp);
        Assert.areEqual('FERPA COMMENT 1', gAccess[5].comment);

        Assert.areEqual('--', gAccess[6].author);
        Assert.areEqual(1644150668000L, gAccess[6].commentTimestamp);
        Assert.areEqual('FERPA COMMENT 2', gAccess[6].comment);

        Assert.areEqual('0000000000', gAccess[7].author);
        Assert.areEqual(1644064268000L, gAccess[7].commentTimestamp);
        Assert.areEqual('FERPA COMMENT 3', gAccess[7].comment);
    }

    @IsTest
    private static void testGetCreditByExam() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        // Main test
        Test.startTest();
        List<StudentProfileController.CreditByExamWrapper> allTransferWork = StudentProfileController.getCreditByExam(
            '1215721572'
        );
        Test.stopTest();

        // 5 unique tests with class equilvalents
        Assert.areEqual(5, allTransferWork.size());

        // Correct exam credits
        Assert.areEqual('United States Since 1865', allTransferWork[0].title);
        Assert.areEqual('HST 110', allTransferWork[0].courseTitle);
        Assert.areEqual('4', allTransferWork[0].score);
        Assert.areEqual('3', allTransferWork[0].unitsTransferred);

        Assert.areEqual('General Chemistry I', allTransferWork[1].title);
        Assert.areEqual('CHM 113', allTransferWork[1].courseTitle);
        Assert.areEqual('5', allTransferWork[1].score);
        Assert.areEqual('3', allTransferWork[1].unitsTransferred);

        Assert.areEqual('Principles of Programming', allTransferWork[2].title);
        Assert.areEqual('CSE 110', allTransferWork[2].courseTitle);
        Assert.areEqual('5', allTransferWork[2].score);
        Assert.areEqual('3', allTransferWork[2].unitsTransferred);

        Assert.areEqual('United States to 1865', allTransferWork[3].title);
        Assert.areEqual('HST 109', allTransferWork[3].courseTitle);
        Assert.areEqual('0', allTransferWork[3].score);
        Assert.areEqual('3', allTransferWork[3].unitsTransferred);

        Assert.areEqual('General Chemistry II', allTransferWork[4].title);
        Assert.areEqual('CHM 116', allTransferWork[4].courseTitle);
        Assert.areEqual('0', allTransferWork[4].score);
        Assert.areEqual('3', allTransferWork[4].unitsTransferred);
    }

    @IsTest
    private static void testGetCreditByExamNotRunningError() {
        // Mock response
        StudentProfileCalloutMock mockCallout = new StudentProfileCalloutMock();
        mockCallout.transferWorkApiRunning = false;
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Exception thrownError = null;

        // Main test
        Test.startTest();
        try {
            List<StudentProfileController.CreditByExamWrapper> allTransferWork = StudentProfileController.getCreditByExam(
                '1215721572'
            );
        } catch (Exception ex) {
            thrownError = ex;
        }
        Test.stopTest();

        Assert.isInstanceOfType(
            thrownError,
            StudentProfileTransferWork.TrasnferWorkAPIException.class,
            'Expected to throw an exception of type StudentProfileTransferWork.TrasnferWorkAPIException, but actually threw ' +
            thrownError?.getTypeName()
        );
        Assert.isTrue(
            thrownError?.getMessage()?.contains('503 Error, API is not running'),
            'Expected error message to contain "503 Error, API is not running", but it instead said "' +
                thrownError?.getMessage() +
                '"'
        );
        // Error logged
        Case errorLoggerCase = [SELECT Id, Subject, Description FROM Case ORDER BY CreatedDate DESC LIMIT 1];
        Assert.isTrue(
            errorLoggerCase?.Subject?.contains('StudentProfileTransferWork.TrasnferWorkAPIException'),
            'Expected error logger case for StudentProfileTransferWork.TrasnferWorkAPIException, but subject instead said: "' +
                errorLoggerCase?.Subject +
                '"'
        );
    }

    @IsTest
    private static void testGetCreditByExamNoPermsError() {
        // Mock response
        StudentProfileCalloutMock mockCallout = new StudentProfileCalloutMock();
        mockCallout.transferWorkApiPermission = false;
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Exception thrownError = null;

        // Main test
        Test.startTest();
        try {
            List<StudentProfileController.CreditByExamWrapper> allTransferWork = StudentProfileController.getCreditByExam(
                '1215721572'
            );
        } catch (Exception ex) {
            thrownError = ex;
        }
        Test.stopTest();

        Assert.isInstanceOfType(
            thrownError,
            StudentProfileTransferWork.TrasnferWorkAPIException.class,
            'Expected to throw an exception of type StudentProfileTransferWork.TrasnferWorkAPIException, but actually threw ' +
            thrownError?.getTypeName()
        );
        Assert.isTrue(
            thrownError?.getMessage()?.contains('Invalid Client'),
            'Expected error message to contain "Invalid Client", but it instead said "' +
                thrownError?.getMessage() +
                '"'
        );
        // Error logged
        Case errorLoggerCase = [SELECT Id, Subject, Description FROM Case ORDER BY CreatedDate DESC LIMIT 1];
        Assert.isTrue(
            errorLoggerCase?.Subject?.contains('StudentProfileTransferWork.TrasnferWorkAPIException'),
            'Expected error logger case for StudentProfileTransferWork.TrasnferWorkAPIException, but subject instead said: "' +
                errorLoggerCase?.Subject +
                '"'
        );
    }

    private static String getStudentProfileContactEmplId() {
        return '1203436008';
    }
    private static String getStudentProfileContactId() {
        return [SELECT Id FROM Contact WHERE EmplId__c = :getStudentProfileContactEmplId() LIMIT 1].Id;
    }
    private static String getStudentProfileContactAsurite() {
        return 'test20test';
    }
}
