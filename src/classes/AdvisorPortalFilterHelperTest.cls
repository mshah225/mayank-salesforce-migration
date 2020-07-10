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

        Test.setFixedSearchResults(new List<String>{testContact.Id});

        // Act 
        Test.startTest();
        Set<Id> results = AdvisorPortalFilterHelper.filterContacts(filter, new Set<Id>{testContact.Id});
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
            new Case_Classification__c(
                Id = categoryWatchlistId,
                Name = 'Watchlist'
            ),
            new Case_Classification__c(
                Id = functionalGroupId,
                Name = 'ASU Advisor Outreach'
            )
        };

        CaseFactory.AdvisorOutreachCase watchlistCaseMaker = new CaseFactory.AdvisorOutreachCase(
            UserInfo.getUserId(),
            IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach'),
            'Outreach Required',
            functionalGroupId,
            categoryWatchlistId,
            testContact.Id,
            null);
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
        List<Case> results = AdvisorPortalFilterHelper.filterCases(filter, new Set<Id>{testContact.Id});
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size(), 'One Case matches the results, should have been returned.');
        System.assertEquals('Outreach Required', results[0].Status);
        System.assertEquals('Test Subject', results[0].Subject);
    }

    @IsTest
    static void testFilterStudentGroups() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        insert new Student_Group__c(
            SG_Contact__c = testContact.Id,
            SG_PeopleSoft_Code__c = 'COMPSCI'
        );

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.studentGroupCode = 'compsci';

        // Act
        Test.startTest();
        Set<Id> results = AdvisorPortalFilterHelper.filterStudentGroups(filter, new Set<Id>{testContact.Id});
        Test.stopTest();

        // Assert
        System.assert(results.contains(testContact.Id), 'The testContact Id should have been returned.');
    }

    @IsTest
    static void testFilterStudentPlans() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        Location__c tempe = new Location__c(
            Name = 'Tempe',
            Location_Code__c = 'TEMPE'
        );
        insert tempe;

        insert new Student_Program_Plan__c(
            Contact__c = testContact.Id,
            Cohort__c = 'Senior',
            Campus__c = tempe.Id,
            Residency__c = 'Resident',
            Plan_Description__c = 'Computer Science'
        );

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.academicLevel = 'senior;junior';
        filter.campus = 'tempe;downtown';
        filter.residency = 'resident;international';
        filter.major = 'computer';

        // Act
        Test.startTest();
        Set<Id> results = AdvisorPortalFilterHelper.filterStudentPlans(filter, new Set<Id>{testContact.Id});
        Test.stopTest();

        // Assert
        System.assert(results.contains(testContact.Id), 'The testContact Id should have been returned.');
    }

    @IsTest
    static void testFilterStudentAdvisors() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        Location__c tempe = new Location__c(
            Name = 'Tempe',
            Location_Code__c = 'TEMPE'
        );
        insert tempe;

        Student_Program_Plan__c testPlan = new Student_Program_Plan__c(
            Contact__c = testContact.Id,
            Cohort__c = 'Senior',
            Campus__c = tempe.Id,
            Residency__c = 'Resident',
            Plan_Description__c = 'Computer Science'
        );
        insert testPlan;

        Student_Program_Plan_Advisor__c testAdvisor = new Student_Program_Plan_Advisor__c(
            Name = 'Test Advisor',
            Advisor_Name__c = 'Sally Advisor',
            Student_Program_Plan__c = testPlan.Id
        );
        insert testAdvisor;

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.advisor = 'sally';

        Test.setFixedSearchResults(new List<String>{testAdvisor.Id});

        // Act
        Test.startTest();
        Set<Id> results = AdvisorPortalFilterHelper.filterStudentAdvisors(filter, new Set<Id>{testContact.Id});
        Test.stopTest();

        // Assert
        System.assert(results.contains(testContact.Id), 'The testContact Id should have been returned.');
    }
}