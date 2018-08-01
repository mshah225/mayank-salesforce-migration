@isTest
public class ContactFactory {
    public class DefaultContact extends TestFactory {
        public DefaultContact() {
            super(new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'Test@Test.com',
                EmplId__c = '1234567890'
            ));
            this.addToFieldsToIncrement('LastName');
        }
    }
    
    public class AllEmailsFilled extends TestFactory {
        public AllEmailsFilled(Id accountId) {
            super(new Contact(
                FirstName = 'Test',
                LastName = 'Test',
                Email = 'Test@Test.com',
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
        }
    }
}