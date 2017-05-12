trigger LeadTrigger on Lead (after delete, after insert, after update, before delete, before insert, before update) 
{
    TriggerFactory.createAndExecuteHandler(LeadHandler.class);
    
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) 
    {
        system.debug('territory assignment');
        system.debug('before tah: ' + limits.getQueryRows());
        TerritoryAssignmentHelper tah = new TerritoryAssignmentHelper();
        tah.LeadTA();
        system.debug('after tah' + limits.getQueryRows());
    }
}