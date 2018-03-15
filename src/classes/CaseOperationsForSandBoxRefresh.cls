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
	    
	    Boolean caseShouldBeDeleted = isDevOrQA(baseUrl);

        if (caseShouldBeDeleted) {
            delete scope;
        }
    }
    
    private String orgIsQAOrDev(String url) {
        Boolean isDevOrQA = false;
        if (url.containsIgnoreCase('DEV') || url.containsIgnoreCase('UAT')) {
            orgType = true;
        }
        
        return isDevOrQA;
    }
    
    
    public void finish(Database.BatchableContext BC) { }
}