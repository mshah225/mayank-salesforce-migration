@isTest
public class Test_ShowMyCases {
    private static Integer numberOfPods;
    private static Integer numberOfCases;
    private static Integer numberOfStudents;
    private static ShowMyCasesController smsc;
    private static List<Success_Pod__c> pod; // Used to store the pod created for testing
    private static string query;

    static {
        smsc = new ShowMyCasesController();
        numberOfPods = 3;
        numberOfcases = 5;
        numberOfStudents = 5;

        pod = new List<Success_Pod__c>([SELECT OwnerId FROM Success_Pod__c LIMIT 1]);

        if (pod.size() > 0) {
            Query =
                'SELECT CaseNumber, ContactId, Contact.Name, Contact.EMPLID__c, Subject, Description, Status, FollowUp_Date__c, Curr_Cont_Prediction_Level__c, Most_Recent_Outlook_Change_Direction__c, Prev_Cont_Prediction_Level__c, Change_Date__c ' +
                'FROM Case ' +
                'WHERE OwnerId = \'' +
                pod[0].ownerId +
                '\' ' +
                'AND recordTypeId = \'' +
                IDHelper.getRTID('Case', 'ASU_Advisor_Outreach') +
                '\' ' +
                'AND isClosed = false ' +
                'ORDER BY Contact.LastName ASC';

            smsc.queryAttr = query;
        }
    }

    @testSetup
    public static void testSetup() {
        TestDataFactory.makeMeAnAdvisorUser(numberOfPods, numberOfCases, numberOfStudents);
    }

    /*
     * Tests caseList's getter
     */
    public static testMethod void Test_getCaseList() {
        // note, the number of cases in the list will either be equal to pageSize
        // Or numberOfCasesToCreate if this value is fewer than pageSize.
        // This is because the standard set controller will only get the number of records
        // set in setCon.setPageSize().

        if (numberOfCases * 2 < smsc.pageSize) {
            system.assertEquals(numberOfCases * 2, smsc.caseList.size());
        } else {
            system.assertEquals(smsc.pageSize, smsc.caseList.size());
        }
    }

    /*
     * Tests force refresh method and setCons ability to reset the refresh variable
     */
    public static testMethod void Test_forceRefresh() {
        ApexPages.StandardSetController ssc; // Used to store set controller so we can call getter
        List<Case> casesBeforeRefresh = new List<Case>(); // List of cases prior to refresh

        ssc = smsc.setCon; // Get setcon to force code to run

        for (showMyCasesController.caseWrapper cw : smsc.caseList) {
            casesBeforeRefresh.add(cw.obj);
        }

        smsc.refreshList = true; // force a refresh

        for (Integer x = 0; x < casesBeforeRefresh.size(); x++) {
            system.assertEquals(casesBeforeRefresh[x].id, smsc.caseList[x].obj.id);
        }
    }

    /*
     * Tests the conroller's ability to selectcases and retrive selected cases
     */
    public static testMethod void Test_GetSelectedCases() {
        for (showMyCasesController.caseWrapper cw : smsc.caseList) {
            cw.selected = true;
        }

        system.assertEquals(smsc.caseList.size(), smsc.selectedCases.size());
    }

    /*
     * Tests the controller's ability to change the owner of cases
     */
    public static testMethod void Test_TransferCases() {
        List<Id> casesToVerify = new List<Id>();

        // Select cases to transfer
        for (showMyCasesController.caseWrapper cw : smsc.caseList) {
            cw.selected = true;
        }

        // Set ownerId for new cases
        smsc.ownerId = UserInfo.getUserId();

        // Store a copy of the cases to use for checking owner ID changed
        for (Case c : smsc.selectedCases) {
            casesToVerify.add(c.Id);
        }

        // Transfer
        smsc.transferCases();

        // Verify ownerIds changed
        for (Case c : [SELECT OwnerId FROM Case WHERE Id IN :casesToVerify]) {
            system.assertEquals(UserInfo.getUserId(), c.ownerId);
        }
    }

    /*
     * Tests the controllers ability to set and get the page size value
     */
    public static testMethod void Test_getSetPageSize() {
        smsc.pageSize = 25;
        system.assertEquals(25, smsc.pageSize);

        // Set it again to make sure 25 is not just a value stored in the cookie
        // to minimize chance of missing errors
        smsc.pageSize = 50;
        system.assertEquals(50, smsc.pageSize);
    }

    /*
     * Tests the controllers ability to handle null values in sortDir
     */
    public static testMethod void Test_getSort() {
        smsc.sortDir = null; // Set to null
        system.assertEquals('ASC', smsc.sortDir); // Make sure the sortDir is set to default ASC
    }

    /*
     * Tests the controllers ability to toggle the sort dir
     */
    public static testMethod void Test_setSortField() {
        // Set sortfield to contact.name
        // verify the query contains "ORDER BY" and "Contact.Name"
        smsc.sortField = 'Contact.Name';

        system.assert(smsc.query.contains('ORDER BY'));
        system.assert(smsc.query.contains('Contact.Name'));
    }

