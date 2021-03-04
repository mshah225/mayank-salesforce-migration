trigger AccountTrigger on Account(
    after delete,
    after insert,
    after undelete,
    after update,
    before delete,
    before insert,
    before update
) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        TerritoryAssignmentHelper tah = new TerritoryAssignmentHelper();
        tah.AccountTA();
    }
}
