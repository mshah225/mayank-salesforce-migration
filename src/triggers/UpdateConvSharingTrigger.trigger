trigger UpdateConvSharingTrigger on smagicinteract__Conversation__c (before insert, before update, before delete,after insert,
                                                                     after update, after delete, after undelete) {
    ConversationDispatcher dispatcher = new ConversationDispatcher(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
    if(trigger.isBefore) {
        if (trigger.isUpdate) {
            dispatcher.beforeUpdate();
        }else if (trigger.isInsert) {
            dispatcher.beforeInsert();
        }else if (trigger.isDelete) {
            dispatcher.beforeDelete();
        }
    } else if (trigger.isAfter){
        if (trigger.isUpdate) {
            dispatcher.afterUpdate();
        }else if (trigger.isInsert) {
            dispatcher.afterInsert();
        }else if (trigger.isDelete) {
            dispatcher.afterDelete();
        }else if (trigger.isUndelete) {
            dispatcher.afterUndelete();
        }
    }                                                                    
}