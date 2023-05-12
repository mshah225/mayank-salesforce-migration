trigger CampaignTrigger on Campaign(
    after delete,
    after insert,
    after undelete,
    after update,
    before delete,
    before insert,
    before update
) {
    CampaignDispatcher dispatcher = new CampaignDispatcher(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            dispatcher.beforeUpdate();
        } else if (Trigger.isInsert) {
            dispatcher.beforeInsert();
        } else if (Trigger.isDelete) {
            dispatcher.beforeDelete();
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            dispatcher.afterUpdate();
        } else if (Trigger.isInsert) {
            dispatcher.afterInsert();
        } else if (Trigger.isDelete) {
            dispatcher.afterDelete();
        } else if (Trigger.isUndelete) {
            dispatcher.afterUndelete();
        }
    }
}
