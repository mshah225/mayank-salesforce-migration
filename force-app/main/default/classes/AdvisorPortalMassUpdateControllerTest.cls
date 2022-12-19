@IsTest
private class AdvisorPortalMassUpdateControllerTest {
    @IsTest
    static void testRecommendedActions() {
        // Act
        Test.startTest();
        Map<String, String> actions = AdvisorPortalMassUpdateController.populateRecommendedActionOptions();
        Test.stopTest();

        // Assert
        System.assert(actions.size() > 0);
    }

    @IsTest
    static void testReturnTermOptions() {
        // Act
        Test.startTest();
        Map<String, String> termOptions = AdvisorPortalMassUpdateController.populateReturnTermOptions();
        Test.stopTest();

        // Assert
        System.assert(termOptions.size() > 0);
    }

    @IsTest
    static void testStudentRiskOptions() {
        // Act
        Test.startTest();
        Map<String, String> riskOptions = AdvisorPortalMassUpdateController.populateStudentRiskOptions();
        Test.stopTest();

        // Assert
        System.assert(riskOptions.size() > 0);
    }

    @IsTest
    static void testReasonNotReturningOptions() {
        // Act
        Test.startTest();
        Map<String, String> returningOptions = AdvisorPortalMassUpdateController.populateReasonNotReturningOptions();
        Test.stopTest();

        // Assert
        System.assert(returningOptions.size() > 0);
    }

    @IsTest
    static void testUpdateCases() {
        // Arrange
        Case testCase = TestDataFactory.createCase('Test Case');
        insert testCase;

        // Act
        Test.startTest();
        testCase.Subject = 'Updated Subject';
        AdvisorPortalMassUpdateController.updateCases(new List<Case>{ testCase });
        Test.stopTest();

        // Assert
        System.assertEquals('Updated Subject', [SELECT Subject FROM Case WHERE Id = :testCase.Id].Subject);
    }

    @IsTest
    static void testLoadMetadata() {
        Advisor_Portal_Mass_Close_Configuration__mdt testMdt1 = new Advisor_Portal_Mass_Close_Configuration__mdt();
        testMdt1.Dropdown__c = 'caseStatus';
        testMdt1.Value__c = 'In Person Meeting';
        testMdt1.Required_Fields__c = '';

        Advisor_Portal_Mass_Close_Configuration__mdt testMdt2 = new Advisor_Portal_Mass_Close_Configuration__mdt();
        testMdt2.Dropdown__c = 'caseStatus';
        testMdt2.Value__c = 'Closed: Administratively Resolved (No Outreach)';
        testMdt2.Required_Fields__c = '';

        Advisor_Portal_Mass_Close_Configuration__mdt testMdt3 = new Advisor_Portal_Mass_Close_Configuration__mdt();
        testMdt3.Dropdown__c = 'studentIntent';
        testMdt3.Value__c = 'Not returning temporarily';
        testMdt3.Required_Fields__c = 'notReturning, returnTerm';

        // Act
        Test.startTest();
        Map<String, Map<String, List<String>>> metadata = AdvisorPortalMassUpdateController.convertMetadataToMapping(
            new List<Advisor_Portal_Mass_Close_Configuration__mdt>{testMdt1, testMdt2,testMdt3}
        );
        Test.stopTest();

        // Assert
        System.assert(metadata.get('caseStatus').containsKey('In Person Meeting'));
        System.assert(metadata.get('caseStatus').containsKey('Closed: Administratively Resolved (No Outreach)'));

        System.assert(metadata.get('studentIntent').get('Not returning temporarily').contains('notReturning'));
        System.assert(metadata.get('studentIntent').get('Not returning temporarily').contains('returnTerm'));
    }
}