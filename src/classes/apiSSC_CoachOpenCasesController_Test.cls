@isTest
private class apiSSC_CoachOpenCasesController_Test {
    public static Success_POD__c successPOD;
    public static User userCoach;
    public static User userAdvisor;
    public static Contact userStudent;
    public static Success_Resource__c successCoach;
    public static Success_Resource__c successAdvisor;
    public static Success_Student__c successStudent;
    public static Case caseCoach1;
    public static Case caseAdvisor1;
    public static String contactRecordTypeId;

    static void init() {
        createCoachTestData();
    }

    static private void createCoachTestData() {
        //Coach POD RT
        String podCoachRecordTypeId = '';
        List<RecordType> rectype1 = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :'Coach' AND SobjectType = 'Success_POD__c'
        ];
        if (rectype1.size() > 0)
            podCoachRecordTypeId = rectype1[0].Id;

        //Contact RT
        contactRecordTypeId = '';
        List<RecordType> rectype3 = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :'External_Mastered' AND SobjectType = 'Contact'
        ];
        if (rectype3.size() > 0)
            contactRecordTypeId = rectype3[0].Id;

        //Profile RT
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        //Coach Case RT
        String coachCaseRecordTypeId = '';
        List<RecordType> rectype5 = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :'ASU_Coach_Outreach' AND SobjectType = 'Case'
        ];
        if (rectype5.size() > 0)
            coachCaseRecordTypeId = rectype5[0].Id;

        //Coach RT
        String coachRecordTypeId = '';
        List<RecordType> rectype6 = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :'Coach' AND SobjectType = 'Success_Resource__c'
        ];
        if (rectype6.size() > 0)
            coachRecordTypeId = rectype6[0].Id;

        //create pod
        successPOD = new Success_POD__c();
        successPOD.RecordTypeId = podCoachRecordTypeId;
        successPOD.Name = 'Coach POD';
        insert successPOD;

        //create coach
        userCoach = new User();
        userCoach.Lastname = 'coach';
        userCoach.Email = 'thecoach@asu.edu.xyz';
        userCoach.Username = 'thecoach@asu.edu.xyz';
        userCoach.Alias = 'thecoach';
        userCoach.ASURITE_for_External_ID__c = 'thecoach';
        userCoach.TimeZoneSidKey = 'America/Phoenix';
        userCoach.LocaleSidKey = 'en_US';
        userCoach.EmailEncodingKey = 'ISO-8859-1';
        userCoach.ProfileId = profileId;
        userCoach.LanguageLocaleKey = 'en_US';
        insert userCoach;

        //create success coach
        successCoach = new Success_Resource__c();
        successCoach.Resource__c = userCoach.Id;
        successCoach.RecordTypeId = coachRecordTypeId;
        successCoach.Role__c = 'User';
        successCoach.AgentID__c = '12345';
        successCoach.Success_POD__c = successPOD.Id;
        successCoach.IsActive__c = true;
        insert successCoach;

        //create student
        userStudent = new Contact();
        userStudent.RecordTypeId = contactRecordTypeId;
        userStudent.Firstname = 'John';
        userStudent.Lastname = 'Doe';
        userStudent.Email = 'john.doe@asu.edu.xyz';
        userStudent.ASURITE_ID__c = 'jdoe1';
        userStudent.Hidden_Selected__c = true;
        userStudent.EMPLID__c = '8888';
        insert userStudent;

        //create success student
        successStudent = new Success_Student__c();
        successStudent.Student__c = userStudent.Id;
        successStudent.Success_Resource__c = successCoach.Id;
        successStudent.Success_POD__c = successPOD.Id;
        insert successStudent;

        //create coach case
        caseCoach1 = new Case();
        caseCoach1.RecordTypeId = coachCaseRecordTypeId;
        caseCoach1.Type = 'Coach Initiated';
        caseCoach1.Subject = 'Drop/Withdrawn';
        caseCoach1.Status = 'New';
        caseCoach1.Priority = 'Normal';
        caseCoach1.Followup_Date__c = System.today();
        caseCoach1.OwnerId = userCoach.Id;
        insert caseCoach1;
    }

    static testMethod void testGetCoachOpenCases() {
        init();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.AddParameter('coachId', 'thecoach');
        req.requestURI = System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/SuccessCoachOpenCases';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        List<Case> results = apiSSC_CoachOpenCasesController.getOpenCases();

        System.assertEquals(1, results.size());
    }
}
