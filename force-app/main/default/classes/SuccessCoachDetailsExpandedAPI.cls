@RestResource(urlMapping='/MySuccessCoach')
global with sharing class SuccessCoachDetailsExpandedAPI {
    @HttpGet
    global static List<Success_Resource__c> getMyCoach() {
        String studentId = RestContext.request.params.get('studentId');
        List<Success_Resource__c> coachInfo = new List<Success_Resource__c>();
        List<Success_Student__c> studentInfo = new List<Success_Student__c>();
        String coachCaseRecordTypeId = '';
        List<RecordType> rectype = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :'Coach' AND SobjectType = 'Success_Resource__c'
        ];
        if (rectype.size() > 0)
            coachCaseRecordTypeId = rectype[0].Id;
        if (studentId != null && studentId != '') {
            studentInfo = [
                SELECT Id, Success_Resource__c
                FROM Success_Student__c
                WHERE Student__r.ASURite_ID__c = :studentId AND Coaching_Student__c = TRUE AND Is_Active__c = TRUE
                LIMIT 1
            ];
            if (studentInfo.size() > 0) {
                coachInfo = [
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
                    WHERE RecordTypeId = :coachCaseRecordTypeId AND Id = :studentInfo[0].Success_Resource__c
                ];
            }
        }

        return coachInfo;
    }
}
