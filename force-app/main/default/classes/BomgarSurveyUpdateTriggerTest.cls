@istest
private class BomgarSurveyUpdateTriggerTest {
    private static final String sessionName = 'Test+RTN02';
    private static final String testUserAlias = 'testUsr';

    @TestSetup
    private static void setup() {
        Case c = new Case(Subject = 'TestCase', Description = 'Description');
        insert c;

        bomgar__BomgarSession__c session = new bomgar__BomgarSession__c(
            Name = sessionName,
            bomgar__RelatedCase__c = c.Id,
            bomgar__Duration__c = '00:02:00'
        );
        insert session;

        bomgar__Survey__c surveyHolder = new bomgar__Survey__c(bomgar__BomgarSession__c = session.Id);
        insert surveyHolder;

        Bomgar__Participant__c bp = new Bomgar__Participant__c(
            bomgar__Username__c = testUserAlias,
            bomgar__IsPrimary__c = true,
            bomgar__ParticipantType__c = 'Representative',
            bomgar__BomgarSession__c = session.Id
        );
        insert bp;

        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'test.user@test.example.com',
            Email = 'test.user@test.example.com',
            Alias = testUserAlias,
            CommunityNickname = testUserAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('Standard User'),
            FederationIdentifier = bp.bomgar__Username__c + '@admin.asu.edu'
        );
        insert u;
    }

    @isTest
    private static void surveyUpdateTriggerTestResolved() {
        bomgar__BomgarSession__c session = [
            SELECT bomgar__RelatedCase__c
            FROM bomgar__BomgarSession__c
            WHERE Name = :sessionName
        ];
        bomgar__Survey__c surveyHolder = [SELECT Id FROM bomgar__Survey__c];

        bomgar__SurveyData__c survey = new bomgar__SurveyData__c(
            bomgar__Survey__c = surveyHolder.Id,
            Name = 'close_state',
            bomgar__Value__c = 'Resolved'
        );

        Test.startTest();
        insert survey;
        Test.stopTest();

        Case c = [SELECT Status FROM Case WHERE Id = :session.bomgar__RelatedCase__c];
        System.assertEquals('Closed: Resolved', c.Status);
    }

    @isTest
    private static void surveyUpdateTriggerTestEscalate() {
        bomgar__BomgarSession__c session = [
            SELECT bomgar__RelatedCase__c
            FROM bomgar__BomgarSession__c
            WHERE Name = :sessionName
        ];
        bomgar__Survey__c surveyHolder = [SELECT Id FROM bomgar__Survey__c];

        bomgar__SurveyData__c survey = new bomgar__SurveyData__c(
            bomgar__Survey__c = surveyHolder.Id,
            Name = 'close_state',
            bomgar__Value__c = 'Escalate'
        );

        Test.startTest();
        insert survey;
        Test.stopTest();

        Case c = [SELECT Status FROM Case WHERE Id = :session.bomgar__RelatedCase__c];
        System.assertEquals('New', c.Status);
    }

    @isTest
    private static void testUpdateCaseOwner() {
        bomgar__BomgarSession__c session = [
            SELECT bomgar__RelatedCase__c
            FROM bomgar__BomgarSession__c
            WHERE Name = :sessionName
        ];
        bomgar__Survey__c surveyHolder = [SELECT Id FROM bomgar__Survey__c];

        bomgar__SurveyData__c survey = new bomgar__SurveyData__c(
            bomgar__Survey__c = surveyHolder.Id,
            Name = 'close_state',
            bomgar__Value__c = 'Escalate'
        );

        Test.startTest();
        insert survey;
        Test.stopTest();

        User u = [SELECT Id FROM User WHERE Alias = :testUserAlias];
        Case c = [SELECT OwnerId FROM Case WHERE Id = :session.bomgar__RelatedCase__c];
        System.assertEquals(u.Id, c.OwnerId);
    }

    @isTest
    private static void padTests() {
        /**
         * We don't do anything on update, delete, or undelete so this is just to
         * pad the test coverage - nothing to actually test
         */
        bomgar__BomgarSession__c session = [
            SELECT bomgar__RelatedCase__c
            FROM bomgar__BomgarSession__c
            WHERE Name = :sessionName
        ];
        bomgar__Survey__c surveyHolder = [SELECT Id FROM bomgar__Survey__c];

        bomgar__SurveyData__c survey = new bomgar__SurveyData__c(
            bomgar__Survey__c = surveyHolder.Id,
            Name = 'close_state',
            bomgar__Value__c = 'Escalate'
        );

        Test.startTest();
        insert survey;
        update survey;
        delete survey;
        undelete survey;
        Test.stopTest();
    }
}
