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
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            dispatcher.afterInsert();
        }
    }
}
