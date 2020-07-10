trigger FamilyPortalGuardianTrigger on Family_Portal_Guardian__c (after delete, after insert, after update, before delete, before insert, before update) {
    FamilyPortalGuardianDispatcher dispatcher = new FamilyPortalGuardianDispatcher(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
    
    if (trigger.isBefore) {
        if (trigger.isInsert) {
          dispatcher.beforeInsert();
        }
        if (trigger.isUpdate) {
          dispatcher.beforeUpdate();
        }
        if (trigger.isDelete) {
          dispatcher.beforeDelete();
        }
    }
    
    if (trigger.isAfter) {
        if (trigger.isInsert) {
          dispatcher.afterInsert();
        }
        if (trigger.isUpdate) {
          dispatcher.afterUpdate();
        }
        if (trigger.isDelete) {
          dispatcher.afterDelete();
        }
        if (trigger.isUndelete) {
          dispatcher.afterUndelete();
        }
    }
}