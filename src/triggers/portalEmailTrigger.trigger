trigger portalEmailTrigger on Portal_Email__c (after delete, after insert, after undelete, after update,
    before delete, before insert, before update) {
    
    PortalEmailDispatcher d = new PortalEmailDispatcher(trigger.newMap, trigger.oldMap);
        
    if (trigger.isBefore) {
        if (trigger.isUpdate) d.beforeUpdate();
        if (trigger.isInsert) d.beforeInsert();
        if (trigger.isDelete) d.beforeDelete();
    }
    if (trigger.isAfter) {
        if (trigger.isUpdate) d.afterUpdate();
        if (trigger.isInsert) d.afterInsert();
        if (trigger.isDelete) d.afterDelete();
        if (trigger.isUnDelete) d.afterUnDelete();
    }
}