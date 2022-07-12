@isTest
private with sharing class FeedbackButtonServiceTest {
    private final static String carName = 'TestCAR';
    private final static String feedbackStr = 'feedbackText';
    private final static String testUserLastName = 'TestUserFbBtnSrv';

    @TestSetup
    static void setup() {
        final String emplNum = '3339990136';

        Contact c = new Contact(LastName = testUserLastName, EmplId__c = emplNum);
        insert c;

        User u = new User(
            Username = 'test.user@test.example.com',
            LastName = testUserLastName,
            Email = 'test.user@test.example.com',
            Alias = 'testUsr',
            CommunityNickname = 'testUsr',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = RecordIdHelper.getProfileId('System Administrator'),
            LanguageLocaleKey = 'en_US',
            EmployeeNumber = emplNum
        );
        insert u;

        Case_Classification__c functionalGroup = new Case_Classification__c(
            Name = 'TestFunctionalGroup',
            Active__c = true,
            Visible__c = true,
            Record_Types_String__c = 'wer',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
        );
        insert functionalGroup;
        Case_Classification__c category = new Case_Classification__c(
            Name = 'TestCategory',
            Active__c = true,
            Visible__c = true,
            Parent__c = functionalGroup.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Category')
        );
        insert category;

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Queue_ID__c = u.Id.to15(),
            Origin__c = 'Test',
            CC_Functional_Group__c = functionalGroup.Id,
            CC_Category__c = category.Id,
            Email_Address__c = 'testCustomSetting@test.test',
            Priority__c = 10
        );
        insert car;

        Feedback_Cars__c customSetting = new Feedback_Cars__c(Name = carName, CAR_Id__c = car.Id);
        insert customSetting;
    }

    @isTest
    private static void testValidFeedback() {
        User u = [SELECT Id FROM User WHERE LastName = :testUserLastName];

        System.runAs(u) {
            FeedbackButtonService.submitFeedback(carName, feedbackStr);
        }

        Case c = [SELECT Id, Description FROM Case];
        System.assertEquals(feedbackStr, c.Description);
    }

    @isTest
    private static void testInvalidDescription() {
        User u = [SELECT Id FROM User WHERE LastName = :testUserLastName];
        try {
            System.runAs(u) {
                FeedbackButtonService.submitFeedback(carName, '');
            }
            System.assert(false, 'Should have thrown an error and not reached this line');
        } catch (FeedbackButtonService.LWCFeedbackException e) {
            System.assertEquals(
                'Feedback must contain some text. Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080 (1-855-278-5080).',
                e.getMessage()
            );
        }
    }

    @isTest
    private static void testInvalidCarName() {
        User u = [SELECT Id FROM User WHERE LastName = :testUserLastName];
        try {
            System.runAs(u) {
                FeedbackButtonService.submitFeedback('invalidName', feedbackStr);
            }
            System.assert(false, 'Should have thrown an error and not reached this line');
        } catch (FeedbackButtonService.LWCFeedbackException e) {
            System.assertEquals(
                'Invalid carName parameter. Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080 (1-855-278-5080).',
                e.getMessage()
            );
        }
    }

    @isTest
    private static void testInvalidContact() {
        try {
            FeedbackButtonService.submitFeedback(carName, feedbackStr, '');
            System.assert(false, 'Should have thrown an error and not reached this line');
        } catch (FeedbackButtonService.LWCFeedbackException e) {
            System.assertEquals(
                'Invalid contactId parameter. Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080 (1-855-278-5080).',
                e.getMessage()
            );
        }
    }

    @isTest
    private static void testNoContact() {
        try {
            FeedbackButtonService.submitFeedback(carName, feedbackStr);
            System.assert(false, 'Should have thrown an error and not reached this line');
        } catch (FeedbackButtonService.LWCFeedbackException e) {
            System.assertEquals('Unable to find logged in contact.', e.getMessage());
        }
    }
}
