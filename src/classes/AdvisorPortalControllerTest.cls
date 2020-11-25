/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-01-29
 *
 * Unit Tests for AdvisorPortalController.cls
 */
@IsTest
private class AdvisorPortalControllerTest {
    private static final String ADVISOR_OUTREACH_RECORDTYPE = IdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

    @TestSetup
    static void setUpTest() {
        TestDataFactory.createAdvisorStudents(TestDataFactory.createAdvisorPods(1), 1);
    }

    @IsTest
    private static void testContactWithoutCases() {
        // Arrange
        List<String> queueIds = new List<String>();
        for (Group g : [SELECT Id FROM Group WHERE Type = 'Queue']) {
            queueIds.add(g.Id);
        }

        // Act
        Test.startTest();
        List<AdvisorPortalContact> assertContacts = AdvisorPortalController.getPortalContactsForViewOptions(queueIds);
        Test.stopTest();

        // Assert
        System.assertEquals(1, assertContacts.size(), 'Contact\'s without Cases should still be returned.');
    }

    @IsTest
    private static void testContactWithCases() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        Case defaultCase = CaseFactory.DEFAULT_CASE;
        defaultCase.RecordTypeId = ADVISOR_OUTREACH_RECORDTYPE;
        CaseFactory cases = new CaseFactory(defaultCase);

        List<Case> testCases = cases.create(5);
        List<String> queueIds = new List<String>();

        for (Case c : testCases) {
            c.ContactId = testContact.Id;
        }

        insert testCases;

        for (Group g : [SELECT Id FROM Group WHERE Type = 'Queue']) {
            queueIds.add(g.Id);
        }

        // Act
        Test.startTest();
        List<AdvisorPortalContact> assertContacts = AdvisorPortalController.getPortalContactsForViewOptions(queueIds);
        Test.stopTest();

        // Assert
        System.assertEquals(
            1,
            assertContacts.size(),
            'Contact list should NOT be empty, one Contact should have one Case record.'
        );
    }
}
