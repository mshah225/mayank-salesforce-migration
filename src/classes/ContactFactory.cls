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
}