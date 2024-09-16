@isTest
public class ContactChildPrivacyCheckBatchTest {
    @testSetup
    static void setup() {
        List<Contact> contacts = new List<Contact>();

        // Contacts with various ages and Under_13_Years_of_Age__c values
        contacts.add(
            new Contact(LastName = 'Catticusa', Birthdate = Date.today().addYears(-14), Under_13_Years_of_Age__c = true)
        ); // Should be updated to false
        contacts.add(
            new Contact(
                LastName = 'Catticusb',
                Birthdate = Date.today().addYears(-12),
                Under_13_Years_of_Age__c = false
            )
        ); // Should be updated to true
        contacts.add(
            new Contact(
                LastName = 'Catticusc',
                Birthdate = Date.today().addYears(-15),
                Under_13_Years_of_Age__c = false
            )
        ); // Should not change
        contacts.add(
            new Contact(LastName = 'Catticusd', Birthdate = Date.today().addYears(-10), Under_13_Years_of_Age__c = true)
        ); // Should not change

        insert contacts;
    }

    @isTest
    static void testSchedulableExecution() {
        // Start the test
        Test.startTest();
        ContactChildPrivacyCheckBatch batch = new ContactChildPrivacyCheckBatch();
        batch.execute(null);
        Test.stopTest();

        // Verify that the contacts were updated correctly
        for (Contact con : [SELECT Id, Current_Age_Calc__c, Under_13_Years_of_Age__c FROM Contact]) {
            if (con.Current_Age_Calc__c >= 13) {
                System.assertEquals(
                    false,
                    con.Under_13_Years_of_Age__c,
                    'Contact age 13 or older should have Under_13_Years_of_Age__c set to false.'
                );
            } else if (con.Current_Age_Calc__c < 13) {
                System.assertEquals(
                    true,
                    con.Under_13_Years_of_Age__c,
                    'Contact age less than 13 should have Under_13_Years_of_Age__c set to true.'
                );
            }
        }
    }
}