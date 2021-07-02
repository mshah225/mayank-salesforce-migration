@isTest
public with sharing class LiveAgentPreSurveyControllerTest {
    private static final String liveAgentBtnChatButtonId = 'BUTTON_ID';
    private static final String liveAgentBtnChatDeployment = 'CHAT_DEPLOYMENT';
    private static final String liveAgentBtnChatEndpoint = 'ENDPOINT';
    private static final String liveAgentBtnDisplayName = 'DISPLAY_NAME';
    private static final String liveAgentBtnOrgId = 'ORG_ID';
    private static final String carCaseRecordTypeId = 'CS_RCRD_TYP_ID';

    @TestSetup
    static void setup() {
        String buttonName = [
            SELECT DeveloperName
            FROM LiveChatButton
            WHERE DeveloperName != NULL
            ORDER BY DeveloperName ASC
            LIMIT 1
        ]
        .DeveloperName;

        Live_Agent_Button__c liveAgentBtn = new Live_Agent_Button__c(
            Name = buttonName,
            Chat_Button_Id__c = liveAgentBtnChatButtonId,
            Chat_Deployment__c = liveAgentBtnChatDeployment,
            Chat_Endpoint__c = liveAgentBtnChatEndpoint,
            Display_Name__c = liveAgentBtnDisplayName,
            Org_Id__c = liveAgentBtnOrgId
        );
        insert liveAgentBtn;

        Case_Classification__c functionalGroup = new Case_Classification__c(
            Name = 'TestFunctionalGroup',
            Active__c = true,
            Visible__c = true,
            Record_Types_String__c = 'wer',
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
        );
        insert functionalGroup;
        Case_Classification__c category = new Case_Classification__c(
            Name = 'TestCategory',
            Active__c = true,
            Visible__c = true,
            Parent__c = functionalGroup.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Category')
        );
        insert category;
        Case_Classification__c subcategory = new Case_Classification__c(
            Name = 'TestSubCategory',
            Active__c = true,
            Visible__c = true,
            Parent__c = category.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category')
        );
        insert subcategory;

        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'test.user.Emperor.Of.Byzantium@test.test',
            Email = 'test.user@test.test',
            Alias = 'testuser',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = IDHelper.getProfileID('System Administrator'),
            LanguageLocaleKey = 'en_US'
        );
        insert u;

        Group g = new Group(Name = 'TestGroupName', Type = 'Queue');
        insert g;
    }

    @isTest
    private static void testBasicFields() {
        String buttonName = [SELECT Name FROM Live_Agent_Button__c LIMIT 1].Name;
        Id buttonParamId = [SELECT Id FROM LiveChatButton WHERE DeveloperName = :buttonName LIMIT 1].Id;
        Id functionalGroupId = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IDHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
            LIMIT 1
        ]
        .Id;
        Id categoryId = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IDHelper.getRecordTypeId('Case_Classification__c', 'Category')
            LIMIT 1
        ]
        .Id;
        Id subCategoryId = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IDHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category')
            LIMIT 1
        ]
        .Id;
        User u = [SELECT Id, Name FROM User LIMIT 1];

        // Case_Assignment_Rule__c specific to each test
        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Case_Record_Type_Id__c = carCaseRecordTypeId,
            CC_Functional_Group__c = functionalGroupId,
            CC_Category__c = categoryId,
            CC_Sub_Category__c = subCategoryId,
            Queue_ID__c = u.Id.to15(),
            OwnerId = u.Id,
            Email_Address__c = buttonName + '@asu.edu'
        );
        insert car;

        PageReference pageRef = Page.LiveAgentPreSurvey;
        // Start with 3D in button_id because parsing relies on equal sign being represented as %3D but
        // using .getParameters().put(...) uses a equal sign, = (1 character instead of the needed 3)
        pageRef.getParameters().put('button_id', '3D' + buttonParamId.to15());
        Test.setCurrentPage(pageRef);
        Test.startTest();
        LiveAgentPreSurveyController controller = new LiveAgentPreSurveyController();
        Test.stopTest();

        System.assertEquals(buttonName, controller.buttonPressed);
        System.assertEquals(liveAgentBtnChatButtonId, controller.chatButtonId);
        System.assertEquals(liveAgentBtnChatDeployment, controller.chatDeploymentId);
        System.assertEquals(liveAgentBtnChatEndpoint, controller.chatEndpoint);
        System.assertEquals(liveAgentBtnOrgId, controller.orgId);
        System.assertEquals(carCaseRecordTypeId, controller.caseRecordType);
        System.assertEquals(functionalGroupId, controller.caseFunctionalGroup);
        System.assertEquals(categoryId, controller.caseCategory);
        System.assertEquals(subCategoryId, controller.caseSubCategory);
        System.assertEquals(u.Id, controller.caseOwnerId);
        System.assertEquals(u.Name + ' ' + buttonName.replace('_', ' '), controller.caseSubject);
        System.assertEquals(Label.PreSurveyQuestion, controller.presurveyQuestion);
        System.assertEquals('No agents are available.', controller.agentOfflineMessage);
    }

    @isTest
    private static void testWithUserOwner() {
        String buttonName = [SELECT Name FROM Live_Agent_Button__c LIMIT 1].Name;
        Id buttonParamId = [SELECT Id FROM LiveChatButton WHERE DeveloperName = :buttonName LIMIT 1].Id;
        Id functionalGroupId = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IDHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
            LIMIT 1
        ]
        .Id;
        Id categoryId = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IDHelper.getRecordTypeId('Case_Classification__c', 'Category')
            LIMIT 1
        ]
        .Id;
        Id subCategoryId = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IDHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category')
            LIMIT 1
        ]
        .Id;
        User u = [SELECT Id, Name FROM User LIMIT 1];

        // Case_Assignment_Rule__c specific to each test
        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Case_Record_Type_Id__c = carCaseRecordTypeId,
            CC_Functional_Group__c = functionalGroupId,
            CC_Category__c = categoryId,
            CC_Sub_Category__c = subCategoryId,
            Queue_ID__c = u.Id.to15(),
            OwnerId = u.Id,
            Email_Address__c = buttonName + '@asu.edu'
        );
        insert car;

        PageReference pageRef = Page.LiveAgentPreSurvey;
        // Start with 3D in button_id because parsing relies on equal sign being represented as %3D but
        // using .getParameters().put(...) uses a equal sign, = (1 character instead of the needed 3)
        pageRef.getParameters().put('button_id', '3D' + buttonParamId.to15());
        Test.setCurrentPage(pageRef);
        Test.startTest();
        LiveAgentPreSurveyController controller = new LiveAgentPreSurveyController();
        Test.stopTest();

        System.assertEquals(u.Id, controller.caseOwnerId);
        System.assertEquals(u.Name + ' ' + buttonName.replace('_', ' '), controller.caseSubject);
    }

    @isTest
    private static void testWithGroupOwner() {
        String buttonName = [SELECT Name FROM Live_Agent_Button__c LIMIT 1].Name;
        Id buttonParamId = [SELECT Id FROM LiveChatButton WHERE DeveloperName = :buttonName LIMIT 1].Id;
        Id functionalGroupId = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IDHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
            LIMIT 1
        ]
        .Id;
        Id categoryId = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IDHelper.getRecordTypeId('Case_Classification__c', 'Category')
            LIMIT 1
        ]
        .Id;
        Id subCategoryId = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IDHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category')
            LIMIT 1
        ]
        .Id;
        User u = [SELECT Id, Name FROM User LIMIT 1];
        Group g = [SELECT Id, Name FROM Group LIMIT 1];

        // Case_Assignment_Rule__c specific to each test
        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Case_Record_Type_Id__c = carCaseRecordTypeId,
            CC_Functional_Group__c = functionalGroupId,
            CC_Category__c = categoryId,
            CC_Sub_Category__c = subCategoryId,
            Queue_ID__c = g.Id.to15(),
            OwnerId = u.Id,
            Email_Address__c = buttonName + '@asu.edu'
        );
        insert car;

        PageReference pageRef = Page.LiveAgentPreSurvey;
        // Start with 3D in button_id because parsing relies on equal sign being represented as %3D but
        // using .getParameters().put(...) uses a equal sign, = (1 character instead of the needed 3)
        pageRef.getParameters().put('button_id', '3D' + buttonParamId.to15());
        Test.setCurrentPage(pageRef);
        Test.startTest();
        LiveAgentPreSurveyController controller = new LiveAgentPreSurveyController();
        Test.stopTest();

        System.assertEquals(g.Id, controller.caseOwnerId);
        System.assertEquals(g.Name + ' ' + buttonName.replace('_', ' '), controller.caseSubject);
    }
}