    /*
     * Tests the controllers ability to insert mass emails
     */
    public static testMethod void Test_MassEmail() {
        // Select students
        for (ShowMyCasesController.caseWrapper cw : smsc.caseList) {
            cw.selected = true; // Select all the cases
        }

        // Set TempEmail
        smsc.tempEmail.Email_Template_Name__c = 'Advisor Ad-hoc template';
        smsc.tempEmail.Additional_Message_Text__c = 'Test mass email';

        smsc.portalEmailRTID = IDHelper.getRTID('Portal_Email__c', 'Advisor');

        // Insert Portal Emails
        smsc.massEmail();

        system.debug('assert called below me');
        system.assertEquals(smsc.caseList.size(), [SELECT Id FROM Portal_Email__c].size());
        system.debug('assert Called above me');
    }

    /**
     * Test Filter Methods
     */
    @isTest
    private static void checkQueryForFilterAddition() {
        smsc.queryAttr = smsc.query;
        smsc.searchString = 'Tester Mctesterson';
        smsc.caseSubject = 'Testing Subject';
        smsc.campusFilter = 'Tempe';
        smsc.outlookScoreFilter = '5';
        smsc.outlookChangeFilter = 'Up';
        smsc.majorFilter = 'Engineering';
        smsc.studentGroup = 'SG';
        smsc.caseStatusFilter = 'Email Sent';
        smsc.createdByStartDate = Date.valueOf('2018-07-17 00:00:00');
        smsc.createdByEndDate = Date.valueOf('2018-08-17 00:00:00');
        smsc.followupStartDate = Date.valueOf('2018-07-17 00:00:00');
        smsc.followupEndDate = Date.valueOf('2018-08-17 00:00:00');
        smsc.persistenceStartDate = Date.valueOf('2018-07-17 00:00:00');
        smsc.persistenceEndDate = Date.valueOf('2018-08-17 00:00:00');

        Test.startTest();
        smsc.insertFilterIntoQuery();
        Test.stopTest();

        System.assert(smsc.query.contains('Contact.Name LIKE'));
        System.assert(smsc.query.contains('Subject LIKE'));
        System.assert(smsc.query.contains('Contact.Most_Recent_Outlook_Change_Direction__c'));
        System.assert(smsc.query.contains('Contact.Curr_Cont_Prediction_Level__c > 7 AND'));
        System.assert(smsc.query.contains('Plan_Description__c LIKE'));
        System.assert(smsc.query.contains('SG_PeopleSoft_Code__c LIKE'));
        System.assert(smsc.query.contains('CreatedDate >='));
        System.assert(smsc.query.contains('CreatedDate <='));
        System.assert(smsc.query.contains('FollowUp_Date__c >='));
        System.assert(smsc.query.contains('FollowUp_Date__c <='));
        System.assert(smsc.query.contains('Change_Date__c >='));
        System.assert(smsc.query.contains('Change_Date__c <='));
        System.assert(smsc.query.contains('Status ='));
    }

    @isTest
    private static void checkQueryForFilterRemoval() {
        smsc.queryAttr = smsc.query;
        smsc.searchString = 'Tester Mctesterson';
        smsc.caseSubject = 'Testing Subject';
        smsc.campusFilter = 'Tempe';
        smsc.outlookScoreFilter = '5';
        smsc.outlookChangeFilter = 'Up';
        smsc.majorFilter = 'Engineering';
        smsc.studentGroup = 'SG';
        smsc.caseStatusFilter = 'Email Sent';
        smsc.createdByStartDate = Date.valueOf('2018-07-17 00:00:00');
        smsc.createdByEndDate = Date.valueOf('2018-08-17 00:00:00');
        smsc.followupStartDate = Date.valueOf('2018-07-17 00:00:00');
        smsc.followupEndDate = Date.valueOf('2018-08-17 00:00:00');
        smsc.persistenceStartDate = Date.valueOf('2018-07-17 00:00:00');
        smsc.persistenceEndDate = Date.valueOf('2018-08-17 00:00:00');
        smsc.insertFilterIntoQuery();

        Test.startTest();
        smsc.resetSearch();
        Test.stopTest();

        System.assert(!smsc.query.contains('Contact.Name LIKE'));
        System.assert(!smsc.query.contains('Subject LIKE'));
        System.assert(!smsc.query.contains('Contact.Most_Recent_Outlook_Change_Direction__c'));
        System.assert(!smsc.query.contains('Contact.Curr_Cont_Prediction_Level__c > 7 AND'));
        System.assert(!smsc.query.contains('Program_Description__c LIKE'));
        System.assert(!smsc.query.contains('Degree__c LIKE'));
        System.assert(!smsc.query.contains('Plan_Description__c LIKE'));
        System.assert(!smsc.query.contains('SG_PeopleSoft_Code__c LIKE'));
        System.assert(!smsc.query.contains('CreatedDate >='));
        System.assert(!smsc.query.contains('CreatedDate <='));
        System.assert(!smsc.query.contains('FollowUp_Date__c >='));
        System.assert(!smsc.query.contains('FollowUp_Date__c <='));
        System.assert(!smsc.query.contains('Change_Date__c >='));
        System.assert(!smsc.query.contains('Change_Date__c <='));
        System.assert(!smsc.query.contains('Status ='));
    }

