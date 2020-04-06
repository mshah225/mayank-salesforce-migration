global with sharing class CustomSenderService implements Callable {

    // Dispatch actual methods
    global Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'getSenderInfo' {
                return this.getSenderIds((String)args.get('givenCriteria'), (List<String>)args.get('ids'));
            }
            when else {
                throw new SenderServiceMalformedCallException('Method not implemented');
            }
        }
    }

    List<smagicinteract__SMS_SenderId__c> getSenderIds(String givenCriteria, List<String> ids) {
        Boolean flag = true ;
        Set<Id> convIds = new Set<Id>();
        List<smagicinteract__SMS_SenderId__c> senderIds = new List<smagicinteract__SMS_SenderId__c>();
        System.debug('@@--Ids passed : '+ ids);
        for(Id record : ids) {
            if(smagicinteract__Conversation__c.sObjectType == record.getsobjecttype()) {
                convIds.add(record);
            }
        }
        if(convIds != null && convIds.size() > 0) {
            for(smagicinteract__Conversation__c conv : [select Id, (select smagicinteract__SMS_SenderId__r.Id, 
                                                                    smagicinteract__SMS_SenderId__r.smagicinteract__senderId__c, 
                                                                    smagicinteract__SMS_SenderId__r.smagicinteract__Label__c,
                                                                    smagicinteract__SMS_SenderId__r.smagicinteract__Description__c,
                                                                    smagicinteract__SMS_SenderId__r.IsEnterpriseUser__c,
                                                                    smagicinteract__SMS_SenderId__r.smagicinteract__Used_For__c,
                                                                    smagicinteract__SMS_SenderId__r.smagicinteract__Email_Notification_Template__c,
                                                                    smagicinteract__SMS_SenderId__r.smagicinteract__Notification_Recipient__c
                                                                    from smagicinteract__Conversation_Sender_Map__r)
                                                        from smagicinteract__Conversation__c
                                                        where Id in :convIds]) {
                if(conv.smagicinteract__Conversation_Sender_Map__r != null) {
                    for(smagicinteract__Conversation_Sender_Map__c convMap : conv.smagicinteract__Conversation_Sender_Map__r) {
                        if(convMap.smagicinteract__SMS_SenderId__r != null && convMap.smagicinteract__SMS_SenderId__r.IsEnterpriseUser__c) {
                            senderIds.add(convMap.smagicinteract__SMS_SenderId__r);
                            flag = false;
                        }                                                              
                    }
                }
            }
        }
        if(flag){
            senderIds = getDefaultSenderIds();
        }
        System.debug('@@final Sender Ids : '+ senderIds);
        return senderIds;
    }

    private List<smagicinteract__SMS_SenderId__c> getDefaultSenderIds() {
        List<smagicinteract__SMS_SenderId__c> senderIds = new List<smagicinteract__SMS_SenderId__c>();
        for(smagicinteract__SenderId_Profile_Map__c senderProfileMap :  [select id, smagicinteract__SenderId_Lookup__r.Id, 
                                                                         smagicinteract__SenderId_Lookup__r.smagicinteract__senderId__c, 
                                                                         smagicinteract__SenderId_Lookup__r.smagicinteract__Label__c,
                                                                         smagicinteract__SenderId_Lookup__r.smagicinteract__Description__c,
                                                                         smagicinteract__SenderId_Lookup__r.IsEnterpriseUser__c,
                                                                         smagicinteract__SenderId_Lookup__r.smagicinteract__Used_For__c,
                                                                         smagicinteract__SenderId_Lookup__r.smagicinteract__Email_Notification_Template__c,
                                                                         smagicinteract__SenderId_Lookup__r.smagicinteract__Notification_Recipient__c
                                                                         from smagicinteract__SenderId_Profile_Map__c 
                                                                         where (smagicinteract__User__c = :UserInfo.getUserId() 
                                                                         or smagicinteract__Profile_Id__c = :UserInfo.getProfileId())
                                                                         order by smagicinteract__User__c ASC NULLS last]) {
            if(String.isNotBlank(senderProfileMap.smagicinteract__SenderId_Lookup__r.smagicinteract__senderId__c)) {
                senderIds.add(senderProfileMap.smagicinteract__SenderId_Lookup__r);
                break;
            }                                                             
        }
        System.debug('@@--defaultSenderIds : '+ senderIds);
        return senderIds; 
    }
    
    public class SenderServiceMalformedCallException extends Exception {}
}