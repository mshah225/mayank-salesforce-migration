public class PersistenceOutlookService  {

    public static void updateOldPersistenceOutlookRecords(List<Persistence_Outlook__c> newList) {
        Set<Id> contactsConnectedToOutlook = new Set<Id>();
        for (Persistence_Outlook__c outlook : newList) {
            contactsConnectedToOutlook.add(outlook.Contact__c);
            outlook.Current_Flag__c = true; 
        }

        List<Persistence_Outlook__c> oldOutlooksToUpdate = [
            SELECT Id 
            FROM Persistence_Outlook__c 
            WHERE Contact__c IN: contactsConnectedToOutlook
            AND Current_Flag__c = true
        ];

        for (Persistence_Outlook__c oldOutlook : oldOutlooksToUpdate ) {
            oldOutlook.Current_Flag__c = false;
        }

        update oldOutlooksToUpdate;
    }
}
