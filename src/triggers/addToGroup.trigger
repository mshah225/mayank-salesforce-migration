trigger addToGroup on User (after insert, after update) {

    ChatterAutoAddUsers.AddToServiceGroup(trigger.newMap.keySet());
    
}