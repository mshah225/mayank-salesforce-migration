public without sharing class ErrorLogger {
    private static final String DEFAULT_CASE_DESCRIPTION = 'Default';
    private static final String DEFAULT_CASE_SUBJECT = 'Apex Exception Date: ' + System.today();

    private Exception exceptionToLog;
    private String details;
    private Case caseToCreate;
    private Exception errorLoggerException;
    private String className;
    private Boolean allowRepeats;

    public ErrorLogger() {
        caseToCreate = CaseAssignmentRuleAccessor.getNewCaseFromCar();
        caseToCreate.Description = DEFAULT_CASE_DESCRIPTION;
        className = '';
        Id loggedInContactId = ContactService.getLoggedInContactId();
        if (loggedInContactId != null) {
            caseToCreate.ContactId = loggedInContactId;
        }
        allowRepeats = false;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public void setException(Exception exceptionToLog) {
        this.exceptionToLog = exceptionToLog;
        setCaseDescription();
    }

    public void setDetails(String details) {
        this.details = details;
        setCaseDescription();
    }

    public void setAllowRepeats(Boolean allowRepeats) {
        this.allowRepeats = allowRepeats;
    }

    private void setCaseDescription() {
        caseToCreate.Description = getExceptionDetails() + getDetailsSafely();
    }

    private String getExceptionDetails() {
        if (exceptionToLog == null) {
            return 'No exception was set for the ErrorLogger \n';
        } else {
            return exceptionToLog.getTypeName() +
                '\n' +
                exceptionToLog.getMessage() +
                '\n' +
                exceptionToLog.getStackTraceString() +
                '\n';
        }
    }

    private String getDetailsSafely() {
        String caseTimeStamp = '\n\nThis error occurred: ' + '\n' + 'GMT' + '\n' + getCurrentTimeStamp();
        if (details == null) {
            return caseTimeStamp;
        }
        return 'User Description: \n' + details + caseTimeStamp;
    }

    public void setContactId(Id contactId) {
        if (Validator.validateId(contactId, Contact.class)) {
            caseToCreate.ContactId = contactId;
        }
    }

    public Id getContactId() {
        return caseToCreate.ContactId;
    }

    public override String toString() {
        return getCaseDescription();
    }

    public String getCaseDescription() {
        return caseToCreate.Description;
    }

    public String getSubject() {
        String classNameClause = String.isBlank(className) ? '' : className + ' ';
        String exceptionClause = exceptionToLog == null
            ? DEFAULT_CASE_SUBJECT + ' '
            : 'Apex Exception: ' + exceptionToLog.getTypeName() + ' ';
        String dateClause = 'Date: ' + System.today();
        return classNameClause + exceptionClause + dateClause;
    }

    public Boolean log() {
        System.debug(toString());

        caseToCreate.Subject = getSubject();

        if (!allowRepeats) {
            List<Case> oldCases = getDuplicateCasesFromToday();

            if (!oldCases.isEmpty()) {
                oldCases[0].Description = oldCases[0].Description + '\n' + getCurrentTimeStamp();
                caseToCreate = oldCases[0];
            }
        }

        try {
            upsert caseToCreate;
        } catch (Exception errorLoggerException) {
            this.errorLoggerException = errorLoggerException;
            handleLogCaseInsertException();
            return false;
        }

        return true;
    }

    private List<Case> getDuplicateCasesFromToday() {
        if (getContactId() == null) {
            return new List<Case>();
        }
        List<Case> oldCases = [
            SELECT Id, Description
            FROM Case
            WHERE ContactId = :getContactId() AND IsClosed = FALSE AND Subject = :caseToCreate.Subject
            LIMIT 1
        ];

        return oldCases;
    }

    private String getCurrentTimeStamp() {
        return String.valueOfGmt(DateTime.now());
    }

    private void handleLogCaseInsertException() {
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(getEmailList());
        System.debug(toString());
    }

    private List<Messaging.SingleEmailMessage> getEmailList() {
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        for (User emailUser : [
            SELECT Id, Email
            FROM User
            WHERE Receive_Apex_Errors__c = TRUE AND ProfileId = :getAdminProfileId()
        ]) {
            messageList.add(getExceptionEmail(emailUser));
        }
        return messageList;
    }

    private Messaging.SingleEmailMessage getExceptionEmail(User emailUser) {
        Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
        newEmail.setTargetObjectId(emailUser.Id);
        newEmail.setSaveAsActivity(false);
        newEmail.plainTextBody = '\n\n\nLogger Failed to insert case:\n\n' + getEmailDescription();
        newEmail.subject = caseToCreate.Subject;
        return newEmail;
    }

    private String getEmailDescription() {
        return errorLoggerException.getTypeName() +
            '\n' +
            errorLoggerException.getMessage() +
            '\n' +
            errorLoggerException.getStackTraceString() +
            '\n\n' +
            'Case to Create: \n' +
            '\n' +
            String.valueOf(caseToCreate) +
            '\n';
    }

    private Id getAdminProfileId() {
        return [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
    }

    /**
     * Report exceptions via desired method (system debug logs or cases). If case fails to
     * insert, send an email alert.
     *
     * @param Exception The exception that needs to be reported
     * @param List<String> A list of strings that represent the variable names and values
     * seperated by commas
     * @param Boolean Flag to determine if errors are logged to console or as cases
     * @return Boolean True if case is inserted, False if case is not inserted, Null if error
     */
    public static boolean log(Exception ex, List<String> variables, Boolean debug) {
        return log(ex, variables, debug, new Case(), null, false);
    }

    /**
     * Report exceptions via desired method (system debug logs or cases). If case fails to
     * insert, send an email alert.
     *
     * @param Exception The exception that needs to be reported
     * @param List<String> A list of strings that represent the variable names and values
     * seperated by commas
     * @param Boolean Flag to determine if errors are logged to console or as cases
     * @param Boolean Whether we should detect existing cases and append to those (fasle), or always make a new one (true)
     * will be used, If no user is logged in, no contact will be associated
     * @return Boolean True if case is inserted, False if case is not inserted, Null if error
     */
    public static boolean log(Exception ex, List<String> variables, Boolean debug, Boolean allowRepeats) {
        return log(ex, variables, debug, new Case(), null, allowRepeats);
    }

    /**
     * Report exceptions via desired method (system debug logs or cases). If case fails to
     * insert, send an email alert.
     *
     * @param Exception The exception that needs to be reported
     * @param List<String> A list of strings that represent the variable names and values
     * seperated by commas
     * @param Boolean Flag to determine if errors are logged to console or as cases
     * @param Id The contact Id the case should be associated with, If no ID is provided, the logged in user
     * will be used, If no user is logged in, no contact will be associated
     * @return Boolean True if case is inserted, False if case is not inserted, Null if error
     */
    public static boolean log(Exception ex, List<String> variables, Boolean debug, Id contactId) {
        return log(ex, variables, debug, new Case(), contactId, false);
    }

    /**
     * Overload provided for testing only. Pass an invalid case to this overload to force an
     * exception for code coverage.
     *
     * @param Exception The exception that needs to be reported
     * @param List<String> A list of strings that represent the variable names and values
     * seperated by commas
     * @param Boolean Flag to determine if errors are logged to console or as cases
     * @param Case A case object to use for the new case (allows for passing invalid cases for testing.
     * this param should only be utilized directly for test classes)
     * @param Id The contact Id the case should be associated with, If no ID is provided, the logged in user
     * will be used, If no user is logged in, no contact will be associated
     * @return Boolean True if case is inserted, False if case is not inserted, Null if error
     */
    public static boolean log(Exception ex, List<String> variables, Boolean debug, Case newCase, Id contactId) {
        return log(ex, variables, debug, newCase, contactId, false);
    }

    /**
     * Overload provided for testing only. Pass an invalid case to this overload to force an
     * exception for code coverage.
     *
     * @param Exception The exception that needs to be reported
     * @param List<String> A list of strings that represent the variable names and values
     * seperated by commas
     * @param Boolean Flag to determine if errors are logged to console or as cases
     * @param Case A case object to use for the new case (allows for passing invalid cases for testing.
     * this param should only be utilized directly for test classes)
     * @param Id The contact Id the case should be associated with, If no ID is provided, the logged in user
     * will be used, If no user is logged in, no contact will be associated
     * @param Boolean Whether we should detect existing cases and append to those (fasle), or always make a new one (true)
     * @return Boolean True if case is inserted, False if case is not inserted, Null if error
     */
    public static boolean log(
        Exception ex,
        List<String> variables,
        Boolean debug,
        Case newCase,
        Id contactId,
        Boolean allowRepeats
    ) {
        ErrorLogger el = new ErrorLogger();
        el.setException(ex);
        if (variables != null) {
            el.setDetails(String.valueOf(variables));
        }
        el.setContactId(contactId);
        el.setAllowRepeats(allowRepeats);
        return el.log();
    }

    /**
     * Convert Supplied List of SObjects to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param List<SObject> List of objects to be converted to JSON string
     * @return String JSON string from converted list
     */
    public static string convertListToJSON(String varName, List<SObject> sObjectList) {
        if (sObjectList != null && sObjectList.size() > 0) {
            return '{' + varName + ':[' + string.valueOf(sObjectList) + ']}';
        } else if (sObjectList == null) {
            return '{' + varName + ':null}';
        } else {
            return '{' + varName + ':{size:0, objects[]}}';
        }
    }

    /**
     * Convert Supplied List of Ids to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param List<Id> List of objects to be converted to JSON string
     * @return String JSON string from converted list
     */
    public static string convertListToJSON(String varName, List<Id> idList) {
        if (idList != null && idList.size() > 0) {
            return '{' + varName + ':[' + string.valueOf(idList) + ']}';
        } else if (idList == null) {
            return '{' + varName + ':null}';
        } else {
            return '{' + varName + ':{size:0, objects[]}}';
        }
    }

    /**
     * Convert Supplied Set of Ids to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param Set<Id> List of objects to be converted to JSON string
     * @return String JSON string from converted set
     */
    public static string convertSetToJSON(String varName, Set<Id> idSet) {
        if (idSet != null && idSet.size() > 0) {
            return '{' + varName + ':[' + string.valueOf(idSet) + ']}';
        } else if (idSet == null) {
            return '{' + varName + ':null}';
        } else {
            return '{' + varName + ':{size:0, objects[]}}';
        }
    }

    /**
     * Convert Supplied Set of Strings to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param Set<String> List of objects to be converted to JSON string
     * @return String JSON string from converted set
     */
    public static string convertSetToJSON(String varName, Set<String> stringSet) {
        if (stringSet != null && stringSet.size() > 0) {
            return '{' + varName + ':[' + string.valueOf(stringSet) + ']}';
        } else if (stringSet == null) {
            return '{' + varName + ':null}';
        } else {
            return '{' + varName + ':{size:0, objects[]}}';
        }
    }

    /**
     * Convert Supplied Map - Ids to SObjects - to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param Map<Id,SObject> Map - Ids to sobjects - to be converted to JSON string
     * @return String JSON string from converted set
     */
    public static string convertMapToJSON(String varName, Map<Id, SObject> sObjectMap) {
        if (sObjectMap != null && sObjectMap.size() > 0) {
            return '{' + varName + ':[' + string.valueOf(sObjectMap) + ']}';
        } else if (sObjectMap == null) {
            return '{' + varName + ':null}';
        } else {
            return '{' + varName + ':{size:0, objects[]}}';
        }
    }

    /**
     * Convert Supplied Map - Ids to Integers - to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param Map<Id,Integer> Map - Ids to Integers - to be converted to JSON string
     * @return String JSON string from converted set
     */
    public static string convertMapToJSON(String varName, Map<Id, Integer> idToIntMap) {
        if (idToIntMap != null && idToIntMap.size() > 0) {
            return '{' + varName + ':[' + string.valueOf(idToIntMap) + ']}';
        } else if (idToIntMap == null) {
            return '{' + varName + ':null}';
        } else {
            return '{' + varName + ':{size:0, objects[]}}';
        }
    }

    /**
     * Convert Supplied Map - String to String - to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param Map<String,String> Map - String to String - to be converted to JSON string
     * @return String JSON string from converted set
     */
    public static string convertMapToJSON(String varName, Map<String, String> stringToStringMap) {
        if (stringToStringMap != null && stringToStringMap.size() > 0) {
            return '{' + varName + ':[' + string.valueOf(stringToStringMap) + ']}';
        } else if (stringToStringMap == null) {
            return '{' + varName + ':null}';
        } else {
            return '{' + varName + ':{size:0, objects[]}}';
        }
    }

    /**
     * Convert Supplied Boolean value to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param Boolean Boolean Value to be converted to JSON string
     * @return String JSON string from converted set
     */
    public static string convertBooleanToJSON(String varName, Boolean value) {
        return '{' + varName + ':' + String.valueOf(value) + '}';
    }

    /**
     * Convert Supplied Integer value to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param Integer Integer Value to be converted to JSON string
     * @return String JSON string from converted set
     */
    public static string convertIntegerToJSON(String varName, Integer value) {
        return '{' + varName + ':' + String.valueOf(value) + '}';
    }

    /**
     * Convert Supplied String value to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param String String Value to be converted to JSON string
     * @return String JSON string from converted set
     */
    public static string convertStringToJSON(String varName, String value) {
        return '{' + varName + ':' + value + '}';
    }

    /**
     * Convert Supplied Double value to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param Double Double Value to be converted to JSON string
     * @return String JSON string from converted set
     */
    public static string convertDoubleToJSON(String varName, Double value) {
        return '{' + varName + ':' + String.valueOf(value) + '}';
    }

    /**
     * Convert Supplied Id value to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param Id Id Value to be converted to JSON string
     * @return String JSON string from converted set
     */
    public static string convertIdToJSON(String varName, Id value) {
        return '{' + varName + ':' + String.valueOf(value) + '}';
    }

    /**
     * Convert supplied SObject into a JSON string
     *
     * @param String Name of the SObject being passed
     * @param SObject The SObject to be converted to JSON
     * @return String JSON string from converted SOBject
     */
    public static string convertSObjectToJSON(String varName, SObject value) {
        return '{' + varName + ':{' + String.valueOf(value) + '}}';
    }

    public without sharing class ErrorLoggerQueue implements Queueable {
        Exception error;
        List<String> variables;
        Boolean debug;
        Boolean allowRepeats;

        public ErrorLoggerQueue() {
            this.allowRepeats = false;
        }
        public ErrorLoggerQueue(Exception error, List<String> variables, Boolean debug) {
            this.error = error;
            this.variables = variables;
            this.debug = debug;
            this.allowRepeats = false;
        }
        public ErrorLoggerQueue(Exception error, List<String> variables, Boolean debug, Boolean allowRepeats) {
            this.error = error;
            this.variables = variables;
            this.debug = debug;
            this.allowRepeats = allowRepeats;
        }

        public void setError(Exception error) {
            this.error = error;
        }
        public void setVariables(List<String> variables) {
            this.variables = variables;
        }
        public void setDebug(Boolean debug) {
            this.debug = debug;
        }
        public void setAllowRepeats(Boolean allowRepeats) {
            this.allowRepeats = allowRepeats;
        }

        public void execute(QueueableContext context) {
            ErrorLogger.log(error, variables, debug, allowRepeats);
        }
    }
}