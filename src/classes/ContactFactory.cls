@isTest
public class ContactFactory {
    public class DefaultContact extends TestFactory {
        public DefaultContact() {
            super(new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                email = 'Test@Test.com'
            ));
            this.addToFieldsToIncrement('LastName');
            this.addToFieldsToIncrement('email');
        }
    }
    
    public class AllEmailCase extends TestFactory {
        public AllEmailCase(Id accountId) {
            super(new Contact(
                FirstName = 'Test',
                LastName = 'Test',
                email = 'Test@Test.com',
                Corporate_Relations_Email__c = 'Test@Test.com',
                EPO_Email__c = 'Test@Test.com',
                ASU_Email__c = 'Test@Test.com',
                Last_Case_Email_Used__c = 'Test@Test.com',
                Lead_Email__c = 'Test@Test.com',
                Lead_Secondary_Email__c = 'Test@Test.com',
                Parent_Email__c = 'Test@Test.com',
                Personal_Email__c = 'Test@Test.com',
                Birthdate = System.today()
            ));
            this.addToFieldsToIncrement('LastName');
            this.addToFieldsToIncrement('email');
        }
    }
}