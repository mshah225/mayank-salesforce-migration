@isTest
public with sharing class CaseListTransferControllerTest {
    private static final string testUserUsername = 'case-list-transfer-controller-test-user@test.example.com';
    private static final string testSibilingUserUsername = 'case-list-transfer-controller-test-sibiling-user@test.example.com';
    private static final string testParentUserUsername = 'case-list-transfer-controller-test-parent-user@test.example.com';
    private static final string testChildUserUsername = 'case-list-transfer-controller-test-child-user@test.example.com';
    private static final string testNonASRoleName = 'TestUserRole';

    @TestSetup
    static void setup() {
        User runAsUser = new User(Id = UserInfo.getUserId());

        Case_Classification__c functionalGroup = new Case_Classification__c(
            Name = 'TestFunctionalGroup',
            Active__c = true,
            Visible__c = true,
            Record_Types_String__c = 'wer',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
        );
        insert functionalGroup;
        Case_Classification__c category = new Case_Classification__c(
            Name = 'TestCategoryName',
            Active__c = true,
            Visible__c = true,
            Parent__c = functionalGroup.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Category')
        );
        insert category;
        Case_Classification__c subcategory = new Case_Classification__c(
            Name = 'TestSubCategoryName',
            Active__c = true,
            Visible__c = true,
            Parent__c = category.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category')
        );
        insert subcategory;

        Case c = new Case(
            Subject = 'TestCaseSubject',
            Description = 'TestCaseDescription',
            CC_Functional_Group__c = functionalGroup.Id.to15(),
            CC_Category__c = category.Id.to15(),
            CC_Sub_Category__c = subcategory.Id.to15()
        );
        insert c;

        UserRole grandParentUr = new UserRole(Name = 'TestGrandParentUserRole');
        System.runAs(runAsUser) {
            insert grandParentUr;
        }
        UserRole parentUr = new UserRole(Name = 'TestParentUserRole', ParentRoleId = grandParentUr.Id.to15());
        System.runAs(runAsUser) {
            insert parentUr;
        }
        UserRole ur = new UserRole(Name = testNonASRoleName, ParentRoleId = parentUr.Id.to15());
        System.runAs(runAsUser) {
            insert ur;
        }
        UserRole childUr = new UserRole(Name = 'TestChildUserRole', ParentRoleId = ur.Id.to15());
        System.runAs(runAsUser) {
            insert childUr;
        }

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = testUserUsername,
            Email = testUserUsername,
            Alias = 'testUsr',
            CommunityNickname = 'testUsr',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('System Administrator'),
            UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'AS Admission Services']
            .Id
        );
        User testSibilingUser = new User(
            FirstName = 'TestSibling',
            LastName = 'User',
            Username = testSibilingUserUsername,
            Email = testSibilingUserUsername,
            Alias = 'testUsr2',
            CommunityNickname = 'testUsr2',
            Title = 'TestSibTitle',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('System Administrator'),
            UserRoleId = ur.Id,
            IsActive = true,
            UserPermissionsSupportUser = true
        );
        User testParentUser = new User(
            FirstName = 'TestParent',
            LastName = 'User',
            Username = testParentUserUsername,
            Email = testParentUserUsername,
            Alias = 'testUsr3',
            CommunityNickname = 'testUsr3',
            Department = 'TestParDepartment',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('System Administrator'),
            UserRoleId = parentUr.Id,
            IsActive = true,
            UserPermissionsSupportUser = true
        );
        User testChildUser = new User(
            FirstName = 'TestChild',
            LastName = 'User',
            Username = testChildUserUsername,
            Email = testChildUserUsername,
            Alias = 'testUsr4',
            CommunityNickname = 'testUsr4',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('System Administrator'),
            UserRoleId = childUr.Id,
            IsActive = true,
            UserPermissionsSupportUser = true
        );

        System.runAs(runAsUser) {
            insert new List<User>{ testUser, testSibilingUser, testParentUser, testChildUser };
        }

        Case_Assignment_Rule__c car1 = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Service Departments',
            CTPGroup__c = 'grp1',
            Label__c = 'grp1-opt1 (General)',
            CTPVisible__c = true,
            Queue_ID__c = testSibilingUser.Id.to15(),
            CC_Functional_Group__c = functionalGroup.Id.to15(),
            CC_Category__c = category.Id.to15(),
            CC_Sub_Category__c = subcategory.Id.to15(),
            Email_Address__c = 'case-list-transfer-controller-test-email-addr@test.test',
            Case_Feed_Email_Template_Id__c = null,
            Campus__c = Case.Campus__c.getDescribe().getPicklistValues()[0].value,
            Case_Record_Type_Id__c = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach').to15()
        );
        Case_Assignment_Rule__c car2 = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Service Departments',
            CTPGroup__c = 'grp1',
            Label__c = 'grp1-opt2 (General)',
            CTPVisible__c = true
        );
        Case_Assignment_Rule__c car3 = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Service Departments',
            CTPGroup__c = 'grp1',
            Label__c = 'grp1-opt3',
            CTPVisible__c = true
        );
        Case_Assignment_Rule__c car4 = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Service Departments',
            CTPGroup__c = 'grp2',
            Label__c = 'grp2-opt1 (General)',
            CTPVisible__c = true
        );
        Case_Assignment_Rule__c car5 = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Service Departments',
            CTPGroup__c = 'grp2',
            Label__c = 'grp2-opt2',
            CTPVisible__c = true
        );
        Case_Assignment_Rule__c car6 = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Colleges',
            CTPGroup__c = 'grp3',
            Label__c = 'grp3-opt1 (General)',
            CTPVisible__c = true
        );
        Case_Assignment_Rule__c car7 = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Colleges',
            CTPGroup__c = 'grp3',
            Label__c = 'grp3-opt2',
            CTPVisible__c = true
        );
        insert new List<Case_Assignment_Rule__c>{ car1, car2, car3, car4, car5, car6, car7 };
    }

    @isTest
    private static void testSingleCaseController() {
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));
        System.assertEquals(0, ApexPages.getMessages().size());
        System.assertEquals(1, controller.page);
    }

    @isTest
    private static void testErrorWithNoDescription() {
        Case untransferrableCase = new Case(Subject = 'CANT_TRANSFER');
        insert untransferrableCase;

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(
            new ApexPages.StandardController(untransferrableCase)
        );

        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());

        System.assertEquals(ApexPages.severity.ERROR, messages[0].getSeverity());
        System.assertEquals(
            'The Subject and Description are required fields for case transfer. Please fill out the missing fields before transferring the case(s).',
            messages[0].getSummary()
        );
    }

    @isTest
    private static void testSetCaseController() {
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];
        Case c2 = new Case(Subject = 'TestCaseSubject2', Description = 'TestCaseDescription2');
        insert c2;
        List<Case> allCases = new List<Case>{ c, c2 };

        Test.setCurrentPage(Page.CaseTransfer);
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(allCases);
        setController.setSelected(allCases);
        CaseListTransferController controller = new CaseListTransferController(setController);

        System.assertEquals(2, controller.cs.size());
        System.assertEquals(0, ApexPages.getMessages().size());
        System.assertEquals(1, controller.page);
    }

    @isTest
    private static void testSetCaseControllerUsingUrlParams() {
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];
        Case c2 = new Case(Subject = 'TestCaseSubject2', Description = 'TestCaseDescription2');
        insert c2;
        List<Case> allCases = new List<Case>{ c, c2 };

        ApexPages.PageReference pr = Page.CaseTransfer;
        pr.getParameters().put('caseIds', c.Id + ',' + c2.Id);
        Test.setCurrentPage(pr);
        CaseListTransferController controller = new CaseListTransferController(
            new ApexPages.StandardSetController(new List<Case>())
        );

        System.assertEquals(2, controller.cs.size());
        System.assertEquals(0, ApexPages.getMessages().size());
        System.assertEquals(1, controller.page);
    }

    @isTest
    private static void testErrorInvalidIdUsingUrlParams() {
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];
        Case c2 = new Case(Subject = 'TestCaseSubject2', Description = 'TestCaseDescription2');
        insert c2;
        List<Case> allCases = new List<Case>{ c, c2 };

        ApexPages.PageReference pr = Page.CaseTransfer;
        pr.getParameters().put('caseIds', c.Id + ',' + c2.Id + ',INVALID_ID');
        Test.setCurrentPage(pr);
        CaseListTransferController controller = new CaseListTransferController(
            new ApexPages.StandardSetController(new List<Case>())
        );

        List<ApexPages.Message> messages = ApexPages.getMessages();

        System.assertEquals(2, controller.cs.size());
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(1, controller.page);
        System.assertEquals(ApexPages.severity.ERROR, messages[0].getSeverity());
        System.assertEquals('Invalid Id: INVALID_ID', messages[0].getSummary());
    }

    @isTest
    private static void testErrorWithNoDescriptionForSet() {
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];
        Case c2 = new Case(Subject = 'TestCaseSubject2');
        insert c2;
        List<Case> allCases = new List<Case>{ c, c2 };

        ApexPages.PageReference pr = Page.CaseTransfer;
        pr.getParameters().put('caseIds', c.Id + ',' + c2.Id);
        Test.setCurrentPage(pr);
        CaseListTransferController controller = new CaseListTransferController(
            new ApexPages.StandardSetController(new List<Case>())
        );

        List<ApexPages.Message> messages = ApexPages.getMessages();

        System.assertEquals(2, controller.cs.size());
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(1, controller.page);
        System.assertEquals(ApexPages.severity.ERROR, messages[0].getSeverity());
        System.assertEquals(
            'The Subject and Description are required fields for case transfer. Please fill out the missing fields before transferring the case(s).',
            messages[0].getSummary()
        );
    }

    @isTest
    private static void testPage1() {
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        controller.page1();

        System.assertEquals(0, ApexPages.getMessages().size());
        System.assertEquals(1, controller.page);
    }

    @isTest
    private static void testPage2() {
        User u = [SELECT Id FROM User WHERE Username = :testUserUsername];
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        System.runAs(u) {
            controller.page2();
        }

        controller.asUsersToAdd.sort();
        // controller.userList.sort(); // already sorted in searchUsers()

        System.assertEquals(controller.asUsersToAdd.size(), controller.userList.size());
        for (Integer i = 0; i < controller.asUsersToAdd.size(); i++) {
            System.assertEquals(controller.asUsersToAdd[i].Id, controller.userList[i].Id);
        }
        System.assertEquals(0, ApexPages.getMessages().size());
        System.assertEquals(2, controller.page);
    }

    @isTest
    private static void testPage3() {
        User u = [SELECT Id FROM User WHERE Username = :testUserUsername];
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];

        List<Case_Assignment_Rule__c> allCARs = [
            SELECT Id, CTPColumn__c, CTPGroup__c, Label__c
            FROM Case_Assignment_Rule__c
        ];
        Map<String, List<Case_Assignment_Rule__c>> serviceCARS = new Map<String, List<Case_Assignment_Rule__c>>();
        Map<String, List<Case_Assignment_Rule__c>> collegeCARS = new Map<String, List<Case_Assignment_Rule__c>>();
        for (Case_Assignment_Rule__c car : allCARs) {
            if (car.CTPColumn__c == 'Service Departments') {
                if (!serviceCARS.containsKey(car.CTPGroup__c))
                    serviceCARS.put(car.CTPGroup__c, new List<Case_Assignment_Rule__c>());
                serviceCARS.get(car.CTPGroup__c).add(car);
            } else if (car.CTPColumn__c == 'Colleges') {
                if (!collegeCARS.containsKey(car.CTPGroup__c))
                    collegeCARS.put(car.CTPGroup__c, new List<Case_Assignment_Rule__c>());
                collegeCARS.get(car.CTPGroup__c).add(car);
            }
        }

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        controller.page3();

        // Contains all required CARs
        System.assertEquals(allCARs.size(), controller.allGenCARs.size());
        for (Case_Assignment_Rule__c car : allCARs) {
            Boolean matchFound = false;
            for (Case_Assignment_Rule__c controllerCAR : controller.allGenCARs) {
                if (car.Id == controllerCAR.Id) {
                    matchFound = true;
                    break;
                }
            }
            System.assert(matchFound, 'Could not find CAR in controller\'s CAR list');
        }
        // Properly sorted all College CARs
        System.assertEquals(collegeCARs.size(), controller.collegeCARS.size());
        for (String key : collegeCARs.keySet()) {
            System.assert(controller.collegeCARS.containsKey(key));

            for (Case_Assignment_Rule__c car : collegeCARs.get(key)) {
                Boolean matchFound = false;
                for (Case_Assignment_Rule__c controllerCAR : controller.collegeCARs.get(key)) {
                    if (car.Id == controllerCAR.Id) {
                        matchFound = true;
                        break;
                    }
                }
                System.assert(matchFound, 'Could not find CAR in controller\'s CAR list');
            }
        }
        // Properly sorted all Service CARs
        System.assertEquals(serviceCARS.size(), controller.serviceCARS.size());
        for (String key : serviceCARS.keySet()) {
            System.assert(controller.serviceCARS.containsKey(key));

            for (Case_Assignment_Rule__c car : serviceCARS.get(key)) {
                Boolean matchFound = false;
                for (Case_Assignment_Rule__c controllerCAR : controller.serviceCARS.get(key)) {
                    if (car.Id == controllerCAR.Id) {
                        matchFound = true;
                        break;
                    }
                }
                System.assert(matchFound, 'Could not find CAR in controller\'s CAR list');
            }
        }

        System.assertEquals(0, ApexPages.getMessages().size());
        System.assertEquals(3, controller.page);
    }

    @isTest
    private static void testPage4() {
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        controller.page4();

        System.assertEquals(0, ApexPages.getMessages().size());
        System.assertEquals(4, controller.page);
    }

    @isTest
    private static void testResetSearch() {
        User u = [SELECT Id FROM User WHERE Username = :testUserUsername];
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = :testNonASRoleName LIMIT 1];
        User testSibilingUser = [SELECT Id, Name FROM User WHERE Username = :testSibilingUserUsername];
        User testParentUser = [SELECT Id, Email FROM User WHERE Username = :testParentUserUsername];
        User testChildUser = [SELECT Id, Name FROM User WHERE Username = :testChildUserUsername];
        List<User> relatedUsers = new List<User>{ testSibilingUser, testParentUser, testChildUser };

        update new User(Id = u.Id, UserRoleId = ur.Id);

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        System.runAs(u) {
            controller.page2();
            controller.searchUsers();
        }

        // No search term results
        System.assertEquals(relatedUsers.size(), controller.userList.size());
        for (User relatedUser : relatedUsers) {
            Boolean matchFound = false;
            for (User usrOption : controller.userList) {
                if (usrOption.Id == relatedUser.Id) {
                    matchFound = true;
                    break;
                }
            }
            System.assert(matchFound, 'Related user that should have been included, wasn\'t');
        }
        System.assertEquals(0, ApexPages.getMessages().size());

        // Search by name
        Test.setFixedSearchResults(new List<Id>{ testChildUser.Id });
        controller.searchString = testChildUser.Name;
        System.runAs(u) {
            controller.searchUsers();
        }
        System.assertEquals(1, controller.userList.size());
        System.assertEquals(testChildUser.Id, controller.userList[0].Id);
        System.assertEquals(0, ApexPages.getMessages().size());

        // Reset search term results
        System.runAs(u) {
            controller.resetSearch();
        }
        System.assertEquals(relatedUsers.size(), controller.userList.size());
        for (User relatedUser : relatedUsers) {
            Boolean matchFound = false;
            for (User usrOption : controller.userList) {
                if (usrOption.Id == relatedUser.Id) {
                    matchFound = true;
                    break;
                }
            }
            System.assert(matchFound, 'Related user that should have been included, wasn\'t');
        }
        System.assertEquals(0, ApexPages.getMessages().size());
    }

    @isTest
    private static void testEmptySearchWithASRole() {
        User u = [SELECT Id FROM User WHERE Username = :testUserUsername];
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        System.runAs(u) {
            controller.page2();
            controller.searchUsers();
        }

        System.assertEquals(controller.asUsersToAdd.size(), controller.userList.size());
        for (User userThatShouldBeIncluded : controller.asUsersToAdd) {
            Boolean matchFound = false;
            for (User userThatActuallyIsIncluded : controller.userList) {
                if (userThatShouldBeIncluded.Id == userThatActuallyIsIncluded.Id) {
                    matchFound = true;
                    break;
                }
            }
            System.assert(matchFound, 'User that should be included, wasn\'t');
        }
        System.assertEquals(0, ApexPages.getMessages().size());
    }

    @isTest
    private static void testEmptySearchWithoutASRole() {
        User u = [SELECT Id FROM User WHERE Username = :testUserUsername];
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = :testNonASRoleName LIMIT 1];
        User testSibilingUser = [SELECT Id, Title FROM User WHERE Username = :testSibilingUserUsername];
        User testParentUser = [SELECT Id, Department FROM User WHERE Username = :testParentUserUsername];
        User testChildUser = [SELECT Id, Name FROM User WHERE Username = :testChildUserUsername];
        List<User> relatedUsers = new List<User>{ testSibilingUser, testParentUser, testChildUser };

        update new User(Id = u.Id, UserRoleId = ur.Id);

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        System.runAs(u) {
            controller.page2();
            controller.searchUsers();
        }

        System.assertEquals(relatedUsers.size(), controller.userList.size());
        for (User relatedUser : relatedUsers) {
            Boolean matchFound = false;
            for (User usrOption : controller.userList) {
                if (usrOption.Id == relatedUser.Id) {
                    matchFound = true;
                    break;
                }
            }
            System.assert(matchFound, 'Related user that should have been included, wasn\'t');
        }
        System.assertEquals(0, ApexPages.getMessages().size());
    }

    @isTest
    private static void testSearchTerms() {
        User u = [SELECT Id FROM User WHERE Username = :testUserUsername];
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = :testNonASRoleName LIMIT 1];
        User testSibilingUser = [SELECT Id, Name FROM User WHERE Username = :testSibilingUserUsername];
        User testParentUser = [SELECT Id, Email FROM User WHERE Username = :testParentUserUsername];
        User testChildUser = [SELECT Id, Name FROM User WHERE Username = :testChildUserUsername];
        List<User> relatedUsers = new List<User>{ testSibilingUser, testParentUser, testChildUser };

        update new User(Id = u.Id, UserRoleId = ur.Id);

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        System.runAs(u) {
            controller.page2();
            controller.searchUsers();
        }

        // No search term results
        System.assertEquals(relatedUsers.size(), controller.userList.size());
        for (User relatedUser : relatedUsers) {
            Boolean matchFound = false;
            for (User usrOption : controller.userList) {
                if (usrOption.Id == relatedUser.Id) {
                    matchFound = true;
                    break;
                }
            }
            System.assert(matchFound, 'Related user that should have been included, wasn\'t');
        }
        System.assertEquals(0, ApexPages.getMessages().size());

        // Search by name
        Test.setFixedSearchResults(new List<Id>{ testChildUser.Id });
        controller.searchString = testChildUser.Name;
        System.runAs(u) {
            controller.searchUsers();
        }
        System.assertEquals(1, controller.userList.size());
        System.assertEquals(testChildUser.Id, controller.userList[0].Id);
        System.assertEquals(0, ApexPages.getMessages().size());
    }

    @isTest
    private static void testTransferToSelectedId() {
        User u = [SELECT Id FROM User WHERE Username = :testUserUsername];
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];
        User testSibilingUser = [SELECT Id FROM User WHERE Username = :testSibilingUserUsername];

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        ApexPages.PageReference pr = null;
        System.runAs(u) {
            controller.page2();
            controller.selectedId = testSibilingUser.Id;
            pr = controller.transferCase();
        }

        c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id LIMIT 1];

        System.assertEquals('/' + c.Id, pr.getUrl());
        System.assert(pr.getRedirect());
        System.assertEquals(testSibilingUser.Id, c.OwnerId);
        System.assertEquals(0, ApexPages.getMessages().size());
    }

    @isTest
    private static void testTransferToSelectedPublicCAR() {
        User u = [SELECT Id FROM User WHERE Username = :testUserUsername];
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];
        User testSibilingUser = [SELECT Id FROM User WHERE Username = :testSibilingUserUsername];
        Case_Assignment_Rule__c car = [
            SELECT
                Id,
                Queue_ID__c,
                CC_Functional_Group__c,
                CC_Category__c,
                CC_Sub_Category__c,
                Email_Address__c,
                Case_Feed_Email_Template_Id__c,
                Campus__c
            FROM Case_Assignment_Rule__c
            WHERE Queue_ID__c != NULL
        ];

        c.CC_Functional_Group__c = null;
        c.CC_Category__c = null;
        c.CC_Sub_Category__c = null;
        update c;

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        ApexPages.PageReference pr = null;
        System.runAs(u) {
            controller.page2();
            controller.page3();
            controller.selectedId = car.Id;
            pr = controller.transferCase();
        }

        c = [
            SELECT
                Id,
                OwnerId,
                CC_Functional_Group__c,
                CC_Category__c,
                CC_Sub_Category__c,
                Case_Feed_Email__c,
                Case_Feed_Email_Template_Id__c,
                Campus__c
            FROM Case
            WHERE Id = :c.Id
            LIMIT 1
        ];

        System.assertEquals('/' + c.Id, pr.getUrl());
        System.assert(pr.getRedirect());
        System.assertEquals(0, ApexPages.getMessages().size());
        System.assertEquals(car.Queue_ID__c, c.OwnerId);
        System.assertEquals(car.CC_Functional_Group__c, c.CC_Functional_Group__c);
        System.assertEquals(car.CC_Category__c, c.CC_Category__c);
        System.assertEquals(car.CC_Sub_Category__c, c.CC_Sub_Category__c);
        System.assertEquals(car.Email_Address__c, c.Case_Feed_Email__c);
        System.assertEquals(car.Case_Feed_Email_Template_Id__c, c.Case_Feed_Email_Template_Id__c);
        System.assertEquals(car.Campus__c, c.Campus__c);
    }

    @isTest
    private static void testTransferToSelectedPrivateCAR() {
        User u = [SELECT Id FROM User WHERE Username = :testUserUsername];
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];
        User testSibilingUser = [SELECT Id FROM User WHERE Username = :testSibilingUserUsername];
        Case_Assignment_Rule__c car = [
            SELECT
                Id,
                Queue_ID__c,
                CC_Functional_Group__c,
                CC_Category__c,
                CC_Sub_Category__c,
                Email_Address__c,
                Case_Feed_Email_Template_Id__c,
                Campus__c
            FROM Case_Assignment_Rule__c
            WHERE Queue_ID__c != NULL
        ];
        Case_Classification__c functionalGroup = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
            LIMIT 1
        ];

        // Unset functional group since it be set by CAR
        c.CC_Functional_Group__c = null;
        c.CC_Category__c = null;
        c.CC_Sub_Category__c = null;
        update c;

        // Set as private for this test
        functionalGroup.Is_Functional_Group_Private__c = true;
        functionalGroup.Queue_ID__c = car.Queue_ID__c;
        update functionalGroup;

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        ApexPages.PageReference pr = null;
        System.runAs(u) {
            controller.page2();
            controller.page3();
            controller.selectedId = car.Id;
            pr = controller.transferCase();
        }

        c = [
            SELECT
                Id,
                OwnerId,
                CC_Functional_Group__c,
                CC_Category__c,
                CC_Sub_Category__c,
                Case_Feed_Email__c,
                Case_Feed_Email_Template_Id__c,
                Campus__c
            FROM Case
            WHERE Id = :c.Id
            LIMIT 1
        ];

        System.assertEquals(5, controller.page);
        System.assertEquals(0, ApexPages.getMessages().size());
        System.assertEquals(car.Queue_ID__c, c.OwnerId);
        System.assertEquals(car.CC_Functional_Group__c, c.CC_Functional_Group__c);
        System.assertEquals(car.CC_Category__c, c.CC_Category__c);
        System.assertEquals(car.CC_Sub_Category__c, c.CC_Sub_Category__c);
        System.assertEquals(car.Email_Address__c, c.Case_Feed_Email__c);
        System.assertEquals(car.Case_Feed_Email_Template_Id__c, c.Case_Feed_Email_Template_Id__c);
        System.assertEquals(car.Campus__c, c.Campus__c);
    }

    @isTest
    private static void testTransferErrorWithNoDescription() {
        Case untransferrableCase = new Case(Subject = 'CANT_TRANSFER');
        insert untransferrableCase;

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(
            new ApexPages.StandardController(untransferrableCase)
        );
        controller.transferCase();

        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(2, messages.size()); // one from constructor and another from transfer attempt

        System.assertEquals(ApexPages.severity.ERROR, messages[1].getSeverity());
        System.assertEquals(
            'The Subject and Description are required fields for case transfer. Please fill out the missing fields before transferring the case.',
            messages[1].getSummary()
        );
    }

    @isTest
    private static void testRelease() {
        User u = [SELECT Id FROM User WHERE Username = :testUserUsername];
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];

        Case_Assignment_Rule__c car = [SELECT Id, Queue_ID__c FROM Case_Assignment_Rule__c WHERE Queue_ID__c != NULL];
        User testParentUser = [SELECT Id FROM User WHERE Username = :testParentUserUsername];

        car.Queue_ID__c = testParentUser.Id.to15();
        update car;

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        ApexPages.PageReference pr = controller.releaseOwnership();

        c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id LIMIT 1];

        System.assertEquals(testParentUser.Id, c.OwnerId);
        System.assertEquals('/' + c.Id, pr.getUrl());
    }

    @isTest
    private static void testReleaseErrorInvalidFunctionalGroup() {
        User u = [SELECT Id FROM User WHERE Username = :testUserUsername];
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];

        Case_Assignment_Rule__c car = [SELECT Id, Queue_ID__c FROM Case_Assignment_Rule__c WHERE Queue_ID__c != NULL];
        User testParentUser = [SELECT Id FROM User WHERE Username = :testParentUserUsername];

        delete car;

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        ApexPages.PageReference pr = controller.releaseOwnership();

        c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id LIMIT 1];

        List<ApexPages.Message> messages = ApexPages.getMessages();

        System.assertEquals(1, messages.size());
        System.assertEquals(ApexPages.severity.ERROR, messages[0].getSeverity());
        System.assertEquals(
            'Could not locate assignment rule. Please ensure that the functional group, category and sub-category fields are filled out correctly for all cases.',
            messages[0].getSummary()
        );
    }

    @isTest
    private static void testReleaseErrorWithNoDescription() {
        Case untransferrableCase = new Case(Subject = 'CANT_TRANSFER');
        insert untransferrableCase;

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(
            new ApexPages.StandardController(untransferrableCase)
        );
        controller.releaseOwnership();

        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(2, messages.size()); // one from constructor and another from transfer attempt

        System.assertEquals(ApexPages.severity.ERROR, messages[1].getSeverity());
        System.assertEquals(
            'The Subject and Description are required fields for case transfer. Please fill out the missing fields before transferring the case.',
            messages[1].getSummary()
        );
    }

    @isTest
    private static void testReleaseErrorWithMixedFunctionalGroups() {
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];
        Case c2 = new Case(Subject = 'TestCaseSubject2', Description = 'TestCaseDescription2');
        insert c2;
        List<Case> allCases = new List<Case>{ c, c2 };

        ApexPages.PageReference pr = Page.CaseTransfer;
        pr.getParameters().put('caseIds', c.Id + ',' + c2.Id);
        Test.setCurrentPage(pr);
        CaseListTransferController controller = new CaseListTransferController(
            new ApexPages.StandardSetController(new List<Case>())
        );
        controller.releaseOwnership();

        List<ApexPages.Message> messages = ApexPages.getMessages();

        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.severity.ERROR, messages[0].getSeverity());
        System.assertEquals(
            'All of the selected cases must be assigned to the same functional group.',
            messages[0].getSummary()
        );
    }

    @isTest
    private static void testBack() {
        Case c = [
            SELECT Id, Subject, Description, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            LIMIT 1
        ];

        Test.setCurrentPage(Page.CaseTransfer);
        CaseListTransferController controller = new CaseListTransferController(new ApexPages.StandardController(c));

        controller.page = 1;
        ApexPages.PageReference pr = controller.goBack();
        System.assertEquals(1, controller.page);
        System.assertEquals('/' + c.Id, pr.getUrl());

        controller.page = 2;
        pr = controller.goBack();
        System.assertEquals(1, controller.page);
        System.assertEquals(null, pr);

        controller.page = 3;
        pr = controller.goBack();
        System.assertEquals(1, controller.page);
        System.assertEquals(null, pr);

        controller.page = 4;
        controller.toUser = true;
        pr = controller.goBack();
        System.assertEquals(2, controller.page);
        System.assertEquals(null, pr);

        controller.page = 4;
        controller.toUser = false;
        pr = controller.goBack();
        System.assertEquals(3, controller.page);
        System.assertEquals(null, pr);

        controller.page = 5;
        pr = controller.goBack();
        System.assertEquals(5, controller.page);
        System.assertEquals('/' + c.Id, pr.getUrl());
    }
}
