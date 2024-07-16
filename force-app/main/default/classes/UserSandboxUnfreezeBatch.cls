/**
 * Batch class to unfreeze user logins in a sandbox environment.
 * This class is responsible for finding and unfreezing user logins that are frozen in a sandbox environment.
 */
public class UserSandboxUnfreezeBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    private static final Boolean debug = false;
    @TestVisible
    private String query;
    private List<UserLogin> usersToUnfreeze = new List<UserLogin>();

    /**
     * Constructor to initialize the batch query if in a sandbox environment.
     */
    public UserSandboxUnfreezeBatch() {
        if (SandboxHelper.isSandbox) {
            if (SandboxHelper.hasValidSandboxField) {
                this.query = buildQuery();
            } else {
                this.query = '';
            }
        } else {
            handleInvalidQuery('Cannot schedule UserSandboxUnfreezeBatch in production environment');
        }
    }

    /**
     * Handles invalid queries by logging an error and preventing batch execution.
     *
     * @param message The error message to log.
     */
    private void handleInvalidQuery(String message) {
        List<String> vars = new List<String>();
        vars.add(ErrorLogger.convertStringToJSON('Environment', SandboxHelper.sandboxName));
        vars.add(ErrorLogger.convertStringToJSON('Message', message));
        ErrorLogger.log(new IllegalArgumentException(message), vars, debug);
        this.query = null;
    }

    /**
     * Builds the query to find frozen users based on the sandbox field.
     *
     * @return The query string to find frozen users.
     */
    private String buildQuery() {
        return 'SELECT Id, UserId FROM UserLogin WHERE IsFrozen = true AND UserId IN (SELECT Id FROM User WHERE IsActive = true AND ' +
            SandboxHelper.sandboxFieldName +
            ' = true)';
    }

    /**
     * Start method to initiate the batch process.
     *
     * @param bc The batch context.
     * @return The query locator to fetch the records.
     */
    public Database.Querylocator start(Database.BatchableContext bc) {
        if (String.isNotBlank(query)) {
            return Database.getQueryLocator(query);
        } else {
            throw new IllegalArgumentException('The query cannot be null or blank.');
        }
    }

    /**
     * Execute method to process each batch of records.
     *
     * @param bc The batch context.
     * @param scope The list of records to process.
     */
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        for (UserLogin userToUnfreeze : (List<UserLogin>) scope) {
            userToUnfreeze.IsFrozen = false;
            usersToUnfreeze.add(userToUnfreeze);
        }

        if (!usersToUnfreeze.isEmpty()) {
            try {
                update usersToUnfreeze;
            } catch (Exception ex) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertStringToJSON('message', 'Error unfreezing sandbox users'));
                vars.add(ErrorLogger.convertStringToJSON('query', query));
                vars.add(ErrorLogger.convertListToJSON('scope', scope));
                vars.add(ErrorLogger.convertListToJSON('usersToUnfreeze', usersToUnfreeze));
                ErrorLogger.log(ex, vars, debug);
            }
        }
    }

    /**
     * Finish method to handle post-processing after the batch completes.
     *
     * @param bc The batch context.
     */
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        if (job.Status == 'Failed') {
            try {
                throw new IllegalArgumentException('UserSandboxUnfreezeBatch job failed');
            } catch (Exception ex) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertIdToJSON('AsyncApexJob.Id', job.Id));
                vars.add(ErrorLogger.convertStringToJSON('AsyncApexJob.Status', job.Status));
                vars.add(ErrorLogger.convertStringToJSON('query', query));
                vars.add(ErrorLogger.convertListToJSON('usersToUnfreeze', usersToUnfreeze));
                ErrorLogger.log(ex, vars, debug);
            }
        }
    }

    /**
     * Execute method for the schedulable interface to start the batch.
     *
     * @param ctx The schedulable context.
     */
    public void execute(SchedulableContext ctx) {
        if (String.isNotBlank(query)) {
            Database.executeBatch(new UserSandboxUnfreezeBatch(), 200);
        } else {
            handleInvalidQuery('Cannot execute UserSandboxUnfreezeBatch due to null or blank query.');
        }
    }
}