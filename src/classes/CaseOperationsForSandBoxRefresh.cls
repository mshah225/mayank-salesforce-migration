public class CaseOperationsForSandBoxRefresh implements Database.Batchable<sObject> {  

	public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Case';
        return Database.getQueryLocator(query); 
    }

    public void execute(Database.BatchableContext BC, List<Case> scope) {
        deleteAllDevOrQACases(scope);
    }  
    
    private void deleteAllDevOrQACases(List<Case> scope) {
        String baseUrl = '';
        
	    if (!Test.isRunningTest()) {
	        baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
	    } else {
	        baseUrl = 'https://asu--roger.QA.cs53.my.salesforce.com';
	    }
	    
	    Boolean caseShouldBeDeleted = orgIsQAOrDev(baseUrl);

        if (caseShouldBeDeleted) {
            delete scope;
        }
    }
    
    private Boolean orgIsQAOrDev(String url) {
        Boolean isDevOrQA = false;
        if (url.containsIgnoreCase('DEV') || url.containsIgnoreCase('UAT')) {
            isDevOrQA = true;
        }
        
        return isDevOrQA;
    }
    
    
    public void finish(Database.BatchableContext BC) { }
}