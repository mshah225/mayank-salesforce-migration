public without sharing class TerritoryAssignmentAccount {
    public static Boolean assignTerritoriesOnBeforeInsertDone = false;
    public static Boolean assignTerritoriesOnBeforeUpdateDone = false;

    public void assignTerritoriesOnBeforeInsert(List<Account> newAccountList) {
        if (assignTerritoriesOnBeforeInsertDone) {
            return;
        }

        Map<String, String> KVMap = new Map<String, String>();
        Set<String> ZipsInTrigger = new Set<String>();
        List<Key_Value__c> KVList = new List<Key_Value__c>();

        for (Account InsZip : newAccountList) {
            //Ensures Zipcode is five digits or less
            string shortZip = TerritoryAssignmentService.shortenZipCode(InsZip.ShippingPostalCode);
            ZipsInTrigger.add(shortZip);
        }

        if (ZipsInTrigger.size() > 0) {
            KVList = [
                SELECT Id, Geomarket_ZIP__c, Geomarket_Code__c
                FROM Key_Value__c
                WHERE RecordType.DeveloperName = 'Geomarket_Code_Map' AND Geomarket_ZIP__c IN :ZipsInTrigger
            ];

            for (Key_Value__c K : KVList) {
                KVMap.put(K.Geomarket_ZIP__c, K.Geomarket_Code__c);
            }

            for (Account AccGeo : newAccountList) {
                //Ensures Zipcode is five digits or less
                string shortZip = TerritoryAssignmentService.shortenZipCode(AccGeo.ShippingPostalCode);
                AccGeo.Geomarket_Code__c = KVMap.get(shortZip);
            }
        }

        assignTerritoriesOnBeforeInsertDone = true;
    }

    public void assignTerritoriesOnBeforeUpdate(List<Account> newAccountList, Map<Id, Account> oldAccountMap) {
        assignTerritories(newAccountList);

        if (assignTerritoriesOnBeforeUpdateDone) {
            return;
        }

        for (Account acc : newAccountList) {
            if (
                acc.Defer_Territory_Assignment__c == false &&
                oldAccountMap.get(acc.Id).Defer_Territory_Assignment__c == true
            ) {
                continue;
            }

            if (
                acc.Territory_Manager__c != null &&
                oldAccountMap.get(acc.Id).Territory_Manager__c != acc.Territory_Manager__c &&
                oldAccountMap.get(acc.Id).Territory_Manager__c != null
            ) {
                acc.Defer_Territory_Assignment__c = true;
                acc.Previous_Territory_Manager_ID__c = oldAccountMap.get(acc.Id).Territory_Manager__c;
            }
        }
        assignTerritoriesOnBeforeUpdateDone = true;
    }
}
