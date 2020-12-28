@IsTest
private class AdvisorPortalFilterSectionControllerTest {
    @TestSetup
    static void setUpTest() {
        TestDataFactory.createAdvisorStudents(TestDataFactory.createAdvisorPods(1), 1);
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

        List<Case> testCases = TestDataFactory.createCases(3);
        Integer i = 0;
        for (Case c : testCases) {
            c.ContactId = testContact.Id;
            c.Subject = 'Subject ' + i;
            c.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
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

        List<Case> testCases = TestDataFactory.createCases(3);
        Integer i = 0;
        for (Case c : testCases) {
            c.ContactId = testContact.Id;
            c.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
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
            IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach'),
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

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        testContact1.EmplId__c = '0011221100';
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        testContact2.ASURite_ID__c = 'testid_1';
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Location__c testCampus1 = new Location__c(Location_Code__c = '0011221100', Name = 'test-loc-ap-r1');
        Location__c testCampus2 = new Location__c(Location_Code__c = '0011221101', Name = 'test-loc-ap-r2');
        insert new List<Location__c>{ testCampus1, testCampus2 };

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        testContact1.EmplId__c = '0011221100';
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        testContact2.ASURite_ID__c = 'testid_1';
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        Student_Program_Plan__c studentProgramPlan1 = new Student_Program_Plan__c(
            Contact__c = testContact1.Id,
            Campus__c = testCampus1.Id
        );
        Student_Program_Plan__c studentProgramPlan2 = new Student_Program_Plan__c(
            Contact__c = testContact2.Id,
            Campus__c = testCampus2.Id
        );

        insert new List<Student_Program_Plan__c>{ studentProgramPlan1, studentProgramPlan2 };

        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.campus = 'test-loc-ap-r2';
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact2.Id, results[0].portalContact.Id, 'Should get second test contact');
    }

    @IsTest
    private static void testAcademicLevelFilter() {
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        Student_Program_Plan__c studentProgramPlan1 = new Student_Program_Plan__c(
            Contact__c = testContact1.Id,
            Cohort__c = 'test-cohort-1'
        );
        Student_Program_Plan__c studentProgramPlan2 = new Student_Program_Plan__c(
            Contact__c = testContact2.Id,
            Cohort__c = 'test-cohort-2'
        );

        insert new List<Student_Program_Plan__c>{ studentProgramPlan1, studentProgramPlan2 };

        AdvisorPortalFilter filter = new AdvisorPortalFilter();

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        Student_Group__c testSG1 = new Student_Group__c(
            SG_Contact__c = testContact1.Id,
            SG_PeopleSoft_Code__c = 'testapr1',
            SG_Status__c = true
        );
        Student_Group__c testSG2 = new Student_Group__c(
            SG_Contact__c = testContact2.Id,
            SG_PeopleSoft_Code__c = 'testapr2',
            SG_Status__c = true
        );
        insert new List<Student_Group__c>{ testSG1, testSG2 };

        AdvisorPortalFilter filter = new AdvisorPortalFilter();

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

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        Student_Program_Plan__c studentProgramPlan1 = new Student_Program_Plan__c(
            Contact__c = testContact1.Id,
            Residency__c = 'International'
        );
        Student_Program_Plan__c studentProgramPlan2 = new Student_Program_Plan__c(
            Contact__c = testContact2.Id,
            Residency__c = 'Non-Resident'
        );

        insert new List<Student_Program_Plan__c>{ studentProgramPlan1, studentProgramPlan2 };

        AdvisorPortalFilter filter = new AdvisorPortalFilter();

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.Status = 'New';
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.Status = 'Outreach Required';
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.Status = 'New';
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.Status = 'Outreach Required';
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.Status = 'New';
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
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
            Name = 'test-category-ap-r1',
            Active__c = true,
            Visible__c = true,
            Parent__c = parent.Id,
            RecordTypeId = Schema.SObjectType.Case_Classification__c.getRecordTypeInfosByName()
                .get('Category')
                .getRecordTypeId()
        );
        Case_Classification__c testClassification2 = new Case_Classification__c(
            Name = 'test-category-ap-r2',
            Active__c = true,
            Visible__c = true,
            Parent__c = parent.Id,
            RecordTypeId = Schema.SObjectType.Case_Classification__c.getRecordTypeInfosByName()
                .get('Category')
                .getRecordTypeId()
        );

        insert new List<Case_Classification__c>{ testClassification1, testClassification2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.CC_Functional_Group__c = parent.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.CC_Functional_Group__c = parent.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.CC_Functional_Group__c = parent.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.CC_Functional_Group__c = parent.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.CC_Functional_Group__c = parent.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        testCase1.CC_Category__c = testClassification1.Id;
        testCase2.CC_Category__c = testClassification2.Id;
        testCase3.CC_Category__c = testClassification1.Id;
        testCase4.CC_Category__c = testClassification2.Id;
        testCase5.CC_Category__c = testClassification1.Id;

        update new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.Subject = 'test-subject-ap-r1';
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.Subject = 'test-subject-ap-r2';
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.Subject = 'test-subject-ap-r1';
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.Subject = 'test-subject-ap-r2';
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.Subject = 'test-subject-ap-r1';
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        Persistence_Outlook__c testPersistenceOutlook1 = new Persistence_Outlook__c(
            Contact__c = testContact1.Id,
            Curr_Cont_Prediction_Level__c = 4
        );
        Persistence_Outlook__c testPersistenceOutlook2 = new Persistence_Outlook__c(
            Contact__c = testContact2.Id,
            Curr_Cont_Prediction_Level__c = 6
        );

        insert new List<Persistence_Outlook__c>{ testPersistenceOutlook1, testPersistenceOutlook2 };

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        Persistence_Outlook__c testPersistenceOutlook1 = new Persistence_Outlook__c(
            Contact__c = testContact1.Id,
            Change_Direction__c = 1
        );
        Persistence_Outlook__c testPersistenceOutlook2 = new Persistence_Outlook__c(
            Contact__c = testContact2.Id,
            Change_Direction__c = 0
        );

        insert new List<Persistence_Outlook__c>{ testPersistenceOutlook1, testPersistenceOutlook2 };

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.caseCount = 2;
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.getContactCaseWrappersWithLessQueries(
            new List<Id>{ testUser.Id },
            filter
        );
        System.assertEquals(1, results.size(), 'Should get 1 contact-case wrapper returned');
        System.assertEquals(testContact1.Id, results[0].portalContact.Id, 'Should get first test contact');
    }

    @IsTest
    private static void testCreatedDateFilter() {
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.CreatedDate = System.now().addDays(-2);
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.CreatedDate = System.now().addDays(-2);
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.Followup_Date__c = System.today().addDays(1);
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.Followup_Date__c = System.today().addDays(1);
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        Contact testContact3 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact4 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2, testContact3, testContact4 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        Success_Pod__c testSuccPod = new Success_Pod__c(OwnerId = testUser.Id);

        insert testSuccPod;

        Success_Student__c testSuccessStudent1 = new Success_Student__c(
            Student__c = testContact3.Id,
            Success_Pod__c = testSuccPod.Id
        );
        Success_Student__c testSuccessStudent2 = new Success_Student__c(
            Student__c = testContact2.Id,
            Success_Pod__c = testSuccPod.Id
        );

        insert new List<Success_Student__c>{ testSuccessStudent1, testSuccessStudent2 };

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

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
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

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.CC_Functional_Group__c = parent.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.CC_Functional_Group__c = parent.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.CC_Functional_Group__c = parent.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.CC_Functional_Group__c = parent.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.CC_Functional_Group__c = parent.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        testCase1.CC_Category__c = testClassification1.Id;
        testCase3.CC_Category__c = testClassification1.Id;
        testCase5.CC_Category__c = testClassification1.Id;

        update new List<Case>{ testCase1, testCase3, testCase5 };

        AdvisorPortalFilter filter = new AdvisorPortalFilter();

        filter.watchlistCasesState = true;
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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        testContact1.EmplId__c = '0011221100';
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        testContact2.ASURite_ID__c = 'testid_1';
        insert new List<Contact>{ testContact1, testContact2 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.Subject = 'test-subject-ap-r1';
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.Subject = 'test-subject-ap-r2';
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.Subject = 'test-subject-ap-r1';
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.Subject = 'test-subject-ap-r2';
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.Subject = 'test-subject-ap-r1';
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

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
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Read Only'];

        User testUser = TestDataFactory.createUser('text-user-ap-r1', p.Id);
        insert testUser;

        Contact testContact1 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact2 = TestDataFactory.createContact('test-contact-ap-r2');
        Contact testContact3 = TestDataFactory.createContact('test-contact-ap-r1');
        Contact testContact4 = TestDataFactory.createContact('test-contact-ap-r2');
        insert new List<Contact>{ testContact1, testContact2, testContact3, testContact4 };

        Case testCase1 = TestDataFactory.createCase('test-case-ap-r1');
        testCase1.ContactId = testContact1.Id;
        testCase1.ownerId = testUser.Id;
        testCase1.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase2 = TestDataFactory.createCase('test-case-ap-r2');
        testCase2.ContactId = testContact1.Id;
        testCase2.ownerId = testUser.Id;
        testCase2.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase3 = TestDataFactory.createCase('test-case-ap-r3');
        testCase3.ContactId = testContact2.Id;
        testCase3.ownerId = testUser.Id;
        testCase3.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase4 = TestDataFactory.createCase('test-case-ap-r4');
        testCase4.ContactId = testContact2.Id;
        testCase4.ownerId = testUser.Id;
        testCase4.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        Case testCase5 = TestDataFactory.createCase('test-case-ap-r5');
        testCase5.ContactId = testContact2.Id;
        testCase5.ownerId = testUser.Id;
        testCase5.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        insert new List<Case>{ testCase1, testCase2, testCase3, testCase4, testCase5 };

        Success_Pod__c testSuccPod = new Success_Pod__c(OwnerId = testUser.Id);

        insert testSuccPod;

        Success_Student__c testSuccessStudent1 = new Success_Student__c(
            Student__c = testContact3.Id,
            Success_Pod__c = testSuccPod.Id
        );
        Success_Student__c testSuccessStudent2 = new Success_Student__c(
            Student__c = testContact2.Id,
            Success_Pod__c = testSuccPod.Id
        );

        insert new List<Success_Student__c>{ testSuccessStudent1, testSuccessStudent2 };

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
        // Arrange
        List<Contact> listOfContacts = new List<Contact>();
        listOfContacts.add(
            new Contact(
                FirstName = 'test',
                LastName = 'rtn-advisorportal',
                Email = 'test@email.rtn.test',
                EmplId__c = '13000'
            )
        );
        listOfContacts.add(
            new Contact(
                FirstName = 'test2',
                LastName = 'rtn-advisorportal',
                Email = 'test@email.rtn.test',
                EmplId__c = '13001'
            )
        );
        insert listOfContacts;

        List<Student_Group__c> listOfStudentGroups = new List<Student_Group__c>();
        listOfStudentGroups.add(
            new Student_Group__c(
                SG_Contact__c = listOfContacts[0].Id,
                SG_PeopleSoft_Code__c = 'TESTGRP-r1',
                SG_Status__c = true
            )
        );
        listOfStudentGroups.add(
            new Student_Group__c(
                SG_Contact__c = listOfContacts[0].Id,
                SG_PeopleSoft_Code__c = 'TESTGRP-r2',
                SG_Status__c = true
            )
        );
        listOfStudentGroups.add(
            new Student_Group__c(
                SG_Contact__c = listOfContacts[1].Id,
                SG_PeopleSoft_Code__c = 'TESTGRP-r1',
                SG_Status__c = true
            )
        );
        listOfStudentGroups.add(
            new Student_Group__c(
                SG_Contact__c = listOfContacts[1].Id,
                SG_PeopleSoft_Code__c = 'TESTGRP-r2',
                SG_Status__c = false
            )
        );
        insert listOfStudentGroups;

        AdvisorPortalFilter filter1 = new AdvisorPortalFilter();
        filter1.studentGroupCode = 'testgrp-r1';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
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
        // Arrange
        List<Contact> listOfContacts = new List<Contact>();
        listOfContacts.add(
            new Contact(
                FirstName = 'test',
                LastName = 'rtn-advisorportal',
                Email = 'test@email.rtn.test',
                EmplId__c = '13000'
            )
        );
        listOfContacts.add(
            new Contact(
                FirstName = 'test2',
                LastName = 'rtn-advisorportal',
                Email = 'test@email.rtn.test',
                EmplId__c = '13001'
            )
        );
        insert listOfContacts;

        List<Location__c> listOfLocations = new List<Location__c>();
        listOfLocations.add(new Location__c(Name = 'Test-r1', Location_Code__c = 'TEST-R1'));
        listOfLocations.add(new Location__c(Name = 'Test-r2', Location_Code__c = 'TEST-R2'));
        insert listOfLocations;

        List<Student_Program_Plan__c> listOfStudentPrograms = new List<Student_Program_Plan__c>();
        listOfStudentPrograms.add(
            new Student_Program_Plan__c(
                Contact__c = listOfContacts[0].Id,
                Cohort__c = 'Senior',
                Campus__c = listOfLocations[0].Id,
                Residency__c = 'Resident',
                Plan_Type_Text__c = 'MAJ',
                Plan_Description__c = 'Computer Science'
            )
        );
        listOfStudentPrograms.add(
            new Student_Program_Plan__c(
                Contact__c = listOfContacts[1].Id,
                Cohort__c = 'Junior',
                Campus__c = listOfLocations[1].Id,
                Residency__c = 'International',
                Plan_Type_Text__c = 'MAJ',
                Plan_Description__c = 'Computer Science'
            )
        );
        listOfStudentPrograms.add(
            new Student_Program_Plan__c(
                Contact__c = listOfContacts[1].Id,
                Cohort__c = 'Senior',
                Campus__c = listOfLocations[1].Id,
                Residency__c = 'Resident',
                Plan_Type_Text__c = 'MAJ',
                Plan_Description__c = 'Law'
            )
        );
        insert listOfStudentPrograms;

        AdvisorPortalFilter filter1 = new AdvisorPortalFilter();
        filter1.academicLevel = 'senior;junior';
        filter1.campus = 'test-r1;test-r2';
        filter1.residency = 'resident;international';
        filter1.major = 'computer';

        AdvisorPortalFilter filter2 = new AdvisorPortalFilter();
        filter2.major = 'law';

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
        Test.stopTest();

        System.debug(results1);
        System.debug(results2);

        // Assert
        System.assertEquals(2, results1.size());
        System.assertEquals(1, results2.size());
        System.assert(
            results1.contains(listOfContacts[0].Id),
            'The first contact should be in the first set of results.'
        );
        System.assert(
            results1.contains(listOfContacts[1].Id),
            'The second contact should be in the first set of results.'
        );
        System.assert(
            !results2.contains(listOfContacts[0].Id),
            'The first contact should not be in the second set of results.'
        );
        System.assert(
            results2.contains(listOfContacts[1].Id),
            'The second contact should be in the second set of results.'
        );
    }
}
