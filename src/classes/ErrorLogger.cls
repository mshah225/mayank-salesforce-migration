public without sharing class  ErrorLogger {
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
        return log(ex, variables, debug, new Case(), null);
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
        return log(ex, variables, debug, new Case(), contactId);
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
        if (debug) {
            // Report exception via system debug logs
            debug(ex, variables);
            
            return false;
        } else {
            List<Case> oldCases; // Existing cases with the same subject
            List<Case_Assignment_Rule__c> sfCar; //The CAR to be used to assign the case to SF Support
            Group queue; // Owner of the case to be created
            string subject; // Case/Email subject
            Boolean createCase = false; // Determine if a case should be created
            string EMPLId;
            Contact loggedInContact; // Contact Record for the logged in user
            
            
            try {
                // Get the contactId of the logged in user
                subject = 'Apex Exception: ' + ex.getTypeName() + ' Date: ' + system.today();
                
                // Get contact for case
                // The contact that is passed is not valid
                if (!Validator.validateId(contactId, Contact.Class)) {
                    
                    //retrive logged in contact
                    loggedInContact=ContactService.getLoggedInContact();
                }
                    
                // Check to see if the logged in user has an open case
                // with the same subject for de-duping
                if (loggedInContact != null) {
                    
                    system.debug('errorLogger 78: ' + limits.getQueryRows());
                    oldCases = [SELECT Subject, IsClosed 
                       FROM Case 
                       WHERE (ContactId = :loggedInContact.Id)
                       AND IsClosed = false 
                       AND subject = :subject];
                    system.debug('errorLogger 84: ' + limits.getQueryRows());
                       
                   if (oldCases.size() > 0) {
                       createCase = false;
                       debug(ex, variables);
                   } else {
                       createCase = true;
                   }
                } else { // If no contact Id is found, create a case
                    createCase = true;
                }
                
                if (createCase) {
                    sfCar = new List<Case_Assignment_Rule__c>([Select Queue_ID__c, CC_Functional_Group__c, CC_Category__c,
                        CC_Sub_Category__c, Email_Address__c, Case_Feed_Email_Template_Id__c, Campus__c, Origin__c,
                        Case_Record_Type_Id__c
                        FROM Case_Assignment_Rule__c
                        WHERE Origin__c = 'Error Logger' ORDER BY Priority__c DESC LIMIT 1]);
                       
                    if (sfCar.size() == 0) {
                        sfCar.add(createDefaultCar());
                        
                        insert sfCar;
                    }
                
                    queue = [SELECT Id
                        FROM Group 
                        WHERE Name = 'ASU Salesforce Support (Case)' 
                        AND Type = 'Queue' LIMIT 1];
                    
                    newCase.OwnerId = sfCar[0].Queue_ID__c;
                    newCase.CC_Functional_Group__c = sfCar[0].CC_Functional_Group__c;
                    newCase.CC_Category__c = sfCar[0].CC_Category__c;
                    newCase.CC_Sub_Category__c = sfCar[0].CC_Sub_Category__c;
                    newCase.Case_Feed_Email__c = sfCar[0].Email_Address__c;
                    newCase.Case_Feed_Email_Template_Id__C = sfCar[0].Case_Feed_Email_Template_Id__c;
                    newCase.Campus__c = sfCar[0].Campus__c;
                    newCase.Origin__c = sfCar[0].Origin__c;
                    newCase.Subject = subject;
                    newCase.Visible_by_Contact__c = false;
                    if (contactId != null && Validator.validateId((String) contactId, contact.class)) {
                        newCase.contactId = contactId;
                    } else {
                        if (loggedInContact != null){
                            newCase.contactId = loggedInContact.Id;
                        }
                    }
                    
                    newCase.Description = ex.getMessage() + '\n'
                        + ex.getStackTraceString() + '\n'
                        + 'Variable Snap Shot:';
                    
                    if (variables.size() > 0) {
                        for (String s : variables) {
                            newCase.description = newCase.Description + '\n' + s;
                        }
                    }
                    
                    debug(ex, variables);
                    insert newCase;
                    
                    return true;
                } else {
                    return false;
                }
            } catch (Exception nex) {
                Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
                List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
                List<Messaging.SendEmailResult> results;
                List<String> addresses = new List<String>();
                List<Id> recipientObjectIds = new List<Id>();
                List<String> vars = new List<String>();
                Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
                
                // Uses targetObjectId to send Emails
                // uses the Recieve_Apex_errors__c field on user object to determine the users to which the Error email needs to be sent.
                
                for(User emailUser : [
                    SELECT id, Email
                    FROM User
                    WHERE Receive_Apex_Errors__c = true
                    AND ProfileId = :adminProfileId
                ]){
                    newEmail = new Messaging.SingleEmailMessage();
                    newEmail.setTargetObjectId(emailUser.Id);
                    newEmail.subject = subject;
                    newEmail.setSaveAsActivity(false);
                    newEmail.plainTextBody = ex.getMessage() + '\n'
                    + ex.getStackTraceString() + '\n'
                    + 'Variable Snap Shot:';
                
                    if (variables.size() > 0) {
                        for (String s : variables) {
                        newEmail.plainTextBody = newEmail.plainTextBody + '\n' + s;
                        }
                    }
                
                
                    // Add exception info for why the case failed to create
                    newEmail.plainTextBody = newEmail.plainTextBody + '\n\n\nLogger Failed to insert case:\n'
                        + nex.getTypeName() + '\n'
                        + nex.getMessage() + '\n'
                        + nex.getStackTraceString() + '\n'
                        + 'Variable Snap Shot:';
                        
                    vars.add(convertSObjectToJSON('newCase',newCase));
                    vars.add(convertListToJSON('oldCases',oldCases));
                    if (loggedInContact != null){
                        vars.add(convertIdToJSON('loggedInContactId',loggedInContact.Id));
                    }
                    
                    vars.add(convertSObjectToJSON('queue',queue));
                    vars.add(convertStringToJSON('subject',subject));
                    vars.add(convertBooleanToJSON('createCase',createCase));
                    
                    for (String s : vars) {
                        newEmail.plainTextBody = newEmail.plainTextBody + '\n' + s;
                    }
                    
                    debug(ex, variables);
                    debug(nex, vars);
                    messageList.add(newEmail);
                        
                }    
                results = messaging.sendEmail(messageList);
                    
                return null;
            }
        }
    }
    
    private static void debug(Exception ex, List<String> variables) {
        system.debug(ex.getMessage());
        system.debug(ex.getStackTraceString());
        system.debug('Variable snap shot');
        
        for (String s : variables) {
            system.debug(s);
        }
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
     * Convert Supplied Map - Ids to SObjects - to a JSON string
     *
     * @param String Name of the list being passed to lable the object
     * @param Map<Id,SObject> Map - Ids to sobjects - to be converted to JSON string
     * @return String JSON string from converted set
     */
    public static string convertMapToJSON(String varName, Map<Id,SObject> sObjectMap) {
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
    public static string convertMapToJSON(String varName, Map<Id,Integer> idToIntMap) {
         if (idToIntMap != null && idToIntMap.size() > 0) {
             return '{' + varName + ':[' + string.valueOf(idToIntMap) + ']}';
         } else if (idToIntMap == null) {
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
    
    /**
     * Creates a Default Case Assignment Rule for the Error Logger
     * <p>
     * I opted to use this rout for 3 reasons:
     * -Reduce potential for errors in the error logger
     * -Ensure that test classes do not need to create CARs themselves
     * -Can function in any environment (developer sandbox) without setup
     * </p>
     *
     * @return Case_Assignment_Rule__c The new case assignment rule
     */
    public static Case_Assignment_Rule__c createDefaultCar() {
        Case_Assignment_Rule__c defaultCar = new Case_Assignment_Rule__c();
        List<Case_Classification__c> lstCaseCategory = [SELECT Id, Name, Parent__c FROM Case_Classification__c WHERE Active__c = true AND Name='General' AND Parent__r.Name='ASU Salesforce Support'];  // query category and functional group from case classification if it exists
        List<RecordType> lstRT = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName='Functional_Group' OR DeveloperName='Category']; // query record types of case classification object
        Integer priority; // Priority of the new CAR
        String QueueId = [SELECT Id FROM Group WHERE Name = 'ASU Salesforce Support (Case)'].Id; // Owner of the new CAR
        List<Case_Assignment_Rule__c> highestPriority = new List<Case_Assignment_Rule__c>(
            [SELECT Priority__c FROM Case_Assignment_Rule__c ORDER By Priority__c DESC LIMIT 1]
        ); // Used to get the next sequential priority
        String recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'ASU Service' LIMIT 1].Id;
        
        if (highestPriority.size() == 1) {
            priority = integer.valueOf(highestPriority[0].Priority__c) + 1;
        } else {
            priority = 1;
        }
        
        // Required Fields
        defaultCar.Customer_Notice_Email_From_Name__c = 'ASU Salesforce Support';
        defaultCar.Queue_ID__c = QueueId.left(15);
        defaultCar.Priority__c = priority;
        
        // Other fields required by Error Logger
        // Assign Functional Group and Category if they exist
        if(lstCaseCategory!=null && lstCaseCategory.size()>0) {
            defaultCar.CC_Functional_Group__c = lstCaseCategory[0].Parent__c;
            defaultCar.CC_Category__c = lstCaseCategory[0].Id;
        }
        // Create Functional Group and Category Record and then assign it to default CAR
        else {
            Case_Classification__c defaultFuncGroup=new Case_Classification__c();
            defaultFuncGroup.Name='ASU Salesforce Support';
            defaultFuncGroup.Record_Types__c='ASU Coach Outreach; ASU Service';
            defaultFuncGroup.Record_Types_String__c='ASU Coach Outreach;ASU Service';
            defaultFuncGroup.Active__c=true;
            defaultFuncGroup.Visible__c=true;
            if(lstRT[0].DeveloperName=='Functional_Group')
                defaultFuncGroup.RecordTypeId=lstRT[0].Id;
            else 
                defaultFuncGroup.RecordTypeId=lstRT[1].Id;
            
            insert defaultFuncGroup;
            
            Case_Classification__c defaultCategory= new Case_Classification__c();
            defaultCategory.Name='General';
            defaultCategory.Active__c=true;
            defaultCategory.Visible__c=true;
            defaultCategory.Parent__c=defaultFuncGroup.Id;
            if(lstRT[0].DeveloperName=='Category')
                defaultCategory.RecordTypeId=lstRT[0].Id;
            else 
                defaultCategory.RecordTypeId=lstRT[1].Id;
            
            insert defaultCategory;
            
            defaultCar.CC_Functional_Group__c = defaultCategory.Parent__c;
            defaultCar.CC_Category__c = defaultCategory.Id;
        }
        defaultCar.Email_Address__c = ''; //ToDo see if we should add SF email here
        defaultCar.Case_Feed_Email_Template_Id__c = '';
        defaultCar.Campus__c = '';
        defaultCar.Origin__c ='Error Logger';
        defaultCar.Case_Record_Type_Id__c = recordTypeId.left(15);
        
        return defaultCar;
    }
}