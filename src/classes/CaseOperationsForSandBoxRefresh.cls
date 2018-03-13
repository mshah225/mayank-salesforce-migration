global class CaseOperationsForSandBoxRefresh implements Database.Batchable<sObject> {  

    global String baseUrl = '';
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Case';
        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        
        // Find out Org Type from Base URL.
	    if (!Test.isRunningTest()) {
	        baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
	    }
	    else {
	        baseUrl = 'https://asu--roger.QA.cs53.my.salesforce.com';
	    }
	    
	    String orgType = '';
        System.debug('baseUrl =' + baseUrl);
        
        if (baseUrl.containsIgnoreCase('DEV')) {
            orgType = 'DEV';
        } else if (baseUrl.containsIgnoreCase('UAT')) {
            orgType = 'UAT';
        } else if (baseUrl.containsIgnoreCase('QA')) {
            orgType = 'QA';
        }
        
        //Delete All Case Rows
        if (orgType== 'DEV' || orgType == 'QA' ) {
            Delete scope;
        }
    }  
    
    global void finish(Database.BatchableContext BC) { }
}