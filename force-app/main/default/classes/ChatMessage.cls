public class ChatMessage {
    public String performedBy { get; set; }
    public String text { get; set; }

    public ChatMessage(Chat_Message__c liveChatMessage) {
        this.performedBy = '';
        this.text = liveChatMessage.Body__c;
    }

    public ChatMessage(bomgar__Event__c bomgarMessage) {
        this.performedBy = bomgarMessage.bomgar__PerformedByValue__c;
        this.text = bomgarMessage.bomgar__Text__c;
    }
}
