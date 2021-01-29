@isTest
public class OpportunityFactory extends TestFactory {
    public static final Opportunity DEFAULT_OPPORTUNITY = new Opportunity(
        Name = 'Test Opp ',
        RecordTypeId = IdHelper.getRecordTypeId('Opportunity', 'Undergraduate_Prospect'),
        StageName = 'Prospect',
        CloseDate = Date.today().addYears(1),
        Type = 'First Time Freshman'
    );

    public OpportunityFactory() {
        super(DEFAULT_OPPORTUNITY);
        this.addToFieldsToIncrement('Name');
    }

    public OpportunityFactory(Opportunity opportunityToCreate) {
        super(opportunityToCreate);
        this.addToFieldsToIncrement('Name');
    }

    public Opportunity createOne() {
        return (Opportunity) this.create()[0];
    }

    public void setRealtedContactsWithAccounts(Contact contact) {
        setRealtedContactsWithAccounts(new List<Contact>{ contact });
    }

    public void setRealtedContactsWithAccounts(List<Contact> contacts) {
        List<Account> accounts = new List<Account>();
        for (Contact contact : contacts) {
            accounts.add(new Account(Id = contact.AccountId));
        }

        this.setRelatedObject('Contact__c', contacts);
        this.setRelatedObject('AccountId', accounts);
    }
}
