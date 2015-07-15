public without sharing class UserHandler implements ITrigger
{
	public void bulkBefore() {}

	public void bulkAfter() {}

	public void beforeInsert(SObject so) 
	{
		User newUser = (User) so;

		if (newUser.UserPermissionsKnowledgeUser)
		{
			newUser.Role_Knowledge__c = true;
		}

		if(newUser.ContactId != null &&  newUser.Contact.CAP__c == null)
		{
			Profile newUserProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'];
			newUser.ProfileId = newUserProfile.Id;
		}
	}

	public void beforeUpdate(SObject oldSo, SObject so) 
	{
		User updatedUser = (User) so;
		User oldUser = (User) so;

		if (updatedUser.UserPermissionsKnowledgeUser)
		{
			updatedUser.Role_Knowledge__c = true;
		}
		else
		{
			updatedUser.Role_Knowledge__c = false;
		}
	}

	public void beforeDelete(SObject so) {}

	public void beforeFinally() {}

	public void afterInsert(SObject so) {}

	public void afterUpdate(SObject oldSo, SObject so) {}

	public void afterDelete(SObject so) {}

	public void andFinally() {}
}