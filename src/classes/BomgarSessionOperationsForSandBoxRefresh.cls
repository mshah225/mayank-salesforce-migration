global class BomgarSessionOperationsForSandBoxRefresh implements Database.Batchable<sObject>
{
	global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name FROM bomgar__BomgarSession__c WHERE bomgar__RelatedCase__c != Null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<bomgar__BomgarSession__c> scope){
        
        //Delete All  bomgar__BomgarSession__c Rows
        Delete scope;
    }  
    global void finish(Database.BatchableContext BC){
        
        
        //Activate workflows
        UpdateWorkflowTriggersForSandboxRefresh objUpdateQWorkflow = new UpdateWorkflowTriggersForSandboxRefresh();
        objUpdateQWorkflow.ActivateWorkflowTriggers();
    }
}