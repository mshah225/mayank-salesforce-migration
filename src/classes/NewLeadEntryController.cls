public with sharing class NewLeadEntryController {

    private Lead extLead; 
    private Lead_Interest__c leadInterest; 
    private Task leadTask;
    private Boolean showComment; 
    
    public NewLeadEntryController() {
       extLead = new Lead(); 
       leadInterest = new Lead_Interest__c(); 
       leadTask = new Task();
    
       setDefaultValues();
    }
    
    public Lead getExtLead() {
        return extLead;
    }
    
    public void setExtLead(Lead l) {
        extLead = l;
    }
    
    public Lead_Interest__c getLeadInterest() {
        return leadInterest;
    }
    
    public void setLeadInterest(Lead_Interest__c li) {
        leadInterest = li;
    }
    
    public Task getLeadTask() {
        return leadTask;
    }
    
    public void setLeadTask(Task t) {
        leadTask = t;
    }  

    private void setDefaultValues() {
       // Set default values for our new records
       List<User> sfAdminUserList = new List<User>([SELECT Id FROM User Where LastName = 'Admin' AND FirstName = 'Salesforce' AND Profile.Name = 'System Administrator']);
       if (sfAdminUserList.size() > 0) {
        extLead.OwnerId = sfAdminUserList[0].Id;
        leadInterest.OwnerId = sfAdminUserList[0].Id;
       }
       extLead.Company = 'Arizona State University';
       extLead.Status = 'Prospect';
       leadTask.Status = 'Completed';
       leadTask.OwnerId = UserInfo.getUserId();     
    }
    
    public PageReference extSave() {
        return saveAll(false);
    }
    
    public PageReference extSaveAndNew() {
        return saveAll(true);
    }
    
    private List<String> validateEntry() {
        List<String> validationErrors = new List<String>();
        // Check to make sure College/Plan combination actually exists
        if (leadInterest.Plan__c != null && leadInterest.College__c != null) {
            List<Plan__c> matchingPlans = new List<Plan__c>([SELECT Id FROM Plan__c WHERE Id = :leadInterest.Plan__c AND Program__c = :leadInterest.College__c]);
            if (matchingPlans.size() == 0) {
                validationErrors.add('The specfied College & Plan combination is not valid');
            }
        }
        return validationErrors;
    }
    
    private PageReference saveAll(boolean saveAndNew) {
        List<String> validationErrors = new List<String>();
        validationErrors = validateEntry();
        if (validationErrors.size() > 0) {
            for (String s: validationErrors) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, s);
                ApexPages.addMessage(myMsg);
            }
            return ApexPages.currentPage();
        }
        //if (extLead.Enrollment_Term__c != null) {
        //    List<Term__c> terms = new List<Term__c>([SELECT Id FROM Term__c WHERE Name = :extLead.Enrollment_Term__c]);
        //    if (terms.size() > 0) {
        //        leadInterest.Term__c = terms[0].Id;
        //    } 
        //    else {
        //        leadInterest.Term__c = null;
        //    }
        //}
        try {
            insert extLead;
            // Lead should now have an ID, so set the Lead Interest's related Lead reference
            leadInterest.Leads__c = extLead.Id;
            leadInterest.Primary_Source__c = extLead.LeadSource;
            leadInterest.Secondary_Source__c = extLead.Lead_Source_Subtype__c;
            
            insert leadInterest;
            if (leadTask.Description != null) {
                // Set the Task's related Lead reference
                leadTask.WhoId = extLead.Id;
                insert leadTask;
            }
        }
        catch (DMLException e) {
            if (e.getMessage().contains('A lead match has been found')) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'This appears to be a duplicate Lead');
                ApexPages.addMessage(myMsg);
                return ApexPages.currentPage();
            }
        }
        
        if (saveAndNew) {
            // Navigate to a fresh/blank version of this page
            PageReference pgRef = new PageReference('/apex/NewLeadEntry');
            pgRef.setRedirect(true);
            return pgRef;           
        }
        else {
            // Navigate to the page layout for the newly created Lead record
            PageReference pgRef = new PageReference('/' + extLead.Id); 
            pgRef.setRedirect(true);
            return pgRef;           
        }
        
        
        
    }
    
}