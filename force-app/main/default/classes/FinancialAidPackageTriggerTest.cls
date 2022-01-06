@isTest
private class FinancialAidPackageTriggerTest {
    @TestSetup
    private static void setup() {
        Contact c = new Contact(FirstName = 'TestContact', LastName = 'TestContact');
        insert c;
    }

    @isTest
    private static void testFAPackStatusTimeStampOnInsert() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Date today = System.now().date();

        Financial_Aid_Package__c newFaPack = new Financial_Aid_Package__c(
            Contact__c = c.Id,
            Aid_Year__c = String.valueOf(today.year()),
            EFC_Range__c = 'Very High',
            FAFSA_Date_Received__c = today,
            Fin_Aid_Package_Date__c = today,
            Financial_Aid_Status__c = 'Act on Your Awards',
            Pell_Eligibility__c = false,
            Promise_Cohort__c = 'Obama'
        );

        Datetime beforeInsert = System.now();

        while (System.now().getTime() - beforeInsert.getTime() < 1000) {
            // Waste at least 1000ms to ensure FA_Status_Time_Stamp__c is far enough from these comparison time stamps
        }

        Test.startTest();
        insert newFaPack;
        Test.stopTest();

        Datetime afterInsert = System.now();
        while (System.now().getTime() - afterInsert.getTime() < 1000) {
            // Waste at least 1000ms to ensure FA_Status_Time_Stamp__c is far enough from these comparison time stamps
        }
        afterInsert = System.now();

        List<Financial_Aid_Package__c> faPacks = [
            SELECT Id, FA_Status_Time_Stamp__c, CreatedDate
            FROM Financial_Aid_Package__c
        ];

        System.assert(!faPacks.isEmpty(), 'Did not create Financial Aid Packages');
        for (Financial_Aid_Package__c faPack : faPacks) {
            System.assert(faPack.FA_Status_Time_Stamp__c >= beforeInsert);
            System.assert(faPack.FA_Status_Time_Stamp__c <= afterInsert);
        }
    }

    @isTest
    private static void testFAPackStatusTimeStampOnUpdate() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Date today = System.now().date();

        Financial_Aid_Package__c newFaPack = new Financial_Aid_Package__c(
            Contact__c = c.Id,
            Aid_Year__c = String.valueOf(today.year()),
            EFC_Range__c = 'Very High',
            FAFSA_Date_Received__c = today,
            Fin_Aid_Package_Date__c = today,
            Financial_Aid_Status__c = 'Act on Your Awards',
            Pell_Eligibility__c = false,
            Promise_Cohort__c = 'Obama'
        );

        insert newFaPack;

        newFaPack.Financial_Aid_Status__c = 'Disbursement';

        Datetime beforeUpdate = System.now();

        while (System.now().getTime() - beforeUpdate.getTime() < 1000) {
            // Waste at least 1000ms to ensure FA_Status_Time_Stamp__c is far enough from these comparison time stamps
        }

        Test.startTest();
        update newFaPack;
        Test.stopTest();

        Datetime afterUpdate = System.now();
        while (System.now().getTime() - afterUpdate.getTime() < 1000) {
            // Waste at least 1000ms to ensure FA_Status_Time_Stamp__c is far enough from these comparison time stamps
        }
        afterUpdate = System.now();

        //Get the records we created
        List<Financial_Aid_Package__c> faPacks = [
            SELECT Id, FA_Status_Time_Stamp__c, CreatedDate
            FROM Financial_Aid_Package__c
        ];

        System.assert(!faPacks.isEmpty(), 'Did not create Financial Aid Packages');
        for (Financial_Aid_Package__c faPack : faPacks) {
            System.assert(faPack.FA_Status_Time_Stamp__c >= beforeUpdate);
            System.assert(faPack.FA_Status_Time_Stamp__c <= afterUpdate);
        }
    }

    @isTest
    private static void padTests() {
        /**
         * Just exists to pad the test coverage - we don't do anything on delete/undelete
         */
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Date today = System.now().date();

        Financial_Aid_Package__c newFaPack = new Financial_Aid_Package__c(
            Contact__c = c.Id,
            Aid_Year__c = String.valueOf(today.year()),
            EFC_Range__c = 'Very High',
            FAFSA_Date_Received__c = today,
            Fin_Aid_Package_Date__c = today,
            Financial_Aid_Status__c = 'Act on Your Awards',
            Pell_Eligibility__c = false,
            Promise_Cohort__c = 'Obama'
        );

        Test.startTest();
        insert newFaPack;
        delete newFaPack;
        undelete newFaPack;
        Test.stopTest();
    }
}
