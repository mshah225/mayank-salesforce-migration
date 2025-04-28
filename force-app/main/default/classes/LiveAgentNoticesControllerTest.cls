@isTest
public with sharing class LiveAgentNoticesControllerTest {
    @isTest
    private static void testShowMessage() {
        setupButtonConfig();
        LiveChatButton chatButton = [
            SELECT Id, DeveloperName
            FROM LiveChatButton
            WHERE DeveloperName != NULL
            ORDER BY DeveloperName ASC
            LIMIT 1
        ];

        Datetime currentTime = System.now();
        LiveAgent_Custom_Message__c msg = new LiveAgent_Custom_Message__c(
            Custom_Message__c = 'Custom Message',
            Start_Date_Time__c = currentTime.addHours(-2),
            End_Date_Time__c = currentTime.addHours(2),
            LiveAgent_Button__c = chatButton.DeveloperName
        );
        insert msg;

        PageReference pageRef = Page.LiveAgentPreSurvey;
        // Start with 3D in button_id because parsing relies on equal sign being represented as %3D but
        // using .getParameters().put(...) uses an equal sign, = (1 character instead of the needed 3)
        pageRef.getParameters().put('button_id', '3D' + chatButton.Id.to15());
        Test.setCurrentPage(pageRef);
        Test.startTest();
        LiveAgentNoticesController controller = new LiveAgentNoticesController();
        Test.stopTest();

        System.assertEquals(1, controller.noticeList.size());
    }

    @isTest
    private static void testNoShowOutOfDateMessage() {
        setupButtonConfig();
        LiveChatButton chatButton = [
            SELECT Id, DeveloperName
            FROM LiveChatButton
            WHERE DeveloperName != NULL
            ORDER BY DeveloperName ASC
            LIMIT 1
        ];

        Datetime currentTime = System.now();
        LiveAgent_Custom_Message__c msgOld = new LiveAgent_Custom_Message__c(
            Custom_Message__c = 'Custom Message',
            Start_Date_Time__c = currentTime.addHours(-6),
            End_Date_Time__c = currentTime.addHours(-2),
            LiveAgent_Button__c = chatButton.DeveloperName
        );
        LiveAgent_Custom_Message__c msgFuture = new LiveAgent_Custom_Message__c(
            Custom_Message__c = 'Custom Message 2',
            Start_Date_Time__c = currentTime.addHours(2),
            End_Date_Time__c = currentTime.addHours(6),
            LiveAgent_Button__c = chatButton.DeveloperName
        );
        insert new List<LiveAgent_Custom_Message__c>{ msgOld, msgFuture };

        PageReference pageRef = Page.LiveAgentPreSurvey;
        // Start with 3D in button_id because parsing relies on equal sign being represented as %3D but
        // using .getParameters().put(...) uses an equal sign, = (1 character instead of the needed 3)
        pageRef.getParameters().put('button_id', '3D' + chatButton.Id.to15());
        Test.setCurrentPage(pageRef);
        Test.startTest();
        LiveAgentNoticesController controller = new LiveAgentNoticesController();
        Test.stopTest();

        System.assertEquals(0, controller.noticeList.size());
    }

    // We cannot insert test custom metadata, and cannot override static variables for all tests using @TestSetup,
    // so we must manually do this in each test function
    private static void setupButtonConfig() {
        String buttonName = [
            SELECT DeveloperName
            FROM LiveChatButton
            WHERE DeveloperName != NULL
            ORDER BY DeveloperName ASC
            LIMIT 1
        ]
        .DeveloperName;

        LiveAgentPreSurveyController.TEST_BUTTON_CONFIG = new Live_Agent_Button_Setting__mdt(
            Label = 'DISPLAY_NAME',
            DeveloperName = buttonName,
            Chat_Button_Id__c = 'BUTTON_ID',
            Chat_Deployment__c = 'CHAT_DEPLOYMENT',
            Chat_Endpoint__c = 'ENDPOINT',
            Org_Id__c = 'ORG_ID'
        );
    }
}
