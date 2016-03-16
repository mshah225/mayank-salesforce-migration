trigger CampaignMemberTrigger on CampaignMember (after delete, after insert, after update, before delete, before insert, before update)
{
	TriggerFactory.createAndExecuteHandler(CampaignMemberHandler.class);
}