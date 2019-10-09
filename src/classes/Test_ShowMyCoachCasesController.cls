@isTest
public with sharing class Test_ShowMyCoachCasesController {

    @isTest static void testPopulateTimeZone() {
        // Map from Case.ContactId to Success_Student__c.Time_Zone__c
        Map<Id, String> expectedTimeZone = new Map<Id, String>();

        // Test data that needs to be created
        List<Contact> contacts = new List<Contact>();
        List<Success_Student__c> students = new List<Success_Student__c>();
        List<Case> cases = new List<Case>();

        // Create 3 test contacts
        for (Integer i = 1; i <= 3; i++) {
            contacts.add(new Contact(FirstName='Success' + i, LastName='Student' + i, EMPLID__c='' + i));
        }

        insert contacts;  // Populate IDs for contacts

        // Create 3 test success students with different time zones using the 3 contacts
        for (Integer i = 0; i < 3; i++) {
            Contact con = contacts.get(i);
            String timeZone;
            if (i == 0) {
                timeZone = 'Arizona (AZ)';
            } else if (i == 1) {
                timeZone = 'Alaska (AK)';
            } else {
                timeZone = 'Hawaii-Hilo (HI)';
            }
            Success_Student__c student = new Success_Student__c(Student__c=con.Id, Time_Zone__c='Arizona (AZ)');
            students.add(student);
            expectedTimeZone.put(con.Id, student.Time_Zone__c);  // Store Time_Zone__c in map
        }

        insert students;

        // Create 3 test Cases for each of the students using the 3 contacts
        for (Integer i = 0; i < 3; i++) {
            Contact con = contacts.get(i);
            Case c = new Case(
                RecordTypeId='012d00000021xGLAAY',  // Set as ASU Coach Outreach Case
                ContactId=con.Id,
                Status='In Progress',
                Origin__c='In Person',
                Subject='Test subject'
            );
        }

        insert cases;

        // Now that we have all test data required, we can start the test
        Test.startTest();
        ShowMyCoachCasesController controller = new ShowMyCoachCasesController();
        // Needed for myProactiveQuery attribute
        CoachPortalMainPageController mainController = new CoachPortalMainPageController();

        // Must set query before calling this method by setting queryAttr to myProactiveQuery
        controller.queryAttr = mainController.myProactiveQuery;
        controller.resetRecordList();
        Test.stopTest();

        // Check that the time zones in the case wrapper match the expected time zones
        for (ShowMyCoachCasesController.CaseWrapper cw : controller.caseList) {
            String expected = expectedTimeZone.get(cw.obj.ContactId);
            String actual = cw.timeZone;
            System.assertEquals(expected, actual);
        }
    }
}
