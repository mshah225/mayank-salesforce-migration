global class CaseOperationsForSandBoxRefresh implements Database.Batchable<sObject>
{
	global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name FROM Case';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope){
        
        // Find out Org Type from Base URL.
	    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
	    String orgType = '';
        System.debug('baseUrl =' + baseUrl);
        
        if(baseUrl.containsIgnoreCase('DEV')){
            orgType = 'DEV';
        } else if(baseUrl.containsIgnoreCase('QA')) {
            orgType = 'QA';
        } else if(baseUrl.containsIgnoreCase('UAT')) {
            orgType = 'UAT';
        }
        
        //Delete All Case Rows
        
        if(orgType== 'DEV' || orgType == 'QA' ){
            Delete scope;
        }
    }  
    global void finish(Database.BatchableContext BC){
        
        BomgarSessionOperationsForSandBoxRefresh b=new BomgarSessionOperationsForSandBoxRefresh();
        Database.executeBatch(b);
    }
}