@RestResource(urlMapping='/SuccessCoachOpenCases')
global with sharing class SuccessCoachStudentOpenCasesAPI {
    @HttpGet
    global static List<Case> getOpenCases() {
        String coachId = RestContext.request.params.get('coachId');
        String studentId = RestContext.request.params.get('studentId');
        List<Case> cases = new List<Case>();
        if (coachId != null) {
            List<Success_Resource__c> coach = new List<Success_Resource__c>();
            coach = [SELECT Resource__r.Id FROM Success_Resource__c WHERE ASURiteID__c = :coachId];
            if (coach.size() > 0) {
                cases = [
                    SELECT
                        Id,
                        Subject,
                        Status,
                        Priority,
                        Origin__c,
                        Description,
                        Type,
                        Case_Link__c,
                        Contact.ASURite_ID__c,
                        Contact.FirstName,
                        Contact.LastName,
                        CreatedDate
                    FROM Case
                    WHERE isClosed = FALSE AND OwnerId = :coach[0].Resource__r.Id AND Contact.ASURite_ID__c = :studentId
                    ORDER BY CreatedDate DESC
                ];
            }
        }

        return cases;
    }
}
