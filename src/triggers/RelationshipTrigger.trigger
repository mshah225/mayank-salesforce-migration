trigger RelationshipTrigger on Relationship__c (after delete, after insert, after update,
before delete, before insert, before update) {
    TriggerFactory.createAndExecuteHandler(RelationshipHandler.class);
}