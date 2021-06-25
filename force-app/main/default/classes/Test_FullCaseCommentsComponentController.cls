/*****************************************
 * File: Test_FullCaseCommentsComponentController
 * Author: Mathew Ruff, Sierr-Cedar Inc.
 * Description: Unit Tests for FullCaseCommentsComponentController.cls
 ******************************************/
@IsTest
private class Test_FullCaseCommentsComponentController {
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

    static testMethod void testMapGeneration() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'test' LIMIT 1];
        Test.setCurrentPage(Page.fullContactCaseComments);
        ApexPages.currentPage().getParameters().put('id', testContact.Id);

        // Act
        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(testContact);
        FullCaseCommentsController fccc = new FullCaseCommentsController(std);
        FullCaseCommentsComponentController compControll = new FullCaseCommentsComponentController();
        compControll.comments = fccc.comments;
        Test.stopTest();

        // Assert
        System.assert(compControll.caseNumberMap.size() == 5); // Should show 5 CaseNumbers for the 5 Cases
        System.assert(compControll.caseSubjectMap.size() == 5); // Should show 5 Case Subjects for the 5 Cases
    }
}
