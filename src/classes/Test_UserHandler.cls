@isTest
public class Test_UserHandler
{
    @isTest static void changeKnowledgePermission()
    {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User updateUser = (User)userCreator.create(1)[0];
        Id sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        updateUser.ProfileId = sysAdminProfile;
        insert updateUser;

        updateUser.Role_Knowledge__c = true;

        update updateUser;

        updateUser = [SELECT Role_Knowledge__c FROM User WHERE Id =: updateUser.Id];

        System.assert(!updateUser.Role_Knowledge__c);
    }

    @isTest static void insertCAPUser()
    {
        Account acc = new Account(Name='Test Account Name');
        insert acc;

        Contact testContact = ContactService.createTestContact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'User';
        testContact.ASURite_ID__c = 'testuser';
        testContact.CAP_Possible__c = TRUE;
        testContact.ACcountId = acc.Id;
        insert testContact;

        Test.startTest();
        Student_Group__c testGroup = new Student_Group__c();
        testGroup.SG_Status__c = TRUE;
        testGroup.SG_PeopleSoft_Code__c = 'CP00';
        testGroup.SG_Contact__c = testContact.Id;
        insert testGroup;

        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User testUser = (User)userCreator.create(1)[0];
        testUser.Username += 'community';
        testUser.CommunityNickname += 'community';
        Id communityProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
        testUser.ProfileId = communityProfile;

        testUser.isActive = true;
        testUser.FederationIdentifier = 'testuser@asu.edu';
        insert testUser;
        Test.stopTest();

        Profile communityCapProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'];
        testUser = [SELECT ProfileId FROM User WHERE Id = :testUser.Id];

        System.assert(testUser.ProfileId == communityCapProfile.Id);
    }

    @isTest static void insertNonCAPUser()
    {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User testUser = (User)userCreator.create(1)[0];
        testUser.Username += 'chatter';
        testUser.CommunityNickname += 'chatter';
        Id chatterProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Chatter User'].Id;
        testUser.ProfileId = chatterProfile;
        testUser.FederationIdentifier = 'testuser@asu.edu';
        insert testUser;

        Profile communityCapProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'];
        testUser = [SELECT ProfileId FROM User WHERE Id = :testUser.Id];

        System.assert(testUser.ProfileId != communityCapProfile.Id);
    }
}