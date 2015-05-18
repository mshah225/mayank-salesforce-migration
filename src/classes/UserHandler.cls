public without sharing class UserHandler implements ITrigger
{
	public void bulkBefore() {}

	public void bulkAfter() {}

	public void beforeInsert(SObject so) 
	{
		User newUser = (User) so;

		if (newUser.UserPermissionsKnowledgeUser)
		{
			newUser.Is_Knowledge_User__c = true;
		}
	}

	public void beforeUpdate(SObject oldSo, SObject so) 
	{
		User updatedUser = (User) so;
		User oldUser = (User) so;

		if (updatedUser.UserPermissionsKnowledgeUser)
		{
			updatedUser.Is_Knowledge_User__c = true;
		}
		else
		{
			updatedUser.Is_Knowledge_User__c = false;
		}
	}

	public void beforeDelete(SObject so) {}

	public void beforeFinally() {}

	public void afterInsert(SObject so) {}

	public void afterUpdate(SObject oldSo, SObject so) {}

	public void afterDelete(SObject so) {}

	public void andFinally() {}
}