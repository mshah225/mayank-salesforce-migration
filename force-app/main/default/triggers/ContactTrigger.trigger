trigger ContactTrigger on Contact(
    after delete,
    after insert,
    after update,
    before delete,
    before insert,
    before update
) {
    TriggerFactory.createAndExecuteHandler(ContactHandler.class);

    if (Trigger.isAfter && Trigger.isUpdate) {
        TerritoryAssignmentContact ta = new TerritoryAssignmentContact();
        ta.assignTerritoriesOnAfterUpdate();
    }
}
