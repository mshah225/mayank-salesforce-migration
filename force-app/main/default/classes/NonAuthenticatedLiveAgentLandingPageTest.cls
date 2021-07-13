@isTest
public with sharing class NonAuthenticatedLiveAgentLandingPageTest {
    private static final String liveAgentBtnChatButtonId = 'BUTTON_ID';
    private static final String liveAgentBtnChatDeployment = 'CHAT_DEPLOYMENT';
    private static final String liveAgentBtnChatEndpoint = 'ENDPOINT';
    private static final String liveAgentBtnDisplayName = 'DISPLAY_NAME';
    private static final String liveAgentBtnOrgId = 'ORG_ID';

    @TestSetup
    static void setup() {
        Live_Agent_Button__c liveAgentBtn = new Live_Agent_Button__c(
            Name = 'Non_Authenticated_Live_Chat',
            Chat_Button_Id__c = liveAgentBtnChatButtonId,
            Chat_Deployment__c = liveAgentBtnChatDeployment,
            Chat_Endpoint__c = liveAgentBtnChatEndpoint,
            Display_Name__c = liveAgentBtnDisplayName,
            Org_Id__c = liveAgentBtnOrgId
        );
        insert liveAgentBtn;
    }

    @isTest
    private static void testBasicFields() {
        PageReference pageRef = Page.NonAuthenticatedLiveAgentLandingPage;
        // Start with 3D in button_id because parsing relies on equal sign being represented as %3D but
        // using .getParameters().put(...) uses a equal sign, = (1 character instead of the needed 3)
        Test.setCurrentPage(pageRef);
        Test.startTest();
        NonAuthenticatedLiveAgentLandingPage controller = new NonAuthenticatedLiveAgentLandingPage();
        Test.stopTest();

        System.assertEquals(liveAgentBtnOrgId, controller.orgId);
        System.assertEquals(liveAgentBtnChatDeployment, controller.chatDeploymentId);
        System.assertEquals(liveAgentBtnChatButtonId, controller.chatButtonId);
        System.assertEquals(liveAgentBtnChatEndpoint, controller.chatEndpoint);
        System.assertEquals(
            'We apologize for the inconvenience. We are having trouble connecting you with a representative. Please call 1-855-278-5080 to speak to a representative immediately.',
            controller.agentOfflineMessage
        );
    }
}