    @isTest
    private static void checkQueryForNoFilters() {
        smsc.searchString = '';
        Test.startTest();
        smsc.insertFilterIntoQuery();
        Test.stopTest();

        System.assert(!smsc.query.contains('Contact.Name LIKE'));
        System.assert(!smsc.query.contains('Subject LIKE'));
        System.assert(!smsc.query.contains('Contact.Currently_Enrolled__c = LIKE'));
        System.assert(!smsc.query.contains('Campus__r.Name LIKE'));
        System.assert(!smsc.query.contains('Contact.Arizona_Resident__c ='));
        System.assert(!smsc.query.contains('Contact.US_Citizen__c ='));
        System.assert(!smsc.query.contains('Contact.Most_Recent_Outlook_Change_Direction__c'));
        System.assert(!smsc.query.contains('Contact.Curr_Cont_Prediction_Level__c > 7 AND'));
        System.assert(!smsc.query.contains('Program_Description__c LIKE'));
        System.assert(!smsc.query.contains('Degree__c LIKE'));
        System.assert(!smsc.query.contains('Plan_Description__c LIKE'));
        System.assert(!smsc.query.contains('SG_PeopleSoft_Code__c LIKE'));
        System.assert(!smsc.query.contains('CreatedDate >='));
        System.assert(!smsc.query.contains('CreatedDate <='));
        System.assert(!smsc.query.contains('FollowUp_Date__c >='));
        System.assert(!smsc.query.contains('FollowUp_Date__c <='));
        System.assert(!smsc.query.contains('Change_Date__c >='));
        System.assert(!smsc.query.contains('Change_Date__c <='));
        System.assert(!smsc.query.contains('Status ='));
    }

    @isTest
    private static void checkDefaultCaseStatusOptions() {
        Test.startTest();
        List<SelectOption> caseStatusOptions = smsc.caseStatusOptions;
        Test.stopTest();

        System.assert(caseStatusOptions.size() > 1);
        System.assert(caseStatusOptions.get(0).getValue() == '--' && caseStatusOptions.get(0).getLabel().equals('--'));
    }

    @isTest
    private static void checkDefaultOutlookScoreOptions() {
        Test.startTest();
        List<SelectOption> outlookScoreOptions = smsc.outlookScoreOptions;
        Test.stopTest();

        System.assert(
            outlookScoreOptions.get(0).getValue() == '--' && outlookScoreOptions.get(0).getLabel().equals('--')
        );
        System.assert(
            outlookScoreOptions.get(1).getValue() == '1' && outlookScoreOptions.get(1).getLabel().equals('Very Low')
        );
        System.assert(
            outlookScoreOptions.get(2).getValue() == '2' && outlookScoreOptions.get(2).getLabel().equals('Low')
        );
        System.assert(
            outlookScoreOptions.get(3).getValue() == '3' && outlookScoreOptions.get(3).getLabel().equals('Moderate')
        );
        System.assert(
            outlookScoreOptions.get(4).getValue() == '4' && outlookScoreOptions.get(4).getLabel().equals('High')
        );
        System.assert(
            outlookScoreOptions.get(5).getValue() == '5' && outlookScoreOptions.get(5).getLabel().equals('Very High')
        );
    }

    @isTest
    private static void checkDefaultOutlookChangeOptions() {
        Test.startTest();
        List<SelectOption> outlookChangeOptions = smsc.outlookChangeOptions;
        Test.stopTest();

        System.assert(
            outlookChangeOptions.get(0).getValue() == '--' && outlookChangeOptions.get(0).getLabel().equals('--')
        );
        System.assert(
            outlookChangeOptions.get(1).getValue() == '1' && outlookChangeOptions.get(1).getLabel().equals('Up')
        );
        System.assert(
            outlookChangeOptions.get(2).getValue() == '-1' && outlookChangeOptions.get(2).getLabel().equals('Down')
        );
    }

    @isTest
    private static void checkForNullCategoryOptions() {
        ShowMyCasesController showMyCasesController = new ShowMyCasesController();
        Case caseToTest = new Case();
        showMyCasesController.caseList = new List<ShowMyCasesController.CaseWrapper>();
        showMyCasesController.caseList.add(new ShowMyCasesController.CaseWrapper(caseToTest));

        Test.startTest();
        List<SelectOption> caseCategoryOptions = showMyCasesController.caseCategoryOptions;
        Test.stopTest();

        System.assertEquals(1, caseCategoryOptions.size());
    }
}
