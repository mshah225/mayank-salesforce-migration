trigger StudentProgramPlanTrigger on Student_Program_Plan__c (after delete, after insert, after undelete, after update,
    before delete, before insert, before update) {

    StudentProgramPlanDispatcher dispatcher = new StudentProgramPlanDispatcher(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);

    if (trigger.isBefore) {}
    if (trigger.isAfter) {
        if (trigger.isInsert) {
            dispatcher.afterInsert();
        }
    }
}
