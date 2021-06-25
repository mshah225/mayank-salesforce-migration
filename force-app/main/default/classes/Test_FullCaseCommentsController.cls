/*****************************************
 * File: Test_FullCaseCommentsController
 * Author: Mathew Ruff, Sierra-Cedar Inc.
 * Description: Unit Tests for FullCaseCommentsController.cls
 ******************************************/
@IsTest
private class Test_FullCaseCommentsController {
    @testSetup
    static void setUp() {
        Contact testContact = TestDataFactory.createContact('test');
        insert testContact;

        List<Case> cases = TestDataFactory.createCases(5);
        for (Case c : cases) {
            c.ContactId = testContact.Id;
            c.RecordTypeId = IDHelper.getRTID('Case', 'ASU_Coach_Outreach');
        }
        insert cases;

        List<CaseComment> testComments = new List<CaseComment>();
        for (Case c : cases) {
            CaseComment comment = new CaseComment(ParentId = c.Id, CommentBody = 'testing this ' + c.CaseNumber);
            testComments.add(comment);
        }
        insert testComments;
    }

    static testMethod void testContactDetailPage() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'test' LIMIT 1];
        Test.setCurrentPage(Page.fullContactCaseComments);
        ApexPages.currentPage().getParameters().put('id', testContact.Id);

        // Act
        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(testContact);
        FullCaseCommentsController fccc = new FullCaseCommentsController(std);
        Test.stopTest();

        // Assert
        System.assert(fccc.comments.size() == 5); // Should show 5 CaseComments. One each from the 5 test Cases.
    }

    static testMethod void testCaseDetailPage() {
        // Arrange
        Case testCase = [SELECT Id FROM Case WHERE Contact.LastName = 'test' LIMIT 1];
        Test.setCurrentPage(Page.fullCaseComments);
        ApexPages.currentPage().getParameters().put('id', testCase.Id);

        // Act
        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(testCase);
        FullCaseCommentsController fccc = new FullCaseCommentsController(std);
        Test.stopTest();

        // Assert
        System.assert(fccc.comments.size() == 1); // Should show only 1 CaseComment from 1 test Case.
    }
}
