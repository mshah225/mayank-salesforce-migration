@isTest
public class AccountFactory {
    public class Institution extends TestFactory {
        public Institution() {
            super(new Account(Name = 'Arizona State University', Type = 'HS'));
            this.addToFieldsToIncrement('Name');
        }
    }
    public class DefaultAccount extends TestFactory {
        public DefaultAccount() {
            super(new Account(Name = 'Test'));
            this.addToFieldsToIncrement('Name');
        }
    }
}
