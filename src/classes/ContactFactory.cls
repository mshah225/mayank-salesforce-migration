@isTest
public class ContactFactory {
    public class DefaultContact extends TestFactory {
        public DefaultContact() {
            super(new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'test@test.com'
            ));
            this.addToFieldsToIncrement('LastName');
        }
    }
    
    public class AllEmailsFilled extends TestFactory {
        public AllEmailsFilled(Id accountId) {
            super(new Contact(
                FirstName = 'Test',
                LastName = 'Test',
                Email = 'test@test.com',
                Corporate_Relations_Email__c = 'crtest@test.com',
                EPO_Email__c = 'epotest@test.com',
                ASU_Email__c = 'asutest@test.com',
                Lead_Email__c = 'leadtest@test.com',
                Lead_Secondary_Email__c = 'lead2test@test.com',
                Parent_Email__c = 'parenttest@test.com',
                Personal_Email__c = 'personaltest@test.com',
                Birthdate = System.today()
            ));
            this.addToFieldsToIncrement('LastName');
        }
    }
}