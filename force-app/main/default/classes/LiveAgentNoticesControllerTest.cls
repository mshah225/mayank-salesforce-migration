@isTest
public with sharing class LiveAgentNoticesControllerTest {
    @TestSetup
    private static void setup() {
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
            Chat_Button_Id__c = 'BUTTON_ID',
            Chat_Deployment__c = 'CHAT_DEPLOYMENT',
            Chat_Endpoint__c = 'ENDPOINT',
            Display_Name__c = 'DISPLAY_NAME',
            Org_Id__c = 'ORG_ID'
        );
        insert liveAgentBtn;
    }

    @isTest
    private static void testShowMessage() {
        String buttonName = [SELECT Name FROM Live_Agent_Button__c LIMIT 1].Name;
        Id buttonParamId = [SELECT Id FROM LiveChatButton WHERE DeveloperName = :buttonName LIMIT 1].Id;

        Datetime currentTime = System.now();
        LiveAgent_Custom_Message__c msg = new LiveAgent_Custom_Message__c(
            Custom_Message__c = 'Custom Message',
            Start_Date_Time__c = currentTime.addHours(-2),
            End_Date_Time__c = currentTime.addHours(2),
            LiveAgent_Button__c = buttonName
        );
        insert msg;

        PageReference pageRef = Page.LiveAgentPreSurvey;
        // Start with 3D in button_id because parsing relies on equal sign being represented as %3D but
        // using .getParameters().put(...) uses an equal sign, = (1 character instead of the needed 3)
        pageRef.getParameters().put('button_id', '3D' + buttonParamId.to15());
        Test.setCurrentPage(pageRef);
        Test.startTest();
        LiveAgentNoticesController controller = new LiveAgentNoticesController();
        Test.stopTest();

        System.assertEquals(1, controller.noticeList.size());
    }

    @isTest
    private static void testNoShowOutOfDateMessage() {
        String buttonName = [SELECT Name FROM Live_Agent_Button__c LIMIT 1].Name;
        Id buttonParamId = [SELECT Id FROM LiveChatButton WHERE DeveloperName = :buttonName LIMIT 1].Id;

        Datetime currentTime = System.now();
        LiveAgent_Custom_Message__c msgOld = new LiveAgent_Custom_Message__c(
            Custom_Message__c = 'Custom Message',
            Start_Date_Time__c = currentTime.addHours(-6),
            End_Date_Time__c = currentTime.addHours(-2),
            LiveAgent_Button__c = buttonName
        );
        LiveAgent_Custom_Message__c msgFuture = new LiveAgent_Custom_Message__c(
            Custom_Message__c = 'Custom Message 2',
            Start_Date_Time__c = currentTime.addHours(2),
            End_Date_Time__c = currentTime.addHours(6),
            LiveAgent_Button__c = buttonName
        );
        insert new List<LiveAgent_Custom_Message__c>{ msgOld, msgFuture };

        PageReference pageRef = Page.LiveAgentPreSurvey;
        // Start with 3D in button_id because parsing relies on equal sign being represented as %3D but
        // using .getParameters().put(...) uses an equal sign, = (1 character instead of the needed 3)
        pageRef.getParameters().put('button_id', '3D' + buttonParamId.to15());
        Test.setCurrentPage(pageRef);
        Test.startTest();
        LiveAgentNoticesController controller = new LiveAgentNoticesController();
        Test.stopTest();

        System.assertEquals(0, controller.noticeList.size());
    }
}
