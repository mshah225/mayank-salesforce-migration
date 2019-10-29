@isTest
public with sharing class Test_ShowMyCoachCasesController {
    // Map from Case.ContactId to Success_Student__c.Time_Zone__c
    private static Map<Id, String> expectedTimeZone = new Map<Id, String>();

    static void setup() {
        // Case classification test objects necessary to set student.Coaching_Student__c to true
        Case_Classification__c asuCoachOutreach = new Case_Classification__c(
            Name = 'ASU Coach Outreach',
            RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Functional Group' LIMIT 1].Id,
            Active__c = true,
            Visible__c = true
        );
        insert asuCoachOutreach;  // Populate ID

        Case_Classification__c adHoc = new Case_Classification__c(
            Name = 'Ad Hoc',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Category'].Id,
            Parent__c = asuCoachOutreach.Id,
            Active__c = true,
            Visible__c = true
        );
        insert adHoc;

        ContactFactory.DefaultContact contactFact = new ContactFactory.DefaultContact();
        SuccessStudentFactory.DefaultAdvisingStudent successStudentFact = new SuccessStudentFactory.DefaultAdvisingStudent();
        CaseFactory caseFact = new CaseFactory(
            new Case(
                RecordTypeId='012d00000021xGLAAY',  // Set as ASU Coach Outreach Case
                Status='In Progress',
                Origin__c='In Person',
                Subject='Test Subject',
                Description='Test Description'
            )
        );

        List<Contact> contacts = (List<Contact>) contactFact.create(3);
        insert contacts;  // Populate Contact IDs

        List<Success_Student__c> students = (List<Success_Student__c>) successStudentFact.create(4);
        // Link to Contacts and set different time zones for each student
        for (Integer i = 0; i < 4; i++) {
            Contact con;
            if (i < 3) {
                con = contacts.get(i);
            } else {
                // 4th test success student will be associated with
                // the third contact
                con = contacts.get(2);
            }
            Success_Student__c student = students.get(i);
            String timeZone = null;
            if (i == 0) {
                timeZone = 'Arizona (AZ)';
            } else if (i == 1) {
                timeZone = 'Alaska (AK)';
            } else if (i == 2) {
                timeZone = 'Hawaii-Hilo (HI)';
            }
            student.Student__c = con.Id;
            student.Time_Zone__c = timeZone;
            if (i != 1) {
                student.Coaching_Student__c = true;
            } else {
                // Set 2nd coaching student's Coaching_Student__c
                // Because of this, the 2nd coaching student's time zone
                // should not be retrieved even though it is defined as Alaska (AK)
                student.Coaching_Student__c = false;
            }
            if (i == 0 || i == 2) {
                expectedTimeZone.put(con.Id, student.Time_Zone__c);  // Store Time_Zone__c in map
            }
        }

        insert students;

        List<Case> cases = (List<Case>) caseFact.create(3);
        // Link cases to Contacts
        for (Integer i = 0; i < 3; i++) {
            Case cse = cases.get(i);
            Contact con = contacts.get(i);
            cse.ContactId = con.Id;
        }
        insert cases;
    }

    @isTest static void testPopulateTimeZone() {
        setup();
        Test.startTest();
        ShowMyCoachCasesController controller = new ShowMyCoachCasesController();
        // Needed for myProactiveQuery attribute
        CoachPortalMainPageController mainController = new CoachPortalMainPageController();
        // Must set query before calling resetRecordList
        controller.queryAttr = mainController.myProactiveQuery;
        controller.resetRecordList();
        Test.stopTest();

        // Check that 3 cases were added to controller.caseList
        System.assertEquals(3, controller.caseList.size());

        // Check that the time zones in the case wrapper match the expected time zones
        for (ShowMyCoachCasesController.CaseWrapper cw : controller.caseList) {
            System.debug('' + cw.obj.Contact.Name + ': ' + cw.timeZone);
            String expected = expectedTimeZone.get(cw.obj.ContactId);
            String actual = cw.timeZone;
            System.assertEquals(expected, actual);
        }
    }
}
