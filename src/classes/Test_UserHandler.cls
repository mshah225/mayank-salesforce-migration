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
		User updateUser = [SELECT Is_Knowledge_User__c FROM User LIMIT 1];

		updateUser.Is_Knowledge_User__c = true;

		update updateUser;

		updateUser = [SELECT Is_Knowledge_User__c FROM User WHERE Id =: updateUser.Id];

		System.assert(!updateUser.Is_Knowledge_User__c);
	}
}