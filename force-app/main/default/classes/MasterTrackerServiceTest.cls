@isTest
public class MasterTrackerServiceTest {

    // Method to generate a test Opportunity record
    private static Opportunity createTestOpportunity(String testType) {
        // Create a test Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Create a test Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id // Associate the Contact with the Account
        );
        insert testContact;

        // Create the Opportunity and associate it with the Account and Contact
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            Contact__c = testContact.Id,
            AccountId = testAccount.Id, // Associate the Opportunity with the Account
            Admission_Test_Type__c = testType,
            Sync_to_Master_Tracker_Record__c = true // Ensure this flag is set so the test triggers sync
        );
        insert opp;

        return opp;
    }

    // Method to generate Test Scores
    private static List<Test_Score__c> createTestScores(Opportunity opp, String component, Decimal score, Date testDate, Decimal percentile) {
        
        Test_Score__c testScore = new Test_Score__c(
            Contact__c = opp.Contact__c, // Make sure Contact__c is set from Opportunity
            Test_Component__c = component,
            Test_Component_Score__c = score,
            Test_Date__c = testDate,
            Test_Component_Percentile__c = percentile,
            Integration_Source__c = 'PeopleSoft',
            Test_Source__c = 'Educational Testing Service',
            Test_Type__c = opp.Admission_Test_Type__c
        );
        insert testScore;
        return new List<Test_Score__c>{testScore};
    }

    @isTest
    static void testCreateMasterTrackerRecord() {
        // Prepare test data
        Opportunity testOpp = createTestOpportunity('GMAT');
        
        // Create related test scores
        List<Test_Score__c> testScores = createTestScores(testOpp, 'DISPLAY', 750, Date.today().addYears(-3), 90);
        createTestScores(testOpp, 'QUAN', 45, Date.today().addYears(-3), 80);
        createTestScores(testOpp, 'VERB', 40, Date.today().addYears(-3), 85);

        // Test the method
        Test.startTest();
        Graduate_Master_Tracker__c masterTracker = MasterTrackerService.createMasterTrackerRecord(testOpp);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, masterTracker.Id, 'The Graduate_Master_Tracker__c record should have been inserted.');
        System.assertEquals(testOpp.Id, masterTracker.Opportunity__c, 'Opportunity ID should match.');
        System.assertEquals(750, masterTracker.Display_Score__c, 'Display score should match.');
        System.assertEquals(45, masterTracker.Quantitative_Total__c, 'Quantitative score should match.');
        System.assertEquals(40, masterTracker.Verbal_Total__c, 'Verbal score should match.');
    }

    @isTest
    static void testUpdateMasterTrackerWithNewTestScores() {
        // Prepare test data
        Opportunity testOpp = createTestOpportunity('GRE');
        
        // Insert a Graduate_Master_Tracker__c record related to the Opportunity
        Graduate_Master_Tracker__c tracker = new Graduate_Master_Tracker__c(
            Opportunity__c = testOpp.Id
        );
        insert tracker;

        // Create new test scores to update the tracker
        createTestScores(testOpp, 'DISPLAY', 320, Date.today().addYears(-2), 85);
        createTestScores(testOpp, 'QUAR', 160, Date.today().addYears(-2), 75);
        createTestScores(testOpp, 'VERR', 150, Date.today().addYears(-2), 80);

        // Prepare a map of Opportunities with new test scores
        Map<Id, Opportunity> oppsWithNewTestScores = new Map<Id, Opportunity>{testOpp.Id => testOpp};

        // Test the method
        Test.startTest();
        MasterTrackerService.updateMasterTrackerWithNewTestScores(oppsWithNewTestScores);
        Test.stopTest();

        // Query the updated tracker record
        Graduate_Master_Tracker__c updatedTracker = [SELECT Id, Quantitative_Total__c, Verbal_Total__c
                                                     FROM Graduate_Master_Tracker__c
                                                     WHERE Id =: tracker.Id];

        // Assertions
        System.assertEquals(160, updatedTracker.Quantitative_Total__c, 'Quantitative score should be updated.');
        System.assertEquals(150, updatedTracker.Verbal_Total__c, 'Verbal score should be updated.');
    }
}
