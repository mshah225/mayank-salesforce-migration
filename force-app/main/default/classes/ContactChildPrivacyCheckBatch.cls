// Implemented for Children's Online Privacy Protection Rule ("COPPA")
public class ContactChildPrivacyCheckBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    private static final Boolean debug = false;
    private String query =
        'SELECT Id, Current_Age_Calc__c, Under_13_Years_of_Age__c ' +
        'FROM Contact ' +
        'WHERE Birthdate != null AND Current_Age_Calc__c != null ' +
        'AND ((Current_Age_Calc__c >= 13 AND Under_13_Years_of_Age__c = true) ' +
        'OR (Current_Age_Calc__c < 13 AND Under_13_Years_of_Age__c = false))';

    private List<Contact> contactsToMarkThirteenOrOver = new List<Contact>();
    private List<Contact> contactsToMarkTwelveOrUnder = new List<Contact>();

    public Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQuerylocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        for (Contact con : (List<Contact>) scope) {
            if (con.Current_Age_Calc__c >= 13) {
                con.Under_13_Years_of_Age__c = false;
                contactsToMarkThirteenOrOver.add(con);
            } else if (con.Current_Age_Calc__c < 13) {
                con.Under_13_Years_of_Age__c = true;
                contactsToMarkTwelveOrUnder.add(con);
            }
        }

        if (!contactsToMarkThirteenOrOver.isEmpty()) {
            try {
                update contactsToMarkThirteenOrOver;
            } catch (Exception ex) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertStringToJSON('query', query));
                vars.add(ErrorLogger.convertListToJSON('scope', scope));
                vars.add(ErrorLogger.convertListToJSON('contactsToMarkThirteenOrOver', contactsToMarkThirteenOrOver));
                ErrorLogger.log(ex, vars, debug);
            }
        }

        if (!contactsToMarkTwelveOrUnder.isEmpty()) {
            try {
                update contactsToMarkTwelveOrUnder;
            } catch (Exception ex) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertStringToJSON('query', query));
                vars.add(ErrorLogger.convertListToJSON('scope', scope));
                vars.add(ErrorLogger.convertListToJSON('contactsToMarkTwelveOrUnder', contactsToMarkTwelveOrUnder));
                ErrorLogger.log(ex, vars, debug);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        if (job.Status == 'Failed') {
            try {
                throw new IllegalArgumentException('ContactChildPrivacyCheckBatch job failed');
            } catch (Exception ex) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertIdToJSON('AsyncApexJob.Id', job.Id));
                vars.add(ErrorLogger.convertStringToJSON('AsyncApexJob.Status', job.Status));
                vars.add(ErrorLogger.convertStringToJSON('query', query));
                vars.add(ErrorLogger.convertListToJSON('contactsToMarkThirteenOrOver', contactsToMarkThirteenOrOver));
                vars.add(ErrorLogger.convertListToJSON('contactsToMarkTwelveOrUnder', contactsToMarkTwelveOrUnder));
                ErrorLogger.log(ex, vars, debug);
            }
        }
    }

    public void execute(SchedulableContext ctx) {
        ContactChildPrivacyCheckBatch batch = new ContactChildPrivacyCheckBatch();
        Database.executebatch(batch, 200);
    }
}