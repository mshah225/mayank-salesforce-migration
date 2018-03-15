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
    
    public class SandBoxRefreshLead extends TestFactory {
        public SandBoxRefreshLead() {
            super(new Lead(
                FirstName = 'Mister',
                LastName = 'Test',
                Company = 'Test Pvt Ltd ',
                Email = 'test@test.com',
                Recruiting_Email__c = 'test@test.com',
                Secondary_Email__c = 'test@test.com',
                Date_of_Birth__c = System.today()
            ));
            this.addToFieldsToIncrement('LastName');
            this.addToFieldsToIncrement('Company');
            this.addToFieldsToIncrement('Email');
        }
    }
}