@isTest
public class ContactFactory extends TestFactory {
    public static final Contact DEFAULT_CONTACT = new Contact(
        FirstName = 'Test',
        LastName = 'Contact',
        Email = 'test@test.com',
        EmplId__c = '12000'
    );
    
    public ContactFactory(Contact testContact) {
        super(testContact);
        this.addToFieldsToIncrement('LastName');
        this.addToFieldsToIncrement('EmplId__c');
    }
    
    public Contact createOne() {
        return (Contact) this.create(1)[0];
    }
    
    public class DefaultContact extends TestFactory {
        public DefaultContact() {
            super(new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'test@test.com',
                EmplId__c = '123456'
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
