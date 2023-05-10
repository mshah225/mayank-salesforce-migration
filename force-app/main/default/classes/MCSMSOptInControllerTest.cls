@isTest
public with sharing class MCSMSOptInControllerTest {
    @TestSetup
    static void setup() {
        Contact c = new Contact(
            FirstName = 'MCMSOptInController',
            Middle_Name__c = 'Middle',
            LastName = 'TestContact',
            ASURite_ID__c = 'asurite1',
            EMPLID__c = '1230097832',
            Email = 'mcmsOptInController@test.test',
            Phone = '4029912548',
            Birthdate = Date.newInstance(1990, 11, 27),
            MailingStreet = '1372 S. Testburry',
            MailingCity = 'Testland',
            MailingState = 'Arizona',
            MailingPostalCode = '85218',
            MailingCountry = 'United States'
        );
        insert c;
    }

    @isTest
    private static void testOptInWithSubscriberKey() {
        Contact c = [
            SELECT
                Id,
                FirstName,
                Middle_Name__c,
                LastName,
                ASURite_ID__c,
                EMPLID__c,
                Email,
                Phone,
                Birthdate,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            LIMIT 1
        ];
        String subscriberKey = 'SUBSCRIBER_KEY';
        String shortCode = '883009';
        String messageText = 'Message text goes here.';

        Test.setMock(HttpCalloutMock.class, new MarketingCloudSMSOptInCalloutMock());
        Test.startTest();
        MCSMSOptInController.OptInResult oir = MCSMSOptInController.optIn(
            subscriberKey,
            c.Phone,
            shortCode,
            messageText,
            c.ASURite_ID__c,
            c.EMPLID__C,
            c.FirstName,
            c.LastName,
            c.Middle_Name__c,
            c.Email,
            c.Birthdate.format(),
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        );
        Test.stopTest();

        System.assert(oir.success);
        System.assertEquals('Opted in with Subscriber Key ' + subscriberKey, oir.message);
    }

    @isTest
    private static void testOptInWithNoSubscriberKey() {
        Contact c = [
            SELECT
                Id,
                FirstName,
                Middle_Name__c,
                LastName,
                ASURite_ID__c,
                EMPLID__c,
                Email,
                Phone,
                Birthdate,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            LIMIT 1
        ];
        String subscriberKey = '';
        String shortCode = '883009';
        String messageText = 'Message text goes here.';

        Test.setMock(HttpCalloutMock.class, new MarketingCloudSMSOptInCalloutMock());
        Test.startTest();
        MCSMSOptInController.OptInResult oir = MCSMSOptInController.optIn(
            subscriberKey,
            c.Phone,
            shortCode,
            messageText,
            c.ASURite_ID__c,
            c.EMPLID__C,
            c.FirstName,
            c.LastName,
            c.Middle_Name__c,
            c.Email,
            c.Birthdate.format(),
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        );
        Test.stopTest();

        System.assert(oir.success);
        System.assertEquals('Opted in with Subscriber Key ' + c.Id, oir.message);
    }

    @isTest
    private static void testOptInCreateNewSubscriber() {
        Contact c = [
            SELECT
                Id,
                FirstName,
                Middle_Name__c,
                LastName,
                ASURite_ID__c,
                EMPLID__c,
                Email,
                Phone,
                Birthdate,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            LIMIT 1
        ];
        String subscriberKey = '';
        String shortCode = '883009';
        String messageText = 'Message text goes here.';

        MarketingCloudSMSOptInCalloutMock calloutMock = new MarketingCloudSMSOptInCalloutMock();
        calloutMock.shouldFindExistingContact = false;
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        MCSMSOptInController.OptInResult oir = MCSMSOptInController.optIn(
            subscriberKey,
            c.Phone,
            shortCode,
            messageText,
            c.ASURite_ID__c,
            c.EMPLID__C,
            c.FirstName,
            c.LastName,
            c.Middle_Name__c,
            c.Email,
            c.Birthdate.format(),
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        );
        Test.stopTest();

        System.assert(oir.success);
        System.assertEquals('Opted in with Subscriber Key ' + c.Id, oir.message);
    }

    @isTest
    private static void testErrorMessageLackingMessageInfo() {
        Contact c = [
            SELECT
                Id,
                FirstName,
                Middle_Name__c,
                LastName,
                ASURite_ID__c,
                EMPLID__c,
                Email,
                Phone,
                Birthdate,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            LIMIT 1
        ];
        String subscriberKey = 'SUBSCRIBER_KEY';
        String shortCode = '883009';
        String messageText = 'Message text goes here.';

        Test.setMock(HttpCalloutMock.class, new MarketingCloudSMSOptInCalloutMock());
        Test.startTest();
        MCSMSOptInController.OptInResult oir1 = MCSMSOptInController.optIn(
            subscriberKey,
            '',
            shortCode,
            messageText,
            c.ASURite_ID__c,
            c.EMPLID__C,
            c.FirstName,
            c.LastName,
            c.Middle_Name__c,
            c.Email,
            c.Birthdate.format(),
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        );
        MCSMSOptInController.OptInResult oir2 = MCSMSOptInController.optIn(
            subscriberKey,
            c.Phone,
            '',
            messageText,
            c.ASURite_ID__c,
            c.EMPLID__C,
            c.FirstName,
            c.LastName,
            c.Middle_Name__c,
            c.Email,
            c.Birthdate.format(),
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        );
        MCSMSOptInController.OptInResult oir3 = MCSMSOptInController.optIn(
            subscriberKey,
            c.Phone,
            shortCode,
            '',
            c.ASURite_ID__c,
            c.EMPLID__C,
            c.FirstName,
            c.LastName,
            c.Middle_Name__c,
            c.Email,
            c.Birthdate.format(),
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        );
        Test.stopTest();

        System.assert(!oir1.success);
        System.assert(!oir2.success);
        System.assert(!oir3.success);
        System.assertEquals('mobilenumber, shortCode, and messageText/keyword are required', oir1.message);
        System.assertEquals('mobilenumber, shortCode, and messageText/keyword are required', oir2.message);
        System.assertEquals('mobilenumber, shortCode, and messageText/keyword are required', oir3.message);
    }

    @isTest
    private static void testErrorExistingSubscriberMalformed() {
        Contact c = [
            SELECT
                Id,
                FirstName,
                Middle_Name__c,
                LastName,
                ASURite_ID__c,
                EMPLID__c,
                Email,
                Phone,
                Birthdate,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            LIMIT 1
        ];
        String subscriberKey = '';
        String shortCode = '883009';
        String messageText = 'Message text goes here.';

        MarketingCloudSMSOptInCalloutMock calloutMock = new MarketingCloudSMSOptInCalloutMock();
        calloutMock.shouldReturnMalformedContact = true;
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        MCSMSOptInController.OptInResult oir = MCSMSOptInController.optIn(
            subscriberKey,
            c.Phone,
            shortCode,
            messageText,
            c.ASURite_ID__c,
            c.EMPLID__C,
            c.FirstName,
            c.LastName,
            c.Middle_Name__c,
            c.Email,
            c.Birthdate.format(),
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        );
        Test.stopTest();

        System.assert(!oir.success);
        System.assertEquals('There was a problem retrieving a Subscriber Key/Contact ID', oir.message);
    }

    @isTest
    private static void testErrorExistingSubscriberNoId() {
        Contact c = [
            SELECT
                Id,
                FirstName,
                Middle_Name__c,
                LastName,
                ASURite_ID__c,
                EMPLID__c,
                Email,
                Phone,
                Birthdate,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            LIMIT 1
        ];
        String subscriberKey = '';
        String shortCode = '883009';
        String messageText = 'Message text goes here.';

        MarketingCloudSMSOptInCalloutMock calloutMock = new MarketingCloudSMSOptInCalloutMock();
        calloutMock.shouldReturnNoId = true;
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        MCSMSOptInController.OptInResult oir = MCSMSOptInController.optIn(
            subscriberKey,
            c.Phone,
            shortCode,
            messageText,
            c.ASURite_ID__c,
            c.EMPLID__C,
            c.FirstName,
            c.LastName,
            c.Middle_Name__c,
            c.Email,
            c.Birthdate.format(),
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        );
        Test.stopTest();

        System.assert(!oir.success);
        System.assertEquals('There was a problem retrieving a Subscriber Key/Contact ID', oir.message);
    }

    @isTest
    private static void testErrorNewSubscriberMalformed() {
        Contact c = [
            SELECT
                Id,
                FirstName,
                Middle_Name__c,
                LastName,
                ASURite_ID__c,
                EMPLID__c,
                Email,
                Phone,
                Birthdate,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            LIMIT 1
        ];
        String subscriberKey = '';
        String shortCode = '883009';
        String messageText = 'Message text goes here.';

        MarketingCloudSMSOptInCalloutMock calloutMock = new MarketingCloudSMSOptInCalloutMock();
        calloutMock.shouldFindExistingContact = false;
        calloutMock.shouldReturnMalformedContact = true;
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        MCSMSOptInController.OptInResult oir = MCSMSOptInController.optIn(
            subscriberKey,
            c.Phone,
            shortCode,
            messageText,
            c.ASURite_ID__c,
            c.EMPLID__C,
            c.FirstName,
            c.LastName,
            c.Middle_Name__c,
            c.Email,
            c.Birthdate.format(),
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        );
        Test.stopTest();

        System.assert(!oir.success);
        System.assertEquals('There was a problem retrieving a Subscriber Key/Contact ID', oir.message);
    }

    @isTest
    private static void testErrorNewSubscriberNoId() {
        Contact c = [
            SELECT
                Id,
                FirstName,
                Middle_Name__c,
                LastName,
                ASURite_ID__c,
                EMPLID__c,
                Email,
                Phone,
                Birthdate,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            LIMIT 1
        ];
        String subscriberKey = '';
        String shortCode = '883009';
        String messageText = 'Message text goes here.';

        MarketingCloudSMSOptInCalloutMock calloutMock = new MarketingCloudSMSOptInCalloutMock();
        calloutMock.shouldFindExistingContact = false;
        calloutMock.shouldReturnNoId = true;
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        MCSMSOptInController.OptInResult oir = MCSMSOptInController.optIn(
            subscriberKey,
            c.Phone,
            shortCode,
            messageText,
            c.ASURite_ID__c,
            c.EMPLID__C,
            c.FirstName,
            c.LastName,
            c.Middle_Name__c,
            c.Email,
            c.Birthdate.format(),
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        );
        Test.stopTest();

        System.assert(!oir.success);
        System.assertEquals('There was a problem retrieving a Subscriber Key/Contact ID', oir.message);
    }

    @isTest
    private static void testErrorNewSubscriberEmptyResponse() {
        Contact c = [
            SELECT
                Id,
                FirstName,
                Middle_Name__c,
                LastName,
                ASURite_ID__c,
                EMPLID__c,
                Email,
                Phone,
                Birthdate,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            LIMIT 1
        ];
        String subscriberKey = '';
        String shortCode = '883009';
        String messageText = 'Message text goes here.';

        MarketingCloudSMSOptInCalloutMock calloutMock = new MarketingCloudSMSOptInCalloutMock();
        calloutMock.shouldFindExistingContact = false;
        calloutMock.shouldReturnEmptyWhenCreatingContact = true;
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        MCSMSOptInController.OptInResult oir = MCSMSOptInController.optIn(
            subscriberKey,
            c.Phone,
            shortCode,
            messageText,
            c.ASURite_ID__c,
            c.EMPLID__C,
            c.FirstName,
            c.LastName,
            c.Middle_Name__c,
            c.Email,
            c.Birthdate.format(),
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        );
        Test.stopTest();

        System.assert(!oir.success);
        System.assertEquals('There was a problem retrieving a Subscriber Key/Contact ID', oir.message);
    }

    @isTest
    private static void testErrorFailingAuthorization() {
        Contact c = [
            SELECT
                Id,
                FirstName,
                Middle_Name__c,
                LastName,
                ASURite_ID__c,
                EMPLID__c,
                Email,
                Phone,
                Birthdate,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            LIMIT 1
        ];
        String subscriberKey = '';
        String shortCode = '883009';
        String messageText = 'Message text goes here.';

        MarketingCloudSMSOptInCalloutMock calloutMock = new MarketingCloudSMSOptInCalloutMock();
        calloutMock.shouldFailAuthorization = true;
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        MCSMSOptInController.OptInResult oir = MCSMSOptInController.optIn(
            subscriberKey,
            c.Phone,
            shortCode,
            messageText,
            c.ASURite_ID__c,
            c.EMPLID__C,
            c.FirstName,
            c.LastName,
            c.Middle_Name__c,
            c.Email,
            c.Birthdate.format(),
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        );
        Test.stopTest();

        System.assert(!oir.success);
        System.assertEquals('There was a problem calling the Marketing Cloud API', oir.message);
    }
}