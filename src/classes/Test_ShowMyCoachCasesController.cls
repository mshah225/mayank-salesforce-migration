@isTest
public with sharing class Test_ShowMyCoachCasesController {
    // Map from Case.ContactId to Success_Student__c.Time_Zone__c
    private static Map<Id, String> expectedTimeZone = new Map<Id, String>();

    static void setup() {
        // Case classification test objects necessary to set student.Coaching_Student__c to true
        Case_Classification__c asuCoachOutreach = new Case_Classification__c(
            Name = 'ASU Coach Outreach',
            RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Functional Group' LIMIT 1]
            .Id,
            Active__c = true,
            Visible__c = true
        );
        insert asuCoachOutreach; // Populate ID

        Case_Classification__c adHoc = new Case_Classification__c(
            Name = 'Ad Hoc',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Category']
            .Id,
            Parent__c = asuCoachOutreach.Id,
            Active__c = true,
            Visible__c = true
        );
        insert adHoc;

        ContactFactory.DefaultContact contactFact = new ContactFactory.DefaultContact();
        SuccessStudentFactory.DefaultAdvisingStudent successStudentFact = new SuccessStudentFactory.DefaultAdvisingStudent();
        CaseFactory caseFact = new CaseFactory(
            new Case(
                RecordTypeId = '012d00000021xGLAAY', // Set as ASU Coach Outreach Case
                Status = 'In Progress',
                Origin__c = 'In Person',
                Subject = 'Test Subject',
                Description = 'Test Description'
            )
        );

        List<Contact> contacts = (List<Contact>) contactFact.create(5);
        insert contacts; // Populate Contact IDs

        Id coachRTId = [SELECT Id, Name, sObjectType  From RecordType WHERE Name = 'Coach' And SObjectType = 'Success_Student__c' LIMIT 1].Id;
        
        List<Success_Student__c> students = (List<Success_Student__c>) successStudentFact.create(6);
        // Test cases:
        // -----------
        Success_Student__c student;
        Contact con;

        // 1st Student - General Case
        student = students.get(0);
        con = contacts.get(0);
        student.RecordTypeId = coachRTId;
        student.Student__c = con.Id;
        student.Time_Zone__c = 'Arizona (AZ)';
        student.Coaching_Student__c = true;
        student.Is_Active__c = true;
        expectedTimeZone.put(con.Id, student.Time_Zone__c);

        // 2nd Student - Not Coaching Student
        student = students.get(1);
        con = contacts.get(1);
        student.Student__c = con.Id;
        student.Time_Zone__c = 'Alaska (AK)';
        student.Coaching_Student__c = false;
        student.Is_Active__c = true;
        expectedTimeZone.put(con.Id, null);

        // 3rd Student - Not Active
        student = students.get(2);
        con = contacts.get(2);
        student.RecordTypeId = coachRTId;
        student.Student__c = con.Id;
        student.Time_Zone__c = 'Hawaii-Hilo (HI)';
        student.Coaching_Student__c = true;
        student.Is_Active__c = false;
        expectedTimeZone.put(con.Id, null);

        // 4th Student - No Time Zone
        student = students.get(3);
        con = contacts.get(3);
        student.RecordTypeId = coachRTId;
        student.Student__c = con.Id;
        student.Time_Zone__c = null;
        student.Coaching_Student__c = true;
        student.Is_Active__c = true;
        expectedTimeZone.put(con.Id, null);

        // 5th/6th Students - Multiple Students Associated with Single Contact
        // Should only display Mountain (MST)
        student = students.get(4);
        con = contacts.get(4);
        student.RecordTypeId = coachRTId;
        student.Student__c = con.Id;
        student.Time_Zone__c = null;
        student.Coaching_Student__c = true;
        student.Is_Active__c = true;

        student = students.get(5);
        student.RecordTypeId = coachRTId;
        student.Student__c = con.Id;
        student.Time_Zone__c = 'Mountain (MST)';
        student.Coaching_Student__c = true;
        student.Is_Active__c = true;
        expectedTimeZone.put(con.Id, student.Time_Zone__c);

        insert students;

        List<Case> cases = (List<Case>) caseFact.create(5); // One for each Contact
        // Link cases to Contacts
        for (Integer i = 0; i < 5; i++) {
            Case cse = cases.get(i);
            Contact ct = contacts.get(i);
            cse.ContactId = ct.Id;
        }
        insert cases;
    }

    @isTest
    static void testPopulateTimeZone() {
        setup();
        Test.startTest();
        ShowMyCoachCasesController controller = new ShowMyCoachCasesController();
        // Needed for myProactiveQuery attribute
        CoachPortalMainPageController mainController = new CoachPortalMainPageController();
        // Must set query before calling resetRecordList
        controller.queryAttr = mainController.myProactiveQuery;
        controller.resetRecordList();
        Test.stopTest();

        // Check that 5 cases were added to controller.caseList
        System.assertEquals(5, controller.caseList.size());
    }
}
