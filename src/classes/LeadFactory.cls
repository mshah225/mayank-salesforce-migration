@isTest
public class LeadFactory {

    public class DefaultLead extends TestFactory {
        public DefaultLead() {
            super(new Lead(
                firstName = 'Mister',
                lastName = 'Test',
                company = 'Test Inc'
            ));
            this.addToFieldsToIncrement('lastName');
            this.addToFieldsToIncrement('company');
        }
    }
}