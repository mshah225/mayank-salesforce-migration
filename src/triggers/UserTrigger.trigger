trigger UserTrigger on User(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerFactory.createAndExecuteHandler(UserHandler.class);

    Boolean needsBatch = (System.isBatch() || System.isFuture());

    /**
     * If we are running asyncronously, call Chatter add syncronously,
     * else call the future wrapper to run asyncronously.
     */
    if (needsBatch && Trigger.isAfter) {
        ChatterAutoAddUsers.addToChatterGroup(Trigger.newMap.keySet());
    } else if (Trigger.isAfter) {
        ChatterAutoAddUsers.addToChatterGroupFuture(Trigger.newMap.keySet());
    }
}
