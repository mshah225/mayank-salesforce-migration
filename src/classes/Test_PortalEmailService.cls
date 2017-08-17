@isTest
public class Test_PortalEmailService {
    static Id advisorRTID = IDHelper.getRTID('Portal_Email__c', 'Advisor');
    static Id coachRTID = IDHelper.getRTID('Portal_Email__c', 'Coach');
    
    @testSetup
    public static void testSetup() {
        TestDataFactory.makeMeAnAdvisorUser(3, 3, 3);
        
        List<Portal_Email__c> emailsToInsert = new List<Portal_Email__c>();
        List<Case> caseList = [Select Id FROM Case];
        List<Success_Student__c> studentList = [Select Id FROM Success_Student__c];
        
        for(Integer i = 0; i < 10; i++){
            Portal_Email__c tmp = new Portal_Email__c();
            tmp.Additional_Message_Text__c = 'Hello World';
            if(Math.mod(i, 2) == 0){
                tmp.Success_Student__c = studentList[0].Id;
            }
            if(Math.mod(i, 3) == 0){
                tmp.RecordTypeId = coachRTID;
            }
            else{
            	tmp.RecordTypeId = advisorRTID;
            }
            tmp.From_Address__c = 'abc123@test.com';
            tmp.Case__c = caseList[0].Id;
            
            emailsToInsert.add(tmp);
        }
        
        insert emailsToInsert;
        
    }
    
    public static testmethod void testSetFromAddressAdvsior(){
         
        Map<Id, Portal_Email__c> emailsToUpdate = new Map<Id, Portal_Email__c>();
        Test.startTest();
        List<Portal_Email__c> emailList = [Select Primary_Owner_Id__c, Case_Most_Recent_Queue__c, RecordTypeId, From_Address__c, Success_Student__c 
                                           FROM Portal_Email__c
                                           WHERE RecordTypeId =: advisorRTID];
        for(Portal_Email__c pe : emailList){
            emailsToUpdate.put(pe.Id, pe);
        }
        PortalEmailService pes = new PortalEmailService();
        PortalEmailService.setFromAddress(emailsToUpdate);
        emailList = [Select From_Address__c, Primary_Owner_Id__c 
                     FROM Portal_Email__C 
                     WHERE RecordTypeId =: advisorRTID AND Success_Student__c = NULL];
        List<EmailMessage> newMessages = [Select Id FROM EmailMessage];
        System.assertEquals(newMessages.size(), 10);
        Test.stopTest();      
    }
    
    public static testmethod void testSetFromAddressCoach(){
        Map<Id, Portal_Email__c> emailsToUpdate = new Map<Id, Portal_Email__c>();
        Test.startTest();
        List<Portal_Email__c> emailList = [Select Primary_Owner_Id__c, Case_Most_Recent_Queue__c, RecordTypeId, From_Address__c, Success_Student__c 
                                           FROM Portal_Email__c
                                           WHERE RecordTypeId =: coachRTID];
        for(Portal_Email__c pe : emailList){
            emailsToUpdate.put(pe.Id, pe);
        }
        
        PortalEmailService pes = new PortalEmailService();
        PortalEmailService.setFromAddress(emailsToUpdate);
        emailList = [Select From_Address__c, Primary_Owner_Id__c 
                     FROM Portal_Email__C 
                     WHERE RecordTypeId =: coachRTID AND Success_Student__c = NULL];
        List<EmailMessage> newMessages = [Select Id FROM EmailMessage];
        System.assertEquals(newMessages.size(), 10);
        Test.stopTest();
    }
    
    /**
     * Tests Coach Emailing for NULL Input
     */
    public static testmethod void testNullCoach(){
        Test.startTest();
      	  PortalEmailService.enqueueCoach(NULL);
        Test.stopTest();
        
        List<Case> errorList = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];    
        System.assertEquals(1, errorList.size());
        delete errorList;  
    }
    /**
     * Tests Advisor Emailing for NULL Input
     */ 
    public static testmethod void testNullAdvisor(){

        Test.startTest();
      	  PortalEmailService.enqueueAdvisor(NULL);
        Test.stopTest();
        
        List<Case> errorList = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];    
        System.assertEquals(1, errorList.size());
        delete errorList;  
    }
    
}