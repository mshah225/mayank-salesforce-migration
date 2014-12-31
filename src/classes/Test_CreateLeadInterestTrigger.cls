@isTest(SeeAllData=true)
private class Test_CreateLeadInterestTrigger {
    
        
        
      static testMethod void myUnitTest() {
        
        Task tk=new Task();
      
        tk.OwnerId=[select id from user where Profile.Name='System Administrator' And isactive=true limit 1 ].id;
        //tk.OwnerId= '005d00000024CmfAAE';
        //System.debug('owner id: '+tk.OwnerId);
        tk.Subject='Test';
        tk.whoid=[select id from Lead Limit 1 ].id;
        //'00QJ0000005orka';
        tk.Type='Web Form';
        if (Schema.Sobjecttype.Task.getRecordTypeInfosByName().get('Admin Task Layout') != NULL)
            tk.RecordTypeId=Schema.Sobjecttype.Task.getRecordTypeInfosByName().get('Admin Task Layout').getRecordTypeId();
        //System.debug('RecordTypeInfo: '+Schema.Sobjecttype.Task.getRecordTypeInfosByName().get('Admin Task Layout').getRecordTypeId());
        //System.debug('RecordTypeId: '+tk.RecordTypeId);
        //tk.RecordTypeId= '012d0000000wr5AAAQ' ;
        tk.Enrollment_Term__c='2014 Summer';
        tk.Plan_Code__c='FAMHISTMA';
        tk.College__c='GRHI';
        insert tk;
        
      }

static testMethod void myUnitTest2() {
        
        Task tk=new Task();
      
         //tk.OwnerId= '005d00000024CmfAAE';
       tk.OwnerId=[select id from user where Profile.Name='System Administrator'  And isactive=true limit 1].id;
        tk.Subject='Test';
        tk.whoid=[select id from Contact Limit 1 ].id;
        //'00QJ0000005orka';
        tk.Type='Web Form';
        if (Schema.Sobjecttype.Task.getRecordTypeInfosByName().get('Admin Task Layout') != NULL)
         tk.RecordTypeId=Schema.Sobjecttype.Task.getRecordTypeInfosByName().get('Admin Task Layout').getRecordTypeId();
        //tk.RecordTypeId= '012d0000000wr5AAAQ' ;
        tk.Enrollment_Term__c='2014 Summer';
        tk.Plan_Code__c='FAMHISTMA';
        tk.College__c='GRHI';
        insert tk;
        
      }


}