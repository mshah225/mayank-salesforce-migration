global class ContactOperationsForSandBoxRefresh implements Database.Batchable<sObject>
{
	global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name, email, Birthdate, silverpop_Silverpop_RecipientID_c FROM Contact';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){
        
        //Update Contacts with new Email and Birthdate.
        List<Contact> contactToBeUpdate = new List<Contact>();
        for(Contact con: scope){
            
            //Change valid Contact Email address
            if(String.isNotBlank(con.email) && (con.Email.right(4) != '.dev')){
                con.email = con.email+'.dev';
            }
            
            if(String.isNotBlank(con.Corporate_Relations_Email__c) && (con.Corporate_Relations_Email__c.right(4) != '.dev')){
                con.Corporate_Relations_Email__c = con.Corporate_Relations_Email__c+'.dev';
            }
            
            if(String.isNotBlank(con.EPO_Email__c) && (con.EPO_Email__c.right(4) != '.dev')){
                con.EPO_Email__c = con.EPO_Email__c+'.dev';
            }
            
            
            if(String.isNotBlank(con.ASU_Email__c) && (con.ASU_Email__c.right(4) != '.dev')){
                con.ASU_Email__c = con.ASU_Email__c+'.dev';
            }
            
            if(String.isNotBlank(con.Last_Case_Email_Used__c) && (con.Last_Case_Email_Used__c.right(4) != '.dev')){
                con.Last_Case_Email_Used__c = con.Last_Case_Email_Used__c+'.dev';
            }
            
            if(String.isNotBlank(con.Lead_Email__c) && (con.Lead_Email__c.right(4) != '.dev')){
                con.Lead_Email__c = con.Lead_Email__c+'.dev';
            }
            
            
            if(String.isNotBlank(con.Lead_Secondary_Email__c) && (con.Lead_Secondary_Email__c.right(4) != '.dev')){
                con.Lead_Secondary_Email__c = con.Lead_Secondary_Email__c+'.dev';
            }
            
            
            if(String.isNotBlank(con.Parent_Email__c) && (con.Parent_Email__c.right(4) != '.dev')){
                con.Parent_Email__c = con.Parent_Email__c+'.dev';
            }
            
            
            if(String.isNotBlank(con.Personal_Email__c) && (con.Personal_Email__c.right(4) != '.dev')){
                con.Personal_Email__c = con.Personal_Email__c+'.dev';
            }
            
            //Add 30 days to change real birthdate of contact
            if(con.Birthdate != null){
                Integer intRandom = Math.round(Math.random()*1000);
                intRandom = Math.mod(intRandom, 60) - 30;
                Date birthDate = con.Birthdate;
                con.Birthdate = birthDate.addDays(intRandom);
            }
            
            
            //Clean up of silverpop_Silverpop_RecipientID_c from Contact
            con.silverpop__Silverpop_RecipientID__c = '';
            contactToBeUpdate.add(con);
        }
        
        if(!contactToBeUpdate.isEmpty()){
            update contactToBeUpdate;
        }
    }  
    global void finish(Database.BatchableContext BC){
        
        
        UserOperationsForSandBoxRefresh b=new UserOperationsForSandBoxRefresh();
        Database.executeBatch(b);
    }
}