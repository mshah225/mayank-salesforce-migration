public class TerritoryAssignmentRuleService {
    /**
     * Returns all the fields on TerritoryAssignmentRule in a String
     * @return A string containing all the TerritoryAssignmentRule fields
     */
    public static String fieldsToString() {
        String tarFields = null;

        Map<String, SObjectField> tarFieldMap = ObjectService.getObjectFieldMap('Territory_Assignment_Rule__c');

        tarFields = ObjectService.objectFieldsToString(tarFieldMap);

        return tarFields;
    }

    /**
     * Returns a map of all the Territory Assignment Rules sorted by their Rule Key
     * @return A map containing a set of Rule Keys and their associated Territory Assignment Rules
     */
    public static Map<String, List<Territory_Assignment_Rule__c>> mapTerritoryAssignmentRulesToRuleKey() {
        Map<String, List<Territory_Assignment_Rule__c>> tarMap = new Map<String, List<Territory_Assignment_Rule__c>>();

        List<Territory_Assignment_Rule__c> tars = new List<Territory_Assignment_Rule__c>();

        try {
            String selectAllTars =
                'SELECT ' +
                fieldsToString() +
                ', User__r.IsActive ' +
                'FROM Territory_Assignment_Rule__c';
            tars = Database.query(selectAllTars);
        } catch (Exception e) {
            throw new TerritoryAssignmentRuleServiceException(
                '!!!ERROR!!!: An error occurred trying to get all of the Territory Assignment Rules in this Org.\n' +
                e.getMessage()
            );
        }

        // Iterate through the list of Territory Assignment Rules and sort them by Rule Key
        for (Territory_Assignment_Rule__c tar : tars) {
            if (tarMap.containsKey(tar.Rule_Key__c)) {
                tarMap.get(tar.Rule_Key__c).add(tar);
            } else {
                tarMap.put(tar.Rule_Key__c, new List<Territory_Assignment_Rule__c>{ tar });
            }
        }

        return tarMap;
    }

    /**
     * Returns the appropriate Territory Assignment Rule for a given list of TARs and an  Assignment Number
     * @param A list of possible Territory Assignment Rules
     * @param A Decimal containing the Opportunity or Lead Assignment Number
     * @return A Territory Assignment Rule that corresponds to the tarList and assignmentNumber, or null if none could be found
     */
    public static Territory_Assignment_Rule__c getTerritoryAssignmentRule(
        List<Territory_Assignment_Rule__c> tarList,
        Decimal assignmentNumber
    ) {
        Territory_Assignment_Rule__c tarToReturn;
        Territory_Assignment_Rule__c defaultTar;

        Boolean useDefaultTar = false;

        if (tarList == null) {
            useDefaultTar = !useDefaultTar;
        } else {
            // Find the right Territory Assignment Rule for our Opportunity Assignment Number
            for (Territory_Assignment_Rule__c tar : tarList) {
                // This is the fallback Territory Assignment Rule
                if (tar.Range_Start__c == null) {
                    defaultTar = tar;
                } else if (tar.Range_Start__c <= assignmentNumber && tar.Range_End__c >= assignmentNumber) {
                    tarToReturn = tar;
                }
            }

            // If no range defined Territory Assignment Rules were found, return the fallback Territory Assignment Rule
            if (tarToReturn == null) {
                tarToReturn = defaultTar;
            }
        }

        return tarToReturn;
    }

    public class TerritoryAssignmentRuleServiceException extends Exception {
    }
}
