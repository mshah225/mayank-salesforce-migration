public class NonAuthenticatedLiveAgentLandingPage {
    public Live_Agent_Button__c nonAuthenticatedButton {get; set;}
    
    public NonAuthenticatedLiveAgentLandingPage() {
        nonAuthenticatedButton = Live_Agent_Button__c.getInstance('Non_Authenticated_Live_Chat');
    }
}