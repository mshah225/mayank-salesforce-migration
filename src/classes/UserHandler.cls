public without sharing class UserHandler implements ITrigger
{
	public void bulkBefore() 
	{
		if(Trigger.isInsert)
		{
			List<User> newUsers = Trigger.new; 
			Id communityProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
			Id communityCapProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'].Id;
			List<Id> contactIds = new List<Id>();
			Map<Id, User> contactToUser = new Map<Id, User>();

			for(Integer x = 0; x < newUsers.size(); x++)
			{
				User newUser = newUsers.get(0);

				if (newUser.UserPermissionsKnowledgeUser)
				{
					newUser.Role_Knowledge__c = true;
				}

				if(newUser.ProfileId == communityProfile)
				{
					contactIds.add(newUser.ContactId);
					contactToUser.put(newUser.ContactId, newUser);
				}
			}

			if(contactIds.size() > 0)
			{
				System.debug('CONTACT IDS: ' + contactIds);
				List<Contact> newUserContacts = [SELECT Id, CAP__c FROM Contact WHERE Id IN :contactIds];
				for(Integer x = 0; x < newUserContacts.size(); x++)
				{
					System.debug('NEW USER CONTACTS: ' + newUserContacts);
					User u = contactToUser.get(newUserContacts.get(x).Id);
					if(newUserContacts.get(x).CAP__c != null)
					{
						u.ProfileId = communityCapProfile;
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