public class ContactOperationsForSandBoxRefresh implements Database.Batchable<sObject> {
    public String query;

    public ContactOperationsForSandBoxRefresh() {
        query =
            'SELECT Id, Name, email, Birthdate, ASU_Email__c, Corporate_Relations_Email__c, ' +
            'EPO_Email__c, Last_Case_Email_Used__c, Lead_Email__c, Lead_Secondary_Email__c, ' +
            'Parent_Email__c, Personal_Email__c, silverpop__Silverpop_RecipientID__c ' +
            'FROM Contact';
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Contact> contactsToUpdate = new List<Contact>();
        String orgType = SandboxRefreshService.setOrgTypeFromUrl(baseUrl);

        for (Contact contactToScrub : scope) {
            if (!String.isEmpty(orgType)) {
                List<String> fieldList = new List<String>{
                    'email',
                    'Corporate_Relations_Email__c',
                    'EPO_Email__c',
                    'ASU_Email__c',
                    'Last_Case_Email_Used__c',
                    'Lead_Email__c',
                    'Lead_Secondary_Email__c',
                    'Parent_Email__c',
                    'Personal_Email__c'
                };

                contactToScrub = (Contact) SandboxRefreshService.scrambleEmailField(contactToScrub, fieldList);
            }

            if (contactToScrub.Birthdate != null) {
                contactToScrub.Birthdate = SandboxRefreshService.scrambleBirthday(contactToScrub.Birthdate);
            }

            contactToScrub = (Contact) SandboxRefreshService.removeSilverPopId(contactToScrub);

            contactsToUpdate.add(contactToScrub);
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }

    public void finish(Database.BatchableContext BC) {
    }
}
