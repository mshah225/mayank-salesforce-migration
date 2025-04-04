global class InactiveRelationshipBatchJob implements Database.Batchable<SObject> {
    private static final Boolean debug = true; 

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id 
            FROM Relationship__c 
            WHERE Relationship_End_Date__c <= TODAY 
              AND Active_Relationship__c = true
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Relationship__c> scope) {
        for (Relationship__c relToUpdate : scope) {
            relToUpdate.Active_Relationship__c = false;
        }

        try {        
            update scope;
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('Exception: ', ex.getMessage()));
            ErrorLogger.log(ex, vars, debug);
        }  
    }

    global void finish(Database.BatchableContext BC) {
    }
}