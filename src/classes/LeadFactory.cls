@isTest
public class LeadFactory {

    public class DefaultLead extends TestFactory {
        public DefaultLead() {
            super(new Lead(
                FirstName = 'Mister',
                LastName = 'Test',
                Company = 'Test Inc'
            ));
            this.addToFieldsToIncrement('LastName');
            this.addToFieldsToIncrement('Company');
        }
    }
}