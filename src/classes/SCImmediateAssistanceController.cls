public class SCImmediateAssistanceController {
	public Live_Agent_Button__c financeChatButton {get; set;}
    public Live_Agent_Button__c studentServicesChatButton {get; set;}
    public Live_Agent_Button__c technicalSupportChatButton {get; set;}
    
    public SCImmediateAssistanceController() {
        financeChatButton = Live_Agent_Button__c.getInstance('Finances_Live_Chat');
        studentServicesChatButton = Live_Agent_Button__c.getInstance('ASU_Services_Live_Chat');
        technicalSupportChatButton = Live_Agent_Button__c.getInstance('Technical_Support_Live_Chat');
    }
}
