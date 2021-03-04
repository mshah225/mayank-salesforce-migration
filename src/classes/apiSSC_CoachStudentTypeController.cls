@RestResource(urlMapping='/SuccessCoachStudentType')
global with sharing class apiSSC_CoachStudentTypeController {
    @HttpGet
    global static sObject getStudents() {
        String ASURite = RestContext.request.params.get('ASURite');
        if (ASURite != null) {
            //Check if asurite is coach
            List<Success_Resource__c> coachList = new List<Success_Resource__c>();
            //Coach RT
            String coachRecordTypeId = '';
            List<RecordType> rectype = [
                SELECT Id
                FROM RecordType
                WHERE DeveloperName = :'Coach' AND SobjectType = 'Success_Resource__c'
            ];
            if (rectype.size() > 0)
                coachRecordTypeId = rectype[0].Id;
            coachList = [
                SELECT
                    Id,
                    Name,
                    Resource__r.Name,
                    Resource__r.Email,
                    Resource__r.Phone,
                    Resource__r.Title,
                    Resource__r.TimeZoneSidKey,
                    ASURiteID__c,
                    AgentID__c
                FROM Success_Resource__c
                WHERE RecordTypeId = :coachRecordTypeId AND ASURiteID__c = :ASURite
                LIMIT 1
            ];
            if (coachList.size() > 0) {
                return coachList[0];
            }
            //Check if asurite is student
            List<Success_Student__c> studentList = new List<Success_Student__c>();
            studentList = [
                SELECT Id, EMPLID__c, Name, Student__r.Name, Student__r.Email
                FROM Success_Student__c
                WHERE ASURiteID__c = :ASURite
                LIMIT 1
            ];
            if (studentList.size() > 0) {
                return studentList[0];
            }
        }
        //asurite not found in success objects
        return null;
    }
}
