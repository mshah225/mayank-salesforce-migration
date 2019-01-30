public without sharing class LiveAgentPostSurveyController {
    public String postChatSurveyLink {get; set;}
    public String agentOfflineMessage {get; set;}
    
    public LiveAgentPostSurveyController() {
        setPostChatSurveyLink();
        setAgentOfflineMessage();
    }
    
    private void setPostChatSurveyLink() {
        List<Live_Agent_Setting__mdt> settings = [
            SELECT Value__c 
            FROM Live_Agent_Setting__mdt 
            WHERE DeveloperName = 'Post_Chat_Survey_Link'
            LIMIT 1
        ];
        
        postChatSurveyLink = settings.isEmpty() ? '' : settings[0].Value__c;
    }
    
    private void setAgentOfflineMessage() {
        List<LiveAgent_Custom_Message__c> offlineMessages = [
            SELECT Custom_Message__c 
            FROM LiveAgent_Custom_Message__c 
            WHERE LiveAgent_Button__c = 'Agent Offline'
            ORDER BY CreatedDate DESC
        ];
        agentOfflineMessage = offlineMessages.isEmpty() ? 'We apologize for the inconvenience. We are having trouble connecting you with a representative. Please call 1-855-278-5080 to speak to a representative immediately.' : offlineMessages[0].Custom_Message__c;
    }
}