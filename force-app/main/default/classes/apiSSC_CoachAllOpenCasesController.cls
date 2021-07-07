@RestResource(urlMapping='/SuccessCoachAllOpenCases')
global with sharing class apiSSC_CoachAllOpenCasesController {
    @HttpGet
    global static List<Case> getAllOpenCases() {
        String coachId = RestContext.request.params.get('coachId');
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
                    WHERE isClosed = FALSE AND OwnerId = :coach[0].Resource__r.Id
                    ORDER BY CreatedDate DESC
                ];
            }
        }

        return cases;
    }
}
