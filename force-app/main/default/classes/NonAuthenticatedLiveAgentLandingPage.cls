public class NonAuthenticatedLiveAgentLandingPage {
    public Live_Agent_Button__c nonAuthenticatedButton { get; set; }
    public String orgId { get; set; }
    public String chatDeploymentId { get; set; }
    public String chatButtonId { get; set; }
    public String chatEndpoint { get; set; }
    public String scriptEndpointUrl { get; set; }
    public String agentOfflineMessage { get; set; }

    public NonAuthenticatedLiveAgentLandingPage() {
        nonAuthenticatedButton = Live_Agent_Button__c.getInstance('Non_Authenticated_Live_Chat');
        orgId = nonAuthenticatedButton.Org_Id__c;
        chatDeploymentId = nonAuthenticatedButton.Chat_Deployment__c;
        chatButtonId = nonAuthenticatedButton.Chat_Button_Id__c;
        chatEndpoint = nonAuthenticatedButton.Chat_Endpoint__c;
        scriptEndpointUrl = chatEndpoint.replace('https://d', 'https://c').replace('/chat', '');
        setAgentOfflineMessage();
    }

    private void setAgentOfflineMessage() {
        List<LiveAgent_Custom_Message__c> offlineMessages = [
            SELECT Custom_Message__c
            FROM LiveAgent_Custom_Message__c
            WHERE LiveAgent_Button__c = 'Agent Offline'
            ORDER BY CreatedDate DESC
        ];
        agentOfflineMessage = offlineMessages.isEmpty()
            ? 'We apologize for the inconvenience. We are having trouble connecting you with a representative. Please call 1-855-278-5080 to speak to a representative immediately.'
            : offlineMessages[0].Custom_Message__c;
    }
}
