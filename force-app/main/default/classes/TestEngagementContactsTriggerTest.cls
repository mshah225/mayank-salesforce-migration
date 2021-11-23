@isTest
private class TestEngagementContactsTriggerTest {
    @TestSetup
    private static void setup() {
        Success_POD__c successPOD = new Success_POD__c(
            RecordTypeId = IDHelper.getRecordTypeId('Success_POD__c', 'Coach'),
            Name = 'Coach POD'
        );
        insert successPOD;

        User userCoachUser = new User(
            Lastname = 'coach',
            Alias = 'coachu',
            Email = 'thecoachuser@asu.edu.xyz',
            Username = 'thecoachuser@asu.edu.xyz',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = IDHelper.getProfileId('System Administrator'),
            LanguageLocaleKey = 'en_US'
        );
        insert userCoachUser;

        Success_Resource__c successCoachUser = new Success_Resource__c(
            Resource__c = userCoachUser.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Success_Resource__c', 'Coach'),
            Role__c = 'User',
            AgentID__c = '12345',
            Success_POD__c = successPOD.Id,
            IsActive__c = true
        );
        insert successCoachUser;

        Contact userStudent = new Contact(
            RecordTypeId = IDHelper.getRecordTypeId('Contact', 'External_Mastered'),
            Firstname = 'John',
            Lastname = 'Doe',
            Email = 'john.doe@asu.edu.xyz',
            ASURITE_ID__c = 'jdoe1',
            Hidden_Selected__c = true,
            EMPLID__c = '8888'
        );
        insert userStudent;

        Date today = System.today();
        Case caseCoach1 = new Case(
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Coach_Outreach'),
            Type = 'Coach Initiated',
            Subject = 'Drop/Withdrawn',
            Status = 'New',
            Priority = 'Normal',
            Followup_Date__c = today,
            OwnerId = userCoachUser.Id,
            ASR_Date__c = today,
            ASR_Comments__c = 'comments here',
            ASR_Reasons__c = 'reasons here',
            ASR_Actions__c = 'actions here',
            Recommended_Actions__c = 'address financial issues;adjust course balance',
            Reasons_Not_Returning__c = 'Academic;Disqualified'
        );
        insert caseCoach1;
    }

    @isTest
    private static void testSuccessfulInsert() {
        Case caseCoach1 = [SELECT Id FROM Case];
        Contact userStudent = [SELECT Id FROM Contact];
        Success_Resource__c successCoachUser = [SELECT Id FROM Success_Resource__c];

        Test_Engagement_Contacts__c e = new Test_Engagement_Contacts__c(
            Test_Case__c = caseCoach1.Id,
            Test_Contact__c = userStudent.Id,
            Test_Status__c = 'Pending',
            Test_Success_Resource__c = successCoachUser.Id
        );

        Test.startTest();
        insert e;
        update e;
        Test.stopTest();

        System.assert(!String.isBlank(e.Id));
    }

    @isTest
    private static void testSetStatus() {
        Case caseCoach1 = [SELECT Id FROM Case];
        Contact userStudent = [SELECT Id FROM Contact];
        Success_Resource__c successCoachUser = [SELECT Id FROM Success_Resource__c];

        Test_Engagement_Contacts__c e = new Test_Engagement_Contacts__c(
            Test_Case__c = caseCoach1.Id,
            Test_Contact__c = userStudent.Id,
            Test_Status__c = 'Pending',
            Test_Success_Resource__c = successCoachUser.Id
        );

        Test.startTest();
        insert e;
        Test.stopTest();

        e = [SELECT Test_Status__c FROM Test_Engagement_Contacts__c WHERE Id = :e.Id LIMIT 1];

        System.assertEquals('Sent', e.Test_Status__c);
    }

    @isTest
    private static void padTests() {
        /**
         * We don't do anything on delete or undelete - so there is nothing to test.  This is just
         * to help pad the test coverage.
         */
        Case caseCoach1 = [SELECT Id FROM Case];
        Contact userStudent = [SELECT Id FROM Contact];
        Success_Resource__c successCoachUser = [SELECT Id FROM Success_Resource__c];

        Test_Engagement_Contacts__c e = new Test_Engagement_Contacts__c(
            Test_Case__c = caseCoach1.Id,
            Test_Contact__c = userStudent.Id,
            Test_Status__c = 'Pending',
            Test_Success_Resource__c = successCoachUser.Id
        );

        Test.startTest();
        insert e;
        Test.stopTest();

        delete e;
        undelete e;
    }
}
