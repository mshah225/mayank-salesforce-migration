trigger PreviousEducationTrigger on Previous_Education__c(
    after delete,
    after insert,
    after undelete,
    after update,
    before delete,
    before insert,
    before update
) {
    TriggerFactory.createAndExecuteHandler(PreviousEducationHandler.class);

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        TerritoryAssignmentPreviousEducation ta = new TerritoryAssignmentPreviousEducation();
        ta.assignTerritories();
    }
}
