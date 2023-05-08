@isTest
public with sharing class PersistenceFeedbackControllerTest {
    private static String testUserLastName = 'PersistenceFeedbackControllerTestUser';
    private static String testFunctionalGroupName = 'TestFunctionalGroup';
    private static String testCategoryName = 'TestCategory';
    private static String testSubCategoryName = 'TestSubCategory';
    private static String testCarEmail = 'testCustomSetting@test.test';

    @TestSetup
    static void setup() {
        Contact c = ContactService.createTestContact();
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
            EmployeeNumber = '8820109876'
        );
        insert u;

        Case_Classification__c functionalGroup = new Case_Classification__c(
            Name = testFunctionalGroupName,
            Active__c = true,
            Visible__c = true,
            Record_Types_String__c = 'wer',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
        );
        insert functionalGroup;
        Case_Classification__c category = new Case_Classification__c(
            Name = testCategoryName,
            Active__c = true,
            Visible__c = true,
            Parent__c = functionalGroup.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Category')
        );
        insert category;
        Case_Classification__c subCategory = new Case_Classification__c(
            Name = testSubCategoryName,
            Active__c = true,
            Visible__c = true,
            Parent__c = category.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category')
        );
        insert subCategory;

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Queue_ID__c = u.Id.to15(),
            Origin__c = 'Test',
            CC_Functional_Group__c = functionalGroup.Id,
            CC_Category__c = category.Id,
            CC_Sub_Category__c = subCategory.Id,
            Email_Address__c = testCarEmail,
            Campus__c = 'TestCampus',
            Priority__c = 10
        );
        insert car;

        Feedback_Cars__c customSetting = new Feedback_Cars__c(Name = 'Persistence Outlook', CAR_Id__c = car.Id);
        insert customSetting;
    }

    @isTest
    private static void testMissingUrlParameters() {
        PageReference pageRef = Page.PersistenceFeedback;
        Test.setCurrentPage(pageRef);
        Test.startTest();

        PersistenceFeedbackController controller = new PersistenceFeedbackController();

        try {
            controller.init();
        } catch (Exception ex) {
            Test.stopTest();
            
            Case errorLoggerCase = [SELECT Id, Subject FROM Case];
            System.assertEquals('Error: Missing URL parameter \'misc\' required.', ex.getMessage(), 'Incorrect error message');
            System.assert(errorLoggerCase.Subject.contains('MissingUrlParametersException'));
            System.assert(errorLoggerCase.Description.contains('URLParamsExistAndAreValid'));
            System.assert(errorLoggerCase.Description.contains('caseDescription'));
            System.assert(errorLoggerCase.Description.contains('caseContactId'));
            System.assert(errorLoggerCase.Description.contains('AlertHandler'));

            System.assertEquals(false, controller.URLParamsExistAndAreValid);
        }
    }

    @isTest
    private static void testValidUrlParams() {
        String caseDesc = 'Student detail and comments goes here.';

        PageReference pageRef = Page.PersistenceFeedback;
        pageRef.getParameters().put('misc', caseDesc);
        pageRef.getParameters().put('retUrl', 'https://return.url');
        Test.setCurrentPage(pageRef);
        Test.startTest();

        PersistenceFeedbackController controller = new PersistenceFeedbackController();
        Object res = controller.init();
        
        Test.stopTest();
        System.assertEquals(caseDesc + '\n', controller.CaseDescription);
        System.assertEquals(true, controller.URLParamsExistAndAreValid);
        System.assertEquals(null, res);
    }

    @isTest
    private static void testSubmitWithInvalidUrlParameters() {
        String caseDesc = 'Student detail and comments goes here.';

        PageReference pageRef = Page.PersistenceFeedback;
        pageRef.getParameters().put('misc', caseDesc);
        pageRef.getParameters().put('retUrl', 'https://return.url');
        Test.setCurrentPage(pageRef);
        Test.startTest();

        PersistenceFeedbackController controller = new PersistenceFeedbackController();

        controller.init();
        controller.URLParamsExistAndAreValid = false;

        try {
            controller.submit();            
        } catch (Exception ex) {
            Test.stopTest();
            System.assertEquals(1, controller.alertHandler.alerts.size());
            System.assertEquals(customAlert.FATAL, controller.alertHandler.alerts[0].severity);
            System.assertEquals(
            'Form submission after initialization error. Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080 (1-855-278-5080).',
            controller.alertHandler.alerts[0].message
            );

            Case errorLoggerCase = [SELECT Id, Subject FROM Case];
            System.assertEquals('Error: Form submission after initialization error', ex.getMessage(), 'Incorrect error message');
            System.assert(errorLoggerCase.Subject.contains('dynamicFeedbackException'));
            System.assert(errorLoggerCase.Description.contains('URLParamsExistAndAreValid'));
            System.assert(errorLoggerCase.Description.contains('proceed'));
            System.assert(errorLoggerCase.Description.contains('caseDescription'));
            System.assert(errorLoggerCase.Description.contains('caseContactId'));
            System.assert(errorLoggerCase.Description.contains('AlertHandler'));
            System.assert(errorLoggerCase.Description.contains('feedbackCase'));
        }
    }

    @isTest
    private static void testSubmitWithEmptyDescription() {
        String caseDesc = 'Student detail and comments goes here.';

        PageReference pageRef = Page.PersistenceFeedback;
        pageRef.getParameters().put('misc', caseDesc);
        pageRef.getParameters().put('retUrl', 'https://return.url');
        Test.setCurrentPage(pageRef);
        Test.startTest();

        PersistenceFeedbackController controller = new PersistenceFeedbackController();

        controller.init();
        controller.caseDescription = '';
        controller.submit();

        System.assertEquals(1, controller.alertHandler.alerts.size());
        System.assertEquals(customAlert.WARNING, controller.alertHandler.alerts[0].severity);
        System.assertEquals(
            'Feedback comments are required.',
            controller.alertHandler.alerts[0].message
        );
    }

    @isTest
    private static void testSubmitCase() {
        String caseDesc = 'Student detail and comments goes here.';

        PageReference pageRef = Page.PersistenceFeedback;
        pageRef.getParameters().put('misc', caseDesc);
        pageRef.getParameters().put('retUrl', 'https://return.url');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        PersistenceFeedbackController controller = new PersistenceFeedbackController();
        controller.init();
        controller.submit();
        Test.stopTest();

        Case createdCase = [
            SELECT
                Id,
                ContactId,
                Subject,
                Description,
                Origin__c,
                CC_Functional_Group__r.Name,
                CC_Category__r.Name,
                CC_Sub_Category__r.Name,
                Owner.Name,
                Case_Feed_Email__c,
                IsVisibleInSelfService
            FROM Case
            LIMIT 1
        ];

        System.assertEquals('Persistence Outlook feedback', createdCase.Subject);
        System.assertEquals(caseDesc, createdCase.Description);
        System.assertEquals('Test', createdCase.Origin__c);
        System.assertEquals(testFunctionalGroupName, createdCase.CC_Functional_Group__r.Name);
        System.assertEquals(testCategoryName, createdCase.CC_Category__r.Name);
        System.assertEquals(testSubCategoryName, createdCase.CC_Sub_Category__r.Name);
        System.assertEquals(testUserLastName, createdCase.Owner.Name);
        System.assertEquals(testCarEmail.toLowerCase(), createdCase.Case_Feed_Email__c.toLowerCase());
        System.assert(!createdCase.IsVisibleInSelfService);

        System.assertEquals(1, controller.alertHandler.alerts.size());
        System.assertEquals(customAlert.CONFIRM, controller.alertHandler.alerts[0].severity);
        System.assertEquals(
            'Thank you for your feedback about the Persistence Outlook. You may now close this window.',
            controller.alertHandler.alerts[0].message
        );
    }
}