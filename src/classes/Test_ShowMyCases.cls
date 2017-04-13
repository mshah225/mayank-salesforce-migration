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
        
        pod = new List<Success_Pod__c>([SELECT OwnerId FROM Success_Pod__c Limit 1]);
        
        if (pod.size() > 0) {
            Query = 'SELECT CaseNumber, ContactId, Contact.Name, Contact.EMPLID__c, Subject, Description, Status, FollowUp_Date__c ' +
                'FROM Case ' +
                'WHERE OwnerId = \'' + pod[0].ownerId + '\' ' +
                'AND recordTypeId = \'' + RTIDHelper.getRTID('Case', 'ASU Advisor Outreach') + '\' ' +
                'AND isClosed = false';
            
            smsc.query = query;
        }
    }
    
    @testSetup
    public static void testSetup() {
        TestDataFactory.makeMeAnAdvisorUser(numberOfPods, numberOfCases, numberOfStudents);
    }
    
    /*
     * Tests caseList's getter
     */
    public static testMethod void Test_getStudentList() {
        // note, the number of students in the list will either be equal to pageSize
        // Or numberOfStudentsToCreate if this value is fewer than pageSize.
        // This is because the standard set controller will only get the number of records
        // set in setCon.setPageSize().
         
        if (numberOfStudents < smsc.pageSize) {
            system.assertEquals(numberOfStudents, smsc.caseList.size());
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
    public static testmethod void Test_getSort() {
        smsc.sortDir = null; // Set to null
        system.assertEquals('DESC', smsc.sortDir); // Make sure the sortDir is set to default DESC
    }
    
    /*
     * Tests the controllers ability to toggle the sort dir
     */
    public static testmethod void Test_setSortField() {
        // Set sortfield to contact.name
        // verify the query contains "ORDER BY" and "Contact.Name"
        smsc.sortField = 'Contact.Name';
        
        system.assert(smsc.query.contains('ORDER BY'));
        system.assert(smsc.query.contains('Contact.Name'));
    }
    
    /*
     * Tests the controllers ability to insert mass emails
     */
    public static testmethod void Test_MassEmail() {
        // Select students
        for (ShowMyCasesController.caseWrapper cw : smsc.caseList) {
            cw.selected = true; // Select all the cases
        }
        
        // Set TempEmail
        smsc.tempEmail.Email_Template_Name__c = 'Advisor Ad-hoc template';
        smsc.tempEmail.Additional_Message_Text__c = 'Test mass email';
        
        smsc.portalEmailRTID = RTIDHelper.getRTID('Portal_Email__c', 'Advisor');
        
        // Insert Portal Emails
        smsc.massEmail();
        
        system.debug('assert called below me');
        system.assertEquals(smsc.caseList.size(), [SELECT Id FROM Portal_Email__c].size());
        system.debug('assert Called above me');
    }
}