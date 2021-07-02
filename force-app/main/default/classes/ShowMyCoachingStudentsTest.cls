/*****************************************
 * File: ShowMyCoachingStudentsTest
 * Author: Mathew Ruff, Sierra-Cedar
 * Description: Unit Tests for showMyCoachingStudentsController.cls
 ******************************************/
@IsTest
private class ShowMyCoachingStudentsTest {
    private static showMyCoachingStudentsController smcsc;
    private static String query; // Used to generate standard set controller objects
    private static List<Success_Pod__c> pod; // Used to store the pod created for testing
    private static Integer numberOfstudentsToCreate = 3; // Number of students that will be created

    /*
     * Static initilizaion code to minimize repeat code per test method
     */
    static {
        smcsc = new showMyCoachingStudentsController();

        pod = new List<Success_Pod__c>([SELECT Id FROM Success_Pod__c LIMIT 1]);

        if (pod.size() > 0) {
            query =
                'SELECT Student_Name__c, EMPLID__c, Student__c ' +
                'FROM Success_Student__c ' +
                'WHERE Success_Pod__c = \'' +
                pod[0].Id +
                '\' ' +
                'AND Is_Active__c = true';
            smcsc.queryAttr = query;
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
        Id successPodRTID = [SELECT Id FROM RecordType WHERE SObjectType = 'Success_Pod__c' AND Name = 'Coach'].Id;

        Success_Pod__c sp = new Success_Pod__c(ownerId = testGroup.Id, recordTypeId = successPodRTID);

        insert sp;

        // Create student(s) and assign to pod
        List<Contact> contactsToCreate = TestDataFactory.createContacts(numberOfstudentsToCreate);
        List<Success_Student__c> studentsToCreate = new List<Success_Student__c>();

        insert contactsToCreate;

        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Service - Success Coach'];

        User u1 = TestDataFactory.createUser('Testing1', p.Id);
        insert u1;

        Success_Resource__c testResource = new Success_Resource__c(Resource__c = u1.Id);
        insert testResource;

        Id coachRTId = [
            SELECT Id, Name, sObjectType
            FROM RecordType
            WHERE Name = 'Coach' AND SObjectType = 'Success_Student__c'
            LIMIT 1
        ]
        .Id;

        for (Contact c : contactsToCreate) {
            studentsToCreate.add(
                new Success_Student__c(
                    RecordTypeId = coachRTId,
                    Student__c = c.Id,
                    Success_Pod__c = sp.Id,
                    Success_Resource__c = testResource.Id,
                    Is_Active__c = true,
                    Coaching_Student__c = true
                )
            );
        }

        insert studentsToCreate;
    }

    /*
     * Tests the setCon's getter.
     */
    public static testMethod void Test_getSetCon() {
        // Verify that we have the correct number of records.
        System.assertEquals(numberOfStudentsToCreate, smcsc.setCon.getResultsize());
    }

    /*
     * Tests the controllers ability to handle null values in sortDir
     */
    public static testMethod void Test_getSortField() {
        smcsc.sortField = 'Student_Name__c';
        System.assert(smcsc.query.contains('ORDER BY Student_Name__c DESC'));
    }

    /*
     * Tests the controllers ability to handle null values in sortDir
     */
    public static testMethod void Test_getSort() {
        smcsc.sortDir = null; // Set to null
        System.assertEquals('DESC', smcsc.sortDir); // Make sure the sortDir is set to default DESC
    }

    /*
     * Tests the controllers ability to retrieve the selected students
     */
    public static testMethod void Test_getSelectedStudents() {
        for (showMyCoachingStudentsController.studentWrapper sw : smcsc.studentList) {
            sw.selected = true; // Select all the cases
        }

        System.assertEquals(smcsc.studentList.size(), smcsc.selectedStudents.size());
    }

    /*
     * Tests the search functionality
     */
    public static testMethod void Test_myStudentsSearch() {
        // Arrange
        User testUser = [SELECT Id FROM User WHERE LastName = 'Testing1' LIMIT 1];

        // Act
        smcsc.ownerId = testUser.Id;
        smcsc.searchString = '0, Mister';
        smcsc.myStudentsSearch();

        // Assert
        System.debug('merf: ' + smcsc.studentList);
        System.assert(smcsc.studentList.size() == 1);

        smcsc.resetMyStudentsSearch();
        System.assert(smcsc.studentList.size() == 3);
    }

    /*
     * Tests setCon override methods
     */
    public static testMethod void Test_setConNavigation() {
        smcsc.setConNext();
        smcsc.setConPrev();
        smcsc.setConPageSize(1);
        System.assert(smcsc.setCon.getRecords().size() == 1);
    }

    /*
     * Tests the controllers ability to insert mass emails
     */
    public static testMethod void Test_MassEmail() {
        // Select students
        for (showMyCoachingStudentsController.studentWrapper sw : smcsc.studentList) {
            sw.selected = true; // Select all the cases
        }

        // Set TempEmail
        smcsc.tempEmail.Email_Template_Name__c = 'Advisor Ad-hoc template';
        smcsc.tempEmail.Additional_Message_Text__c = 'Test mass email';

        smcsc.portalEmailRTID = IDHelper.getRTID('Portal_Email__c', 'Advisor');

        // Insert Portal Emails
        smcsc.massEmail();

        System.assertEquals(smcsc.studentList.size(), [SELECT Id FROM Portal_Email__c].size());
    }
}
