@isTest
private class EmailAPIServiceTest {
    private static Contact testContact;
    private static List<Case> testCases;
    private static EmailTemplate testEmailTemplate;
    private static Case_Assignment_Rule__c testCAR;

    private static void createTestData() {
        testContact = ContactService.createTestContact();
        insert testContact;

        testCases = CaseService.createTestCases(1, testContact);
        insert testCases;
    }

    @future
    private static void createFutureTestData() {
        testEmailTemplate = new EmailTemplate(
            DeveloperName = 'email_test_dev_name',
            FolderId = UserInfo.getUserId(),
            TemplateType = 'text',
            Name = 'i am a test template',
            Subject = 'test template subject',
            HtmlValue = 'test template body'
        );
        insert testEmailTemplate;

        String templateId = testEmailTemplate.Id;
        templateId = templateId.substring(0, 14);

        String contactId = testContact.Id;
        contactId = contactId.substring(0, 14);

        testCAR = new Case_Assignment_Rule__c(
            Priority__c = 8888,
            Queue_ID__c = contactId,
            Customer_Notice_Email_From_Name__c = 'test test',
            Email_Template_ID__c = templateId
        );
        insert testCAR;
    }

    @isTest
    private static void sendAutoReplyTest() {
        User usr = [SELECT id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(usr) {
            Test.startTest();
            createTestData();
            createFutureTestData();
            Test.stopTest();

            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/EmailService/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof('{ "emailCaseId": "", "carId": "' + testCAR.Id + '" }');
            RestContext.request = request;
            RestContext.response = response;

            EmailAPIService.sendAutoReply(testCases[0].Id, testCar.Id);

            System.assertEquals(400, response.statusCode);
        }
    }

    @isTest
    private static void sendAutoReplyTestBadCase() {
        User usr = [SELECT id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(usr) {
            Test.startTest();
            createTestData();
            createFutureTestData();
            Test.stopTest();

            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/EmailService/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof('{ "emailCaseId": "", "carId": "' + testCAR.Id + '" }');
            RestContext.request = request;
            RestContext.response = response;

            Case badCase = new Case();

            EmailAPIService.sendAutoReply(badCase.Id, testCar.Id);

            System.assertEquals(400, response.statusCode);
        }
    }

    @isTest
    private static void getDefaultOrgWideEmailAddressTest() {
        Test.startTest();
        Email_To_Case_Configuration__c emailCaseConfig = new Email_To_Case_Configuration__c(
            Name = 'Default Org Wide Email Address',
            Value__c = 'test@test.test'
        );
        insert emailCaseConfig;
        EmailAPIService.loadConfigurationSettings();
        String orgWideEmailAddress = EmailAPIService.getConfigurationSetting('Default Org Wide Email Address');

        OrgWideEmailAddress[] owea = [
            SELECT Id, DisplayName, Address
            FROM OrgWideEmailAddress
            WHERE Address = :orgWideEmailAddress
        ];
        Test.stopTest();

        if (!owea.isEmpty()) {
            System.assertEquals(owea[0], EmailAPIService.getDefaultOrgWideEmailAddress());
        } else {
            System.assertEquals(null, EmailAPIService.getDefaultOrgWideEmailAddress());
        }
    }
}
