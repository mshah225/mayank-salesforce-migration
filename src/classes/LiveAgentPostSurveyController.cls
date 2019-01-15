public without sharing class LiveAgentPostSurveyController {
    public String postChatSurveyLink {get; set;}
    
    public LiveAgentPostSurveyController() {
        setPostChatSurveyLink();
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
}
