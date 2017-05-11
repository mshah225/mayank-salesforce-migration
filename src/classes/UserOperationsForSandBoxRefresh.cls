global class UserOperationsForSandBoxRefresh implements Database.Batchable<sObject>
{
	global Database.QueryLocator start(Database.BatchableContext BC){

	    String query = 'SELECT Id, Name, IsActive,Sandbox_DEV__c,Sandbox_QA__c,Sandbox_UAT__c FROM User WHERE Id != \''+ UserInfo.getUserId() + '\' AND profile.Name !=\'System Administrator\' And isActive=true';
	    return Database.getQueryLocator(query);
	    
    }

    global void execute(Database.BatchableContext BC, List<User> scope){
	    
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
        
        //Inactive non System Admin Users
        List<User> UserToBeUpdate = new List<User>();
        for(User usr: scope){
            
    	    if(orgType == 'DEV'){
    	        if(usr.Sandbox_DEV__c == false){
    	            usr.IsActive = false;
                    UserToBeUpdate.add(usr);
    	        }
    	    } else if(orgType == 'QA'){
    	        
    	        if(usr.Sandbox_QA__c == false){
    	            usr.IsActive = false;
                    UserToBeUpdate.add(usr);
    	        }
    	    } else if(orgType == 'UAT'){
    	        
    	        if(usr.Sandbox_UAT__c == false){
    	            usr.IsActive = false;
                    UserToBeUpdate.add(usr);
    	        }
    	    } else{
                usr.IsActive = false;
                UserToBeUpdate.add(usr);
    	    }
        }
        
        if(!UserToBeUpdate.isEmpty()){
            //update UserToBeUpdate;
            update UserToBeUpdate;
        }
    }  
    global void finish(Database.BatchableContext BC){
        
        CaseOperationsForSandBoxRefresh b=new CaseOperationsForSandBoxRefresh();
        Database.executeBatch(b);
    }
}