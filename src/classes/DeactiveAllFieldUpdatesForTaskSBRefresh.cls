global class DeactiveAllFieldUpdatesForTaskSBRefresh {

    global void DeactiveAllFieldUpdatesForTask(){
        
        Workflow_Triggers__c workflowTriggersObj = Workflow_Triggers__c.getOrgDefaults();
        workflowTriggersObj.Contact_Update_Owner_Assignment__c = false;
        
        
        upsert workflowTriggersObj;
    }
}