@isTest
public class Test_UserHandler 
{
	@isTest static void changeKnowledgePermission()
	{
		User updateUser = [SELECT Role_Knowledge__c FROM User LIMIT 1];

		updateUser.Role_Knowledge__c = true;

		update updateUser;

		updateUser = [SELECT Role_Knowledge__c FROM User WHERE Id =: updateUser.Id];

		System.assert(!updateUser.Role_Knowledge__c);
	}

	@isTest static void insertCAPUser()
	{
		Contact testContact = ContactService.createTestContact();
		testContact.CAP_Possible__c = TRUE;
		insert testContact;

		Student_Group__c testGroup = new Student_Group__c();
		testGroup.SG_Status__c = TRUE;
		testGroup.SG_PeopleSoft_Code__c = 'CP00';
		testGroup.SG_Contact__c = testContact.Id;
		insert testGroup;

		User testUser = UserService.createTestUser();
		testUser.ContactId = testContact.Id;
		insert testUser;

		Profile communityCapProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'];
		testUser = [SELECT ProfileId FROM User WHERE Id = :testUser.Id];

		System.assert(testUser.ProfileId == communityCapProfile.Id);
	}
}
