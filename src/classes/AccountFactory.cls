@isTest
public class AccountFactory {
    public class DefaultAccount extends TestFactory {
        public DefaultAccount() {
            super(new Account(
                Name = 'Test'
            ));
            this.addToFieldsToIncrement('Name');
        }
    }
}