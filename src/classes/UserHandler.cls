public without sharing class UserHandler implements ITrigger
{
	public void bulkBefore() 
	{
		if(Trigger.isInsert)
		{
			List<User> newUsers = Trigger.new; 
			Id communityProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
			Id communityCapProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'].Id;

			for(Integer x = 0; x < newUsers.size(); x++)
			{
				User newUser = newUsers.get(0);

				if (newUser.UserPermissionsKnowledgeUser)
				{
					newUser.Role_Knowledge__c = true;
				}

				if(newUser.ProfileId == communityProfile)
				{
					Contact newUserContact;
					if(newUser.ContactId == null)
					{
						newUserContact = [SELECT Id, CAP__c FROM Contact WHERE ASURite_ID__c = :newUser.Alias AND FirstName = :newUser.FirstName AND LastName = :newUser.LastName LIMIT 1];
						if(newUserContact == null)
						{
							newUser.ContactId.addError('No Contact for this user!');	
						}
						else
						{
							newUser.ContactId = newUserContact.Id;	
						}
					}
					else
					{
						newUserContact = [SELECT CAP__c FROM Contact WHERE Id = :newUser.ContactId];
					}

					if(newUserContact.CAP__c != null)
					{
						newUser.ProfileId = communityCapProfile;
					}
				}
			}
		}
	}

	public void bulkAfter() {}

	public void beforeInsert(SObject so) {}

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