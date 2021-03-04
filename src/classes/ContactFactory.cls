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
            super(new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', EmplId__c = '123456'));
            this.addToFieldsToIncrement('LastName');
            this.addToFieldsToIncrement('EmplId__c');
        }
    }

    public class WithRequiredFields extends TestFactory {
        /**
         * Creates a new Contact with all required fields populated
         */
        public WithRequiredFields() {
            super(
                new Contact(
                    FirstName = 'Test',
                    LastName = 'Contact',
                    MailingPostalCode = '85282',
                    Email = 'test.user@test.example.com',
                    Birthdate = Date.newInstance(1989, 8, 12),
                    Self_Service_PIN__c = 57483638,
                    PIN_lockout__c = true,
                    ASURite_ID__c = 'testuser'
                )
            );
            this.addToFieldsToIncrement('LastName');
            this.addToFieldsToIncrement('EmplId__c');
            this.addToFieldsToIncrement('ASURite_ID__c');
        }

        /**
         * Generates a single Contact with all required fields
         *
         * @return a new Contact with all required fields
         */
        public Contact createOne() {
            return (Contact) super.create().get(0);
        }

        /**
         * Generates multiple Contacts with all required fields
         *
         * @param numberToCreate the number of Contacts to create
         *
         * @return a list of the generated Contacts
         */
        public List<Contact> createMany(Integer numberToCreate) {
            return (List<Contact>) super.create(numberToCreate);
        }
    }

    public class AllEmailsFilled extends TestFactory {
        public AllEmailsFilled(Id accountId) {
            super(
                new Contact(
                    FirstName = 'Test',
                    LastName = 'Test',
                    Email = 'test@test.com',
                    Corporate_Relations_Email__c = 'test@test.com',
                    EPO_Email__c = 'test@test.com',
                    ASU_Email__c = 'test@test.com',
                    Last_Case_Email_Used__c = 'test@test.com',
                    Lead_Email__c = 'test@test.com',
                    Lead_Secondary_Email__c = 'test@test.com',
                    me3hs_User_ID__c = 'test@test.com',
                    Parent_Email__c = 'test@test.com',
                    Personal_Email__c = 'test@test.com',
                    Birthdate = System.today(),
                    AccountId = accountId
                )
            );
            this.addToFieldsToIncrement('LastName');
        }

        public AllEmailsFilled() {
            super(
                new Contact(
                    FirstName = 'Test',
                    LastName = 'Test',
                    Email = 'test@test.com',
                    Corporate_Relations_Email__c = 'test@test.com',
                    EPO_Email__c = 'test@test.com',
                    ASU_Email__c = 'test@test.com',
                    Last_Case_Email_Used__c = 'test@test.com',
                    Lead_Email__c = 'test@test.com',
                    Lead_Secondary_Email__c = 'test@test.com',
                    me3hs_User_ID__c = 'test@test.com',
                    Parent_Email__c = 'test@test.com',
                    Personal_Email__c = 'test@test.com',
                    Birthdate = System.today()
                )
            );
            this.addToFieldsToIncrement('LastName');
        }
    }
}
