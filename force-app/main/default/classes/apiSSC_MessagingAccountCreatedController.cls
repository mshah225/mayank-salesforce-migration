@RestResource(urlMapping='/SuccessMessagingAccountCreated')
global with sharing class apiSSC_MessagingAccountCreatedController {
    @HttpPut
    global static String updateMessagingFlag() {
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
                SELECT Id, Messaging_Account_Created__c
                FROM Success_Resource__c
                WHERE RecordTypeId = :coachRecordTypeId AND ASURiteID__c = :ASURite
                LIMIT 1
            ];
            if (coachList.size() > 0) {
                Success_Resource__c thisResource = coachList[0];
                thisResource.Messaging_Account_Created__c = true;
                update thisResource;
                return 'Updated ' + ASURite + ' coach messaging account created flag to true';
            }
            //Check if asurite is student
            List<Success_Student__c> studentList = new List<Success_Student__c>();
            studentList = [
                SELECT Id, Messaging_Account_Created__c
                FROM Success_Student__c
                WHERE ASURiteID__c = :ASURite
                LIMIT 1
            ];
            if (studentList.size() > 0) {
                Success_Student__c thisResource = studentList[0];
                thisResource.Messaging_Account_Created__c = true;
                update thisResource;
                return 'Updated ' + ASURite + ' student messaging account created flag to true';
            }
        }
        //asurite not found in success objects
        return 'No Account Found';
    }
}
