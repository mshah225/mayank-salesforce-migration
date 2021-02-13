@isTest
public class Test_QADefaultHandler {
    private static QADefaultHandler qadh;
    private static Integer numberOfPods;
    private static Integer numberOfCases;
    private static Integer numberOfStudents;
    private static List<Case> cases;

    static {
        qadh = new QADefaultHandler();
        numberOfPods = 1;
        numberOfCases = 3;
        numberOfStudents = 5;
        cases = new List<Case>([SELECT OwnerId, RecordTypeId, Most_Recent_Queue__c FROM Case]);
    }

    @testSetup
    public static void testSetup() {
        // Short hand to populate some cases that are advisor cases
        TestDataFactory.makeMeAnAdvisorUser(numberOfPods, numberOfCases, numberOfStudents);
    }

    /*
     * Tests the QADefaultHandlers ability to identify advisor cases
     *
     * <p>
     * At this point, all cases are advisor cases so this should always be true.
     * </p>
     */
    public static testMethod void Test_isAdvisorCase() {
        for (Case c : cases) {
            if (c.recordTypeId == IDHelper.getRTID('Case', 'ASU_Advisor_Outreach')) {
                system.assert(qadh.isAdvisorCase(c));
            } else {
                system.assert(!qadh.isAdvisorCase(c));
            }
        }
    }

    /*
     * Tests the QADefaultHandler's ability to determine if the case is
     * owned by a group as opposed to a user.
     */
    public static testMethod void Test_caseOwnedByGroup() {
        for (Case c : cases) {
            if (Validator.validateId(c.OwnerId, Group.class)) {
                system.assert(qadh.caseOwnedByGroup(c));
            } else {
                system.assert(!qadh.caseOwnedByGroup(c));
            }
        }
    }

    /*
     * Tests the QADefaultHandler's ability to determine the from address for the provided case
     */
    public static testMethod void Test_getEmailFromAddress() {
        for (Case c : cases) {
            if (qadh.isAdvisorCase(c)) {
                if (qadh.caseOwnedByGroup(c)) {
                    system.assertEquals(
                        [SELECT Primary_Email__c FROM Success_Pod__c WHERE OwnerId = :c.OwnerId]
                        .Primary_Email__c,
                        qadh.getEmailFromAddress(c.Id)
                    );
                } else {
                    system.assertEquals(
                        [SELECT Primary_Email__c FROM Success_Pod__c WHERE Owner_Name__c = :c.Most_Recent_Queue__c]
                        .Primary_Email__c,
                        qadh.getEmailFromAddress(c.Id)
                    );
                }
            }
        }
    }

    public static testMethod void Test_nullContextId() {
        qadh.getEmailFromAddress(null);
        List<Case> errorList = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        System.assertEquals(1, errorList.size());
    }
}
