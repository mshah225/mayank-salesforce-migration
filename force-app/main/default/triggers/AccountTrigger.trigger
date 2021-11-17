trigger AccountTrigger on Account(
    after delete,
    after insert,
    after undelete,
    after update,
    before delete,
    before insert,
    before update
) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            TerritoryAssignmentAccount ta = new TerritoryAssignmentAccount();
            ta.assignTerritoriesOnBeforeInsert();
        } else if (Trigger.isUpdate) {
            TerritoryAssignmentAccount ta = new TerritoryAssignmentAccount();
            ta.assignTerritoriesOnBeforeUpdate();
        }
    }
}
