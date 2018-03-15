global class ContactOperationsForSandBoxRefresh implements Database.Batchable<sObject> {
    global String baseUrl  = '';
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, email, Birthdate, ASU_Email__c, Corporate_Relations_Email__c, EPO_Email__c, Last_Case_Email_Used__c, Lead_Email__c, Lead_Secondary_Email__c, Parent_Email__c, Personal_Email__c, silverpop__Silverpop_RecipientID__c FROM Contact';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        
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
        for (Contact contactToScrub : scope) {
            
             if (orgType == 'DEV') {
             
                if (String.isNotBlank(contactToScrub.email) && (contactToScrub.Email.right(4) != '.dev')) {
                    contactToScrub.email = contactToScrub.email + '.dev';
                }
                
                if (String.isNotBlank(contactToScrub.Corporate_Relations_Email__c) && (contactToScrub.Corporate_Relations_Email__c.right(4) != '.dev')) {
                    contactToScrub.Corporate_Relations_Email__c = contactToScrub.Corporate_Relations_Email__c + '.dev';
                }
                
                if (String.isNotBlank(contactToScrub.EPO_Email__c) && (contactToScrub.EPO_Email__c.right(4) != '.dev')) {
                    contactToScrub.EPO_Email__c = contactToScrub.EPO_Email__c + '.dev';
                }
                
                
                if (String.isNotBlank(contactToScrub.ASU_Email__c) && (contactToScrub.ASU_Email__c.right(4) != '.dev')) {
                    contactToScrub.ASU_Email__c = contactToScrub.ASU_Email__c + '.dev';
                }
                
                if (String.isNotBlank(contactToScrub.Last_Case_Email_Used__c) && (contactToScrub.Last_Case_Email_Used__c.right(4) != '.dev')) {
                    contactToScrub.Last_Case_Email_Used__c = contactToScrub.Last_Case_Email_Used__c + '.dev';
                }
                
                if (String.isNotBlank(contactToScrub.Lead_Email__c) && (contactToScrub.Lead_Email__c.right(4) != '.dev')) {
                    contactToScrub.Lead_Email__c = contactToScrub.Lead_Email__c + '.dev';
                }
                
                
                if (String.isNotBlank(contactToScrub.Lead_Secondary_Email__c) && (contactToScrub.Lead_Secondary_Email__c.right(4) != '.dev')) {
                    contactToScrub.Lead_Secondary_Email__c = contactToScrub.Lead_Secondary_Email__c + '.dev';
                }
                
                
                if (String.isNotBlank(contactToScrub.Parent_Email__c) && (contactToScrub.Parent_Email__c.right(4) != '.dev')) {
                    contactToScrub.Parent_Email__c = contactToScrub.Parent_Email__c + '.dev';
                }
                
                
                if (String.isNotBlank(contactToScrub.Personal_Email__c) && (contactToScrub.Personal_Email__c.right(4) != '.dev')) {
                    contactToScrub.Personal_Email__c = contactToScrub.Personal_Email__c + '.dev';
                }
             }
             
             if (orgType == 'UAT') {
                //Change valid Contact Email address
                if (String.isNotBlank(contactToScrub.email) && (contactToScrub.Email.right(4) != '.uat')) {
                    contactToScrub.email = contactToScrub.email + '.uat';
                }
                
                if (String.isNotBlank(contactToScrub.Corporate_Relations_Email__c) && (contactToScrub.Corporate_Relations_Email__c.right(4) != '.uat')) {
                    contactToScrub.Corporate_Relations_Email__c = contactToScrub.Corporate_Relations_Email__c + '.uat';
                }
                
                if (String.isNotBlank(contactToScrub.EPO_Email__c) && (contactToScrub.EPO_Email__c.right(4) != '.uat')) {
                    contactToScrub.EPO_Email__c = contactToScrub.EPO_Email__c + '.uat';
                }
                
                
                if (String.isNotBlank(contactToScrub.ASU_Email__c) && (contactToScrub.ASU_Email__c.right(4) != '.uat')) {
                    contactToScrub.ASU_Email__c = contactToScrub.ASU_Email__c + '.uat';
                }
                
                if (String.isNotBlank(contactToScrub.Last_Case_Email_Used__c) && (contactToScrub.Last_Case_Email_Used__c.right(4) != '.uat')) {
                    contactToScrub.Last_Case_Email_Used__c = contactToScrub.Last_Case_Email_Used__c + '.uat';
                }
                
                if (String.isNotBlank(contactToScrub.Lead_Email__c) && (contactToScrub.Lead_Email__c.right(4) != '.uat')) {
                    contactToScrub.Lead_Email__c = contactToScrub.Lead_Email__c + '.uat';
                }
                
                
                if (String.isNotBlank(contactToScrub.Lead_Secondary_Email__c) && (contactToScrub.Lead_Secondary_Email__c.right(4) != '.uat')) {
                    contactToScrub.Lead_Secondary_Email__c = contactToScrub.Lead_Secondary_Email__c + '.uat';
                }
                
                
                if (String.isNotBlank(contactToScrub.Parent_Email__c) && (contactToScrub.Parent_Email__c.right(4) != '.uat')) {
                    contactToScrub.Parent_Email__c = contactToScrub.Parent_Email__c + '.uat';
                }
                
                
                if (String.isNotBlank(contactToScrub.Personal_Email__c) && (contactToScrub.Personal_Email__c.right(4) != '.uat')) {
                    contactToScrub.Personal_Email__c = contactToScrub.Personal_Email__c + '.uat';
                }
             }
             
             if (orgType == 'QA') {
                //Change valid Contact Email address
                if (String.isNotBlank(contactToScrub.email) && (contactToScrub.Email.right(4) != '.qa')) {
                    contactToScrub.email = contactToScrub.email + '.qa';
                }
                
                if (String.isNotBlank(contactToScrub.Corporate_Relations_Email__c) && (contactToScrub.Corporate_Relations_Email__c.right(4) != '.qa')) {
                    contactToScrub.Corporate_Relations_Email__c = contactToScrub.Corporate_Relations_Email__c + '.qa';
                }
                
                if (String.isNotBlank(contactToScrub.EPO_Email__c) && (contactToScrub.EPO_Email__c.right(4) != '.qa')) {
                    contactToScrub.EPO_Email__c = contactToScrub.EPO_Email__c + '.qa';
                }
                
                
                if (String.isNotBlank(contactToScrub.ASU_Email__c) && (contactToScrub.ASU_Email__c.right(4) != '.qa')) {
                    contactToScrub.ASU_Email__c = contactToScrub.ASU_Email__c + '.qa';
                }
                
                if (String.isNotBlank(contactToScrub.Last_Case_Email_Used__c) && (contactToScrub.Last_Case_Email_Used__c.right(4) != '.qa')) {
                    contactToScrub.Last_Case_Email_Used__c = contactToScrub.Last_Case_Email_Used__c + '.qa';
                }
                
                if (String.isNotBlank(contactToScrub.Lead_Email__c) && (contactToScrub.Lead_Email__c.right(4) != '.qa')) {
                    contactToScrub.Lead_Email__c = contactToScrub.Lead_Email__c + '.qa';
                }
                
                
                if (String.isNotBlank(contactToScrub.Lead_Secondary_Email__c) && (contactToScrub.Lead_Secondary_Email__c.right(4) != '.qa')) {
                    contactToScrub.Lead_Secondary_Email__c = contactToScrub.Lead_Secondary_Email__c + '.qa';
                }
                
                
                if (String.isNotBlank(contactToScrub.Parent_Email__c) && (contactToScrub.Parent_Email__c.right(4) != '.qa')) {
                    contactToScrub.Parent_Email__c = contactToScrub.Parent_Email__c + '.qa';
                }
                
                
                if (String.isNotBlank(contactToScrub.Personal_Email__c) && (contactToScrub.Personal_Email__c.right(4) != '.qa')) {
                    contactToScrub.Personal_Email__c = contactToScrub.Personal_Email__c + '.qa';
                }
             }
            
            if (contactToScrub.Birthdate != null) {
                Integer intRandom = Math.round(Math.random()*1000);
                intRandom = Math.mod(intRandom, 60) - 30;
                Date birthDate = contactToScrub.Birthdate;
                contactToScrub.Birthdate = birthDate.addDays(intRandom);
            }
            
            contactToScrub.silverpop__Silverpop_RecipientID__c = '';
            contactToBeUpdate.add(contactToScrub);
        }
        
        if (!contactToBeUpdate.isEmpty()) {
            update contactToBeUpdate;
        }
    } 
    
    global void finish(Database.BatchableContext BC) { }
}