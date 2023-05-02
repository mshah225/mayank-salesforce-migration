public without sharing class AccountService {
    public static Boolean assignTerritoryDone = false;

    public static void assignTerritory(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        if (assignTerritoryDone) {
            return;
        }
        assignTerritoryDone = true;

        Map<String, String> geomarketZipWithGeomarketCode = new Map<String, String>();
        Set<String> zipcodesToCheck = new Set<String>();
        List<Key_Value__c> geomarkets = new List<Key_Value__c>();

        for (Account newAccount : newAccounts) {
            //Ensures Zipcode is five digits or less
            string shortZip = TerritoryAssignmentService.shortenZipCode(newAccount.ShippingPostalCode);
            zipcodesToCheck.add(shortZip);
        }

        if (zipcodesToCheck.size() > 0) {
            geomarkets = [
                SELECT Id, Geomarket_ZIP__c, Geomarket_Code__c
                FROM Key_Value__c
                WHERE RecordType.DeveloperName = 'Geomarket_Code_Map' AND Geomarket_ZIP__c IN :zipcodesToCheck
            ];

            for (Key_Value__c geomarket : geomarkets) {
                geomarketZipWithGeomarketCode.put(geomarket.Geomarket_ZIP__c, geomarket.Geomarket_Code__c);
            }

            for (Account newAccount : newAccounts) {
                //Ensures Zipcode is five digits or less
                string shortZip = TerritoryAssignmentService.shortenZipCode(newAccount.ShippingPostalCode);
                newAccount.Geomarket_Code__c = geomarketZipWithGeomarketCode.get(shortZip);
            }
        }

        if (oldAccountsMap != null && oldAccountsMap.size() > 0) {
            for (Account newAccount : newAccounts) {
                if (
                    newAccount.Defer_Territory_Assignment__c == false &&
                    oldAccountsMap.get(newAccount.Id).Defer_Territory_Assignment__c == true
                ) {
                    continue;
                }

                if (
                    newAccount.Territory_Manager__c != null &&
                    oldAccountsMap.get(newAccount.Id).Territory_Manager__c != newAccount.Territory_Manager__c &&
                    oldAccountsMap.get(newAccount.Id).Territory_Manager__c != null
                ) {
                    newAccount.Defer_Territory_Assignment__c = true;
                    newAccount.Previous_Territory_Manager_ID__c = oldAccountsMap.get(newAccount.Id)
                        .Territory_Manager__c;
                }
            }
        }
    }
}