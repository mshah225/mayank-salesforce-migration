@isTest
private class TestEngagementContactsTrigger_Test {
    public static Success_POD__c successPOD;
    public static User userCoachUser;
    public static Contact userStudent;
    public static Success_Resource__c successCoachUser;
    public static Success_Student__c successStudent;
    public static Case caseCoach1;
    public static Test_Engagement_Contacts__c e;
    public static String contactRecordTypeId;
    public static String coachRecordTypeId;

    @isTest
    static void testTrigger() {
        createCoachTestData();
        insert new et4ae5__Configuration__c(et4ae5__Support_Ticket_Recipient__c = 'example@example.com');
        Test.startTest();
        //create engagement
        e = new Test_Engagement_Contacts__c();
        e.Test_Case__c = caseCoach1.Id;
        e.Test_Contact__c = userStudent.Id;
        e.Test_Status__c = 'Pending';
        e.Test_Success_Resource__c = successCoachUser.Id;
        insert e;
        System.assert(!String.isBlank(e.Id));
        Test.stopTest();
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
        String coachResourceRecordTypeId = '';
        List<RecordType> rectype7 = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :'Coach' AND SobjectType = 'Success_Resource__c'
        ];
        if (rectype7.size() > 0)
            coachResourceRecordTypeId = rectype7[0].Id;

        //create pod
        successPOD = new Success_POD__c();
        successPOD.RecordTypeId = podCoachRecordTypeId;
        successPOD.Name = 'Coach POD';
        insert successPOD;

        //create coach user
        userCoachUser = new User();
        userCoachUser.Lastname = 'coach';
        userCoachUser.Alias = 'coachu';
        userCoachUser.Email = 'thecoachuser@asu.edu.xyz';
        userCoachUser.Username = 'thecoachuser@asu.edu.xyz';
        userCoachUser.TimeZoneSidKey = 'America/Phoenix';
        userCoachUser.LocaleSidKey = 'en_US';
        userCoachUser.EmailEncodingKey = 'ISO-8859-1';
        userCoachUser.ProfileId = profileId;
        userCoachUser.LanguageLocaleKey = 'en_US';
        insert userCoachUser;

        //create success coach user
        successCoachUser = new Success_Resource__c();
        successCoachUser.Resource__c = userCoachUser.Id;
        successCoachUser.RecordTypeId = coachResourceRecordTypeId;
        successCoachUser.Role__c = 'User';
        successCoachUser.AgentID__c = '12345';
        successCoachUser.Success_POD__c = successPOD.Id;
        successCoachUser.IsActive__c = true;
        insert successCoachUser;

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
        successStudent.Success_Resource__c = successCoachUser.Id;
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
        caseCoach1.OwnerId = userCoachUser.Id;
        caseCoach1.ASR_Date__c = System.today();
        caseCoach1.ASR_Comments__c = 'comments here';
        caseCoach1.ASR_Reasons__c = 'reasons here';
        caseCoach1.ASR_Actions__c = 'actions here';
        caseCoach1.Recommended_Actions__c = 'address financial issues;adjust course balance';
        caseCoach1.Reasons_Not_Returning__c = 'Academic;Disqualified';
        insert caseCoach1;
    }
}
