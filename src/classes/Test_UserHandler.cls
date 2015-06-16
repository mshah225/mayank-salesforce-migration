@isTest
public class Test_UserHandler 
{
	@testSetup static void setup()
	{
		User testUser = UserService.createTestUser();
		Id sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		testUser.ProfileId = sysAdminProfile;

		insert testUser;
	}

	@isTest static void changeKnowledgePermission()
	{
		User updateUser = [SELECT Role_Knowledge__c FROM User LIMIT 1];

		updateUser.Role_Knowledge__c = true;

		update updateUser;

		updateUser = [SELECT Role_Knowledge__c FROM User WHERE Id =: updateUser.Id];

		System.assert(!updateUser.Role_Knowledge__c);
	}
}