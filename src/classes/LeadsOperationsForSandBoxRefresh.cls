global class LeadsOperationsForSandBoxRefresh implements Database.Batchable<sObject> {   
    global String baseUrl  ='';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, Status, Email, Recruiting_Email__c, Secondary_Email__c, Date_of_Birth__c, silverpop__Silverpop_RecipientID__c FROM Lead';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        
        //Deactive all workflows
        //UpdateWorkflowTriggersForSandboxRefresh.DeactiveWorkflowTriggers();
        
        //Delete Converted Leads
        List<Lead> convertedLeadsToBeDelete = new List<Lead>();
        List<Lead> remainingLeads = new List<Lead>();
        for (Lead l: scope) {
            if (l.Status == 'Closed - Converted') {
                convertedLeadsToBeDelete.add(l);   
            } else {
                remainingLeads.add(l);
            }
        }
        
        if (!convertedLeadsToBeDelete.isEmpty()) {
            Delete convertedLeadsToBeDelete;
        }
        
        
        //Updated Leads to 
        List<Lead> updateLeads = new List<Lead>();
        if (!Test.isRunningTest()) {
            baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        }
    
        String orgType = '';
        if (baseUrl.containsIgnoreCase('DEV')) {
            orgType = 'DEV';
        } else if (baseUrl.containsIgnoreCase('UAT')) {
            orgType = 'UAT';
        } else if (baseUrl.containsIgnoreCase('QA')) {
            orgType = 'QA';
        }
        for (Lead l: remainingLeads) {
            
            //Change valid Contact Email address
            if (orgType == 'DEV') {
                if (String.isNotBlank(l.Email) && (l.Email.right(4) != '.dev')) {
                        l.Email = l.email+'.dev';
                }
                
                if (String.isNotBlank(l.Recruiting_Email__c) && (l.Recruiting_Email__c.right(4) != '.dev')) {
                    l.Recruiting_Email__c=l.Recruiting_Email__c+'.dev';
                }
                
                if (String.isNotBlank(l.Secondary_Email__c) && (l.Secondary_Email__c.right(4) != '.dev')) {
                    l.Secondary_Email__c=l.Secondary_Email__c+'.dev';
                }
            }
            
            
            if (orgType == 'QA') {
                    if (String.isNotBlank(l.Email) && (l.Email.right(4) != '.qa')) {
                            l.Email = l.email+'.qa';
                    }
                    
                    if (String.isNotBlank(l.Recruiting_Email__c) && (l.Recruiting_Email__c.right(4) != '.qa')) {
                        l.Recruiting_Email__c=l.Recruiting_Email__c+'.qa';
                    }
                    
                    if (String.isNotBlank(l.Secondary_Email__c) && (l.Secondary_Email__c.right(4) != '.qa')) {
                        l.Secondary_Email__c=l.Secondary_Email__c+'.qa';
                    }
            }
                
            if (orgType == 'UAT') {
                if (String.isNotBlank(l.Email) && (l.Email.right(4) != '.uat')) {
                        l.Email = l.email+'.uat';
                }
                
                if (String.isNotBlank(l.Recruiting_Email__c) && (l.Recruiting_Email__c.right(4) != '.uat')) {
                    l.Recruiting_Email__c=l.Recruiting_Email__c+'.uat';
                }
                
                if (String.isNotBlank(l.Secondary_Email__c) && (l.Secondary_Email__c.right(4) != '.uat')) {
                    l.Secondary_Email__c=l.Secondary_Email__c+'.uat';
                }
            }
            //Add 30 days to change real birthdate of contact
            
            if (l.Date_of_Birth__c != null) {
                Integer intRandom = Math.round(Math.random()*1000);
                intRandom = Math.mod(intRandom, 60) - 30;
                Date birthDate = l.Date_of_Birth__c;
                l.Date_of_Birth__c = birthDate.addDays(intRandom);
            }
            //Clean up of silverpop_Silverpop_RecipientID_c from Contact
            l.silverpop__Silverpop_RecipientID__c = '';
            updateLeads.add(l);
        }
        
        if (!updateLeads.isEmpty()) {
            update updateLeads;
        }
    }  
    global void finish (Database.BatchableContext BC) { }
}