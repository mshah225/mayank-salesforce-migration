public with sharing class ConversationDispatcher {
    private List<smagicinteract__Conversation__c> newList;
    private Map<Id, smagicinteract__Conversation__c> newMap;
    private List<smagicinteract__Conversation__c> oldList;
    private Map<Id, smagicinteract__Conversation__c> oldMap;

    public ConversationDispatcher(
        List<smagicinteract__Conversation__c> newList,
        Map<Id, smagicinteract__Conversation__c> newMap,
        List<smagicinteract__Conversation__c> oldList,
        Map<Id, smagicinteract__Conversation__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
    }

    public void beforeUpdate() {
    }

    public void beforeDelete() {
    }

    public void afterInsert() {
        ConversationServicer service = new ConversationServicer();
        service.execute(newList);
    }

    public void afterUpdate() {
        ConversationServicer service = new ConversationServicer();
        service.execute(newList);
        service.updateSharing(oldMap, newMap);
    }

    public void afterDelete() {
    }

    public void afterUndelete() {
    }
}
