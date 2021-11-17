public without sharing class TerritoryAssignmentAccount {
    public static Boolean assignTerritoriesDone = false;

    public void assignTerritories() {
        if (assignTerritoriesDone) {
            return;
        }

        Map<String, String> KVMap = new Map<String, String>();
        Set<String> ZipsInTrigger = new Set<String>();
        List<Key_Value__c> KVList = new List<Key_Value__c>();

        for (Account InsZip : (List<Account>) Trigger.New) {
            //Ensures Zipcode is five digits or less
            string shortZip = shortenZipCode(InsZip.ShippingPostalCode);
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

            for (Account AccGeo : (List<Account>) Trigger.New) {
                //Ensures Zipcode is five digits or less
                string shortZip = shortenZipCode(AccGeo.ShippingPostalCode);
                AccGeo.Geomarket_Code__c = KVMap.get(shortZip);
            }
        }

        if (Trigger.isUpdate) {
            Map<ID, Account> AcountOldMap = (Map<ID, Account>) Trigger.oldMap;

            for (Account A : (List<Account>) Trigger.New) {
                if (
                    A.Defer_Territory_Assignment__c == false &&
                    AcountOldMap.get(A.Id).Defer_Territory_Assignment__c == true
                ) {
                    continue;
                }

                if (
                    A.Territory_Manager__c != null &&
                    AcountOldMap.get(A.Id).Territory_Manager__c != A.Territory_Manager__c &&
                    AcountOldMap.get(A.Id).Territory_Manager__c != null
                ) {
                    A.Defer_Territory_Assignment__c = true;
                    A.Previous_Territory_Manager_ID__c = AcountOldMap.get(A.Id).Territory_Manager__c;
                }
            }
        }

        assignTerritoriesDone = true;
    }
}
