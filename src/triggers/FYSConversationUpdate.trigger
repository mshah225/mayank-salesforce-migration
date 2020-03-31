trigger FYSConversationUpdate on smagicinteract__Conversation_Sender_Map__c (after insert, after update) {
    FYSConversationUpdateHandler handler = new FYSConversationUpdateHandler();
    handler.execute(Trigger.new);
}