/**
 * Class TriggerFactory
 *
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
 */
public with sharing class TriggerFactory {
    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Type t - Type of handler to instatiate
     *
     * Throws a TriggerException if no handler has been found.
     */
    public static void createAndExecuteHandler(Type t) {
        // Get a handler appropriate to the object being processed
        ITrigger handler = getHandler(t);

        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null) {
            throw new TriggerException('No Trigger Handler found named: ' + t.getName());
        }

        // Execute the handler to fulfil the trigger
        String triggerType = '';
        if (Trigger.isInsert) {
            triggerType = 'insert';
        } else if (Trigger.isUpdate) {
            triggerType = 'update';
        } else if (Trigger.isDelete) {
            triggerType = 'delete';
        }

        if (Trigger.isBefore) {
            LogSuite.log('DML', 'Starting ' + triggerType + ' of ' + t);
        }

        execute(handler, t);
        LogSuite.log('runstats', '# of QUERIES: ' + Limits.getQueries() + '; # OF DML: ' + Limits.getDMLStatements());

        if (Trigger.isAfter) {
            LogSuite.log('DML', 'Finishing ' + triggerType + ' of ' + t);
        }
    }

    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   ITrigger handler - A Trigger Handler to execute
     */
    private static void execute(ITrigger handler, Type t) {
        // Before Trigger
        if (Trigger.isBefore) {
            // Call the bulk before to handle any caching of data and enable bulkification
            LogSuite.log('CODEFLOW', 'Starting ' + t + ' Bulk Before');
            handler.bulkBefore();
            LogSuite.log('CODEFLOW', 'Finishing ' + t + ' Bulk Before');

            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete) {
                for (SObject so : Trigger.old) {
                    LogSuite.log('CODEFLOW', 'Starting ' + t + ' Before Delete');
                    handler.beforeDelete(so);
                    LogSuite.log('CODEFLOW', 'Finishing ' + t + ' Before Delete');
                }
            } else if (Trigger.isInsert) {
                // Iterate through the records to be inserted passing them to the handler.
                for (SObject so : Trigger.new) {
                    LogSuite.log('CODEFLOW', 'Starting ' + t + ' Before Insert');
                    handler.beforeInsert(so);
                    LogSuite.log('CODEFLOW', 'Finishing ' + t + ' Before Insert');
                }
            } else if (Trigger.isUpdate) {
                // Iterate through the records to be updated passing them to the handler.
                for (SObject so : Trigger.old) {
                    LogSuite.log('CODEFLOW', 'Starting ' + t + ' Before Update');
                    handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                    LogSuite.log('CODEFLOW', 'Finishing ' + t + ' Before Update');
                }
            }

            // Call the bulk beforeFinally to handle any bulk operations at the end of the
            // BEFORE process
            LogSuite.log('CODEFLOW', 'Starting ' + t + ' Before Finally');
            handler.beforeFinally();
            LogSuite.log('CODEFLOW', 'Finishing ' + t + ' Before Finally');
        } else {
            // Call the bulk after to handle any caching of data and enable bulkification
            LogSuite.log('CODEFLOW', 'Starting ' + t + ' Bulk After');
            handler.bulkAfter();
            LogSuite.log('CODEFLOW', 'Finishing ' + t + ' Bulk After');

            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete) {
                for (SObject so : Trigger.old) {
                    LogSuite.log('CODEFLOW', 'Starting ' + t + ' After Delete');
                    handler.afterDelete(so);
                    LogSuite.log('CODEFLOW', 'Finishing ' + t + ' After Delete');
                }
            } else if (Trigger.isInsert) {
                // Iterate through the records inserted passing them to the handler.
                for (SObject so : Trigger.new) {
                    LogSuite.log('CODEFLOW', 'Starting ' + t + ' After Insert');
                    handler.afterInsert(so);
                    LogSuite.log('CODEFLOW', 'Finishing ' + t + ' After Insert');
                }
            } else if (Trigger.isUpdate) {
                // Iterate through the records updated passing them to the handler.
                for (SObject so : Trigger.old) {
                    LogSuite.log('CODEFLOW', 'Starting ' + t + ' After Update');
                    handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                    LogSuite.log('CODEFLOW', 'Finishing ' + t + ' After Update');
                }
            }
        }

        // Perform any post processing
        LogSuite.log('CODEFLOW', 'Starting ' + t + ' And Finally');
        handler.andFinally();
        LogSuite.log('CODEFLOW', 'Finishing ' + t + ' And Finally');
    }

    /**
     * private static method to get the named handler.
     *
     * Arguments:   Type t - Class of handler to instatiate
     *
     * Returns:     ITrigger - A trigger handler if one exists or null.
     */
    private static ITrigger getHandler(Type t) {
        // Instantiate the type
        Object o = t.newInstance();

        // if its not an instance of ITrigger return null
        if (!(o instanceof ITrigger)) {
            return null;
        }

        return (ITrigger) o;
    }

    public class TriggerException extends Exception {
    }
}
