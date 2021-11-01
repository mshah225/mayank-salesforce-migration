@isTest
public with sharing class PSCountryMapServiceTest {
    @isTest
    private static void testMapPSCountryToIntegrationValue() {
        List<PS_Country_Map__c> countries = new List<PS_Country_Map__c>();
        for (Integer i = 0; i < 3; i++) {
            countries.add(
                new PS_Country_Map__c(
                    Name = 'China ' + i,
                    PS_Country_Code__c = 'CH' + i,
                    Country_Name__c = 'China ' + i,
                    Integration_Value__c = 'China',
                    Country_Code__c = 'C' + i
                )
            );
            countries.add(
                new PS_Country_Map__c(
                    Name = 'United States ' + i,
                    PS_Country_Code__c = 'US' + i,
                    Country_Name__c = 'United States ' + i,
                    Integration_Value__c = 'United States',
                    Country_Code__c = 'U' + i
                )
            );
        }
        insert countries;

        Test.startTest();
        Map<String, List<PS_Country_Map__c>> countryMapping = PSCountryMapService.mapPSCountryToIntegrationValue();
        Test.stopTest();

        System.assertEquals(2, countryMapping.keySet().size());
        for (String integVal : countryMapping.keySet()) {
            List<PS_Country_Map__c> countriesForIntegVal = countryMapping.get(integVal);
            System.assertEquals(3, countriesForIntegVal.size());
        }
    }
}
