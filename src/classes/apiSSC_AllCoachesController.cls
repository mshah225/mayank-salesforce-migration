@RestResource(urlMapping='/SuccessAllCoaches')
global with sharing class apiSSC_AllCoachesController {
    @HttpGet
    global static List<Success_Resource__c> getAllCoaches() {
        List<Success_Resource__c> coaches = new List<Success_Resource__c>();
        String coachResourceRecordTypeId;
        List<RecordType> rectype = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = 'Coach' AND SobjectType = 'Success_Resource__c'
        ];
        if (rectype.size() > 0)
            coachResourceRecordTypeId = rectype[0].Id;
        coaches = [
            SELECT
                Id,
                Name,
                Resource__r.Name,
                Resource__r.Email,
                Resource__r.Phone,
                Resource__r.Title,
                Resource__r.TimeZoneSidKey,
                ASURiteID__c,
                AgentID__c,
                RecordTypeId
            FROM Success_Resource__c
            WHERE isActive__c = TRUE AND RecordTypeId = :coachResourceRecordTypeId
            ORDER BY ASURiteID__c ASC
        ];

        return coaches;
    }
}
