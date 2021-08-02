@isTest
public with sharing class ContactUploadValidatorTest {
    @TestSetup
    private static void setup() {
        Subscription__c sub = new Subscription__c(
            Name = 'Test Subscription',
            Subscription_Type__c = 'List',
            Subscriber_Private_in_Salesforce__c = false
        );
        insert sub;
    }

    @isTest
    private static void testValidateAndClean() {
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(
            Subscription__c = sub.Id,
            Subscriber_Status__c = 'Subscribed',
            Phone__c = '(440)-923-0018',
            EMPLID__c = '123456'
        );

        Test.startTest();
        ContactUploadValidator cudValidator = new ContactUploadValidator(cud);
        cudValidator.validateAndClean();
        Test.stopTest();

        System.assert(!cudValidator.isInError(), 'Should have no errors');
        System.assertEquals('4409230018', cud.Phone__c);
    }

    @isTest
    private static void testErrorNoSubscription() {
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(
            Subscriber_Status__c = 'Subscribed',
            EMPLID__c = '123456'
        );

        Test.startTest();
        ContactUploadValidator cudValidator = new ContactUploadValidator(cud);
        cudValidator.validateAndClean();
        Test.stopTest();

        System.assert(cudValidator.isInError(), 'Should have error');
        System.assert(
            cud.Processing_Notes__c.contains('Subscription Id is REQUIRED.'),
            'Does not contain required error'
        );
    }

    @isTest
    private static void testErrorInvalidSubscription() {
        Id notSubId = [SELECT Id FROM User LIMIT 1].Id;
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(
            Subscription__c = notSubId, // Id of wrong type of object
            Subscriber_Status__c = 'Subscribed',
            EMPLID__c = '123456'
        );
        Contact_Upload_Detail__c cud2 = new Contact_Upload_Detail__c(
            Subscription__c = '999z0000001fmBp', // Id of no type of object
            Subscriber_Status__c = 'Subscribed',
            EMPLID__c = '123456'
        );

        Test.startTest();
        ContactUploadValidator cudValidator = new ContactUploadValidator(cud);
        cudValidator.validateAndClean();
        ContactUploadValidator cudValidator2 = new ContactUploadValidator(cud2);
        cudValidator2.validateAndClean();
        Test.stopTest();

        System.assert(cudValidator.isInError(), 'Should have error');
        System.assert(
            cud.Processing_Notes__c.contains('Subscription Id is invalid.'),
            'Does not contain required error'
        );
        System.assert(cudValidator2.isInError(), 'Should have error');
        System.assert(
            cud2.Processing_Notes__c.contains('Subscription Id is invalid.'),
            'Does not contain required error'
        );
    }

    @isTest
    private static void testErrorNoSubscriptionStatus() {
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(Subscription__c = sub.Id, EMPLID__c = '123456');

        Test.startTest();
        ContactUploadValidator cudValidator = new ContactUploadValidator(cud);
        cudValidator.validateAndClean();
        Test.stopTest();

        System.assert(cudValidator.isInError(), 'Should have error');
        System.assert(
            cud.Processing_Notes__c.contains('Subscriber Status is REQUIRED.'),
            'Does not contain required error'
        );
    }

    @isTest
    private static void testErrorInvalidSubscriptionStatus() {
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(
            Subscription__c = sub.Id,
            Subscriber_Status__c = 'INVALID_STATUS',
            EMPLID__c = '123456'
        );

        Test.startTest();
        ContactUploadValidator cudValidator = new ContactUploadValidator(cud);
        cudValidator.validateAndClean();
        Test.stopTest();

        System.assert(cudValidator.isInError(), 'Should have error');
        System.assert(
            cud.Processing_Notes__c.contains(
                'Subscriber Status can only have the values Subscribed, Unsubscribed or No Preference.'
            ),
            'Does not contain required error'
        );
    }

    @isTest
    private static void testValidateWithNameAndEmail() {
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(
            First_Name__c = 'Test CUD',
            Last_Name__c = 'Test CUD Last Name',
            Email__c = 'Test.CUD@test.test'
        );

        Test.startTest();
        ContactUploadValidator cudValidator = new ContactUploadValidator(cud);
        cudValidator.validateDataForMatcher();
        Test.stopTest();

        System.assert(!cudValidator.isInError(), 'Should have no errors');
    }

    @isTest
    private static void testValidateWithASURITE() {
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(ASURITE__c = 'testUsr1');

        Test.startTest();
        ContactUploadValidator cudValidator = new ContactUploadValidator(cud);
        cudValidator.validateDataForMatcher();
        Test.stopTest();

        System.assert(!cudValidator.isInError(), 'Should have no errors');
    }

    @isTest
    private static void testValidateWithEMPLID() {
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(EMPLID__c = '123456');

        Test.startTest();
        ContactUploadValidator cudValidator = new ContactUploadValidator(cud);
        cudValidator.validateDataForMatcher();
        Test.stopTest();

        System.assert(!cudValidator.isInError(), 'Should have no errors');
    }

    @isTest
    private static void testValidateWithNotEnoughFields() {
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c();

        Test.startTest();
        ContactUploadValidator cudValidator = new ContactUploadValidator(cud);
        cudValidator.validateDataForMatcher();
        Test.stopTest();

        System.assert(cudValidator.isInError(), 'Should have error');
        System.assert(
            cud.Processing_Notes__c.contains('First Name, Last Name, and Email OR EMPLID OR Asurite is REQUIRED.'),
            'Does not contain required error'
        );
    }
}
