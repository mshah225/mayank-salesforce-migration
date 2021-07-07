public class LeadsOperationsForSandBoxRefresh implements Database.Batchable<sObject> {
    public String query;

    public LeadsOperationsForSandBoxRefresh() {
        query =
            'SELECT Id, Name, Status, Email, ' +
            'Recruiting_Email__c, Secondary_Email__c, Date_of_Birth__c, ' +
            'silverpop__Silverpop_RecipientID__c ' +
            'FROM Lead';
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Lead> scope) {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        String orgType = SandboxRefreshService.setOrgTypeFromUrl(baseUrl);

        List<Lead> leadsToUpdated = deleteConvertedLeads(scope);

        List<Lead> updateLeads = new List<Lead>();

        for (Lead leadToScrub : leadsToUpdated) {
            if (!String.isEmpty(orgType)) {
                List<String> fieldList = new List<String>{ 'Email', 'Recruiting_Email__c', 'Secondary_Email__c' };

                leadToScrub = (Lead) SandboxRefreshService.scrambleEmailField(leadToScrub, fieldList);
            }

            if (leadToScrub.Date_of_Birth__c != null) {
                leadToScrub.Date_of_Birth__c = SandboxRefreshService.scrambleBirthday(leadToScrub.Date_of_Birth__c);
            }

            leadToScrub = (Lead) SandboxRefreshService.removeSilverPopId(leadToScrub);
            updateLeads.add(leadToScrub);
        }

        if (!updateLeads.isEmpty()) {
            update updateLeads;
        }
    }

    private List<Lead> deleteConvertedLeads(List<Lead> leadsToUpdateOrDelete) {
        List<Lead> leadsToDelete = new List<Lead>();
        List<Lead> leadsToUpdate = new List<Lead>();
        for (Lead leadToCheck : leadsToUpdateOrDelete) {
            if (isConverted(leadToCheck)) {
                leadsToDelete.add(leadToCheck);
            } else {
                leadsToUpdate.add(leadToCheck);
            }
        }

        if (!leadsToDelete.isEmpty()) {
            delete leadsToDelete;
        }

        return leadsToUpdate;
    }

    private boolean isConverted(Lead leadToCheck) {
        return (leadToCheck.Status == 'Closed - Converted');
    }

    public void finish(Database.BatchableContext BC) {
    }
}
