@isTest
public class Test_SummaryListController {
    private static Integer numberOfPods;
    private static Integer numberOfCases;
    private static Integer numberOfStudents;
    private static Id ownerId;
    private static SummaryListController slc;
    private static String query;

    static {
        numberOfPods = 3;
        numberOfCases = 5;
        numberOfStudents = 5;

        slc = new SummaryListController();
        ownerId = UserInfo.getUserId();
        /*
         * Note: Test data factory only creates watchlist cases for the user.
         * We are removing the Category__c filter from this query even though it is passed
         * via the page. (Does not impact behavior of code)
         */
        query =
            'SELECT count(Id) total, Subject, Followup_Date__c ' +
            'FROM Case ' +
            'WHERE OwnerId = \'' +
            ownerId +
            '\' ' +
            'AND recordTypeId = \'' +
            IDHelper.getRTID('Case', 'ASU_Advisor_Outreach') +
            '\' ' +
            'AND IsClosed = false ' +
            'GROUP BY Subject, Followup_Date__c ' +
            'ORDER BY Followup_Date__c ASC NULLS LAST';
        slc.query = query;
    }

    @testSetup
    public static void testSetup() {
        TestDataFactory.makeMeAnAdvisorUser(numberOfPods, numberOfCases, numberOfStudents);
    }

    /*
     * Tests the controllers ability to get the Owner Id from the query
     */
    public static testMethod void Test_getOwnerId() {
        system.assertEquals(UserInfo.getUserId(), slc.ownerId);
    }

    /*
     * Tests the ontrollers ability to generate dynamic queries
     *
     * <p>
     * Note: Test data factory creates cases with no followup date.
     * Because of this, followup date should always be null in query.
     * </p>
     */
    public static testMethod void Test_getDynamicQuery() {
        String tempQuery;
        Id tempRTID = IDHelper.getRTID('Case', 'ASU_Advisor_Outreach');

        slc.subject = 'Case Bloat 0';
        slc.proactiveCaseRTID = tempRTID;
        slc.excludeFollowUpDate = false;
        tempQuery = slc.dynamicQuery;

        system.assert(tempQuery.contains(string.valueOf(UserInfo.getUserId()))); // Check for proper owner Id
        system.assert(tempQuery.contains('Case Bloat 0')); // Check for proper subject
        system.assert(tempQuery.contains(string.valueOf(IDHelper.getRTID('Case', 'ASU_Advisor_Outreach')))); // Check for record type id
        system.assert(tempQuery.contains('null')); // Check for followup date
    }

    /*
     * Tests the controllers ability to accurately summarize results
     *
     * <p>
     * Note: Test data factory creates cases with subject of 'Case Bloat 0' or
     * 'Case Bloat 1' and no followup date. Because of this all cases should be
     * summarized into 2 rows.
     * </p>
     */
    public static testMethod void Test_getSummaryResults() {
        system.assertEquals(2, slc.summaryResult.size());
    }
}
