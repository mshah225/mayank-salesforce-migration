@isTest
public class LeadFactory extends TestFactory {
    public static final Lead DEFAULT_LEAD = new Lead(
        FirstName = 'Mister',
        LastName = 'Test',
        Company = 'Test Inc',
        Email = 'test@test.test',
        LeadSource = 'Email'
    );

    public LeadFactory() {
        super(DEFAULT_LEAD);
        this.addToFieldsToIncrement('Email');
        this.addToFieldsToIncrement('LastName');
        this.addToFieldsToIncrement('Company');
    }

    public LeadFactory(Lead testLead) {
        super(testLead);
        this.addToFieldsToIncrement('Email');
        this.addToFieldsToIncrement('LastName');
        this.addToFieldsToIncrement('Company');
    }

    public Lead createOne() {
        return (Lead) this.create()[0];
    }

    public class DefaultLead extends TestFactory {
        public DefaultLead() {
            super(new Lead(FirstName = 'Mister', LastName = 'Test', Company = 'Test Inc'));
            this.addToFieldsToIncrement('LastName');
            this.addToFieldsToIncrement('Company');
        }
    }

    public class AllEmailAndBirthdayLead extends TestFactory {
        public AllEmailAndBirthdayLead() {
            super(
                new Lead(
                    FirstName = 'Mister',
                    LastName = 'Test',
                    Company = 'Test Pvt Ltd ',
                    Email = 'test@test.com',
                    Recruiting_Email__c = 'test@test.com',
                    Secondary_Email__c = 'test@test.com',
                    Date_of_Birth__c = System.today()
                )
            );
            this.addToFieldsToIncrement('LastName');
            this.addToFieldsToIncrement('Company');
            this.addToFieldsToIncrement('Email');
            this.addToFieldsToIncrement('Recruiting_Email__c');
            this.addToFieldsToIncrement('Secondary_Email__c');
        }
    }
}
