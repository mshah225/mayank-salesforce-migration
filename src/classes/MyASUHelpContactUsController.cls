public without sharing class MyASUHelpContactUsController {
    public String financeChatButton { get; set; }
    public String financeDisplayName { get; set; }
    public String studentServicesChatButton { get; set; }
    public String studentServicesDisplayName { get; set; }
    public String technicalSupportChatButton { get; set; }
    public String technicalSupportDisplayName { get; set; }
    public String orgId { get; set; }
    public String deploymentId { get; set; }
    public String chatEndpoint { get; set; }

    public String contactUsEmailSubject { get; set; }
    public String contactUsEmailMessage { get; set; }

    public MyASUHelpContactUsController() {
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
        technicalSupportDisplayName = technicalSupportChatLAB.Display_Name__c;
    }

    public void sendContactUsEmail() {
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //List<String> toAddresses = new List<String>{ 'salesforcesupport@asu.edu' };
        List<String> toAddresses = new List<String>{ 'mgilardi@asu.edu' };
        mail.setToAddresses(toAddresses);
        mail.setReplyTo(UserInfo.getUserEmail());
        mail.setSenderDisplayName(UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
        mail.setSubject('My ASU Help submission: ' + contactUsEmailSubject);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody(contactUsEmailMessage);
        mail.setHtmlBody(contactUsEmailMessage);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
}
