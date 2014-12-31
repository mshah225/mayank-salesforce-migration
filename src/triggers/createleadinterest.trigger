//Deactivated on 05/01/2014 - hlueck
//May be deleted in the future

trigger createleadinterest on Task (after insert) {
    List <Lead_Interest__c> leadinterest = new List <Lead_Interest__c>();
   
    for (Task tk : Trigger.new) {
        
        
              if (tk.Type == 'Web Form' && Schema.Sobjecttype.Task.getRecordTypeInfosByName().get('Admin Task Layout') != NULL && tk.RecordTypeId==Schema.Sobjecttype.Task.getRecordTypeInfosByName().get('Admin Task Layout').getRecordTypeId() && tk.WhoId!= NULL)  {
        
        Lead_Interest__c LeadInt = new Lead_Interest__c (); //instantiate the object to put values for future record
        
        // and so on so forth untill you map all the fields. 
       
        LeadInt.Primary_Source__c = tk.Task_Source__c; 
        LeadInt.Secondary_Source__c=tk.Task_Source_Subtype__c;
        LeadInt.OwnerId=tk.OwnerId;
        
        if(tk.Whoid!=null){
        if(tk.whoid.getSobjectType().getDescribe().getName()=='Lead')
        {LeadInt.Leads__c=tk.WhoId;
        LeadInt.Type__c='Lead';}
        else
        {LeadInt.Contact__c=tk.WhoId;
        LeadInt.Type__c='Contact';}
        }
        
        list<Term__c> idlistTerm = new List<Term__c>([select id from Term__c where name=:tk.Enrollment_Term__c]);
        
        
        if(idlistTerm.size()>0)
        {
        LeadInt.Term__c = idlistTerm[0].id;
        }
        
        
       list<Plan__c> idlistPlan = new List<Plan__c>([select id from Plan__c where Plan_code__c=:tk.Plan_Code__c]); 
       
       
        if(idlistPlan.size()>0)
        {
            System.debug('=================>'+idlistPlan[0].id);
            LeadInt.Plan__c = idlistPlan[0].id;
        }
       
       list<Program__c> idlistCollege = new List<Program__c>([select id from Program__c where Program_code__c=:tk.College__c]); 
        if(idlistCollege.size()>0)
        {
        LeadInt.College__c = idlistCollege[0].id;
        }
       
        
        leadinterest.add(LeadInt);
        
        }
        
    }
    
    try {
        if (leadinterest.size() >0)
            insert leadinterest; 
    } catch (system.Dmlexception e) {
        system.debug (e);
    }
    
}