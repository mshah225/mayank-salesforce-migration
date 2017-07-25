/*****************************************
* File: apiSSC_CoachStudentsController
* Author: James Galindo
* Description: Custom api controller for coaches/students
* Last Modified By: James Galindo - Added Mobile_Phone__c to the SOQL for Pitch app.
******************************************/
@RestResource(urlMapping='/SuccessCoachStudents')
global with sharing class apiSSC_CoachStudentsController {

  @HttpGet  
  global static List<Success_Student__c> getStudents() {
     String coachId = RestContext.request.params.get('coachId');
     String coachResourceRecordTypeId;
     List<RecordType> rectype = [SELECT Id FROM RecordType WHERE DeveloperName = 'Coach' AND SobjectType = 'Success_Resource__c'];
     if(rectype.size()>0)coachResourceRecordTypeId=rectype[0].Id;
     List<Success_Student__c> studentList = new List<Success_Student__c>();
     if(coachId!=null)
     {
         List<Success_Resource__c> coaches = new List<Success_Resource__c>();
         coaches = [SELECT Id, Name, Resource__r.Name, 
                 Resource__r.Email, Resource__r.Phone, Resource__r.Title, 
                 Resource__r.TimeZoneSidKey, ASURiteID__c,
                 AgentID__c,RecordTypeId
                 FROM Success_Resource__c 
                 WHERE isActive__c = true AND RecordTypeId =: coachResourceRecordTypeId
                 ORDER BY ASURiteID__c ASC];
         if(coaches.size()>0)
         {

             studentList = [SELECT Id, ASURiteID__c, EMPLID__c, Name, Student__r.Name,Student__r.Email, Mobile_Phone__c, Student__r.Gender__c
                             FROM Success_Student__c 
                             WHERE Success_Resource__r.Resource__r.Alias =: coachId];
         }
   
     }
     return studentList;
  }
}
