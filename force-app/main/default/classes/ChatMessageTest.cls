@isTest
private class ChatMessageTest {
	@isTest
    private static void testChatMessageObj() {
        Chat_Message__c message = new Chat_Message__c();
        message.Body__c = 'Test Body';
        
        Test.startTest();
    	ChatMessage chat = new ChatMessage(message);
        Test.stopTest();
        
        System.assertEquals(message.Body__c, chat.text);
    }
    
    @isTest
    private static void testBomgarEventObj() {
        bomgar__Event__c message = new bomgar__Event__c();
        message.bomgar__PerformedByValue__c = 'Test Performed by Value';
        message.bomgar__Text__c = 'Test Text';
        
        Test.startTest();
    	ChatMessage chat = new ChatMessage(message);
        Test.stopTest();
        
        System.assertEquals(message.bomgar__PerformedByValue__c, chat.performedBy);
        System.assertEquals(message.bomgar__Text__c, chat.text);
    }
}