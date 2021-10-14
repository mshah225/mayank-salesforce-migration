@isTest
public with sharing class PersistenceFeedbackControllerTest {
    private static String testUserLastName = 'PersistenceFeedbackControllerTestUser';
    private static String testFunctionalGroupName = 'TestFunctionalGroup';
    private static String testCategoryName = 'TestCategory';
    private static String testSubCategoryName = 'TestSubCategory';
    private static String testCarEmail = 'testCustomSetting@test.test';

    @TestSetup
    static void setup() {
        Contact c = new Contact(LastName = 'TestContact');
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
            ProfileId = IDHelper.getPID('System Administrator'),
            LanguageLocaleKey = 'en_US',
            EmployeeNumber = '8820109876'
        );
        insert u;

        Case_Classification__c functionalGroup = new Case_Classification__c(
            Name = testFunctionalGroupName,
            Active__c = true,
            Visible__c = true,
            Record_Types_String__c = 'wer',
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
        );
        insert functionalGroup;
        Case_Classification__c category = new Case_Classification__c(
            Name = testCategoryName,
            Active__c = true,
            Visible__c = true,
            Parent__c = functionalGroup.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Category')
        );
        insert category;
        Case_Classification__c subCategory = new Case_Classification__c(
            Name = testSubCategoryName,
            Active__c = true,
            Visible__c = true,
            Parent__c = category.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category')
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
    private static void testSubmitCase() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        String caseDesc = 'Case Description goes here.';

        PageReference pageRef = Page.PersistenceFeedback;
        pageRef.getParameters().put('misc', caseDesc);
        pageRef.getParameters().put('retURL', 'https://return.url');
        pageRef.getParameters().put('contactId', c.Id);
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

        System.assertEquals(c.Id, createdCase.ContactId);
        System.assertEquals('Persistence Outlook feedback', createdCase.Subject);
        System.assertEquals(caseDesc, createdCase.Description);
        System.assertEquals('Test', createdCase.Origin__c);
        System.assertEquals(testFunctionalGroupName, createdCase.CC_Functional_Group__r.Name);
        System.assertEquals(testCategoryName, createdCase.CC_Category__r.Name);
        System.assertEquals(testSubCategoryName, createdCase.CC_Sub_Category__r.Name);
        System.assertEquals(testUserLastName, createdCase.Owner.Name);
        System.assertEquals(testCarEmail.toLowerCase(), createdCase.Case_Feed_Email__c.toLowerCase());
        System.assert(!createdCase.IsVisibleInSelfService);
    }

    @isTest
    private static void testAlertOnInvalidParams() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        String caseDesc = 'Case Description goes here.';

        PageReference pageRef = Page.PersistenceFeedback;
        pageRef.getParameters().put('misc', caseDesc);
        pageRef.getParameters().put('retURL', 'https://return.url');
        pageRef.getParameters().put('contactId', c.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        PersistenceFeedbackController controller = new PersistenceFeedbackController();
        controller.init();
        controller.URLParamsExistAndAreValid = false;
        controller.submit();
        Test.stopTest();

        System.assertEquals(1, controller.alertHandler.alerts.size());
        System.assertEquals(customAlert.FATAL, controller.alertHandler.alerts[0].severity);
        System.assertEquals(
            'Form submission after initialization error. Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080 (1-855-278-5080).',
            controller.alertHandler.alerts[0].message
        );
    }

    @isTest
    private static void testAlertOnEmptyDescription() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        String caseDesc = '';

        PageReference pageRef = Page.PersistenceFeedback;
        pageRef.getParameters().put('misc', caseDesc);
        pageRef.getParameters().put('retURL', 'https://return.url');
        pageRef.getParameters().put('contactId', c.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        PersistenceFeedbackController controller = new PersistenceFeedbackController();
        controller.init();
        controller.submit();
        Test.stopTest();

        System.assertEquals(1, controller.alertHandler.alerts.size());
        System.assertEquals(customAlert.WARNING, controller.alertHandler.alerts[0].severity);
        System.assertEquals('Feedback comments are required.', controller.alertHandler.alerts[0].message);
    }

    @isTest
    private static void testErrorLoggerInSubmit() {
        Case_Assignment_Rule__c car = [SELECT Id FROM Case_Assignment_Rule__c LIMIT 1];
        delete car;

        Test.startTest();
        PersistenceFeedbackController controller = new PersistenceFeedbackController();
        controller.init();
        controller.submit();
        Test.stopTest();

        Case errorLoggerCase = [SELECT Id, Subject FROM Case];
        System.assert(errorLoggerCase.Subject.toLowerCase().contains('apex exception'));
    }
}
