trigger LeadTrigger on Lead(after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createAndExecuteHandler(LeadHandler.class);

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        TerritoryAssignmentHelper tah = new TerritoryAssignmentHelper();
        tah.LeadTA();
    }
}
