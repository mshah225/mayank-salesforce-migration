@isTest
public with sharing class CoachPortalCaseRecodingControllerTest {
    // private static final String testUsr1Alias = 'testUsr1';
    // private static final String testUsr2Alias = 'testUsr2';

    // @TestSetup
    // static void setup() {
    //     // Case classification test objects necessary to set student.Coaching_Student__c to true
    //     Case_Classification__c functionalGroup = new Case_Classification__c(
    //         Name = 'ASU Coach Outreach',
    //         RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Functional Group' LIMIT 1]
    //         .Id,
    //         Active__c = true,
    //         Visible__c = true
    //     );
    //     insert functionalGroup;
    //     Case_Classification__c category = new Case_Classification__c(
    //         Name = 'Ad Hoc',
    //         RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Category']
    //         .Id,
    //         Parent__c = functionalGroup.Id,
    //         Active__c = true,
    //         Visible__c = true
    //     );
    //     insert category;

    //     User user1 = new User(
    //         FirstName = 'CaseOwner',
    //         LastName = 'TestUser',
    //         Username = 'caseowner.testuser@test.test',
    //         Email = 'caseowner.testuser@test.test',
    //         Alias = testUsr1Alias,
    //         TimeZoneSidKey = 'America/Phoenix',
    //         LocaleSidKey = 'en_US',
    //         EmailEncodingKey = 'ISO-8859-1',
    //         ProfileId = RecordIdHelper.getProfileID('System Administrator'),
    //         LanguageLocaleKey = 'en_US'
    //     );
    //     User user2 = new User(
    //         FirstName = 'TransferTo',
    //         LastName = 'TestUser',
    //         Username = 'caseowner.testuser2@test.test',
    //         Email = 'caseowner.testuser2@test.test',
    //         Alias = testUsr2Alias,
    //         TimeZoneSidKey = 'America/Phoenix',
    //         LocaleSidKey = 'en_US',
    //         EmailEncodingKey = 'ISO-8859-1',
    //         ProfileId = RecordIdHelper.getProfileID('System Administrator'),
    //         LanguageLocaleKey = 'en_US'
    //     );
    //     insert new List<User>{ user1, user2 };

    //     List<Contact> contacts = new List<Contact>();
    //     for (Integer i = 0; i < 5; i++) {
    //         contacts.add(
    //             new Contact(
    //                 FirstName = 'TestContact' + i,
    //                 LastName = 'TestContact' + i,
    //                 Email = 'testContact' + i + '@test.test',
    //                 EmplId__c = '1234' + i
    //             )
    //         );
    //     }
    //     insert contacts;

    //     // 1st Student - General Case
    //     Success_Student__c student1 = new Success_Student__c(
    //         Student__c = contacts[0].Id,
    //         Coaching_Student__c = true,
    //         Is_Active__c = true,
    //         Time_Zone__c = 'Arizona (AZ)',
    //         RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Coach')
    //     );
    //     // 2nd Student - Not Coaching Student
    //     Success_Student__c student2 = new Success_Student__c(
    //         Student__c = contacts[1].Id,
    //         Coaching_Student__c = false,
    //         Is_Active__c = true,
    //         Time_Zone__c = 'Alaska (AK)'
    //     );
    //     // 3rd Student - Not Active
    //     Success_Student__c student3 = new Success_Student__c(
    //         Student__c = contacts[2].Id,
    //         Coaching_Student__c = true,
    //         Is_Active__c = false,
    //         Time_Zone__c = 'Hawaii-Hilo (HI)',
    //         RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Coach')
    //     );
    //     // 4th Student - No Time Zone
    //     Success_Student__c student4 = new Success_Student__c(
    //         Student__c = contacts[3].Id,
    //         Coaching_Student__c = true,
    //         Is_Active__c = true,
    //         Time_Zone__c = null,
    //         RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Coach')
    //     );
    //     // 5th/6th Students - Multiple Students Associated with Single Contact
    //     // Should only display Mountain (MST)
    //     Success_Student__c student5 = new Success_Student__c(
    //         Student__c = contacts[4].Id,
    //         Coaching_Student__c = true,
    //         Is_Active__c = true,
    //         Time_Zone__c = null,
    //         RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Coach')
    //     );
    //     Success_Student__c student6 = new Success_Student__c(
    //         Student__c = contacts[4].Id,
    //         Coaching_Student__c = true,
    //         Is_Active__c = true,
    //         Time_Zone__c = 'Mountain (MST)',
    //         RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Coach')
    //     );
    //     insert new List<Success_Student__c>{ student1, student2, student3, student4, student5, student6 };

    //     List<Case> cases = new List<Case>();
    //     for (Integer i = 0; i < 5; i++) {
    //         cases.add(
    //             new Case(
    //                 Status = 'In Progress',
    //                 Origin__c = 'In Person',
    //                 Subject = 'Test Subject',
    //                 Description = 'Test Description',
    //                 ContactId = contacts[i].Id,
    //                 OwnerId = user1.Id,
    //                 RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Coach_Outreach')
    //             )
    //         );
    //     }
    //     insert cases;
    // }

    // @isTest
    // private static void testResetRecordList() {
    //     User originalCaseOwner = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
    //     CoachPortalCaseRecodingController controller;

    //     Test.startTest();
    //     System.runAs(originalCaseOwner) {
    //         controller = new CoachPortalCaseRecodingController();
    //         controller.queryAttr = new CoachPortalMainPageController().myProactiveQuery;
    //         controller.resetRecordList();
    //     }
    //     Test.stopTest();
    //     List<Case> foundCases = new List<Case>();
    //     for (CoachPortalCaseRecodingController.caseWrapper wrapper : controller.caseList) {
    //         foundCases.add(wrapper.obj);
    //     }

    //     System.assertEquals(5, controller.caseList.size());
    //     System.assertEquals(5, controller.getContactIds(foundCases).size());
    // }

    // @isTest
    // private static void testProactiveCases() {
    //     User originalCaseOwner = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
    //     CoachPortalCaseRecodingController controller;

    //     Test.startTest();
    //     System.runAs(originalCaseOwner) {
    //         controller = new CoachPortalCaseRecodingController();
    //         controller.queryAttr = new CoachPortalMainPageController().myProactiveQuery;
    //         controller.proactiveCaseRTID = RecordIdHelper.getRecordTypeId('Case', 'ASU_Coach_Outreach');
    //         controller.resetRecordList();
    //     }
    //     Test.stopTest();
    //     List<Case> foundCases = new List<Case>();
    //     for (CoachPortalCaseRecodingController.caseWrapper wrapper : controller.caseList) {
    //         foundCases.add(wrapper.obj);
    //     }

    //     System.assertEquals(5, controller.caseList.size());
    //     System.assertEquals(5, controller.getContactIds(foundCases).size());
    // }

    // @isTest
    // private static void testTransferCases() {
    //     User originalCaseOwner = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
    //     User transferToCaseOwner = [SELECT Id FROM User WHERE Alias = :testUsr2Alias LIMIT 1];
    //     CoachPortalCaseRecodingController controller;

    //     Test.startTest();
    //     System.runAs(originalCaseOwner) {
    //         controller = new CoachPortalCaseRecodingController();
    //         controller.queryAttr = new CoachPortalMainPageController().myProactiveQuery;
    //         controller.resetRecordList();
    //         for (CoachPortalCaseRecodingController.caseWrapper caseWrapper : controller.caseList) {
    //             caseWrapper.selected = true;
    //         }
    //         controller.ownerId = transferToCaseOwner.Id;
    //         controller.transferCases();
    //     }
    //     Test.stopTest();

    //     List<Case> cases = [SELECT Id, OwnerId FROM Case];
    //     System.assertEquals(5, cases.size());
    //     for (Case c : cases) {
    //         System.assertEquals(transferToCaseOwner.Id, c.OwnerId);
    //     }
    // }

    // @isTest
    // private static void testMassEmail() {
    //     User originalCaseOwner = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
    //     List<Contact> contacts = [SELECT Id FROM Contact];
    //     List<Id> contactIds = new List<Id>();
    //     for (Contact c : contacts) {
    //         contactIds.add(c.Id);
    //     }
    //     List<Case> cases = [SELECT Id FROM Case];
    //     List<Id> caseIds = new List<Id>();
    //     for (Case c : cases) {
    //         caseIds.add(c.Id);
    //     }

    //     String emailSubject = 'Email Subject';
    //     String emailDesc = 'More text goes here';
    //     CoachPortalCaseRecodingController controller;

    //     Test.startTest();
    //     System.runAs(originalCaseOwner) {
    //         controller = new CoachPortalCaseRecodingController();
    //         controller.queryAttr = new CoachPortalMainPageController().myProactiveQuery;
    //         controller.portalEmailRTID = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Coach');
    //         controller.resetRecordList();
    //         for (CoachPortalCaseRecodingController.caseWrapper caseWrapper : controller.caseList) {
    //             caseWrapper.selected = true;
    //         }
    //         controller.tempEmail.Subject__c = emailSubject;
    //         controller.tempEmail.Additional_Message_Text__c = emailDesc;
    //         controller.massEmail();
    //     }
    //     Test.stopTest();

    //     List<Portal_Email__c> sentEmails = [
    //         SELECT Id, Case__c, Contact__c, Subject__c, Additional_Message_Text__c
    //         FROM Portal_Email__c
    //     ];

    //     System.assertEquals(5, sentEmails.size());
    //     for (Portal_Email__c email : sentEmails) {
    //         System.assertEquals(emailSubject, email.Subject__c);
    //         System.assertEquals(emailDesc, email.Additional_Message_Text__c);
    //         // Exactly one portal email per case and contact
    //         System.assert(contactIds.contains(email.Contact__c));
    //         contactIds.remove(contactIds.indexOf(email.Contact__c));
    //         System.assert(caseIds.contains(email.Case__c));
    //         caseIds.remove(caseIds.indexOf(email.Case__c));
    //     }
    // }

    // @isTest
    // private static void testClearEmail() {
    //     User originalCaseOwner = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
    //     List<Contact> contacts = [SELECT Id FROM Contact];
    //     List<Id> contactIds = new List<Id>();
    //     for (Contact c : contacts) {
    //         contactIds.add(c.Id);
    //     }
    //     List<Case> cases = [SELECT Id FROM Case];
    //     List<Id> caseIds = new List<Id>();
    //     for (Case c : cases) {
    //         caseIds.add(c.Id);
    //     }

    //     CoachPortalCaseRecodingController controller;

    //     Test.startTest();
    //     System.runAs(originalCaseOwner) {
    //         controller = new CoachPortalCaseRecodingController();
    //         controller.queryAttr = new CoachPortalMainPageController().myProactiveQuery;
    //         controller.tempEmail.Subject__c = 'Email Subject';
    //         controller.tempEmail.Additional_Message_Text__c = 'More text goes here';
    //         controller.clearTempEmail();
    //     }
    //     Test.stopTest();

    //     System.assertEquals('A Message from your College and Department', controller.tempEmail.Subject__c);
    //     System.assertEquals(null, controller.tempEmail.Additional_Message_Text__c);
    // }

    // @isTest
    // private static void testCaseWrapperConstructor() {
    //     User originalCaseOwner = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
    //     List<Case> cases = [SELECT Id, ContactId FROM Case];
    //     Map<Id, Integer> caseToMostRecentOutlookChangeDirection = new Map<Id, Integer>();
    //     Map<Id, Integer> caseToCurrContPredicitonLevel = new Map<Id, Integer>();
    //     CoachPortalCaseRecodingController controller;

    //     List<Persistence_Outlook__c> newPOs = new List<Persistence_Outlook__c>();
    //     for (Integer i = 0; i < cases.size(); i++) {
    //         Persistence_Outlook__c po = new Persistence_Outlook__c(Contact__c = cases[i].ContactId);

    //         // Set Most_Recent_Outlook_Change_Direction__c
    //         if (i == 0) {
    //             po.Change_Direction__c = 0;
    //         } else if (Math.mod(i, 2) == 0) {
    //             po.Change_Direction__c = 1;
    //         } else {
    //             po.Change_Direction__c = -1;
    //         }

    //         // Set Curr_Cont_Prediction_Level__c
    //         if (i == 0) {
    //             po.Curr_Cont_Prediction_Level__c = 3;
    //         } else if (i == 1) {
    //             po.Curr_Cont_Prediction_Level__c = 5;
    //         } else if (i == 2) {
    //             po.Curr_Cont_Prediction_Level__c = 6;
    //         } else if (i == 3) {
    //             po.Curr_Cont_Prediction_Level__c = 7;
    //         } else if (i == 4) {
    //             po.Curr_Cont_Prediction_Level__c = 8;
    //         } else {
    //             po.Curr_Cont_Prediction_Level__c = Math.floor(Math.random() * 10);
    //         }

    //         caseToMostRecentOutlookChangeDirection.put(cases[i].Id, po.Change_Direction__c.intValue());
    //         caseToCurrContPredicitonLevel.put(cases[i].Id, po.Curr_Cont_Prediction_Level__c.intValue());
    //         newPOs.add(po);
    //     }
    //     insert newPOs;

    //     Test.startTest();
    //     System.runAs(originalCaseOwner) {
    //         controller = new CoachPortalCaseRecodingController();
    //         controller.queryAttr = new CoachPortalMainPageController().myProactiveQuery;
    //         controller.resetRecordList();
    //     }
    //     Test.stopTest();

    //     System.assertEquals(5, controller.caseList.size());
    //     for (CoachPortalCaseRecodingController.CaseWrapper wrapper : controller.caseList) {
    //         String expectedChangeDir;
    //         if (caseToMostRecentOutlookChangeDirection.get(wrapper.obj.Id) == 1) {
    //             expectedChangeDir = 'Up';
    //         } else if (caseToMostRecentOutlookChangeDirection.get(wrapper.obj.Id) == -1) {
    //             expectedChangeDir = 'Down';
    //         } else {
    //             expectedChangeDir = ' ';
    //         }

    //         String expectedImageName;
    //         if (caseToCurrContPredicitonLevel.get(wrapper.obj.Id) < 4) {
    //             expectedImageName = 'icon-1.png';
    //         } else if (caseToCurrContPredicitonLevel.get(wrapper.obj.Id) < 6) {
    //             expectedImageName = 'icon-2.png';
    //         } else if (caseToCurrContPredicitonLevel.get(wrapper.obj.Id) == 6) {
    //             expectedImageName = 'icon-3.png';
    //         } else if (caseToCurrContPredicitonLevel.get(wrapper.obj.Id) == 7) {
    //             expectedImageName = 'icon-4.png';
    //         } else {
    //             expectedImageName = 'icon-5.png';
    //         }

    //         System.assertEquals(expectedChangeDir, wrapper.changeDir);
    //         System.assertEquals(expectedImageName, wrapper.imageName);
    //     }
    // }

    // @isTest
    // private static void testTermParsing() {
    //     User originalCaseOwner = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
    //     List<Case> cases = [SELECT Id, ContactId FROM Case];
    //     CoachPortalCaseRecodingController controller;
    //     Map<Id, String> caseToExpectedTermParsing = new Map<Id, String>();

    //     for (Case c : cases) {
    //         Integer strmLength = (Math.random() * 10).intValue();
    //         List<Integer> strmCharArr = new List<Integer>();
    //         for (Integer i = 0; i < strmLength; i++) {
    //             strmCharArr.add(97 + (Math.random() * 25).intValue());
    //         }
    //         c.STRM__c = String.fromCharArray(strmCharArr);

    //         Integer sessionLength = (Math.random() * 50).intValue();
    //         List<Integer> sessionCharArr = new List<Integer>();
    //         for (Integer i = 0; i < sessionLength; i++) {
    //             sessionCharArr.add(97 + (Math.random() * 25).intValue());
    //         }
    //         c.Session__c = String.fromCharArray(sessionCharArr);

    //         caseToExpectedTermParsing.put(c.Id, c.STRM__c + c.Session__c);
    //     }
    //     update cases;

    //     Test.startTest();
    //     System.runAs(originalCaseOwner) {
    //         controller = new CoachPortalCaseRecodingController();
    //         controller.queryAttr = new CoachPortalMainPageController().myProactiveQuery;
    //         controller.resetRecordList();
    //     }
    //     Test.stopTest();

    //     System.assertEquals(5, controller.caseList.size());
    //     for (CoachPortalCaseRecodingController.CaseWrapper wrapper : controller.caseList) {
    //         System.assertEquals(caseToExpectedTermParsing.get(wrapper.obj.Id), wrapper.termSession);
    //     }
    // }

    // @isTest
    // private static void testSearchString() {
    //     User originalCaseOwner = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
    //     Case c = [SELECT Id, Contact.Name FROM Case LIMIT 1];
    //     CoachPortalCaseRecodingController controller;

    //     Test.startTest();
    //     System.runAs(originalCaseOwner) {
    //         controller = new CoachPortalCaseRecodingController();
    //         controller.queryAttr = new CoachPortalMainPageController().myProactiveQuery;
    //         controller.searchString = c.Contact.Name;
    //         controller.resetRecordList();
    //     }
    //     Test.stopTest();

    //     System.assertEquals(c.Contact.Name, controller.searchString);
    //     System.assertEquals(1, controller.caseList.size());
    //     System.assertEquals(c.Id, controller.caseList[0].obj.Id);
    // }

    // @isTest
    // private static void testResetSearchString() {
    //     User originalCaseOwner = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
    //     Case c = [SELECT Id, Contact.Name FROM Case LIMIT 1];
    //     CoachPortalCaseRecodingController controller;

    //     Test.startTest();
    //     System.runAs(originalCaseOwner) {
    //         controller = new CoachPortalCaseRecodingController();
    //         controller.queryAttr = new CoachPortalMainPageController().myProactiveQuery;
    //         controller.searchString = c.Contact.Name;
    //         controller.resetSearch();
    //         controller.resetSearch(); // run a second time to get higher code coverage
    //         controller.resetRecordList();
    //     }
    //     Test.stopTest();

    //     System.assertEquals(5, controller.caseList.size());
    // }

    // @isTest
    // private static void testClearSaveResults() {
    //     User originalCaseOwner = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
    //     Case c = [SELECT Id, Contact.Name FROM Case LIMIT 1];
    //     CoachPortalCaseRecodingController controller;

    //     Test.startTest();
    //     System.runAs(originalCaseOwner) {
    //         controller = new CoachPortalCaseRecodingController();
    //         controller.queryAttr = new CoachPortalMainPageController().myProactiveQuery;
    //         controller.resetRecordList();
    //         for (CoachPortalCaseRecodingController.caseWrapper caseWrapper : controller.caseList) {
    //             caseWrapper.selected = true;
    //         }
    //         controller.clearSaveResults();
    //     }
    //     Test.stopTest();

    //     System.assertEquals(null, controller.emailInsertResults);
    //     System.assertEquals(0, controller.selectedCases.size());
    // }
}