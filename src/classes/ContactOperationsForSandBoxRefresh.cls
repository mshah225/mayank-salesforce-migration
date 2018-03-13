global class ContactOperationsForSandBoxRefresh implements Database.Batchable<sObject> {
    global String baseUrl  ='';
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, email, Birthdate, ASU_Email__c, Corporate_Relations_Email__c, EPO_Email__c, Last_Case_Email_Used__c, Lead_Email__c, Lead_Secondary_Email__c, Parent_Email__c, Personal_Email__c, silverpop__Silverpop_RecipientID__c FROM Contact';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        
        //Update Contacts with new Email and Birthdate.
        List<Contact> contactToBeUpdate = new List<Contact>();
        if (!Test.isRunningTest()) {
            baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        }
    
        String orgType = '';
        if (baseUrl.containsIgnoreCase('DEV')) {
            orgType = 'DEV';
        } else if (baseUrl.containsIgnoreCase('UAT')) {
            orgType = 'UAT';
        } else if (baseUrl.containsIgnoreCase('QA')){
            orgType = 'QA';
        }
        for (Contact con: scope) {
            
             if (orgType == 'DEV') {
                //Change valid Contact Email address
                if(String.isNotBlank(con.email) && (con.Email.right(4) != '.dev')){
                    con.email = con.email+'.dev';
                }
                
                if (String.isNotBlank(con.Corporate_Relations_Email__c) && (con.Corporate_Relations_Email__c.right(4) != '.dev')) {
                    con.Corporate_Relations_Email__c = con.Corporate_Relations_Email__c+'.dev';
                }
                
                if (String.isNotBlank(con.EPO_Email__c) && (con.EPO_Email__c.right(4) != '.dev')) {
                    con.EPO_Email__c = con.EPO_Email__c+'.dev';
                }
                
                
                if (String.isNotBlank(con.ASU_Email__c) && (con.ASU_Email__c.right(4) != '.dev')) {
                    con.ASU_Email__c = con.ASU_Email__c+'.dev';
                }
                
                if (String.isNotBlank(con.Last_Case_Email_Used__c) && (con.Last_Case_Email_Used__c.right(4) != '.dev')) {
                    con.Last_Case_Email_Used__c = con.Last_Case_Email_Used__c+'.dev';
                }
                
                if (String.isNotBlank(con.Lead_Email__c) && (con.Lead_Email__c.right(4) != '.dev')) {
                    con.Lead_Email__c = con.Lead_Email__c+'.dev';
                }
                
                
                if (String.isNotBlank(con.Lead_Secondary_Email__c) && (con.Lead_Secondary_Email__c.right(4) != '.dev')) {
                    con.Lead_Secondary_Email__c = con.Lead_Secondary_Email__c+'.dev';
                }
                
                
                if (String.isNotBlank(con.Parent_Email__c) && (con.Parent_Email__c.right(4) != '.dev')) {
                    con.Parent_Email__c = con.Parent_Email__c+'.dev';
                }
                
                
                if (String.isNotBlank(con.Personal_Email__c) && (con.Personal_Email__c.right(4) != '.dev')) {
                    con.Personal_Email__c = con.Personal_Email__c+'.dev';
                }
             }
             
             if (orgType == 'UAT') {
                //Change valid Contact Email address
                if (String.isNotBlank(con.email) && (con.Email.right(4) != '.uat')) {
                    con.email = con.email+'.uat';
                }
                
                if (String.isNotBlank(con.Corporate_Relations_Email__c) && (con.Corporate_Relations_Email__c.right(4) != '.uat')) {
                    con.Corporate_Relations_Email__c = con.Corporate_Relations_Email__c+'.uat';
                }
                
                if (String.isNotBlank(con.EPO_Email__c) && (con.EPO_Email__c.right(4) != '.uat')) {
                    con.EPO_Email__c = con.EPO_Email__c+'.uat';
                }
                
                
                if (String.isNotBlank(con.ASU_Email__c) && (con.ASU_Email__c.right(4) != '.uat')) {
                    con.ASU_Email__c = con.ASU_Email__c+'.uat';
                }
                
                if (String.isNotBlank(con.Last_Case_Email_Used__c) && (con.Last_Case_Email_Used__c.right(4) != '.uat')) {
                    con.Last_Case_Email_Used__c = con.Last_Case_Email_Used__c+'.uat';
                }
                
                if (String.isNotBlank(con.Lead_Email__c) && (con.Lead_Email__c.right(4) != '.uat')) {
                    con.Lead_Email__c = con.Lead_Email__c+'.uat';
                }
                
                
                if (String.isNotBlank(con.Lead_Secondary_Email__c) && (con.Lead_Secondary_Email__c.right(4) != '.uat')) {
                    con.Lead_Secondary_Email__c = con.Lead_Secondary_Email__c+'.uat';
                }
                
                
                if (String.isNotBlank(con.Parent_Email__c) && (con.Parent_Email__c.right(4) != '.uat')) {
                    con.Parent_Email__c = con.Parent_Email__c+'.uat';
                }
                
                
                if (String.isNotBlank(con.Personal_Email__c) && (con.Personal_Email__c.right(4) != '.uat')) {
                    con.Personal_Email__c = con.Personal_Email__c+'.uat';
                }
             }
             
             if (orgType == 'QA') {
                //Change valid Contact Email address
                if (String.isNotBlank(con.email) && (con.Email.right(4) != '.qa')) {
                    con.email = con.email+'.qa';
                }
                
                if (String.isNotBlank(con.Corporate_Relations_Email__c) && (con.Corporate_Relations_Email__c.right(4) != '.qa')) {
                    con.Corporate_Relations_Email__c = con.Corporate_Relations_Email__c+'.qa';
                }
                
                if (String.isNotBlank(con.EPO_Email__c) && (con.EPO_Email__c.right(4) != '.qa')) {
                    con.EPO_Email__c = con.EPO_Email__c+'.qa';
                }
                
                
                if (String.isNotBlank(con.ASU_Email__c) && (con.ASU_Email__c.right(4) != '.qa')) {
                    con.ASU_Email__c = con.ASU_Email__c+'.qa';
                }
                
                if (String.isNotBlank(con.Last_Case_Email_Used__c) && (con.Last_Case_Email_Used__c.right(4) != '.qa')) {
                    con.Last_Case_Email_Used__c = con.Last_Case_Email_Used__c+'.qa';
                }
                
                if (String.isNotBlank(con.Lead_Email__c) && (con.Lead_Email__c.right(4) != '.qa')) {
                    con.Lead_Email__c = con.Lead_Email__c+'.qa';
                }
                
                
                if (String.isNotBlank(con.Lead_Secondary_Email__c) && (con.Lead_Secondary_Email__c.right(4) != '.qa')) {
                    con.Lead_Secondary_Email__c = con.Lead_Secondary_Email__c+'.qa';
                }
                
                
                if (String.isNotBlank(con.Parent_Email__c) && (con.Parent_Email__c.right(4) != '.qa')) {
                    con.Parent_Email__c = con.Parent_Email__c+'.qa';
                }
                
                
                if (String.isNotBlank(con.Personal_Email__c) && (con.Personal_Email__c.right(4) != '.qa')) {
                    con.Personal_Email__c = con.Personal_Email__c+'.qa';
                }
             }
            
            //Add 30 days to change real birthdate of contact
            if (con.Birthdate != null) {
                Integer intRandom = Math.round(Math.random()*1000);
                intRandom = Math.mod(intRandom, 60) - 30;
                Date birthDate = con.Birthdate;
                con.Birthdate = birthDate.addDays(intRandom);
            }
            
            
            //Clean up of silverpop_Silverpop_RecipientID_c from Contact
            con.silverpop__Silverpop_RecipientID__c = '';
            contactToBeUpdate.add(con);
        }
        
        if (!contactToBeUpdate.isEmpty()) {
            update contactToBeUpdate;
        }
    } 
    
    global void finish(Database.BatchableContext BC){ }
}