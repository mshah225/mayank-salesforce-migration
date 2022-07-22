/*****************************************
 * File: SuccessRecodingControllerTest
 * Author: Mathew Ruff, Sierra-Cedar
 * Description: Unit Tests for SuccessRecodingController.cls
 ******************************************/
@IsTest
private class SuccessRecodingControllerTest {
    @testSetup
    static void setUpTest() {
        TestDataFactory.createFunctionalGroupWithCategory('ASU Coach Outreach', 'Ad Hoc', 'N/A');

        Profile p = [SELECT Id FROM Profile WHERE Name = :System.Label.Success_Coach_Recode_Profile];

        // Test Users
        User testUser1 = TestDataFactory.createUser('test1', p.Id);
        insert testUser1;

        User testUser2 = TestDataFactory.createUser('test2', p.Id);
        insert testUser2;

        Success_Pod__c testPod = new Success_Pod__c(Name = 'pod 1');
        insert testPod;

        // Test Resources
        Success_Resource__c testResource1 = new Success_Resource__c(
            Resource__c = testUser1.Id,
            IsActive__c = true,
            Success_Pod__c = testPod.Id
        );
        insert testResource1;

        Success_Resource__c testResource2 = new Success_Resource__c(
            Resource__c = testUser2.Id,
            IsActive__c = true,
            Success_Pod__c = testPod.Id
        );
        insert testResource2;

        // Test Students
        List<Contact> testContacts = TestDataFactory.createContacts(2);
        insert testContacts;

        List<Case> testCases = TestDataFactory.createCases(2);
        testCases[0].ContactId = testContacts[0].Id;
        testCases[0].OwnerId = testUser1.Id;
        testCases[1].ContactId = testContacts[1].Id;
        testCases[1].OwnerId = testUser2.Id;
        insert testCases;

        Id coachRTId = [
            SELECT Id, Name, sObjectType
            FROM RecordType
            WHERE Name = 'Coach' AND SObjectType = 'Success_Student__c'
        ]
        .Id;

        Success_Student__c testStudent1 = new Success_Student__c(
            RecordTypeId = coachRTId,
            Student__c = testContacts[0].Id,
            Success_Resource__c = testResource1.Id,
            Is_Active__c = true,
            Coaching_Student__c = true
        );
        insert testStudent1;

        Success_Student__c testStudent2 = new Success_Student__c(
            RecordTypeId = coachRTId,
            Student__c = testContacts[1].Id,
            Success_Resource__c = testResource2.Id,
            Is_Active__c = true,
            Coaching_Student__c = true
        );
        insert testStudent2;
    }

    static testMethod void testStudentPath() {
        // Arrange
        Contact contactResult = [SELECT Id, Name FROM Contact WHERE LastName = '0' LIMIT 1];
        User userToTransferToResult = [SELECT Id, Name FROM User WHERE LastName = 'test2' LIMIT 1];
        Test.setCurrentPage(Page.successRecoding);

        // Act
        Test.startTest();
        SuccessRecodingController src = new SuccessRecodingController();
        src.getInitOptions();
        src.selectedInitOpt = 'Student';
        src.setPath();
        src.page1(); // coverage for going back to page 1
        src.selectedInitOpt = 'Student';
        src.setPath();
        Test.setFixedSearchResults(new List<String>{ contactResult.Id });
        src.studentSearchString = 'nothing';
        src.searchForStudents();
        src.selectedContactId = src.contactResults[0].Id;
        src.selectedStudentName = src.contactResults[0].Name;
        src.selectContactAndFindSuccessStudent();
        Test.setFixedSearchResults(new List<String>{ userToTransferToResult.Id });
        src.coachSearchString = 'nothing';
        src.searchForCoaches();
        //src.transferToCoachId = src.resourceResults[0].Id;
        //src.transferToCoachName = src.resourceResults[0].Name;
        src.page4();
        //src.transferStudents();
        Test.stopTest();

        // Assert
        List<Success_Student__c> students = ([
            SELECT Student_Name__c, ASURiteID__c, EMPLID__c, Student__c, Plan_Code__r.Name
            FROM Success_Student__c
            WHERE Success_Resource__r.Resource__r.Id = :userToTransferToResult.Id
        ]);

        // This coach should have two students now.
        //System.Assert(students.size() == 2);
    }

    static testMethod void testCoachPath() {
        // Arrange
        User userToTransferFrom = [SELECT Id, Name FROM User WHERE LastName = 'test1' LIMIT 1];
        User userToTransferTo = [SELECT Id, Name FROM User WHERE LastName = 'test2' LIMIT 1];
        Test.setCurrentPage(Page.successRecoding);

        // Act
        Test.startTest();
        SuccessRecodingController src = new SuccessRecodingController();
        src.getInitOptions();
        src.selectedInitOpt = 'Coach';
        src.setPath();
        Test.setFixedSearchResults(new List<String>{ userToTransferFrom.Id });
        src.coachSearchString = 'nothing';
        src.searchForCoaches();
        src.selectedCoachId = src.resourceResults[0].Id;
        src.selectedCoachName = src.resourceResults[0].Name;
        src.findCoachStudents();
        src.allStudentsChecked = true;
        src.checkAllStudents();
        src.allStudentsChecked = false;
        src.checkAllStudents();
        src.selectStudentsForTransfer(); // Should throw error
        src.allStudentsChecked = true;
        src.checkAllStudents();
        src.selectStudentsForTransfer();
        src.deselectStudentAndBack();
        src.allStudentsChecked = true;
        src.checkAllStudents();
        src.selectStudentsForTransfer();
        Test.setFixedSearchResults(new List<String>{ userToTransferTo.Id });
        src.coachSearchString = 'nothing again';
        src.searchForCoaches();
        //src.transferToCoachId = src.resourceResults[0].Id;
        //src.transferToCoachName = src.resourceResults[0].Name;
        //src.transferStudents();
        Test.stopTest();

        // Assert
        List<Success_Student__c> students = ([
            SELECT Student_Name__c, ASURiteID__c, EMPLID__c, Student__c, Plan_Code__r.Name
            FROM Success_Student__c
            WHERE Success_Resource__r.Resource__r.Id = :userToTransferTo.Id
        ]);

        // This coach should have two students now.
        //System.Assert(students.size() == 2);
    }

    static testMethod void testStudentSearchError() {
        // Act
        Test.startTest();
        SuccessRecodingController src = new SuccessRecodingController();
        src.studentSearchString = 't';
        src.searchForStudents();
        Test.stopTest();

        // Assert
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean b = false;

        for (Apexpages.Message msg : msgs) {
            if (msg.getDetail().contains('Search terms must be at least 3 characters long.')) {
                b = true;
            }
        }

        System.assert(b);
    }

    static testMethod void testCoachSearchError() {
        // Act
        Test.startTest();
        SuccessRecodingController src = new SuccessRecodingController();
        src.coachSearchString = 't';
        src.searchForCoaches();
        Test.stopTest();

        // Assert
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean b = false;

        for (Apexpages.Message msg : msgs) {
            if (msg.getDetail().contains('Search terms must be at least 3 characters long.')) {
                b = true;
            }
        }

        System.assert(b);
    }

    static testMethod void testPageResetnStudTransfer() {
        Test.startTest();
        SuccessRecodingController src = new SuccessRecodingController();
        src.page1Reset();
        src.transferStudents();
        Test.stopTest();

        System.assertEquals(src.coachPath, false);

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean b = false;

        for (Apexpages.Message msg : msgs) {
            if (msg.getDetail().contains('please try again or select another Coach.')) {
                b = true;
            }
        }

        System.assert(b);
    }
}
