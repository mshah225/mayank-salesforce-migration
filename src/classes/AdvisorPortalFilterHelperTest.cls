/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 8/27/19
 *
 * Unit Tests for AdvisorPortalFilterHelper.cls
 */
@IsTest
private class AdvisorPortalFilterHelperTest {
    @TestSetup
    static void setUpTest() {
        TestDataFactory.createAdvisorStudents(TestDataFactory.createAdvisorPods(1), 1);
    }

    @IsTest
    static void testFilterContacts() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.studentString = 'TestContact0';
        filter.watchlistCasesState = false;
        filter.allCasesState = false;

        Test.setFixedSearchResults(new List<String>{ testContact.Id });

        // Act
        Test.startTest();
        Set<Id> results = AdvisorPortalFilterHelper.filterContacts(filter, new Set<Id>{ testContact.Id });
        Test.stopTest();

        // Assert
        System.assert(results.contains(testContact.Id), 'The testContact Id should have been returned.');
    }

    @IsTest
    static void testFilterCases() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        Persistence_Outlook__c testOutlook = new Persistence_Outlook__c(
            Contact__c = testContact.Id,
            Curr_Cont_Prediction_Level__c = 5,
            Change_Direction__c = -1,
            Change_Date__c = System.today().addDays(5)
        );
        insert testOutlook;

        List<Case> testCases = TestDataFactory.createCases(3);
        for (Case c : testCases) {
            c.ContactId = testContact.Id;
            c.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
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
        insert caseToFind;

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.caseSubject = 'Test Subject';
        filter.caseStatus = 'Outreach Required';
        filter.caseCategory = 'Watchlist';
        filter.outlookScore = 'low';
        filter.outlookChange = 'no change';
        filter.createdFromDate = String.valueOf(System.today().addDays(-7));
        filter.createdToDate = String.valueOf(System.today().addDays(20));
        filter.followUpFromDate = String.valueOf(System.today().addDays(-7));
        filter.followUpToDate = String.valueOf(System.today().addDays(20));
        filter.persistenceFromDate = String.valueOf(System.today().addDays(-7));
        filter.persistenceToDate = String.valueOf(System.today().addDays(20));
        filter.watchlistCasesState = true;
        filter.allCasesState = false;

        // Act
        Test.startTest();
        List<Case> results = AdvisorPortalFilterHelper.filterCases(filter, new Set<Id>{ testContact.Id });
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size(), 'One Case matches the results, should have been returned.');
        System.assertEquals('Outreach Required', results[0].Status);
        System.assertEquals('Test Subject', results[0].Subject);
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
        Set<Id> results1 = AdvisorPortalFilterHelper.filterStudentGroups(
            filter1,
            new Set<Id>{ listOfContacts[0].Id, listOfContacts[1].Id }
        );
        Set<Id> results2 = AdvisorPortalFilterHelper.filterStudentGroups(
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
                Plan_Description__c = 'Computer Science'
            )
        );
        listOfStudentPrograms.add(
            new Student_Program_Plan__c(
                Contact__c = listOfContacts[1].Id,
                Cohort__c = 'Junior',
                Campus__c = listOfLocations[1].Id,
                Residency__c = 'International',
                Plan_Description__c = 'Computer Science'
            )
        );
        listOfStudentPrograms.add(
            new Student_Program_Plan__c(
                Contact__c = listOfContacts[1].Id,
                Cohort__c = 'Senior',
                Campus__c = listOfLocations[1].Id,
                Residency__c = 'Resident',
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
        Set<Id> results1 = AdvisorPortalFilterHelper.filterStudentPlans(
            filter1,
            new Set<Id>{ listOfContacts[0].Id, listOfContacts[1].Id }
        );
        Set<Id> results2 = AdvisorPortalFilterHelper.filterStudentPlans(
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
