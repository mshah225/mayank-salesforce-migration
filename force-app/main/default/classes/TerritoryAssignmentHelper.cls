public without sharing class TerritoryAssignmentHelper {
    private static Map<String, List<PS_Country_Map__c>> psCountryMap;
    private static Boolean debug = false;

    public static String shortenZipCode(String zip) {
        if (zip != null) {
            zip = zip.left(5);
        }
        return zip;
    }

    public static String getSFCountry(String country) {
        if (psCountryMap == null) {
            psCountryMap = PSCountryMapService.mapPSCountryToIntegrationValue();
        }
        List<PS_Country_Map__c> possibleCountries = psCountryMap.get(country);

        if (possibleCountries != null && possibleCountries.size() > 0) {
            PS_Country_Map__c psCountry = possibleCountries.get(0);
            String sfCountry = psCountry.Country_Name__c;
            return sfCountry;
        } else {
            return '';
        }
    }

    public static void updateContactList(List<Contact> conList) {
        List<String> vars = new List<String>();
        try {
            update conList;
        } catch (Exception e) {
            vars.add(ErrorLogger.convertListToJSON('conList', conList));
            ErrorLogger.log(e, vars, debug);
        }
    }

    public static void updateOpportunityList(List<Opportunity> oppList) {
        List<String> vars = new List<String>();
        try {
            update oppList;
        } catch (Exception e) {
            vars.add(ErrorLogger.convertListToJSON('oppList', oppList));
            ErrorLogger.log(e, vars, debug);
        }
    }

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
            throw new TerritoryAssignmentHelperException(
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

    public static String fieldsToString() {
        String tarFields = null;
        Map<String, SObjectField> tarFieldMap = ObjectService.getObjectFieldMap('Territory_Assignment_Rule__c');
        tarFields = ObjectService.objectFieldsToString(tarFieldMap);
        return tarFields;
    }

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

    public class TerritoryAssignmentHelperException extends Exception {
    }
}