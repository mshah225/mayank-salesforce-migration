@isTest
private class FinancialAidPackageTriggerTest {
    static List<Id> contactIds = new List<Id>();
    static List<Id> faPackIds = new List<Id>();

    private static void createContacts(Integer qty) {
        List<Contact> contacts = new List<Contact>();

        for (Integer i = 0; i < qty; i++) {
            Contact con = new Contact();
            con.FirstName = 'FName' + i;
            con.LastName = 'LName' + i;
            contacts.add(con);
        }

        insert contacts;

        for (Contact c : contacts) {
            contactIds.add(c.Id);
        }
    }

    private static void createFAPacks(Integer qty) {
        createContacts(qty);

        Date today = Date.today();
        List<Financial_Aid_Package__c> faPacks = new List<Financial_Aid_Package__c>();

        for (Id contactId : contactIds) {
            Financial_Aid_Package__c faPack = new Financial_Aid_Package__c();
            faPack.Contact__c = contactId;
            faPack.Aid_Year__c = String.valueOf(today.year());
            faPack.EFC_Range__c = 'Very High';
            faPack.FAFSA_Date_Received__c = today;
            faPack.Fin_Aid_Package_Date__c = today;
            faPack.Financial_Aid_Status__c = 'Act on Your Awards';
            faPack.Pell_Eligibility__c = false;
            faPack.Promise_Cohort__c = 'Obama';
            faPacks.add(faPack);
        }
        insert faPacks;

        for (Financial_Aid_Package__c f : faPacks) {
            faPackIds.add(f.Id);
        }
    }

    @isTest
    static void testFAPackStatusTimeStampOnInsert() {
        //Invoke the before insert trigger
        createFAPacks(1);

        //Get the records we created
        List<Financial_Aid_Package__c> faPacks = [
            SELECT Id, FA_Status_Time_Stamp__c, CreatedDate
            FROM Financial_Aid_Package__c
            WHERE Id = :faPackIds
        ];

        for (Financial_Aid_Package__c faPack : faPacks) {
            System.debug('Time Stamp is ' + faPack.FA_Status_Time_Stamp__c);
            System.debug('CreatedDate is ' + faPack.CreatedDate);

            System.assertEquals(faPack.CreatedDate.year(), faPack.FA_Status_Time_Stamp__c.year());
            System.assertEquals(faPack.CreatedDate.month(), faPack.FA_Status_Time_Stamp__c.month());
            System.assertEquals(faPack.CreatedDate.day(), faPack.FA_Status_Time_Stamp__c.day());
        }
    }

    @isTest
    static void testFAPackStatusTimeStampOnUpdate() {
        //Invoke the before insert trigger
        createFAPacks(1);

        //Get the records we created
        List<Financial_Aid_Package__c> faPacks = [
            SELECT Id, FA_Status_Time_Stamp__c, LastModifiedDate
            FROM Financial_Aid_Package__c
            WHERE Id = :faPackIds
        ];

        //Change the FA Status to invoke before update trigger
        List<Financial_Aid_Package__c> newFaPacks = new List<Financial_Aid_Package__c>();
        for (Financial_Aid_Package__c f1 : faPacks) {
            f1.Financial_Aid_Status__c = 'Disbursement';
            newFaPacks.add(f1);
        }
        //Update the records
        update newFaPacks;

        //Get the updated records
        newFaPacks = [
            SELECT Id, FA_Status_Time_Stamp__c, LastModifiedDate
            FROM Financial_Aid_Package__c
            WHERE Id = :faPackIds
        ];

        for (Financial_Aid_Package__c f2 : faPacks) {
            System.debug('Time Stamp is ' + f2.FA_Status_Time_Stamp__c);
            System.debug('LastModifiedDate is ' + f2.LastModifiedDate);

            System.assertEquals(f2.LastModifiedDate.year(), f2.FA_Status_Time_Stamp__c.year());
            System.assertEquals(f2.LastModifiedDate.month(), f2.FA_Status_Time_Stamp__c.month());
            System.assertEquals(f2.LastModifiedDate.day(), f2.FA_Status_Time_Stamp__c.day());
        }
    }
}
