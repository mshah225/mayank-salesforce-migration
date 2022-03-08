/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-02-14
 *
 * Controller Logic for AdvisorPortalMassUpdate.cmp
 */
public class AdvisorPortalMassUpdateController {
    @AuraEnabled(cacheable=true)
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

    @AuraEnabled(cacheable=true)
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

    @AuraEnabled(cacheable=true)
    public static Map<String, String> populateStudentRiskOptions() {
        Map<String, String> optionsMap = new Map<String, String>();

        for (Schema.PicklistEntry actionEntry : Case.Student_Presented_Risk_for__c.getDescribe().getPicklistValues()) {
            optionsMap.put(actionEntry.getLabel(), actionEntry.getValue());
        }

        return optionsMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> populateReasonNotReturningOptions() {
        Map<String, String> optionsMap = new Map<String, String>();

        for (Schema.PicklistEntry actionEntry : Case.Reasons_Not_Returning__c.getDescribe().getPicklistValues()) {
            optionsMap.put(actionEntry.getLabel(), actionEntry.getValue());
        }

        return optionsMap;
    }

    @AuraEnabled(cacheable=true)
    //               dropdown     value     required
    public static Map<String, Map<String, List<String>>> getCustomMetadata() {
        // I split these two functions up make it easier to write the tests (since you can't insert test metadata)
        return convertMetadataToMapping(retrieveMetadata());
    }

    @TestVisible
    private static Map<String, Map<String, List<String>>> convertMetadataToMapping(
        List<Advisor_Portal_Mass_Close_Configuration__mdt> metadata
    ) {
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

    private static List<Advisor_Portal_Mass_Close_Configuration__mdt> retrieveMetadata() {
        List<Advisor_Portal_Mass_Close_Configuration__mdt> metadata = new List<Advisor_Portal_Mass_Close_Configuration__mdt>(
            [
                SELECT Dropdown__c, Value__c, Required_Fields__c
                FROM Advisor_Portal_Mass_Close_Configuration__mdt
                WHERE Enabled__c = TRUE
            ]
        );
        return metadata;
    }

    @AuraEnabled
    public static void updateCases(List<Case> casesToUpdate) {
        update casesToUpdate;
    }
}
