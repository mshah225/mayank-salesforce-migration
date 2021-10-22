@isTest
private class FamilyPortalControllerTest {
    private static final String testUserAlias = 'testUsr';
    private static final String testCommunityUserAlias = 'testCUsr';
    private static final String testGuestUserAlias = 'testGUsr';
    private static final String testCommunityGuardianHashId = 'fsAYX7wlOYnlNTBx5bL6Un25Nb8nosg25H7IPECXk8o5';
    private static final string testGuardianHashId = 'loMNA0spLWmqMSDo7aE9Wa02Rs3kaso93Y3KASORv3q7';

    @TestSetup
    static void setup() {
        Contact communityContact = new Contact(
            FirstName = 'John',
            LastName = 'CommunitySmith',
            Email = 'test.community.user@test.example.com'
        );
        insert communityContact;

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            EmployeeNumber = '1348701348',
            ASURITE_for_External_ID__c = 'tUser01',
            Username = 'test.user@test.example.com',
            Email = 'test.user@test.example.com',
            Alias = testUserAlias,
            CommunityNickname = testUserAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = IdHelper.getProfileId('Standard User')
        );
        User testCommunityUser = new User(
            FirstName = communityContact.FirstName,
            LastName = communityContact.LastName,
            Username = communityContact.Email,
            Email = communityContact.Email,
            Alias = testCommunityUserAlias,
            CommunityNickname = testCommunityUserAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ContactId = communityContact.Id,
            ProfileId = IdHelper.getProfileId('ASU Community')
        );
        User testGuestUser = new User(
            LastName = 'site guest user',
            Username = 'test.guest.user@test.example.com',
            Email = 'test.guest.user@test.example.com',
            Alias = testGuestUserAlias,
            CommunityNickname = testGuestUserAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = IdHelper.getProfileId('Standard User')
        );

        insert new List<User>{ testUser, testCommunityUser, testGuestUser };

