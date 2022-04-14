trigger StudentProgramPlanTrigger on Student_Program_Plan__c(
    after delete,
    after insert,
    after undelete,
    after update,
    before delete,
    before insert,
    before update
) {
    StudentProgramPlanDispatcher dispatcher = new StudentProgramPlanDispatcher(
        Trigger.new,
        Trigger.newMap,
        Trigger.old,
        Trigger.oldMap
    );

    if (Trigger.isBefore) {
        if (Trigger.isUpdate)
            dispatcher.beforeUpdate();
        if (Trigger.isInsert)
            dispatcher.beforeInsert();
        if (Trigger.isDelete)
            dispatcher.beforeDelete();
    }
    if (Trigger.isAfter) {
        if (Trigger.isUpdate)
            dispatcher.afterUpdate();
        if (Trigger.isInsert)
            dispatcher.afterInsert();
        if (Trigger.isDelete)
            dispatcher.afterDelete();
        if (Trigger.isUnDelete)
            dispatcher.afterUnDelete();
    }
}