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

		Id communityProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
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
				Profile newUserProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'];
				newUser.ProfileId = newUserProfile.Id;
			}
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

	public void afterInsert(SObject so)
    {
        User newUser = (User) so;

        UserService.addUsersToChatterGroups(newUser.ProfileId, newUser.Id, null, null);
    }

	public void afterUpdate(SObject oldSo, SObject so)
    {
        User newUser = (User) so;
        User oldUser = (User) oldSo;

        if (newUser.ProfileId != oldUser.ProfileId)
        {
            UserService.addUsersToChatterGroups(newUser.ProfileId, newUser.Id, oldUser
                    .ProfileId, oldUser.Id);
        }
    }

	public void afterDelete(SObject so) {}

	public void andFinally() {}
}