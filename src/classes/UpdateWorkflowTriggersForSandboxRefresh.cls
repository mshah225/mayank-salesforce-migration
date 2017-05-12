global class UpdateWorkflowTriggersForSandboxRefresh{
    
    global void ActivateWorkflowTriggers(){
        
        Workflow_Triggers__c workflowTriggersObj = Workflow_Triggers__c.getOrgDefaults();
        workflowTriggersObj.Contact_Update_Owner_Assignment__c = true;
        
        upsert workflowTriggersObj;
    }
    
    global void DeactiveWorkflowTriggers(){
        
         Workflow_Triggers__c workflowTriggersObj = Workflow_Triggers__c.getOrgDefaults();
         
         workflowTriggersObj.Case_Forward_Case_to_External_Unit__c = false;
         workflowTriggersObj.Case_Send_GetFeedback_survey__c = false;
         workflowTriggersObj.Contact_Bad_Mailing_Address_Reset__c = false;
         workflowTriggersObj.Contact_Pin_Lockout_Timeout__c = false;
         workflowTriggersObj.Contact_Sync_to_Silverpop__c = false;
         workflowTriggersObj.Contact_Update_ASU_Gmail__c = false;
         workflowTriggersObj.Contact_Update_Communication_If_Decease__c = false;
         workflowTriggersObj.Contact_Update_Email_on_Contact_Change__c = false;
         workflowTriggersObj.Contact_Update_Owner_Assignment__c = false;
         workflowTriggersObj.Contact_Update_SP_Sync_for_edX_Opt_in__c = false;
         workflowTriggersObj.Task_GRES_Assign_Angela_Harguess__c = false;
         workflowTriggersObj.Task_GRLA_Assign_Alicia_Richardson__c = false;
         workflowTriggersObj.Task_GRLA_Assign_Andra_Williams__c = false;
         workflowTriggersObj.Task_GRLA_Assign_David_Nutt__c = false;
         workflowTriggersObj.Task_GRLA_Assign_Gina_Perez__c = false;
         workflowTriggersObj.Task_GRLA_Assign_Heather_Freireich__c = false;
         workflowTriggersObj.Task_GRLA_Assign_Ixchell_Paape__c = false;
         workflowTriggersObj.Task_GRLA_Assign_Kira_Assad__c = false;
         workflowTriggersObj.Task_GRLA_Assign_Leah_Legg__c = false;
         workflowTriggersObj.Task_GRLA_Assign_Nancy_Winn__c = false;
         workflowTriggersObj.Task_GRLA_Assign_Paul_Morris__c = false;
         workflowTriggersObj.Task_GRLA_Assign_Rebecca_Dial__c = false;
         workflowTriggersObj.Task_GRLA_Assign_Roxanne_Shand__c = false;
         workflowTriggersObj.Task_GRLA_Assign_Wendi_Simonson__c = false;
         workflowTriggersObj.Task_GRND_Assign_Mike__c = false;
         workflowTriggersObj.Task_GRND_Assign_Mike_Mobley__c = false;
         workflowTriggersObj.Task_GRNH_Assign_Anita_Youmara__c = false;
         workflowTriggersObj.Task_GRNH_Assign_Jessie__c = false;
         workflowTriggersObj.Task_GRNH_Assign_Lauren_Madjidi__c = false;
         workflowTriggersObj.Task_GRNH_Assign_Susan__c = false;
         workflowTriggersObj.Task_GRSU_Assign_Jennifer_G__c = false;
         workflowTriggersObj.Task_GRSU_Assign_Katie__c = false;
         workflowTriggersObj.Task_GRTE_Assign_Amy__c = false;
         workflowTriggersObj.Task_GRTE_Assign_Donna__c = false;
         workflowTriggersObj.Task_GRTE_Assign_EDD_PhD__c = false;
         workflowTriggersObj.Task_GRTE_Complete_ASU_Managed__c = false;
         workflowTriggersObj.Task_GRTS_Assign_Grant_Griffin__c = false;
         
         
         upsert workflowTriggersObj;
    }
}