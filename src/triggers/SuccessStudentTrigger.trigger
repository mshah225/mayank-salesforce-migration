trigger SuccessStudentTrigger on Success_Student__c (after delete, after insert, after undelete, after update,
    before delete, before insert, before update) {
    SuccessStudentDispatcher dispatcher = new SuccessStudentDispatcher(trigger.newMap, trigger.oldMap);
    
    if (trigger.isBefore) {
        if (trigger.isUpdate) dispatcher.beforeUpdate();
        if (trigger.isInsert) dispatcher.beforeInsert();
        if (trigger.isDelete) dispatcher.beforeDelete();
    }
    if (trigger.isAfter) {
        if (trigger.isUpdate) dispatcher.afterUpdate();
        if (trigger.isInsert) dispatcher.afterInsert();
        if (trigger.isDelete) dispatcher.afterDelete();
        if (trigger.isUnDelete) dispatcher.afterUnDelete();
    }
}