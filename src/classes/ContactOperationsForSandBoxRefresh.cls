public class ContactOperationsForSandBoxRefresh implements Database.Batchable<sObject> {
    
	public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, email, Birthdate, ASU_Email__c, Corporate_Relations_Email__c, ' 
                        + 'EPO_Email__c, Last_Case_Email_Used__c, Lead_Email__c, Lead_Secondary_Email__c, ' 
                        + 'Parent_Email__c, Personal_Email__c, silverpop__Silverpop_RecipientID__c' 
                        + 'FROM Contact';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Contact> contactsToUpdate = new List<Contact>();
        String orgType = SandboxRefreshService.setOrgTypeFromUrl(baseUrl);
        
        for (Contact contactToScrub : scope) {
            
            if (!String.isEmpty(orgType)) {
                List<String> fieldList = new List<String> {
                    'email', 'Corporate_Relations_Email__c', 'EPO_Email__c', 'ASU_Email__c',
                    'Last_Case_Email_Used__c', 'Lead_Email__c', 'Lead_Secondary_Email__c',
                    'Parent_Email__c', 'Personal_Email__c'
                };
                
                contactToScrub = SandboxRefreshService.scrambleEmailField(contactToScrub, fieldList);
            }
             
            if (contactToScrub.Birthdate != null) {
                contactToScrub.Birthdate = scrambleBirthday(contactToScrub.Birthdate);
            }
            
            removeSilverPopId(contactToScrub);
            
            contactsToUpdate.add(contactToScrub);
        }
        
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    } 
    
    private Date scrambleBirthday(Date originalBirthday) {
        Integer intRandom = Math.round(Math.random()*1000);
        intRandom = Math.mod(intRandom, 60) - 30;
        return originalBirthday.addDays(intRandom);
    }
    
    private void removeSilverPopId(Contact contactToEdit) {
        contactToEdit.silverpop__Silverpop_RecipientID__c = '';
    }
    
    public void finish(Database.BatchableContext BC) { }
}