@RestResource(urlMapping='/CreateChatCase')
global with sharing class apiSSC_CreateChatCaseController {

  @HttpPost  
  global static String createChatCase() {
     String studentId = RestContext.request.params.get('studentId');
     String coachId = RestContext.request.params.get('coachId');
     String description = RestContext.request.params.get('description');
     String coachRecordTypeId;
     String retVal = '';
     List<RecordType> rectype = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName =: 'ASU_Coach_Outreach'];
     if(rectype.size()>0)coachRecordTypeId=rectype[0].Id;
     if(studentId==null || studentId=='')
     {
        retVal = 'Invalid Student Id';
     }
     else if(coachId==null || coachId=='')
     {
        retVal = 'Invalid Coach Id';
     }
     else
     {
         //get student
         List<Success_Student__c> student = new List<Success_Student__c>();
         student = [SELECT Id, Student__c, Success_Resource__c 
                 FROM Success_Student__c 
                 WHERE Student__r.ASURite_ID__c =: studentId LIMIT 1];
         if(student.size()>0)
         {
             //get coach        
             List<Success_Resource__c> coach = new List<Success_Resource__c>();
             coach = [SELECT Id, Resource__c 
                     FROM Success_Resource__c 
                     WHERE ASURiteID__c =: coachId LIMIT 1];
             if(coach.size()>0)
             {
                 Case newCase = new Case();
                 newCase.RecordTypeId = coachRecordTypeId;
                 newCase.Functional_Group__c = 'ASU Coach Outreach';
                 newCase.Category__c = 'Ad Hoc Case';
                 newCase.Type = 'Coach Initiated';
                 newCase.Subject = 'Case created via Chat';
                 newCase.Description = description!=null?description:'Case from Chat';
                 newCase.Status = 'New';
                 newCase.ContactId = student[0].Student__c;
                 newCase.Origin__c = 'Resource';
                 newCase.Visible_by_Contact__c = FALSE;
                 insert newCase;
   
                 Case result;
                 if(newCase.Id!=null)
                 {
                     result = [Select Id 
                                 FROM Case 
                                 WHERE Id =: newCase.Id];
                     //Now let's assign the Case to the Coach!
                     result.OwnerId = coach[0].Resource__c;
                     update result;
                     retVal = result.Id;
                 }
             }
             else
             {
                retVal = 'Invalid Coach Id';
             }
         }
         else
         {
            retVal = 'Invalid Student Id';
         }
     }
     return retVal;
  }
  
}