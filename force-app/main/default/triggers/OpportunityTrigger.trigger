trigger OpportunityTrigger on Opportunity(
    after delete,
    after insert,
    after update,
    before delete,
    before insert,
    before update
) {
    TriggerFactory.createAndExecuteHandler(OpportunityHandler.class);

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        TerritoryAssignmentOpportunity ta = new TerritoryAssignmentOpportunity();
        ta.assignTerritories();
    }
}
