@isTest
public class Test_ShowMyStudents {
    private static showMyStudentsController smsc;
    private static string query; // Used to generate standard set controller objects
    private static List<Success_Pod__c> pod; // Used to store the pod created for testing
    private static integer numberOfstudentsToCreate = 3; // Number of students that will be created

    /*
     * Static initilizaion code to minimize repeat code per test method
     */
    static {
        smsc = new showMyStudentsController();

        pod = new List<Success_Pod__c>([SELECT Id FROM Success_Pod__c LIMIT 1]);

        if (pod.size() > 0) {
            query =
                'SELECT Student_Name__c, EMPLID__c, Student__c, Curr_Cont_Prediction_Level__c, Most_Recent_Outlook_Change_Direction__c, Prev_Cont_Prediction_Level__c, Change_Date__c ' +
                'FROM Success_Student__c ' +
                'WHERE Success_Pod__c = \'' +
                pod[0].Id +
                '\' ' +
                'AND Is_Active__c = true';
            smsc.queryAttr = query;
        }
    }

    /*
     * Create test data
     */
    @testSetup
    public static void testSetup() {
        // Create queue to own pod
        Group testGroup = new Group(Name = 'Test Group Name', Type = 'Queue');

        insert testGroup;

        QueueSobject testQueue = new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Success_Pod__c');

        // To avoid MIXED DML ERROR, you need to insert this non-setup object
        // as the system user. In this case, just the admin running the test.
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testQueue;
        }

        // Create Pod
        Id successPodRTID = [SELECT Id FROM RecordType WHERE SObjectType = 'Success_Pod__c' AND Name = 'Advisor'].Id;

        Success_Pod__c sp = new Success_Pod__c(ownerId = testGroup.Id, recordTypeId = successPodRTID);

        insert sp;

        // Create student(s) and assign to pod
        List<Contact> contactsToCreate = TestDataFactory.createContacts(numberOfstudentsToCreate);
        List<Success_Student__c> studentsToCreate = new List<Success_Student__c>();

        insert contactsToCreate;

        for (Contact c : contactsToCreate) {
            studentsToCreate.add(new Success_Student__c(Student__c = c.Id, Success_Pod__c = sp.Id));
        }

