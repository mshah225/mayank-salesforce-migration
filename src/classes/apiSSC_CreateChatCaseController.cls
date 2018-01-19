@RestResource(urlMapping='/CreateChatCase')
global with sharing class apiSSC_CreateChatCaseController {

  @HttpPost
  global static String createChatCase() {
     String studentId = RestContext.request.params.get('studentId');
     String coachId = RestContext.request.params.get('coachId');
     String description = RestContext.request.params.get('description');
     String commDetails = RestContext.request.params.get('commDetails');
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
             // map to store Case Classification name vs Id
            // related to Functional Group 'ASU Coach Outreach' and
            // Category records with 'ASU Coach Outreach' as parent
            map<String, Id> mapCCNameToId = new map<String, Id>();
            for (Case_Classification__c caseClass : [SELECT Id, Name
                                                     FROM Case_Classification__c
                                                     WHERE Active__c = true
                                                     AND ((RecordType.Name = 'Functional Group' AND Name = 'ASU Coach Outreach')
                                                     OR (RecordType.Name = 'Category' AND Parent__r.Name = 'ASU Coach Outreach'))]
                ) {
                mapCCNameToId.put(caseClass.Name, caseClass.Id);
            }
             //get coach
             List<Success_Resource__c> coach = new List<Success_Resource__c>();
             coach = [SELECT Id, Resource__c
                     FROM Success_Resource__c
                     WHERE ASURiteID__c =: coachId LIMIT 1];
             if(coach.size()>0)
             {
                 Case newCase = new Case();
                 newCase.RecordTypeId = coachRecordTypeId;
                 newCase.CC_Functional_Group__c = (mapCCNameToId.containsKey('ASU Coach Outreach')) ? mapCCNameToId.get('ASU Coach Outreach') : null;//'ASU Coach Outreach';
                 newCase.CC_Category__c = (mapCCNameToId.containsKey('Ad Hoc')) ? mapCCNameToId.get('Ad Hoc') : null;//'Ad Hoc Case';
                 newCase.Type = 'Coach Initiated';
                 newCase.Subject = 'Case created via Chat';
                 newCase.Description = description!=null?description:'Case from Chat';

                 if (commDetails!=null && commDetails.length()>1){
                      newCase.Description+='\n\n'+EncodingUtil.urlDecode(commDetails,'UTF-8').unescapeJava();
                 }

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
