public class AdvisorPortalMassUpdateController {
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

    @AuraEnabled
    //               dropdown     value     required
    public static Map<String, Map<String, List<String>>> getCustomMetadata() {
        List<Advisor_Portal_Mass_Close_Configuration__mdt> metadata = [
            SELECT Dropdown__c, Value__c, Required_Fields__c
            FROM Advisor_Portal_Mass_Close_Configuration__mdt
            WHERE Enabled__c = TRUE
        ];

        if (Test.isRunningTest()) {
            metadata = [
                SELECT Dropdown__c, Value__c, Required_Fields__c
                FROM Advisor_Portal_Mass_Close_Configuration__mdt
                WHERE Enabled__c = FALSE AND MasterLabel LIKE '%[TEST]%'
            ];
        }

        Map<String, Map<String, List<String>>> returnMapping = new Map<String, Map<String, List<String>>>();

        for (Advisor_Portal_Mass_Close_Configuration__mdt metadatum : metadata) {
            if (!returnMapping.containsKey(metadatum.Dropdown__c)) {
                returnMapping.put(metadatum.Dropdown__c, new Map<String, List<String>>());
            }

            List<String> required = new List<String>();
            if (metadatum.Required_Fields__c != null) {
                List<String> splitUp = metadatum.Required_Fields__c.split(',');
                for (String req : splitUp) {
                    required.add(req.trim());
                }
            }
            returnMapping.get(metadatum.Dropdown__c).put(metadatum.Value__c, required);
        }

        return returnMapping;
    }
}
