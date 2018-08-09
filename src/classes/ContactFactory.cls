@isTest
public class ContactFactory {
    public class DefaultContact extends TestFactory {
        public DefaultContact() {
            super(new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'test@test.com',
                EmplId__c = '123456789'
            ));
            this.addToFieldsToIncrement('LastName');
            this.addToFieldsToIncrement('EmplId__c');
        }
    }
    
    public class AllEmailsFilled extends TestFactory {
        public AllEmailsFilled(Id accountId) {
            super(new Contact(
                FirstName = 'Test',
                LastName = 'Test',
                Email = 'test@test.com',
                Corporate_Relations_Email__c = 'test@test.com',
                EPO_Email__c = 'test@test.com',
                ASU_Email__c = 'test@test.com',
                Last_Case_Email_Used__c = 'test@test.com',
                Lead_Email__c = 'test@test.com',
                Lead_Secondary_Email__c = 'test@test.com',
                Parent_Email__c = 'test@test.com',
                Personal_Email__c = 'test@test.com',
                Birthdate = System.today()
            ));
            this.addToFieldsToIncrement('LastName');
        }
    }
}
