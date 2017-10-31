@RestResource(urlMapping='/MyASUCoaches')
global with sharing class apiSSC_MyASUCoachesController {

  @HttpGet  
  global static List<Success_Student__c> getAllCoaches() {
     List<Success_Student__c> students = new List<Success_Student__c>();
     String coachResourceRecordTypeId;
     List<RecordType> rectype = [SELECT Id FROM RecordType WHERE DeveloperName = 'Coach' AND SobjectType = 'Success_Resource__c'];
     if(rectype.size()>0)coachResourceRecordTypeId=rectype[0].Id;
     students = [SELECT Id, ASURiteID__c,EmplId__c,Success_Resource__r.Resource__r.Name,
                 Success_Resource__r.Resource__r.Email, Success_Resource__r.Resource__r.Phone, 
                 Success_Resource__r.Resource__r.Title, Success_Resource__r.Resource__r.TimeZoneSidKey,
                 Success_Resource__r.Resource__r.Alias,Success_Resource__r.Resource__r.EmployeeNumber,
                 Success_Resource__r.AgentID__c
                 FROM Success_Student__c 
                 WHERE Is_Active__c = true 
                 AND Success_Resource__r.RecordTypeId =: coachResourceRecordTypeId
                 ORDER BY ASURiteID__c ASC];

    return students;
  }
}