public class PSCountryMapService {
    /**
     * Returns all the fields on PS_Country_Map__c in a String
     * @return A string containing all of the PS_Country_Map__c fields
     */
    public static String fieldsToString() {
        String psCountryFields = null;

        Map<String, SObjectField> psCountryFieldMap = ObjectService.getObjectFieldMap('PS_Country_Map__c');

        psCountryFields = ObjectService.objectFieldsToString(psCountryFieldMap);

        return psCountryFields;
    }

    /**
     * Returns a map of all the PS Country Maps sorted by their Integration Value
     * @return A map containing a set of Integration Values and their associated PS CountryMaps
     */
    public static Map<String, List<PS_Country_Map__c>> mapPSCountryToIntegrationValue() {
        Map<String, List<PS_Country_Map__c>> psCountryMap = new Map<String, List<PS_Country_Map__c>>();

        List<PS_Country_Map__c> psCountries = new List<PS_Country_Map__c>();

        try {
            String selectAllPSCountries = 'SELECT ' + fieldsToString() + ' FROM PS_Country_Map__c';

            psCountries = Database.query(selectAllPSCountries);
        } catch (Exception e) {
            throw new PSCountryMapServiceException(
                '!!!ERROR!!!: An error occurred trying to get all of the PS_Country_Map__c in this Org.\n' +
                e.getMessage()
            );
        }

        // Iterate through the list of PS Countries and sort them by Integration Value
        for (PS_Country_Map__c psCountry : psCountries) {
            if (psCountryMap.containsKey(psCountry.Integration_Value__c)) {
                psCountryMap.get(psCountry.Integration_Value__c).add(psCountry);
            } else {
                psCountryMap.put(psCountry.Integration_Value__c, new List<PS_Country_Map__c>{ psCountry });
            }
        }

        return psCountryMap;
    }

    public class PSCountryMapServiceException extends Exception {
    }
}
