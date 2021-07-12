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

        Test.setMock(HttpCalloutMock.class, new MCSMSOptInControllerMockCallout());
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

        Test.setMock(HttpCalloutMock.class, new MCSMSOptInControllerMockCallout());
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

        Test.setMock(HttpCalloutMock.class, new MCSMSOptInControllerMockCallout());
        shouldFindExistingContact = false;
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

        Test.setMock(HttpCalloutMock.class, new MCSMSOptInControllerMockCallout());
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

        Test.setMock(HttpCalloutMock.class, new MCSMSOptInControllerMockCallout());
        shouldReturnMalformedContact = true;
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

        Test.setMock(HttpCalloutMock.class, new MCSMSOptInControllerMockCallout());
        shouldReturnNoId = true;
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

        Test.setMock(HttpCalloutMock.class, new MCSMSOptInControllerMockCallout());
        shouldFindExistingContact = false;
        shouldReturnMalformedContact = true;
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

        Test.setMock(HttpCalloutMock.class, new MCSMSOptInControllerMockCallout());
        shouldFindExistingContact = false;
        shouldReturnNoId = true;
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

        Test.setMock(HttpCalloutMock.class, new MCSMSOptInControllerMockCallout());
        shouldFindExistingContact = false;
        shouldReturnEmptyWhenCreatingContact = true;
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

        Test.setMock(HttpCalloutMock.class, new MCSMSOptInControllerMockCallout());
        shouldFailAuthorization = true;
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

    // Booleans for modifying mock callout reponse behavior
    private static Boolean shouldFindExistingContact = true;
    private static Boolean shouldFailAuthorization = false;
    private static Boolean shouldReturnNoId = false;
    private static Boolean shouldReturnMalformedContact = false;
    private static Boolean shouldReturnEmptyWhenCreatingContact = false;
    private static Boolean shouldReturnEmptyWhenOptIn = false;
    private class MCSMSOptInControllerMockCallout implements HttpCalloutMock {
        /**
         * Default interface method containing logic to handle GET, POST, etc.
         * @param HTTPRequest The req request from the callout
         * @return A HTTPResponse containing the contact information from GET/POST
         */
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response;

            if (isAuthorizationRequest(request)) {
                response = authorizationResponse();
            } else if (isOptInRequest(request)) {
                response = optInResponse();
            } else if (isExistingContactRequest(request)) {
                response = existingContactResponse();
            } else if (isNewContactRequest(request)) {
                response = newContactResponse();
            }

            return response;
        }

        private Boolean isAuthorizationRequest(HTTPRequest request) {
            return request.getMethod().equals('POST') &&
                request.getEndpoint().contains('callout:Marketing_Cloud/requestToken');
        }

        private HTTPResponse authorizationResponse() {
            HttpResponse response = new HttpResponse();
            if (!shouldFailAuthorization) {
                response.setStatusCode(200);
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"accessToken": "ACCESS_TOKEN", "expiresIn": 12000}');
            } else {
                response.setStatusCode(400);
            }

            return response;
        }

        private Boolean isOptInRequest(HTTPRequest request) {
            return request.getMethod().equals('POST') &&
                request.getEndpoint().contains('callout:Marketing_Cloud/queueMO/');
        }

        private HTTPResponse optInResponse() {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(201);
            response.setHeader('Content-Type', 'application/json');
            if (!shouldReturnEmptyWhenOptIn) {
                response.setBody('{"success": true}');
            }

            return response;
        }

        private Boolean isExistingContactRequest(HTTPRequest request) {
            return request.getMethod().equals('GET') &&
                request.getEndpoint().contains('callout:Mule_ESB_Contact_Service');
        }

        private HTTPResponse existingContactResponse() {
            Contact c = [SELECT Id FROM Contact];

            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            if (shouldFindExistingContact) {
                response.setBody(
                    '{' +
                    (shouldReturnMalformedContact ? '"MALFORMED"::{]]]: [' : '"contact": [') +
                    '{' +
                    '"id": "' +
                    (shouldReturnNoId ? '' : c.Id) +
                    '",' +
                    '"emplid": null,' +
                    '"asurite": null,' +
                    '"firstname": "Sally",' +
                    '"lastname": "Student",' +
                    '"middlename": null,' +
                    '"birthdate": null,' +
                    '"email": "suzeeq223@gmail.com.dev",' +
                    '"phone": "(623) 555-1212",' +
                    '"city": null,' +
                    '"country": "United States",' +
                    '"countrycode": "US",' +
                    '"street": "111 E North Drive",' +
                    '"postalcode": "85287",' +
                    '"state": "Arizona",' +
                    '"statecode": "AZ",' +
                    '"createddate": "2014-05-02T23:31:50Z",' +
                    '"recordtypeid": "012d0000000wzM5AAI"' +
                    '}' +
                    ']' +
                    '}'
                );
            } else {
                response.setBody('{"contactDetails": []}');
            }

            return response;
        }

        private Boolean isNewContactRequest(HTTPRequest request) {
            return request.getMethod().equals('POST') &&
                request.getEndpoint().contains('callout:Mule_ESB_Contact_Service');
        }

        private HTTPResponse newContactResponse() {
            Contact c = [SELECT Id FROM Contact];

            HttpResponse response = new HttpResponse();
            response.setStatusCode(201);
            if (!shouldReturnEmptyWhenCreatingContact) {
                response.setBody(
                    '{' +
                    (shouldReturnMalformedContact ? '"MALFORMED"::{]]] [{' : '"upsertResults": [{') +
                    '"created": "true",' +
                    '"id": "' +
                    (shouldReturnNoId ? '' : c.Id) +
                    '",' +
                    '"success": "true",' +
                    '"message": "MESSAGE_HERE"' +
                    '}]' +
                    '}'
                );
            }

            return response;
        }
    }
}
