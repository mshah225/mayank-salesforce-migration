@isTest
public with sharing class CoachPortalCaseRecodingControllerTest {
    private static final String testUsr1Alias = 'testUsr1';
    private static final String testUsr2Alias = 'testUsr2';

    @TestSetup
    static void setup() {
        // Case classification test objects necessary to set student.Coaching_Student__c to true
        Case_Classification__c functionalGroup = new Case_Classification__c(
            Name = 'ASU Coach Outreach',
            RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Functional Group' LIMIT 1]
            .Id,
            Active__c = true,
            Visible__c = true
        );
        insert functionalGroup;
        Case_Classification__c category = new Case_Classification__c(
            Name = 'Ad Hoc',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Category']
            .Id,
            Parent__c = functionalGroup.Id,
            Active__c = true,
            Visible__c = true
        );
        insert category;

        User user1 = new User(
            FirstName = 'CaseOwner',
            LastName = 'TestUser',
            Username = 'caseowner.testuser@test.test',
            Email = 'caseowner.testuser@test.test',
            Alias = testUsr1Alias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = RecordIdHelper.getProfileID('System Administrator'),
            LanguageLocaleKey = 'en_US'
        );
        User user2 = new User(
            FirstName = 'TransferTo',
            LastName = 'TestUser',
            Username = 'caseowner.testuser2@test.test',
            Email = 'caseowner.testuser2@test.test',
            Alias = testUsr2Alias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = RecordIdHelper.getProfileID('System Administrator'),
            LanguageLocaleKey = 'en_US'
        );
        insert new List<User>{ user1, user2 };

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(
                new Contact(
                    FirstName = 'TestContact' + i,
                    LastName = 'TestContact' + i,
                    Email = 'testContact' + i + '@test.test',
                    EmplId__c = '1234' + i
                )
            );
        }
        insert contacts;

        // 1st Student - General Case
        Success_Student__c student1 = new Success_Student__c(
            Student__c = contacts[0].Id,
            Coaching_Student__c = true,
            Is_Active__c = true,
            Time_Zone__c = 'Arizona (AZ)',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Coach')
        );
        // 2nd Student - Not Coaching Student
        Success_Student__c student2 = new Success_Student__c(
            Student__c = contacts[1].Id,
            Coaching_Student__c = false,
            Is_Active__c = true,
            Time_Zone__c = 'Alaska (AK)'
        );
        // 3rd Student - Not Active
        Success_Student__c student3 = new Success_Student__c(
            Student__c = contacts[2].Id,
            Coaching_Student__c = true,
            Is_Active__c = false,
            Time_Zone__c = 'Hawaii-Hilo (HI)',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Coach')
        );
        // 4th Student - No Time Zone
        Success_Student__c student4 = new Success_Student__c(
            Student__c = contacts[3].Id,
            Coaching_Student__c = true,
            Is_Active__c = true,
            Time_Zone__c = null,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Coach')
        );
        // 5th/6th Students - Multiple Students Associated with Single Contact
        // Should only display Mountain (MST)
        Success_Student__c student5 = new Success_Student__c(
            Student__c = contacts[4].Id,
            Coaching_Student__c = true,
            Is_Active__c = true,
            Time_Zone__c = null,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Coach')
        );
        Success_Student__c student6 = new Success_Student__c(
            Student__c = contacts[4].Id,
            Coaching_Student__c = true,
            Is_Active__c = true,
            Time_Zone__c = 'Mountain (MST)',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Coach')
        );
        insert new List<Success_Student__c>{ student1, student2, student3, student4, student5, student6 };

        Group testGroup = new Group(Name = 'SH1', Type = 'Queue');
        insert testGroup;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueuesObject testQueue = new QueueSObject(QueueId = testGroup.Id, SObjectType = 'Case');
            insert testQueue;
        }

        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            cases.add(
                new Case(
                    Status = 'In Progress',
                    Origin__c = 'In Person',
                    Subject = 'Test Subject',
                    Description = 'Test Description',
                    ContactId = contacts[i].Id,
                    OwnerId = testGroup.Id,
                    RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Coach_Outreach')
                )
            );
        }
        insert cases;
    }

    @isTest
    private static void testLoadAndResetRecordList() {
        User originalUser = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
        CoachPortalCaseRecodingController controller;

        Test.startTest();
        System.runAs(originalUser) {
            controller = new CoachPortalCaseRecodingController();
            controller.queryAttr = new CoachPortalMainPageController().caseRecodingQuery;
            controller.resetRecordList();
        }
        Test.stopTest();
        List<Case> foundCases = new List<Case>();
        for (CoachPortalCaseRecodingController.CaseWrapper wrapper : controller.caseWrapperList) {
            foundCases.add(wrapper.obj);
        }

        System.assertEquals(5, controller.caseWrapperList.size());
        System.assertEquals(5, controller.getContactIds(foundCases).size());
    }

    @isTest
    private static void testTransferCases() {
        User originalUser = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
        User transferToCaseOwner = [SELECT Id FROM User WHERE Alias = :testUsr2Alias LIMIT 1];
        CoachPortalCaseRecodingController controller;

        Test.startTest();
        System.runAs(originalUser) {
            controller = new CoachPortalCaseRecodingController();
            controller.queryAttr = new CoachPortalMainPageController().caseRecodingQuery;
            controller.resetRecordList();
            for (CoachPortalCaseRecodingController.CaseWrapper wrapper : controller.caseWrapperList) {
                wrapper.selected = true;
            }
            controller.ownerId = transferToCaseOwner.Id;
            controller.transferCases();
        }
        Test.stopTest();

        List<Case> cases = [SELECT Id, OwnerId FROM Case];
        System.assertEquals(5, cases.size());
        for (Case c : cases) {
            System.assertEquals(transferToCaseOwner.Id, c.OwnerId);
        }
    }

    @isTest
    private static void testSearchString() {
        User originalUser = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
        Case c = [SELECT Id, Contact.Name FROM Case LIMIT 1];
        CoachPortalCaseRecodingController controller;

        Test.startTest();
        System.runAs(originalUser) {
            controller = new CoachPortalCaseRecodingController();
            controller.queryAttr = new CoachPortalMainPageController().caseRecodingQuery;
            controller.searchString = c.Contact.Name;
            controller.resetRecordList();
        }
        Test.stopTest();

        System.assertEquals(c.Contact.Name, controller.searchString);
        System.assertEquals(1, controller.caseWrapperList.size());
        System.assertEquals(c.Id, controller.caseWrapperList[0].obj.Id);
    }

    @isTest
    private static void testResetSearchString() {
        User originalUser = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
        Case c = [SELECT Id, Contact.Name FROM Case LIMIT 1];
        CoachPortalCaseRecodingController controller;

        Test.startTest();
        System.runAs(originalUser) {
            controller = new CoachPortalCaseRecodingController();
            controller.queryAttr = new CoachPortalMainPageController().caseRecodingQuery;
            controller.searchString = c.Contact.Name;
            controller.resetSearch();
            controller.resetSearch(); // run a second time to get higher code coverage
            controller.resetRecordList();
        }
        Test.stopTest();

        System.assertEquals(5, controller.caseWrapperList.size());
    }

    @isTest
    private static void testClearSaveResults() {
        User originalUser = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
        Case c = [SELECT Id, Contact.Name FROM Case LIMIT 1];
        CoachPortalCaseRecodingController controller;

        Test.startTest();
        System.runAs(originalUser) {
            controller = new CoachPortalCaseRecodingController();
            controller.queryAttr = new CoachPortalMainPageController().caseRecodingQuery;
            controller.resetRecordList();
            for (CoachPortalCaseRecodingController.CaseWrapper wrapper : controller.caseWrapperList) {
                wrapper.selected = true;
            }
            controller.clearSaveResults();
        }
        Test.stopTest();

        System.assertEquals(0, controller.selectedCases.size());
    }
}