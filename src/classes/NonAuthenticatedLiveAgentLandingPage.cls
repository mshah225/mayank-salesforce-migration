public class NonAuthenticatedLiveAgentLandingPage {
    public Live_Agent_Button__c nonAuthenticatedButton {get; set;}
    
    public NonAuthenticatedLiveAgentLandingPage() {
        nonAuthenticatedButton = Live_Agent_Button__c.getInstance('Non_Authenticate_Live_Chat');
    }
}