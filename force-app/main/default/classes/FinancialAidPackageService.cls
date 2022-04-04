public class FinancialAidPackageService {
    public static void populateStatusTimeStamps(
        List<Financial_Aid_Package__c> newFAs,
        Map<Id, Financial_Aid_Package__c> oldFAs
    ) {
        for (Financial_Aid_Package__c FA : newFAs) {
            if (oldFAs == null || oldFAs.get(FA.Id).Financial_Aid_Status__c != FA.Financial_Aid_Status__c) {
                FA.FA_Status_Time_Stamp__c = System.now();
            }
        }
    }
}
