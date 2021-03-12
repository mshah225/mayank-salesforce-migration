/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-02-14
 *
 * Controller Logic for AdvisorPortalMassUpdate.cmp
 */
public class AdvisorPortalMassUpdateController {
    @AuraEnabled
    public static List<String> populateClosedCaseStatusOptions() {
        return new List<String>{
            'Closed: Customer Self-Resolved',
            'Conferred with Student by Email',
            'Conferred with Student by Phone',
            'In Person Meeting'
        };
    }

    @AuraEnabled
    public static Map<String, String> populateRecommendedActionOptions() {
        Map<String, String> optionsMap = new Map<String, String>();

        for (Schema.PicklistEntry actionEntry : Case.Recommended_Actions__c.getDescribe().getPicklistValues()) {
            String label = '';
            for (String s : actionEntry.getLabel().split(' ')) {
                label += s.substring(0, 1).capitalize() + s.substring(1, s.length()) + ' ';
            }

            optionsMap.put(label.trim(), actionEntry.getValue());
        }

        return optionsMap;
    }

    @AuraEnabled
    public static List<String> populateStudentIntentionOptions() {
        return new List<String>{ 'Not returning ever', 'Not returning temporarily', 'Enrolled' };
    }

    @AuraEnabled
    public static Map<String, String> populateReturnTermOptions() {
        Map<String, String> optionsMap = new Map<String, String>();

        for (
            Schema.PicklistEntry actionEntry : Case.What_term_is_the_student_planning_to_ret__c.getDescribe()
                .getPicklistValues()
        ) {
            optionsMap.put(actionEntry.getLabel(), actionEntry.getValue());
        }

        return optionsMap;
    }

    @AuraEnabled
    public static Map<String, String> populateStudentRiskOptions() {
        Map<String, String> optionsMap = new Map<String, String>();

        for (Schema.PicklistEntry actionEntry : Case.Student_Presented_Risk_for__c.getDescribe().getPicklistValues()) {
            optionsMap.put(actionEntry.getLabel(), actionEntry.getValue());
        }

        return optionsMap;
    }

    @AuraEnabled
    public static Map<String, String> populateReasonNotReturningOptions() {
        Map<String, String> optionsMap = new Map<String, String>();

        for (Schema.PicklistEntry actionEntry : Case.Reasons_Not_Returning__c.getDescribe().getPicklistValues()) {
            optionsMap.put(actionEntry.getLabel(), actionEntry.getValue());
        }

        return optionsMap;
    }

    @AuraEnabled
    public static void updateCases(List<Case> casesToUpdate) {
        update casesToUpdate;
    }
}