        Family_Portal_Guardian__c testCommunityGuardian = new Family_Portal_Guardian__c(
            First_Name__c = testCommunityUser.FirstName,
            Last_Name__c = testCommunityUser.LastName,
            Email__c = testCommunityUser.Email,
            Phone__c = '5555555555',
            ASU_Alumni__c = 'Yes',
            Country__c = 'United States',
            Street__c = '123 Test St',
            City__c = 'Cityville',
            State__c = 'Alaska',
            Zip_Code__c = '88888',
            Business_Unit_Source__c = 'unit01',
            Hash_ID__c = testCommunityGuardianHashId
        );
        Family_Portal_Guardian__c testGuardian = new Family_Portal_Guardian__c(
            First_Name__c = testUser.FirstName,
            Middle_Name__c = 'MiddleName',
            Last_Name__c = testUser.LastName,
            Email__c = testUser.Email,
            Phone__c = '5555555555',
            ASU_Alumni__c = 'Yes',
            Country__c = 'United States',
            Street__c = '123 Test St',
            City__c = 'Cityville',
            State__c = 'Alaska',
            Zip_Code__c = '88888',
            Business_Unit_Source__c = 'unit01',
            EMPLID__c = testUser.EmployeeNumber,
            ASURITE_ID__c = testUser.ASURITE_for_External_ID__c,
            Hash_ID__c = testGuardianHashId
        );
        insert new List<Family_Portal_Guardian__c>{ testGuardian, testCommunityGuardian };
    }

    @isTest
    private static void testPopulatesExistingGuardianInfo() {
        FamilyPortalController controller;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        ApexPages.currentPage().getParameters().put('hid', testGuardianHashId);
        ApexPages.currentPage().getParameters().put('bu', 'businessunit');

        Family_Portal_Guardian__c theGuardian = [
            SELECT Id
            FROM Family_Portal_Guardian__c
            WHERE Hash_Id__c = :testGuardianHashId
        ];
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert c;
        update new Family_Portal_Guardian__c(Id = theGuardian.Id, Contact__c = c.Id);

        User testGuestUser = [SELECT Id FROM User WHERE Alias = :testGuestUserAlias];
        System.runAs(testGuestUser) {
            Test.startTest();
            controller = new FamilyPortalController(); // initialize fields on page
            Test.stopTest();
        }

        Family_Portal_Guardian__c expectedGuardian = queryOneGuardianByHashId(testGuardianHashId);
        Family_Portal_Guardian__c populatedGuardian = controller.familyPortalGuardian;

        assertGuardiansEqual(expectedGuardian, populatedGuardian);
    }

    @isTest
    private static void testUpdateExistingGuardianAndCreateNewContact() {
        FamilyPortalController controller;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        ApexPages.currentPage()
            .setCookies(
                new List<Cookie>{
                    new Cookie('hid', testCommunityGuardianHashId, null, -1, false),
                    new Cookie('bu', 'businessunit', null, -1, false)
                }
            );

        User testGuestUser = [SELECT Id FROM User WHERE Alias = :testGuestUserAlias];
        System.runAs(testGuestUser) {
            Test.startTest();
            controller = new FamilyPortalController();
            controller.familyPortalGuardian.First_Name__c = 'New First Name';
            controller.familyPortalGuardian.Phone__c = '2230430019';
            controller.familyPortalStep5(); // runs the update code
            Test.stopTest();
        }

        Family_Portal_Guardian__c updatedGuardian = queryOneGuardianByHashId(testCommunityGuardianHashId);
        Contact newContact = [SELECT Id FROM Contact WHERE Id = :updatedGuardian.Contact__c];
        Family_Portal_Guardian__c expectedGuardian = controller.familyPortalGuardian;

        assertGuardiansEqual(expectedGuardian, updatedGuardian);
    }

    @isTest
    private static void testNewGuardian() {
        FamilyPortalController controller;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        User testGuestUser = [SELECT Id FROM User WHERE Alias = :testGuestUserAlias];
        System.runAs(testGuestUser) {
            Test.startTest();
            controller = new FamilyPortalController();
            controller.familyPortalGuardian.First_Name__c = 'New First Name';
            controller.familyPortalGuardian.Last_Name__c = 'New Last Name';
            controller.familyPortalGuardian.Email__c = 'new.email@test.test';
            controller.familyPortalGuardian.Zip_Code__c = '23007';
            controller.familyPortalGuardian.Phone__c = '2230430019';
            controller.familyPortalStep5(); // runs the update code
            Test.stopTest();
        }

        Family_Portal_Guardian__c newGuardian = queryOneGuardianByHashId(controller.familyPortalGuardian.Hash_ID__c);
        Family_Portal_Guardian__c expectedGuardian = controller.familyPortalGuardian;

        assertGuardiansEqual(expectedGuardian, newGuardian);
    }

    @isTest
    private static void testUsingCommunityUser() {
        FamilyPortalController controller;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        User testCommunityUser = [SELECT Id, ContactId FROM User WHERE Alias = :testCommunityUserAlias];

        System.runAs(testCommunityUser) {
            Test.startTest();
            controller = new FamilyPortalController();
            Test.stopTest();
        }

        Contact c = [SELECT FirstName, LastName FROM Contact WHERE Id = :testCommunityUser.ContactId];
        Family_Portal_Guardian__c expectedGuardian = new Family_Portal_Guardian__c(
            First_Name__c = c.FirstName,
            Last_Name__c = c.LastName
        );
        Family_Portal_Guardian__c populatedGuardian = controller.familyPortalGuardian;

        assertGuardiansEqual(expectedGuardian, populatedGuardian);
    }

    @isTest
    private static void testUsingNonCommunityUser() {
        FamilyPortalController controller;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        User testUser = [
            SELECT Id, FirstName, LastName, Email, ASURITE_for_External_ID__c, EmployeeNumber
            FROM User
            WHERE Alias = :testUserAlias
        ];

        System.runAs(testUser) {
            Test.startTest();
            controller = new FamilyPortalController();
            Test.stopTest();
        }

        Family_Portal_Guardian__c expectedGuardian = new Family_Portal_Guardian__c(
            First_Name__c = testUser.FirstName,
            Last_Name__c = testUser.LastName,
            Email__c = testUser.Email,
            ASURITE_ID__c = testUser.ASURITE_for_External_ID__c,
            EMPLID__c = testUser.EmployeeNumber
        );
        Family_Portal_Guardian__c populatedGuardian = controller.familyPortalGuardian;

        assertGuardiansEqual(expectedGuardian, populatedGuardian);
    }

    @isTest
    private static void testPopulatesExistingGuardianInterests() {
        FamilyPortalController controller;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        ApexPages.currentPage().getParameters().put('hid', testCommunityGuardianHashId);
        ApexPages.currentPage().getParameters().put('bu', 'businessunit');

        Family_Portal_Guardian__c theGuardian = [
            SELECT Id
            FROM Family_Portal_Guardian__c
            WHERE Hash_Id__c = :testCommunityGuardianHashId
        ];

        // Add interests for this test
        List<Family_Portal_Guardian_Interest__c> interests = new List<Family_Portal_Guardian_Interest__c>();
        for (
            SelectOption option : ObjectService.getPicklistChoicesSelectList(
                'Family_Portal_Guardian_Interest__c',
                'Chosen_Interest__c'
            )
        ) {
            Family_Portal_Guardian_Interest__c interest = new Family_Portal_Guardian_Interest__c(
                Family_Portal_Guardian__c = theGuardian.Id,
                Chosen_Interest__c = option.getValue(),
                Active_Interest__c = Math.random() > 0.5
            );
            interests.add(interest);
        }
        insert interests;

        User testGuestUser = [SELECT Id FROM User WHERE Alias = :testGuestUserAlias];
        System.runAs(testGuestUser) {
            Test.startTest();
            controller = new FamilyPortalController(); // initialize fields on page
            Test.stopTest();
        }

        Family_Portal_Guardian_Interest__c populatedInterests = controller.familyPortalGuardianInterest;

        for (Family_Portal_Guardian_Interest__c interest : interests) {
            if (interest.Active_Interest__c)
                System.assert(populatedInterests.Interest_Choices__c.contains(interest.Chosen_Interest__c));
        }
    }

    @isTest
    private static void testPopulatesExistingGuardianStudents() {
        FamilyPortalController controller;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        ApexPages.currentPage().getParameters().put('hid', testCommunityGuardianHashId);
        ApexPages.currentPage().getParameters().put('bu', 'businessunit');

        Family_Portal_Guardian__c theGuardian = [
            SELECT Id
            FROM Family_Portal_Guardian__c
            WHERE Hash_Id__c = :testCommunityGuardianHashId
        ];

        Map<String, String> enrollmentStatusOptionMap = ObjectService.getPicklistChoicesMap(
            'Family_Portal_Student__c',
            'Enrollment_Status__c'
        );
        Map<String, String> typeOptionMap = ObjectService.getPicklistChoicesMap('Family_Portal_Student__c', 'Type__c');
        Map<String, String> academicCollegeOptionMap = ObjectService.getPicklistChoicesMap(
            'Family_Portal_Student__c',
            'Academic_College__c'
        );
        Map<String, String> academicYearOptionMap = ObjectService.getPicklistChoicesMap(
            'Family_Portal_Student__c',
            'Academic_Year__c'
        );
        Map<String, String> militaryAffliationOptionMap = ObjectService.getPicklistChoicesMap(
            'Family_Portal_Student__c',
            'Military_Affiliation__c'
        );

        // Add students for this test
        List<Family_Portal_Student__c> students = new List<Family_Portal_Student__c>();
        for (Integer i = 0; i < 30; i++) {
            Family_Portal_Student__c student = new Family_Portal_Student__c(
                Family_Portal_Guardian__c = theGuardian.Id,
                Active_Relationship__c = Math.random() > 0.5,
                Enrollment_Status__c = randomValueFromMap(enrollmentStatusOptionMap),
                Enrollment_Status_Year__c = '2032',
                Type__c = randomValueFromMap(typeOptionMap),
                Academic_College__c = randomValueFromMap(academicCollegeOptionMap),
                Academic_Year__c = randomValueFromMap(academicYearOptionMap),
                Military_Affiliation__c = randomValueFromMap(militaryAffliationOptionMap)
            );
            students.add(student);
        }
        insert students;

        User testGuestUser = [SELECT Id FROM User WHERE Alias = :testGuestUserAlias];
        System.runAs(testGuestUser) {
            Test.startTest();
            controller = new FamilyPortalController(); // initialize fields on page
            Test.stopTest();
        }

        List<FamilyPortalController.FamilyPortalStudentWrapper> populatedStudentWrappers = controller.studentWrapperList;

        for (Family_Portal_Student__c student : students) {
            if (student.Active_Relationship__c) {
                Boolean found = false;
                for (
                    FamilyPortalController.FamilyPortalStudentWrapper populatedStudentWrapper : populatedStudentWrappers
                ) {
                    if (
                        populatedStudentWrapper.familyPortalStudentObj.Enrollment_Status__c ==
                        student.Enrollment_Status__c &&
                        populatedStudentWrapper.familyPortalStudentObj.Enrollment_Status_Year__c ==
                        student.Enrollment_Status_Year__c &&
                        populatedStudentWrapper.familyPortalStudentObj.Type__c == student.Type__c &&
                        populatedStudentWrapper.familyPortalStudentObj.Academic_College__c ==
                        student.Academic_College__c &&
                        populatedStudentWrapper.familyPortalStudentObj.Academic_Year__c == student.Academic_Year__c &&
                        populatedStudentWrapper.familyPortalStudentObj.Military_Affiliation__c ==
                        student.Military_Affiliation__c
                    ) {
                        found = true;
                        break;
                    }
                }
                System.assert(found, 'Missing some students that should be included');
            }
        }
    }

    @isTest
    private static void testNewGuardianStudents() {
        FamilyPortalController controller;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        ApexPages.currentPage().getParameters().put('hid', testCommunityGuardianHashId);
        ApexPages.currentPage().getParameters().put('bu', 'businessunit');

        Family_Portal_Guardian__c theGuardian = [
            SELECT Id
            FROM Family_Portal_Guardian__c
            WHERE Hash_Id__c = :testCommunityGuardianHashId
        ];
        Map<String, String> enrollmentStatusOptionMap = ObjectService.getPicklistChoicesMap(
            'Family_Portal_Student__c',
            'Enrollment_Status__c'
        );
        Map<String, String> typeOptionMap = ObjectService.getPicklistChoicesMap('Family_Portal_Student__c', 'Type__c');
        Map<String, String> academicCollegeOptionMap = ObjectService.getPicklistChoicesMap(
            'Family_Portal_Student__c',
            'Academic_College__c'
        );
        Map<String, String> academicYearOptionMap = ObjectService.getPicklistChoicesMap(
            'Family_Portal_Student__c',
            'Academic_Year__c'
        );
        Map<String, String> militaryAffliationOptionMap = ObjectService.getPicklistChoicesMap(
            'Family_Portal_Student__c',
            'Military_Affiliation__c'
        );

        User testGuestUser = [SELECT Id FROM User WHERE Alias = :testGuestUserAlias];
        System.runAs(testGuestUser) {
            Test.startTest();
            controller = new FamilyPortalController();
            for (Integer i = 0; i < 10; i++) {
                controller.addStudentRow();
                Family_Portal_Student__c student = controller.studentWrapperList[
                        controller.studentWrapperList.size() - 1
                    ]
                    .familyPortalStudentObj;
                student.Family_Portal_Guardian__c = theGuardian.Id;
                student.Active_Relationship__c = Math.random() > 0.5;
                student.Enrollment_Status__c = randomValueFromMap(enrollmentStatusOptionMap);
                student.Enrollment_Status_Year__c = '203' + i;
                student.Type__c = randomValueFromMap(typeOptionMap);
                student.Academic_College__c = randomValueFromMap(academicCollegeOptionMap);
                student.Academic_Year__c = randomValueFromMap(academicYearOptionMap);
                student.Military_Affiliation__c = randomValueFromMap(militaryAffliationOptionMap);
            }
            ApexPages.currentPage().getParameters().put('index', '3');
            controller.removeStudentRow();
            controller.familyPortalStep5();
            Test.stopTest();
        }

        List<Family_Portal_Student__c> createdStudents = [
            SELECT
                Enrollment_Status__c,
                Enrollment_Status_Year__c,
                Type__c,
                Active_Relationship__c,
                Academic_College__c,
                Academic_Year__c,
                Military_Affiliation__c
            FROM Family_Portal_Student__c
            WHERE Family_Portal_Guardian__c = :theGuardian.Id
        ];
        List<FamilyPortalController.FamilyPortalStudentWrapper> expectedStudentWrappers = controller.studentWrapperList;

        for (FamilyPortalController.FamilyPortalStudentWrapper expectedStudentWrapper : expectedStudentWrappers) {
            if (expectedStudentWrapper.familyPortalStudentObj.Active_Relationship__c) {
                Boolean found = false;
                for (Family_Portal_Student__c student : createdStudents) {
                    if (
                        expectedStudentWrapper.familyPortalStudentObj.Enrollment_Status__c ==
                        student.Enrollment_Status__c &&
                        expectedStudentWrapper.familyPortalStudentObj.Enrollment_Status_Year__c ==
                        student.Enrollment_Status_Year__c &&
                        expectedStudentWrapper.familyPortalStudentObj.Type__c == student.Type__c &&
                        expectedStudentWrapper.familyPortalStudentObj.Academic_College__c ==
                        student.Academic_College__c &&
                        expectedStudentWrapper.familyPortalStudentObj.Academic_Year__c == student.Academic_Year__c &&
                        expectedStudentWrapper.familyPortalStudentObj.Military_Affiliation__c ==
                        student.Military_Affiliation__c
                    ) {
                        found = true;
                        break;
                    }
                }
                System.assert(found, 'Missing some students that should be included');
            }
        }
    }

    @isTest
    private static void testLoginScreenRedirect() {
        FamilyPortalController controller;
        FamilyPortalController controllerNoHid;
        FamilyPortalController controllerNoBu;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        ApexPages.currentPage().getParameters().put('hid', testCommunityGuardianHashId);
        ApexPages.currentPage().getParameters().put('bu', 'businessunit');

        User testGuestUser = [SELECT Id FROM User WHERE Alias = :testGuestUserAlias];
        PageReference pageRef, pageRefNoHid, pageRefNoBu;
        System.runAs(testGuestUser) {
            Test.startTest();
            controller = new FamilyPortalController();
            controllerNoHid = new FamilyPortalController();
            controllerNoHid.hashId = null;
            controllerNoBu = new FamilyPortalController();
            controllerNoBu.businessUnit = null;
            pageRef = controller.sendUserToLoginScreen();
            pageRefNoHid = controllerNoHid.sendUserToLoginScreen();
            pageRefNoBu = controllerNoBu.sendUserToLoginScreen();
            Test.stopTest();
        }

        System.assertEquals(
            '/FamilyPortal/CommunitiesLogin?bu=businessunit&hid=' + testCommunityGuardianHashId,
            pageRef.getUrl()
        );
        System.assertEquals('/FamilyPortal/CommunitiesLogin?bu=businessunit', pageRefNoHid.getUrl());
        System.assertEquals('/FamilyPortal/CommunitiesLogin?hid=' + testCommunityGuardianHashId, pageRefNoBu.getUrl());
    }

    @isTest
    private static void testPicklistQueries() {
        FamilyPortalController controller;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        ApexPages.currentPage().getParameters().put('hid', testCommunityGuardianHashId);
        ApexPages.currentPage().getParameters().put('bu', 'businessunit');

        User testGuestUser = [SELECT Id FROM User WHERE Alias = :testGuestUserAlias];
        List<SelectOption> actualCountryOptions, actualStateOptions, actualProvienceOptions, actualInterestChoices;
        System.runAs(testGuestUser) {
            Test.startTest();
            controller = new FamilyPortalController();
            actualCountryOptions = controller.getGuardianCountryOptions();
            actualStateOptions = controller.getGuardianStateOptions();
            actualProvienceOptions = controller.getGuardianProvinceOptions();
            actualInterestChoices = controller.getGuardianInterestChoices();
            Test.stopTest();
        }
        List<SelectOption> expectedCountryOptions = ObjectService.getPicklistChoicesSelectList('User', 'CountryCode');
        List<SelectOption> expectedStateOptions = new List<SelectOption>();
        List<SelectOption> expectedProvienceOptions = new List<SelectOption>();
        for (SelectOption selectOpt : ObjectService.getPicklistChoicesSelectList('User', 'StateCode')) {
            if (
                selectOpt.getLabel() == 'Alberta' ||
                selectOpt.getLabel() == 'British Columbia' ||
                selectOpt.getLabel() == 'Manitoba' ||
                selectOpt.getLabel() == 'New Brunswick' ||
                selectOpt.getLabel() == 'Manitoba' ||
                selectOpt.getLabel() == 'Newfoundland and Labrador' ||
                selectOpt.getLabel() == 'Northwest Territories' ||
                selectOpt.getLabel() == 'Nova Scotia' ||
                selectOpt.getLabel() == 'Nunavut' ||
                selectOpt.getLabel() == 'Ontario' ||
                selectOpt.getLabel() == 'Prince Edward Island' ||
                selectOpt.getLabel() == 'Quebec' ||
                selectOpt.getLabel() == 'Saskatchewan' ||
                selectOpt.getLabel() == 'Yukon Territories'
            ) {
                expectedProvienceOptions.add(selectOpt);
            } else {
                expectedStateOptions.add(selectOpt);
            }
        }
        List<SelectOption> expectedInterestChoices = ObjectService.getPicklistChoicesSelectList(
            'Family_Portal_Guardian_Interest__c',
            'Interest_Choices__c'
        );

        for (SelectOption expectedOption : expectedCountryOptions) {
            Boolean found = false;
            for (SelectOption actualOption : actualCountryOptions) {
                if (actualOption.getValue() == expectedOption.getLabel()) {
                    found = true;
                    break;
                }
            }
            System.assert(found, 'Missing an expected country option. Could not find ' + expectedOption.getLabel());
        }
        for (SelectOption expectedOption : expectedStateOptions) {
            Boolean found = false;
            for (SelectOption actualOption : actualStateOptions) {
                if (actualOption.getValue() == expectedOption.getLabel()) {
                    found = true;
                    break;
                }
            }
            System.assert(found, 'Missing an expected state option. Could not find ' + expectedOption.getLabel());
        }
        for (SelectOption expectedOption : expectedProvienceOptions) {
            Boolean found = false;
            for (SelectOption actualOption : actualProvienceOptions) {
                if (actualOption.getValue() == expectedOption.getLabel()) {
                    found = true;
                    break;
                }
            }
            System.assert(found, 'Missing an expected provience option. Could not find ' + expectedOption.getLabel());
        }
        for (SelectOption expectedOption : expectedInterestChoices) {
            Boolean found = false;
            for (SelectOption actualOption : actualInterestChoices) {
                if (actualOption.getValue() == expectedOption.getLabel()) {
                    found = true;
                    break;
                }
            }
            System.assert(
                found,
                'Missing an expected interest choice option. Could not find ' + expectedOption.getLabel()
            );
        }
    }

    @isTest
    private static void testNextPage() {
        FamilyPortalController controller;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        ApexPages.currentPage().getParameters().put('hid', testCommunityGuardianHashId);
        ApexPages.currentPage().getParameters().put('bu', 'businessunit');

        User testGuestUser = [SELECT Id FROM User WHERE Alias = :testGuestUserAlias];
        PageReference pageRef1, pageRef2, pageRef3, pageRef4, pageRef5;
        Decimal pBar1Perc, pBar2Perc, pBar3Perc, pBar4Perc, pBar5Perc;
        System.runAs(testGuestUser) {
            Test.startTest();
            controller = new FamilyPortalController();
            pageRef1 = controller.familyPortalStep1();
            controller.familyPortalStep1OnLoad();
            pBar1Perc = controller.progressBarController.currentPercentage;
            pageRef2 = controller.familyPortalStep2();
            controller.familyPortalStep2OnLoad();
            pBar2Perc = controller.progressBarController.currentPercentage;
            pageRef3 = controller.familyPortalStep3();
            controller.familyPortalStep3OnLoad();
            pBar3Perc = controller.progressBarController.currentPercentage;
            pageRef4 = controller.familyPortalStep4();
            controller.familyPortalStep4OnLoad();
            pBar4Perc = controller.progressBarController.currentPercentage;
            pageRef5 = controller.familyPortalStep5();
            controller.familyPortalStep5OnLoad();
            pBar5Perc = controller.progressBarController.currentPercentage;
            Test.stopTest();
        }

        System.assertEquals(Page.FamilyPortalStep1.getUrl(), pageRef1.getUrl());
        System.assertEquals(0.0, pBar1Perc);
        System.assertEquals(Page.FamilyPortalStep2.getUrl(), pageRef2.getUrl());
        System.assertEquals(25.0, pBar2Perc);
        System.assertEquals(Page.FamilyPortalStep3.getUrl(), pageRef3.getUrl());
        System.assertEquals(50.0, pBar3Perc);
        System.assertEquals(Page.FamilyPortalStep4.getUrl(), pageRef4.getUrl());
        System.assertEquals(75.0, pBar4Perc);
        System.assertEquals(Page.FamilyPortalStep5.getUrl(), pageRef5.getUrl());
        System.assertEquals(100.0, pBar5Perc);
    }

    @isTest
    private static void testStudentWrapper() {
        Map<String, String> expectedStudentTypeChoices = ObjectService.getPicklistChoicesMap(
            'Family_Portal_Student__c',
            'Type__c'
        );

        Family_Portal_Student__c student = new Family_Portal_Student__c(
            Type__c = randomValueFromMap(expectedStudentTypeChoices)
        );
        FamilyPortalController.FamilyPortalStudentWrapper wrapper = new FamilyPortalController.FamilyPortalStudentWrapper(
            student,
            0
        );

        /* Test getting all the type options */
        List<SelectOption> actualStudentTypeChoices = wrapper.getStudentTypeChoices();
        for (String expectedOption : expectedStudentTypeChoices.keySet()) {
            Boolean found = false;
            for (SelectOption actualOption : actualStudentTypeChoices) {
                if (actualOption.getValue() == expectedStudentTypeChoices.get(expectedOption)) {
                    found = true;
                    break;
                }
            }
            System.assert(
                found,
                'Missing an expected student type option option. Could not find ' +
                expectedStudentTypeChoices.get(expectedOption)
            );
        }

        /* Test getting the type from the wrapper */
        String actualStudentTypeChoicesString = wrapper.guardianSelectedStudentTypes[0];
        System.assertEquals(student.Type__c, actualStudentTypeChoicesString);

        /* Test setting type of wrapper */
        String newType = randomValueFromMap(expectedStudentTypeChoices);
        while (student.Type__c == newType) {
            newType = randomValueFromMap(expectedStudentTypeChoices);
            if (expectedStudentTypeChoices.size() >= 1) {
                // prevent infinite loop if one or less options exist
                break;
            }
        }
        wrapper.guardianSelectedStudentTypes = new List<String>{ newType };
        System.assertEquals(newType, student.Type__c);
    }

    @isTest
    private static void testPublicBooleans() {
        FamilyPortalController controllerUS;
        FamilyPortalController controllerCA;
        FamilyPortalController controllerUK;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        Boolean shouldBeInUSOrCA1,
            shouldBeInUS,
            shouldNotBeInCA1,
            shouldBeInUSOrCA2,
            shouldBeInCA,
            shouldNotBeInUS1,
            shouldNotBeInUS2,
            shouldNotBeInCA2,
            shouldNotBeInUSOrCA;

        User testGuestUser = [SELECT Id FROM User WHERE Alias = :testGuestUserAlias];
        System.runAs(testGuestUser) {
            Test.startTest();
            controllerUS = new FamilyPortalController();
            controllerUS.familyPortalGuardian.Country__c = 'United States';
            shouldBeInUS = controllerUS.guardianSelectedCountryIsUS;
            shouldBeInUSOrCA1 = controllerUS.guardianSelectedCountryIsUnitedStatesOrCanada;
            shouldNotBeInCA1 = controllerUS.guardianSelectedCountryIsCanada;
            controllerCA = new FamilyPortalController();
            controllerCA.familyPortalGuardian.Country__c = 'Canada';
            shouldBeInCA = controllerCA.guardianSelectedCountryIsCanada;
            shouldBeInUSOrCA2 = controllerCA.guardianSelectedCountryIsUnitedStatesOrCanada;
            shouldNotBeInUS1 = controllerCA.guardianSelectedCountryIsUS;
            controllerUK = new FamilyPortalController();
            controllerUK.familyPortalGuardian.Country__c = 'United Kingdom';
            shouldNotBeInUSOrCA = controllerUK.guardianSelectedCountryIsUnitedStatesOrCanada;
            shouldNotBeInUS2 = controllerUK.guardianSelectedCountryIsUS;
            shouldNotBeInCA2 = controllerUK.guardianSelectedCountryIsCanada;
            Test.stopTest();
        }

        // US
        System.assert(shouldBeInUS, 'Incorrectly marked this country as not the United States');
        System.assert(shouldBeInUSOrCA1, 'Incorrectly marked this country as not the United States or Canada');
        System.assert(!shouldNotBeInCA1, 'Incorrectly marked this country as Canada');
        // Canada
        System.assert(shouldBeInCA, 'Incorrectly marked this country as not Canada');
        System.assert(shouldBeInUSOrCA2, 'Incorrectly marked this country as not the United States or Canada');
        System.assert(!shouldNotBeInUS1, 'Incorrectly marked this country as the United States');
        // UK
        System.assert(!shouldNotBeInUS2, 'Incorrectly marked this country as the United States');
        System.assert(!shouldNotBeInCA2, 'Incorrectly marked this country as Canada');
        System.assert(!shouldNotBeInUSOrCA, 'Incorrectly marked this country as either the United States or Canada');
    }

    @isTest
    private static void testSetGetGuardianSelectedInterests() {
        FamilyPortalController controller;

        Test.setCurrentPage(Page.FamilyPortalStep1);

        ApexPages.currentPage().getParameters().put('hid', testCommunityGuardianHashId);
        ApexPages.currentPage().getParameters().put('bu', 'businessunit');

        Family_Portal_Guardian__c theGuardian = [
            SELECT Id
            FROM Family_Portal_Guardian__c
            WHERE Hash_Id__c = :testCommunityGuardianHashId
        ];
        // Add some interests to get/set
        List<String> interestsToSetWith = new List<String>();
        List<Family_Portal_Guardian_Interest__c> interests = new List<Family_Portal_Guardian_Interest__c>();
        for (
            SelectOption option : ObjectService.getPicklistChoicesSelectList(
                'Family_Portal_Guardian_Interest__c',
                'Chosen_Interest__c'
            )
        ) {
            Family_Portal_Guardian_Interest__c interest = new Family_Portal_Guardian_Interest__c(
                Family_Portal_Guardian__c = theGuardian.Id,
                Chosen_Interest__c = option.getValue(),
                Active_Interest__c = Math.random() > 0.5
            );
            interests.add(interest);
            if (Math.random() > 0.5) {
                interestsToSetWith.add(option.getValue());
            }
        }
        insert interests;

        User testGuestUser = [SELECT Id FROM User WHERE Alias = :testGuestUserAlias];
        List<String> actualInterestChoices1, actualInterestChoices2;
        System.runAs(testGuestUser) {
            Test.startTest();
            controller = new FamilyPortalController();
            actualInterestChoices1 = controller.guardianSelectedInterests;
            controller.guardianSelectedInterests = interestsToSetWith;
            actualInterestChoices2 = controller.guardianSelectedInterests;
            Test.stopTest();
        }
        List<SelectOption> expectedInterestChoices = ObjectService.getPicklistChoicesSelectList(
            'Family_Portal_Guardian_Interest__c',
            'Interest_Choices__c'
        );

        // Check intial prepopulated
        for (Family_Portal_Guardian_Interest__c expectedOption : interests) {
            if (expectedOption.Active_Interest__c) {
                Boolean found = false;
                for (String actualOption : actualInterestChoices1) {
                    if (actualOption == expectedOption.Chosen_Interest__c) {
                        found = true;
                        break;
                    }
                }
                System.assert(
                    found,
                    'Missing an expected interest choice option. Could not find ' + expectedOption.Chosen_Interest__c
                );
            }
        }
        // Check after we set to new interests
        for (String expectedOption : interestsToSetWith) {
            Boolean found = false;
            for (String actualOption : actualInterestChoices2) {
                if (actualOption == expectedOption) {
                    found = true;
                    break;
                }
            }
            System.assert(found, 'Missing an expected interest choice option. Could not find ' + expectedOption);
        }
    }

    private static String randomValueFromMap(Map<String, String> mapping) {
        List<String> values = mapping.values();
        Integer randomIndx = (Integer) (Math.random() * values.size());
        return values[randomIndx];
    }

    private static Family_Portal_Guardian__c queryOneGuardianByHashId(String hashId) {
        return Database.query(
            'SELECT ' +
            ObjectService.objectFieldsToString('Family_Portal_Guardian__c') +
            ' FROM Family_Portal_Guardian__c WHERE Hash_Id__c=\'' +
            hashId +
            '\''
        );
    }

    private static void assertGuardiansEqual(Family_Portal_Guardian__c expected, Family_Portal_Guardian__c actual) {
        if (expected.First_Name__c != null)
            System.assertEquals(expected.First_Name__c, actual.First_Name__c);
        if (expected.Middle_Name__c != null)
            System.assertEquals(expected.Middle_Name__c, actual.Middle_Name__c);
        if (expected.Last_Name__c != null)
            System.assertEquals(expected.Last_Name__c, actual.Last_Name__c);
        if (expected.Contact__c != null)
            System.assertEquals(expected.Contact__c, actual.Contact__c);
        if (expected.EMPLID__c != null)
            System.assertEquals(expected.EMPLID__c, actual.EMPLID__c);
        if (expected.ASURITE_ID__c != null)
            System.assertEquals(expected.ASURITE_ID__c, actual.ASURITE_ID__c);
        if (expected.Email__c != null)
            System.assertEquals(expected.Email__c, actual.Email__c);
        if (expected.Phone__c != null)
            System.assertEquals(expected.Phone__c, actual.Phone__c);
        if (expected.ASU_Alumni__c != null)
            System.assertEquals(expected.ASU_Alumni__c, actual.ASU_Alumni__c);
        if (expected.Country__c != null)
            System.assertEquals(expected.Country__c, actual.Country__c);
        if (expected.Street__c != null)
            System.assertEquals(expected.Street__c, actual.Street__c);
        if (expected.City__c != null)
            System.assertEquals(expected.City__c, actual.City__c);
        if (expected.State__c != null)
            System.assertEquals(expected.State__c, actual.State__c);
        if (expected.Zip_Code__c != null)
            System.assertEquals(expected.Zip_Code__c, actual.Zip_Code__c);
        if (expected.Hash_ID__c != null)
            System.assertEquals(expected.Hash_ID__c, actual.Hash_ID__c);
    }
}
