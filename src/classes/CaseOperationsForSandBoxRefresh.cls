public class CaseOperationsForSandBoxRefresh implements Database.Batchable<sObject> {  

	public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Case';
        return Database.getQueryLocator(query); 
    }

    public void execute(Database.BatchableContext BC, List<Case> scope) {
        deleteAllDevOrQACases(scope);
    }  
    
    private void deleteAllDevOrQACases(List<Case> scope) {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        String orgType = SandboxRefreshService.setOrgTypeFromUrl(baseUrl);
        
	    Boolean caseShouldBeDeleted = orgIsQAOrDev(orgType);

        if (caseShouldBeDeleted) {
            delete scope;
        }
    }
    
    private Boolean orgIsQAOrDev(String orgType) {
        Boolean isDevOrQA = false;
        if (orgType.containsIgnoreCase('DEV') || orgType.containsIgnoreCase('QA')) {
            isDevOrQA = true;
        }
        
        return isDevOrQA;
    }
    
    
    public void finish(Database.BatchableContext BC) { }
}