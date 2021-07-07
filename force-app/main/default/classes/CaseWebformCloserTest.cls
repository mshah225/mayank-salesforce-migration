@isTest
private class CaseWebformCloserTest {
    private static Case currentCase;
    private static Case previousStateOfCase;
    private static CaseWebformCloser closer;
    private static User apiAsuDrupalUser;

    private static void setupClosedWebformCaseWithEdits() {
        CaseFactory.ClosedWebformCase caseFactory = new CaseFactory.ClosedWebformCase();
        List<Case> twoIdenticalWebformCases = caseFactory.create(2);
        currentCase = twoIdenticalWebformCases[0];
        previousStateOfCase = twoIdenticalWebformCases[1];
        insert previousStateOfCase;
        reQueryPreviousStateOfCase();

        currentCase.Id = previousStateOfCase.Id;
        currentCase.Status = 'New';
        currentCase.Deep_Links__c = 'Revert Me';
        currentCase.Subject = 'Revert Me';

        closer = new CaseWebformCloser(currentCase, previousStateOfCase);
        queryApiAsuDrupalUser();
    }

    private static void reQueryPreviousStateOfCase() {
        previousStateOfCase = [
            SELECT
                Subject,
                Description,
                Status,
                Functional_Group__c,
                Category__c,
                Priority,
                Origin__c,
                Deep_Links__c,
                Number_of_Files__c,
                IsClosed,
                OwnerId
            FROM Case
            WHERE Id = :previousStateOfCase.Id
        ];
    }

    private static void queryApiAsuDrupalUser() {
        apiAsuDrupalUser = [SELECT Id FROM User WHERE Name = 'API ASU DRUPAL' LIMIT 1];
    }

    private static void setupWebformCasesForProcessing() {
        CaseFactory.ProcessingWebformCase caseFactory = new CaseFactory.ProcessingWebformCase();
        List<Case> twoIdenticalWebformCases = caseFactory.create(2);
        currentCase = twoIdenticalWebformCases[0];
        previousStateOfCase = twoIdenticalWebformCases[1];
        insert previousStateOfCase;
        reQueryPreviousStateOfCase();

        closer = new CaseWebformCloser(currentCase, previousStateOfCase);
        queryApiAsuDrupalUser();
    }

    @isTest
    private static void rejectChangeToPreviouslyClosedCase() {
        setupClosedWebformCaseWithEdits();

        System.runAs(apiAsuDrupalUser) {
            Test.startTest();
            closer.handleWebformCase();
            Test.stopTest();
        }

        System.assertEquals(previousStateOfCase.Status, currentCase.Status);
        System.assertEquals(previousStateOfCase.Deep_Links__c, currentCase.Deep_Links__c);
        System.assertEquals(previousStateOfCase.Subject, currentCase.Subject);
    }

    @isTest
    private static void dontRejectChangesForNonDrupalUsers() {
        setupClosedWebformCaseWithEdits();

        Test.startTest();
        closer.handleWebformCase();
        Test.stopTest();

        System.assertEquals('New', currentCase.Status);
        System.assertEquals('Revert Me', currentCase.Deep_Links__c);
        System.assertEquals('Revert Me', currentCase.Subject);
    }

    @isTest
    private static void processFinancialWebformCaseCorrectQueueAssignment() {
        setupWebformCasesForProcessing();

        Test.startTest();
        closer.handleWebformCase();
        Test.stopTest();

        System.assertEquals(CaseWebformCloser.FINANCIAL_AID_CASE_QUEUE, currentCase.OwnerId);
        System.assertEquals(CaseWebformCloser.CASE_CLOSE_WEBFORM_STATUS, currentCase.Status);
        System.assertNotEquals(previousStateOfCase.Subject, currentCase.Subject);
        System.assert(previousStateOfCase.Subject.contains(currentCase.Subject));
        System.assertEquals(false, currentCase.Visible_By_Contact__c);
    }

    @isTest
    private static void processNonFinancialWebformCaseCorrectQueueAssignment() {
        setupWebformCasesForProcessing();
        Id nonFinancialAidQueueId = [
            SELECT Id
            FROM Group
            WHERE Name != 'Financial Aid (Case)' AND Type = 'Queue'
            LIMIT 1
        ]
        .Id;
        currentCase.Subject =
            'Webform:citizenship_verification%ASURITE:1000815525%Queue:' +
            nonFinancialAidQueueId +
            '%First:Keith%Last:Arnold ';

        Test.startTest();
        closer.handleWebformCase();
        Test.stopTest();

        System.assertEquals(nonFinancialAidQueueId, currentCase.OwnerId);
        System.assertEquals('New', currentCase.Status);
        System.assertNotEquals(previousStateOfCase.Subject, currentCase.Subject);
        System.assert(previousStateOfCase.Subject.contains(currentCase.Subject));
        System.assert(!currentCase.Visible_By_Contact__c);
    }
}
