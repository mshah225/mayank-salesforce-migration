@isTest
public with sharing class LiveAgentPostSurveyControllerTest {
    private static final String defaultOfflineMsg = 'We apologize for the inconvenience. We are having trouble connecting you with a representative. Please call 1-855-278-5080 to speak to a representative immediately.';
    private static final String contactFirstName = 'TestFirstName';

    @TestSetup
    static void setup() {
        Contact con = new Contact(FirstName = contactFirstName, LastName = 'TestContact-LiveAgentPostSurvey');
        insert con;

        Case c = new Case(ContactId = con.Id);
        insert c;
    }

    @isTest
    private static void testBasicFields() {
        String nonAuthCallerId = [
            SELECT Value__c
            FROM Live_Agent_Setting__mdt
            WHERE DeveloperName = 'Non_Authenticated_CallerId'
            LIMIT 1
        ]
        .Value__c;

        PageReference pageRef = Page.LiveAgentPostSurvey;
        pageRef.getParameters().put('attachedRecords', '{ "ContactId" : "' + nonAuthCallerId + '" }');
        Test.setCurrentPage(pageRef);
        LiveAgentPostSurveyController controller = new LiveAgentPostSurveyController();

        System.assert(controller.postChatSurveyLink.contains('getfeedback.com'));
        System.assertEquals(nonAuthCallerId, controller.nonAuthCallerId);
        System.assertEquals(defaultOfflineMsg, controller.agentOfflineMessage);
        System.assertEquals('Visitor', controller.contactName);
    }
    @isTest
    private static void testContactAsParam() {
        String contactId = [SELECT Id FROM Contact].Id;
        PageReference pageRef = Page.LiveAgentPostSurvey;
        pageRef.getParameters().put('attachedRecords', '{ "ContactId" : "' + contactId + '" }');
        Test.setCurrentPage(pageRef);
        LiveAgentPostSurveyController controller = new LiveAgentPostSurveyController();

        System.assertEquals(contactFirstName, controller.contactName);
    }

    @isTest
    private static void testCaseAsParam() {
        String caseId = [SELECT Id FROM Case].Id;
        PageReference pageRef = Page.LiveAgentPostSurvey;
        pageRef.getParameters().put('attachedRecords', '{ "CaseId" : "' + caseId + '" }');
        Test.setCurrentPage(pageRef);
        LiveAgentPostSurveyController controller = new LiveAgentPostSurveyController();

        System.assertEquals(contactFirstName, controller.contactName);
    }
}