@isTest
private class CaseWebformCloserTest {
    private static Case currentCase;
    private static Case previousStateOfCase;
    private static CaseWebformCloser closer;
    private static User apiAsuDrupalUser;
    
    @isTest
    private static void rejectChangeToPreviouslyClosedCase() {
        setupClosedWebformCase();
        
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
        setupClosedWebformCase();
        
        Test.startTest();
        closer.handleWebformCase();
        Test.stopTest();
        
        System.assertEquals('Revert Me', currentCase.Status);
        System.assertEquals('Revert Me', currentCase.Deep_Links__c);
        System.assertEquals('Revert Me', currentCase.Subject);
    }
    
    private static void setupClosedWebformCase() {
        CaseFactory.ClosedWebformCase caseFactory = new CaseFactory.ClosedWebformCase();
        List<Case> twoIdenticalWebformCases = caseFactory.create(2);
        currentCase = twoIdenticalWebformCases[0];
        previousStateOfCase = twoIdenticalWebformCases[1];
        
        currentCase.Status = 'Revert Me';
        currentCase.Deep_Links__c = 'Revert Me';
        currentCase.Subject = 'Revert Me';
        
        closer = new CaseWebformCloser(currentCase, previousStateOfCase);
        apiAsuDrupalUser = [SELECT Id FROM User WHERE Name = 'API ASU DRUPAL' LIMIT 1];
    }
    
    @isTest
    private static void processFinancialWebformCaseCorrectQueueAssignment() {
        setupWebformCasesForProcessing();
        
        Test.startTest();
        closer.handleWebformCase();
        Test.stopTest();
        
        System.assertEquals(CaseWebformCloser.FINANCIAL_AID_CASE_QUEUE, currentCase.OwnerId);
        System.assertEquals('Closed: Resolved', currentCase.Status);
        System.assertNotEquals(previousStateOfCase.Subject, currentCase.Subject);
        System.assert(previousStateOfCase.Subject.contains(currentCase.Subject));
        System.assertEquals(FALSE, currentCase.Visible_By_Contact__c);
    }
    
    @isTest
    private static void processNonFinancialWebformCaseCorrectQueueAssignment() {
        setupWebformCasesForProcessing();
        Id nonFinancialAidQueueId = [SELECT Id
            FROM Group
            WHERE Name != 'Financial Aid (Case)'
                AND Type = 'Queue' 
            LIMIT 1
        ].Id;
        currentCase.Subject = 'Webform:citizenship_verification%ASURITE:1000815525%Queue:'
            + nonFinancialAidQueueId + '%First:Keith%Last:Arnold ';
        
        Test.startTest();
        closer.handleWebformCase();
        Test.stopTest();
        
        System.assertEquals(nonFinancialAidQueueId, currentCase.OwnerId);
        System.assertEquals('New', currentCase.Status);
        System.assertNotEquals(previousStateOfCase.Subject, currentCase.Subject);
        System.assert(previousStateOfCase.Subject.contains(currentCase.Subject));
        System.assertNotEquals(FALSE, currentCase.Visible_By_Contact__c);
    }
    
    private static void setupWebformCasesForProcessing() {
        CaseFactory.ProcessingWebformCase caseFactory = new CaseFactory.ProcessingWebformCase();
        List<Case> twoIdenticalWebformCases = caseFactory.create(2);
        currentCase = twoIdenticalWebformCases[0];
        previousStateOfCase = twoIdenticalWebformCases[1];
        
        closer = new CaseWebformCloser(currentCase, previousStateOfCase);
        apiAsuDrupalUser = [SELECT Id FROM User WHERE Name = 'API ASU DRUPAL' LIMIT 1];
    }
}