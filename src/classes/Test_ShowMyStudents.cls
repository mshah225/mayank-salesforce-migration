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
            query = 'SELECT Student_Name__c, EMPLID__c, Student__c ' +
                'FROM Success_Student__c ' +
                'WHERE Success_Pod__c = \'' + pod[0].Id + '\' ' +
                'AND Is_Active__c = true';
            smsc.query = query;
        }
    }
    
    /*
     * Create test data
     */
    @testSetup
    public static void testSetup() {
        // Create queue to own pod
        Group testGroup = new Group(
            Name = 'Test Group Name',
            Type = 'Queue'
        );

        insert testGroup;

        QueueSobject testQueue = new QueueSobject(
            QueueId = testGroup.Id,
            SobjectType = 'Success_Pod__c'
        );
        
        // To avoid MIXED DML ERROR, you need to insert this non-setup object
        // as the system user. In this case, just the admin running the test.
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testQueue;
        }
        
        // Create Pod
        Id successPodRTID = [SELECT Id FROM RecordType WHERE SObjectType = 'Success_Pod__c' AND Name = 'Advisor'].Id;
        
        Success_Pod__c sp = new Success_Pod__c(
            ownerId = testGroup.Id,
            recordTypeId = successPodRTID
        );
        
        insert sp;
        
        // Create student(s) and assign to pod
        List<Contact> contactsToCreate = TestDataFactory.createContacts(numberOfstudentsToCreate);
        List<Success_Student__c> studentsToCreate = new List<Success_Student__c>();
        
        insert contactsToCreate;
        
        for (Contact c : contactsToCreate) {
            studentsToCreate.add(new Success_Student__c(
                Student__c = c.Id,
                Success_Pod__c = sp.Id
            ));
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
     * Tests the controllers ability to handle null values in sortDir
     */
    public static testmethod void Test_getSort() {
        smsc.sortDir = null; // Set to null
        system.assertEquals('DESC', smsc.sortDir); // Make sure the sortDir is set to default DESC
    }
    
    /*
     * Tests the controllers ability to toggle the sort dir
     */
    public static testmethod void Test_toggleSort() {
        // toggleSort violates the single purpose principal and updates the query as well
        // so lets test that here as well
        String tempQuery;
        tempQuery = smsc.query;
        
        smsc.sortField = 'EMPLID__c'; // set sortfield for the query
        
        smsc.toggleSort(); // Since default is DESC, it should now be ASC
        system.assertEquals('ASC', smsc.sortDir);
        
        // The page currently utilizes what can best be described as a bug
        // Because of this, we need to reset the query to the old query or we will just
        // stack order by clauses into the query. The bug in the page handles this for us.
        smsc.query = tempQuery;
        
        smsc.toggleSort();
        system.assertEquals('DESC', smsc.sortDir);
        
        smsc.query = tempQuery;
        
        smsc.toggleSort();
        system.assertEquals('ASC', smsc.sortDir);
        
        
        system.assert(smsc.query.contains('ORDER BY'));
    }
    
    /*
     * Tests the controllers ability to retrieve the selected students
     */
    public static testmethod void Test_getSelectedStudents() {
        for (showMyStudentsController.studentWrapper sw : smsc.studentList) {
            sw.selected = true; // Select all the cases
        }
        
        system.assertEquals(smsc.studentList.size(), smsc.selectedStudents.size());
    }
    
    /*
     * Tests the controllers ability to insert mass emails
     */
    public static testmethod void Test_MassEmail() {
        // Select students
        for (showMyStudentsController.studentWrapper sw : smsc.studentList) {
            sw.selected = true; // Select all the cases
        }
        
        // Set TempEmail
        smsc.tempEmail.Email_Template_Name__c = 'Advisor Ad-hoc template';
        smsc.tempEmail.Additional_Message_Text__c = 'Test mass email';
        
        smsc.portalEmailRTID = RTIDHelper.getRTID('Portal_Email__c', 'Advisor');
        
        // Insert Portal Emails
        smsc.massEmail();
        
        system.assertEquals(smsc.studentList.size(), [SELECT Id FROM Portal_Email__c].size());
    }
}