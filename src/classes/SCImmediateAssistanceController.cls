public without sharing class SCImmediateAssistanceController {
	public String financeChatButton {get; set;}
    public String financeDisplayName {get; set;}
    public String studentServicesChatButton {get; set;}
    public String studentServicesDisplayName {get; set;}
    public String technicalSupportChatButton {get; set;}
    public String technicalSupportDisplayName {get; set;}
    public String orgId {get; set;}
    public String deploymentId {get; set;}
    public String chatEndpoint {get; set;}
    
    public SCImmediateAssistanceController() {
        Live_Agent_Button__c financeChatLAB = Live_Agent_Button__c.getInstance('Finances_Live_Chat');
        Live_Agent_Button__c studentServicesChatLAB = Live_Agent_Button__c.getInstance('ASU_Services_Live_Chat');
        Live_Agent_Button__c technicalSupportChatLAB = Live_Agent_Button__c.getInstance('Technical_Support_Live_Chat');
        
        orgId = financeChatLAB.Org_Id__c;
        deploymentId = financeChatLAB.Chat_Deployment__c;
        chatEndpoint = financeChatLAB.Chat_Endpoint__c;
        
        financeChatButton = financeChatLAB.Chat_Button_Id__c;
        financeDisplayName = financeChatLAB.Display_Name__c;
        studentServicesChatButton = studentServicesChatLAB.Chat_Button_Id__c;
        studentServicesDisplayName = studentServicesChatLAB.Display_Name__c;
        technicalSupportChatButton = technicalSupportChatLAB.Chat_Button_Id__c;
        technicalSupportDisplayName = studentServicesChatLAB.Display_Name__c;
    }
}