        insert studentsToCreate;
    }

    /*
     * Tests the setCon's getter.
     */
    public static testMethod void Test_getSetCon() {
        // Verify that we have the correct number of records.
        system.assertEquals(numberOfStudentsToCreate, smsc.setCon.getResultsize());
    }

    /*
     * Tests studentList's getter
     */
    public static testMethod void Test_getStudentList() {
        // note, the number of students in the list will either be equal to pageSize
        // Or numberOfStudentsToCreate if this value is fewer than pageSize.
        // This is because the standard set controller will only get the number of records
        // set in setCon.setPageSize().

        if (numberOfStudentsToCreate < smsc.pageSize) {
            system.assertEquals(numberOfStudentsToCreate, smsc.studentList.size());
        } else {
            system.assertEquals(smsc.pageSize, smsc.studentList.size());
        }
    }

    /*
     * Tests pageSize's setter
     *
     * <p>
     * Since all the work happens in the getters/setters we only need to test
     * what comes out of it. If we set the value to 25 and retrieve a different value,
     * we have a problem.
     * </p>
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
     * Tests the controllers ability to default to ASC
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
        smsc.sortField = 'Student_Name__c';

        system.assert(smsc.query.contains('ORDER BY'));
        system.assert(smsc.query.contains('Student_Name__c'));
    }

    /*
     * Tests the controllers ability to retrieve the selected students
     */
    public static testMethod void Test_getSelectedStudents() {
        for (showMyStudentsController.studentWrapper sw : smsc.studentList) {
            sw.selected = true; // Select all the cases
        }

        system.assertEquals(smsc.studentList.size(), smsc.selectedStudents.size());
    }

    /*
     * Tests the controllers ability to insert mass emails
     */
    public static testMethod void Test_MassEmail() {
        // Select students
        for (showMyStudentsController.studentWrapper sw : smsc.studentList) {
            sw.selected = true; // Select all the cases
        }

        // Set TempEmail
        smsc.tempEmail.Email_Template_Name__c = 'Advisor Ad-hoc template';
        smsc.tempEmail.Additional_Message_Text__c = 'Test mass email';

        smsc.portalEmailRTID = IDHelper.getRTID('Portal_Email__c', 'Advisor');

        // Insert Portal Emails
        smsc.massEmail();

        system.assertEquals(smsc.studentList.size(), [SELECT Id FROM Portal_Email__c].size());
    }

    /**
     * Ensures ErrorHandler for UpdateQuery is handing Invalid Query Queries correctly
     */
    public static testMethod void Test_getUpdateQueryError() {
        smsc.query = 'InvalidInput';
        smsc.updateQuery();
        List<Case> errorList = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        System.assertEquals(errorList.size(), 2);
    }

    /**Test Page moving
     */
    public static testMethod void Test_setConNextPrev() {
        smsc.setConPageSize(1);
        smsc.setConNext();
        System.assertEquals(smsc.setCon.getPageNumber(), 2);
        smsc.setConPrev();
        System.assertEquals(smsc.setCon.getPageNumber(), 1);
    }

    /**
     * Test Clear Results
     */
    public static testMethod void Test_clearSaveResults() {
        smsc.clearSaveResults();
        System.assertEquals(smsc.emailInsertResults, null);
        System.assertEquals(smsc.selectedStudents.size(), 0);
    }

    @isTest
    private static void checkQueryForFilterAddition() {
        smsc.queryAttr = smsc.query;
        smsc.searchString = 'Tester Mctesterson';
        smsc.campusFilter = 'Tempe';
        smsc.outlookScoreFilter = '5';
        smsc.outlookChangeFilter = 'Up';
        smsc.majorFilter = 'Engineering';
        smsc.studentGroup = 'SG';
        smsc.persistenceStartDate = Date.valueOf('2018-07-17 00:00:00');
        smsc.persistenceEndDate = Date.valueOf('2018-08-17 00:00:00');
        Test.startTest();
        smsc.insertFilterIntoQuery();
        Test.stopTest();

        System.assert(smsc.query.contains('Student_Name__c LIKE'));
        System.assert(smsc.query.contains('Student__r.Most_Recent_Outlook_Change_Direction__c'));
        System.assert(smsc.query.contains('Student__r.Curr_Cont_Prediction_Level__c > 7 AND'));
        System.assert(smsc.query.contains('Plan_Description__c LIKE'));
        System.assert(smsc.query.contains('SG_PeopleSoft_Code__c LIKE'));
        System.assert(smsc.query.contains('Student__r.Change_Date__c >='));
        System.assert(smsc.query.contains('Student__r.Change_Date__c <='));
    }

    @isTest
    private static void checkQueryForFilterRemoval() {
        smsc.queryAttr = smsc.query;
        smsc.searchString = 'Tester Mctesterson';
        smsc.campusFilter = 'Tempe';
        smsc.outlookScoreFilter = '5';
        smsc.outlookChangeFilter = 'Up';
        smsc.majorFilter = 'Engineering';
        smsc.studentGroup = 'SG';
        smsc.persistenceStartDate = Date.valueOf('2018-07-17 00:00:00');
        smsc.persistenceEndDate = Date.valueOf('2018-08-17 00:00:00');
        smsc.insertFilterIntoQuery();

        Test.startTest();
        smsc.resetSearch();
        Test.stopTest();

        System.assert(!smsc.query.contains('Student_Name__c LIKE'));
        System.assert(!smsc.query.contains('Student__r.Most_Recent_Outlook_Change_Direction__c'));
        System.assert(!smsc.query.contains('Student__r.Curr_Cont_Prediction_Level__c > 7 AND'));
        System.assert(!smsc.query.contains('Program_Description__c LIKE'));
        System.assert(!smsc.query.contains('Degree__c LIKE'));
        System.assert(!smsc.query.contains('Plan_Description__c LIKE'));
        System.assert(!smsc.query.contains('SG_PeopleSoft_Code__c LIKE'));
        System.assert(!smsc.query.contains('Change_Date__c >='));
        System.assert(!smsc.query.contains('Change_Date__c <='));
    }

    @isTest
    private static void checkQueryForNoFilters() {
        smsc.searchString = '';
        Test.startTest();
        smsc.insertFilterIntoQuery();
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
}
