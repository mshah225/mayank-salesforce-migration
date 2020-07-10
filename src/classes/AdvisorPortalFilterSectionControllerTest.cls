@IsTest
private class AdvisorPortalFilterSectionControllerTest {
    @TestSetup
    static void setUpTest() {
        TestDataFactory.createAdvisorStudents(TestDataFactory.createAdvisorPods(1), 1);
    }

    @IsTest
    static void testGetPicklistValues() {
        Test.startTest();
        Map<String, String> picklistValuesMap = AdvisorPortalFilterSectionController.getPicklistValues('Student_Program_Plan__c', 'Residency__c');
        Test.stopTest();
        
        System.assert(picklistValuesMap.size() > 0, 'Controller should have returned values for the Residency picklist.');
        System.assert(picklistValuesMap.keySet().contains('Resident'), 'Ensure the picklist map contains at least one valid picklist value.');
    }

    @IsTest
    static void testGetCaseStatusOptions() {
        Test.startTest();
        Map<String, String> caseStatusMap = AdvisorPortalFilterSectionController.getCaseStatusSettings();
        Test.stopTest();

        System.assert(caseStatusMap.size() > 0, 'Controller should have returned values for the Case Status picklist based upon the custom metadata type.');
        System.assert(caseStatusMap.keySet().contains('In Progress'), 'Ensure the picklist map contains at least one valid picklist value.');
    }

    @IsTest
    private static void testCaseSubjectPicklistValues() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        List<Case> testCases = TestDataFactory.createCases(3);
        Integer i = 0;
        for (Case c : testCases) {
            c.ContactId = testContact.Id;
            c.Subject = 'Subject ' + i;
            c.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
            i++;
        }
        insert testCases;

        List<String> queueIds = new List<String>();
        for (Group g : [SELECT Id FROM Group WHERE Type = 'Queue']) {
            queueIds.add(g.Id);
        }

        // Act
        Test.startTest();
        Map<String, String> subjectMap = AdvisorPortalFilterSectionController.getCaseSubjectPicklistValues(queueIds);
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

        List<String> queueIds = new List<String>();
        for (Group g : [SELECT Id FROM Group WHERE Type = 'Queue']) {
            queueIds.add(g.Id);
        }

        // Act
        Test.startTest();
        Map<String, String> classificationMap = AdvisorPortalFilterSectionController.getCaseClassificationPicklistValues(queueIds);
        Test.stopTest();

        // Assert
        System.assertEquals(1, classificationMap.size(), 'The one Case Category should have been found.');
    }

    @IsTest
    private static void testFilterContacts() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        List<Case> testCases = TestDataFactory.createCases(3);
        for (Case c : testCases) {
            c.ContactId = testContact.Id;
            c.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        }
        insert testCases;

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.studentString = 'TestContact0';
        filter.watchlistCasesState = false;
        filter.allCasesState = false;

        List<String> queueIds = new List<String>();
        for (Group g : [SELECT Id FROM Group WHERE Type = 'Queue']) {
            queueIds.add(g.Id);
        }

        Test.setFixedSearchResults(new List<String>{testContact.Id});

        // Act
        Test.startTest();
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.filterContacts(queueIds, filter);
        Test.stopTest();

        // Assert
        System.assertEquals(results.size(), 1, 'One Contact (the test one) should have been returned.');
        System.assertEquals(results[0].portalContact.Name, 'TestContact0 Test Pod 1');
        System.assertEquals(results[0].cases.size(), 3, 'The 3 test cases should have been returned.');
    }

    @IsTest
    private static void testFilterContactsAllCases() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        List<Case> testCases = TestDataFactory.createCases(5);
        for (Case c : testCases) {
            c.ContactId = testContact.Id;
            // Note, we're not setting the record type here to prove the contact returns with 0 cases.
        }
        insert testCases;

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.studentString = 'stark';
        filter.watchlistCasesState = false;
        filter.allCasesState = true;

        List<String> queueIds = new List<String>();
        for (Group g : [SELECT Id FROM Group WHERE Type = 'Queue']) {
            queueIds.add(g.Id);
        }

        Test.setFixedSearchResults(new List<String>{testContact.Id});

        // Act
        Test.startTest();
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.filterContacts(queueIds, filter);
        Test.stopTest();

        // Assert
        System.assertEquals(results.size(), 1, 'One Contact (the test one) should have been returned, even though 0 cases are returned.');
        System.assertEquals(results[0].portalContact.Name, 'TestContact0 Test Pod 1');
        System.assertEquals(results[0].cases.size(), 0, 'The test cases should NOT have been returned, because they are not Advisor Outreach cases.');
    }

    @IsTest
    private static void testFilterContactsWithCaseCountNegative() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        List<Case> testCases = TestDataFactory.createCases(3);
        for (Case c : testCases) {
            c.ContactId = testContact.Id;
            c.RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        }
        insert testCases;

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.studentString = 'stark';
        filter.watchlistCasesState = false;
        filter.allCasesState = false;
        filter.caseCount = 4;

        List<String> queueIds = new List<String>();
        for (Group g : [SELECT Id FROM Group WHERE Type = 'Queue']) {
            queueIds.add(g.Id);
        }

        Test.setFixedSearchResults(new List<String>{testContact.Id});

        // Act
        Test.startTest();
        List<AdvisorPortalContact> results = AdvisorPortalFilterSectionController.filterContacts(queueIds, filter);
        Test.stopTest();

        // Assert
        System.assertEquals(results.size(), 0, 'No results should have been returned as the casecount filter shoudl have filtered them out.');
    }
}
