@isTest
public class UserTriggerTest {
    @isTest
    static void changeKnowledgePermission() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User updateUser = (User) userCreator.create(1)[0];
        Id sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        updateUser.ProfileId = sysAdminProfile;
        insert updateUser;

        updateUser.Role_Knowledge__c = true;

        update updateUser;

        updateUser = [SELECT Role_Knowledge__c FROM User WHERE Id = :updateUser.Id];

        System.assert(!updateUser.Role_Knowledge__c);
    }

    @isTest
    static void insertCAPUser() {
        Account acc = new Account(Name = 'Test Account Name');
        insert acc;

        Contact testContact = ContactService.createTestContact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'User';
        testContact.ASURite_ID__c = 'testuser';
        testContact.CAP_Possible__c = true;
        testContact.ACcountId = acc.Id;
        insert testContact;

        Test.startTest();
        Student_Group__c testGroup = new Student_Group__c();
        testGroup.SG_Status__c = true;
        testGroup.SG_PeopleSoft_Code__c = 'CP00';
        testGroup.SG_Contact__c = testContact.Id;
        insert testGroup;

        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User testUser = (User) userCreator.create(1)[0];
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

    @isTest
    private static void bulkInsertCAPUsers() {
        Account acc = new Account(Name = 'Test Account Name');
        insert acc;

        List<Contact> testContacts = new List<Contact>();
        Contact testContact = ContactService.createTestContact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'User';
        testContact.ASURite_ID__c = 'testuser1';
        testContact.CAP_Possible__c = true;
        testContact.AccountId = acc.Id;
        testContacts.add(testContact);

        testContact = ContactService.createTestContact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'User';
        testContact.ASURite_ID__c = 'testuser2';
        testContact.CAP_Possible__c = true;
        testContact.ACcountId = acc.Id;
        testContacts.add(testContact);

        insert testContacts;

        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        List<User> testUsers = (List<User>) userCreator.create(2);
        testUsers[0].Username += 'community';
        testUsers[1].Username += 'community';
        testUsers[0].CommunityNickname += 'community';
        testUsers[1].CommunityNickname += 'community';
        Id communityProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
        testUsers[0].ProfileId = communityProfile;
        testUsers[1].ProfileId = communityProfile;

        testUsers[0].isActive = true;
        testUsers[1].isActive = true;
        testUsers[0].FederationIdentifier = 'testuser1@asu.edu';
        testUsers[1].FederationIdentifier = 'testuser2@asu.edu';

        Test.startTest();
        insert testUsers;
        Test.stopTest();

        Profile communityCapProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'];
        Set<Id> testUserIds = new Set<Id>();
        testUserIds.add(testUsers[0].Id);
        testUserIds.add(testUsers[1].Id);
        testUsers = [SELECT ProfileId FROM User WHERE Id IN :testUserIds];

        System.assertEquals(2, testUsers.size());
        System.assert(testUsers[0].ProfileId == communityCapProfile.Id);
        System.assert(testUsers[1].ProfileId == communityCapProfile.Id);
    }

    @isTest
    static void insertNonCAPUser() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User testUser = (User) userCreator.create(1)[0];
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

    //methods to test bulkAfter

    //insert a ASU Service user and check whether hes added to the corresponding chatter group or not.
    @isTest
    static void insertASUServiceUser() {
        Double dbRandom = Math.random();
        //Create record in Chatter Auto Add User custom setting
        Chatter_Auto_Add_Users__c objAsuService = new Chatter_Auto_Add_Users__c();
        objAsuService.Name = 'Case Management';
        //Assign Case Management People Soft Role.
        objAsuService.PeopleSoft_Role__c = 'Case Management';
        // Assign a chatter group name that is unique throughout the org(reason for appending random number)
        objAsuService.Chatter_Group_Name__c = 'ASU Service' + String.valueOf(dbRandom);
        objAsuService.NotificationFrequency__c = 'D';
        insert objAsuService;

        //Insert corresponding collaboration group record(name must be unique throughout org)
        List<CollaborationGroup> testCGList = new List<CollaborationGroup>();
        String strGrpName = 'ASU Service' + String.valueOf(dbRandom);
        CollaborationGroup objCG = new collaborationgroup(name = strGrpName, CollaborationType = 'Public');
        testCGList.add(objCG);
        insert (testCGList);
        //Insert a user with a Case Management People Soft Role
        Test.startTest();
        User testUser = createTestUser();
        testUser.Role_Case_Management__c = true;
        Id asuServiceProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Service - ASU Online'].Id;
        testUser.ProfileId = asuServiceProfile;
        testUser.FederationIdentifier = 'testuserService@asu.edu';
        testUser.EmployeeNumber = '9933663399';
        insert testUser;
        Test.stopTest();
        //Query the CollabortationGroupId(Chatter Group) for the inserted user
        List<CollaborationGroupMember> lstCGM = [
            SELECT MemberId, CollaborationGroupId
            FROM CollaborationGroupMember
            WHERE MemberId = :testUser.Id
        ];

        System.assertEquals(lstCGM.size(), 1);
        //Check whether the user is added to the correct chatter group.
        System.assertEquals(lstCGM[0].CollaborationGroupId, testCGList[0].Id);
    }

    //insert a recruitment user and check whether hes added to the corresponding chatter group or not.
    @isTest
    static void insertASURecruitUser() {
        Double dbRandom = Math.random();
        //Create record in Chatter Auto Add User custom setting
        Chatter_Auto_Add_Users__c objAsuRecruit = new Chatter_Auto_Add_Users__c();
        objAsuRecruit.Name = 'ASU Recruitment2';
        //Assign Recruitment Communications People Soft Role.
        objAsuRecruit.PeopleSoft_Role__c = 'Recruitment Communications';
        // Assign a chatter group name that is unique throughout the org(reason for appending random number)
        objAsuRecruit.Chatter_Group_Name__c = 'ASU Recruitment' + String.valueOf(dbRandom);
        objAsuRecruit.NotificationFrequency__c = 'D';
        insert objAsuRecruit;

        //Insert corresponding collaboration group record(name must be unique throughout org)
        List<CollaborationGroup> testCGList = new List<CollaborationGroup>();
        String strGrpName = 'ASU Recruitment' + String.valueOf(dbRandom);
        CollaborationGroup objCG = new CollaborationGroup(name = strGrpName, CollaborationType = 'Public');
        testCGList.add(objCG);
        insert (testCGList);

        //Insert a user with a Recruitment Communications People Soft Role
        Test.startTest();
        User testUser = createTestUser();
        testUser.Role_Recruitment_Communications__c = true;
        Id asuRecruitProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Recruitment - Admission Services'].Id;
        testUser.ProfileId = asuRecruitProfile;
        testUser.FederationIdentifier = 'testuserRecruit@asu.edu';
        testUser.EmployeeNumber = '9933663399';
        insert testUser;
        Test.stopTest();

        //Query the CollabortationGroupId(Chatter Group) for the inserted user
        List<CollaborationGroupMember> lstCGM = [
            SELECT MemberId, CollaborationGroupId
            FROM CollaborationGroupMember
            WHERE MemberId = :testUser.Id
        ];

        System.assertEquals(lstCGM.size(), 1);
        //Check whether the user is added to the correct chatter group.
        System.assertEquals(lstCGM[0].CollaborationGroupId, testCGList[0].Id);
    }

    //insert a knowledge user and check whether hes added to the corresponding chatter group or not.
    @isTest
    static void insertASUKnowledgeUser() {
        Double dbRandom = Math.random();
        //Create record in Chatter Auto Add User custom setting
        Chatter_Auto_Add_Users__c objAsuKnowledge = new Chatter_Auto_Add_Users__c();
        objAsuKnowledge.Name = 'Knowledge';
        //Assign Knowledge People Soft Role.
        objAsuKnowledge.PeopleSoft_Role__c = 'Knowledge';
        // Assign a chatter group name that is unique throughout the org(reason for appending random number)
        objAsuKnowledge.Chatter_Group_Name__c = 'Knowledge Users' + String.valueOf(dbRandom);
        objAsuKnowledge.NotificationFrequency__c = 'D';
        insert objAsuKnowledge;

        //Insert corresponding collaboration group record(name must be unique throughout org)
        List<CollaborationGroup> testCGList = new List<CollaborationGroup>();
        String strGrpName = 'Knowledge Users' + String.valueOf(dbRandom);
        CollaborationGroup objCG = new CollaborationGroup(name = strGrpName, CollaborationType = 'Public');
        testCGList.add(objCG);
        insert (testCGList);

        //Insert a user with Knwoledge People Soft Role
        Test.startTest();

        User testUser = createTestUser();
        testUser.Role_Knowledge__c = true;
        Id asuRecruitProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Knowledge User'].Id;
        testUser.ProfileId = asuRecruitProfile;
        testUser.FederationIdentifier = 'testuserKnowledge@asu.edu';
        testUser.EmployeeNumber = '9933663399';
        insert testUser;

        Test.stopTest();

        //Query the CollabortationGroupId(Chatter Group) for the inserted user
        List<CollaborationGroupMember> lstCGM = [
            SELECT MemberId, CollaborationGroupId
            FROM CollaborationGroupMember
            WHERE MemberId = :testUser.Id
        ];

        System.assertEquals(lstCGM.size(), 1);
        //Check whether the user is added to the correct chatter group.
        System.assertEquals(lstCGM[0].CollaborationGroupId, testCGList[0].Id);
    }

    //insert a marketing cloud user and check whether the user is added to the corresponding collaboration group.
    @isTest
    static void insertASUMarketingUser() {
        Decimal dbRandom = Math.random();
        dbRandom = dbRandom.SetScale(2); // Round off to two decimal points(More decimal points may cause name character limit to exceed)

        //Create record in Chatter Auto Add User custom setting
        Chatter_Auto_Add_Users__c objAsuMarketing = new Chatter_Auto_Add_Users__c();
        objAsuMarketing.Name = 'Marketing1';
        //Assign Connected Marketing Cloud Adm People Soft Role.
        objAsuMarketing.PeopleSoft_Role__c = 'Connected Marketing Cloud Adm';
        objAsuMarketing.NotificationFrequency__c = 'P';
        // Assign a chatter group name that is unique throughout the org(reason for appending random number)
        objAsuMarketing.Chatter_Group_Name__c = 'ASU Connected Marketing Cloud' + String.valueOf(dbRandom);
        insert objAsuMarketing;

        //Insert corresponding collaboration group record(name must be unique throughout org)
        List<CollaborationGroup> testCGList = new List<CollaborationGroup>();
        String strGrpName = 'ASU Connected Marketing Cloud' + String.valueOf(dbRandom);
        CollaborationGroup objCG = new CollaborationGroup(name = strGrpName, CollaborationType = 'Public');
        testCGList.add(objCG);
        insert (testCGList);

        Test.startTest();

        //Insert a user with Marketing Cloud Admin People Soft Role
        User testUser = createTestUser();
        testUser.Role_Connected_MC_Adm__c = true;
        Id asuRecruitProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Knowledge User'].Id;
        testUser.ProfileId = asuRecruitProfile;
        testUser.FederationIdentifier = 'testuserMarketing1@asu.edu';
        testUser.EmployeeNumber = '9933663399';
        insert testUser;

        Test.stopTest();

        //Query the CollabortationGroupId(Chatter Group) for the inserted user
        List<CollaborationGroupMember> lstCGM = [
            SELECT MemberId, CollaborationGroupId
            FROM CollaborationGroupMember
            WHERE MemberId = :testUser.Id
        ];

        System.assertEquals(lstCGM.size(), 1);
        //Check whether the user is added to the correct chatter group.
        System.assertEquals(lstCGM[0].CollaborationGroupId, testCGList[0].Id);
    }

    //insert a advising user and check whether the user is added to the corresponding collaboration group.
    @isTest
    static void insertASUAdvisingUser() {
        Decimal dbRandom = Math.random();
        dbRandom = dbRandom.SetScale(2); // Round off to two decimal points(More decimal points may cause name character limit to exceed)

        //Insert corresponding Permission Set
        PermissionSet ps = new PermissionSet(
            Name = 'Perm_Academic_Advisor_Portal_' + String.valueOf(dbRandom).replace('.', '_'),
            Label = 'Perm Academic Advisor Portal ' + String.valueOf(dbRandom)
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert ps;
        }

        //Create record in Chatter Auto Add User custom setting
        Chatter_Auto_Add_Users__c objAsuAdvising = new Chatter_Auto_Add_Users__c();
        objAsuAdvising.Name = 'Advising1';
        //Assign Connected Marketing Cloud Adm People Soft Role.
        objAsuAdvising.PeopleSoft_Role__c = 'Academic Advisor Portal';
        objAsuAdvising.NotificationFrequency__c = 'P';
        objAsuAdvising.Required_Permission_Sets__c = ps.Name;
        // Assign a chatter group name that is unique throughout the org(reason for appending random number)
        objAsuAdvising.Chatter_Group_Name__c = 'Academic Advisor Portal ' + String.valueOf(dbRandom);
        insert objAsuAdvising;

        //Insert corresponding collaboration group record(name must be unique throughout org)
        List<CollaborationGroup> testCGList = new List<CollaborationGroup>();
        String strGrpName = 'Academic Advisor Portal ' + String.valueOf(dbRandom);
        CollaborationGroup objCG = new CollaborationGroup(name = strGrpName, CollaborationType = 'Public');
        testCGList.add(objCG);
        insert (testCGList);

        Test.startTest();

        //Insert a user with Academic Advisor Portal People Soft Role
        Id asuRecruitProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Knowledge User'].Id;

        List<User> users = createMultipleTestUsers(2);

        User testUser = users[0];
        testUser.Role_Academic_Advisor_Portal__c = true;
        testUser.ProfileId = asuRecruitProfile;
        testUser.FederationIdentifier = 'testuserMarketing1@asu.edu';
        testUser.EmployeeNumber = '9933663399';

        User testUser2 = users[1];
        testUser2.Role_Academic_Advisor_Portal__c = true;
        testUser2.ProfileId = asuRecruitProfile;
        testUser2.FederationIdentifier = 'testuserMarketing2@asu.edu';
        testUser2.EmployeeNumber = '9933663398';

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new List<User>{ testUser, testUser2 };
        }

        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeID = testUser.Id);
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert psa;
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            update testUser;
        }

        Test.stopTest();

        //Query the CollabortationGroupId(Chatter Group) for the inserted user
        List<CollaborationGroupMember> lstCGM = [
            SELECT MemberId, CollaborationGroupId
            FROM CollaborationGroupMember
            WHERE MemberId = :testUser.Id
        ];

        List<CollaborationGroupMember> lstCGM2 = [
            SELECT MemberId, CollaborationGroupId
            FROM CollaborationGroupMember
            WHERE MemberId = :testUser2.Id
        ];

        System.assertEquals(1, lstCGM.size());
        System.assertEquals(0, lstCGM2.size());
        //Check whether the user is added to the correct chatter group.
        System.assertEquals(testCGList[0].Id, lstCGM[0].CollaborationGroupId);
    }

    @isTest
    public static void checkDeprovisionedUserWithProcessingNotes() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User updateUser = (User) userCreator.create(1)[0];
        Id standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        updateUser.ProfileId = standardProfile;
        updateUser.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'SC Success Coach'].Id;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert updateUser;
        }

        List<Deprovision_User_Configuration__c> deproivisionConfigurations = new List<Deprovision_User_Configuration__c>();
        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(
                Name = 'Change UserRoleId To',
                Id__c = '00Ed00000017bQ5EAI',
                Name__c = 'Z Unassigned (Temporary Role)'
            )
        );
        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(
                Name = 'Change ProfileId To',
                Id__c = '00ed00000019yCpAAI',
                Name__c = 'ASU Chatter User'
            )
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert deproivisionConfigurations;
        }

        updateUser.Deprovision_User__c = true;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            update updateUser;
            Test.stopTest();
        }
        Id userId = updateUser.Id;
        updateUser = Database.Query('SELECT ' + userFieldsForDeprovision() + ' FROM User WHERE Id = :userId');

        assertUserDeprovisioned(updateUser);
    }

    @isTest
    public static void checkBulkDeprovisionedUsersWithProcessingNotes() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        List<User> usersToDeprovision = (List<User>) userCreator.create(40);
        List<Id> deprovisionedUserIds = new List<Id>();
        Id standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        Id successCoachRole = [SELECT Id FROM UserRole WHERE Name = 'SC Success Coach'].Id;

        for (User user : usersToDeprovision) {
            user.ProfileId = standardProfile;
            user.UserRoleId = successCoachRole;
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert usersToDeprovision;
        }

        for (User user : usersToDeprovision) {
            deprovisionedUserIds.add(user.Id);
            user.Deprovision_User__c = true;
        }

        List<Deprovision_User_Configuration__c> deproivisionConfigurations = new List<Deprovision_User_Configuration__c>();
        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(
                Name = 'Change UserRoleId To',
                Id__c = '00Ed00000017bQ5EAI',
                Name__c = 'Z Unassigned (Temporary Role)'
            )
        );
        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(
                Name = 'Change ProfileId To',
                Id__c = '00ed00000019yCpAAI',
                Name__c = 'ASU Chatter User'
            )
        );
        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(Name = 'RemoveValue_CallCenter', Name__c = 'CallCenterId')
        );
        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(Name = 'SwitchToFalse_Sandbox_DEV', Name__c = 'Sandbox_DEV__c')
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert deproivisionConfigurations;
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            update usersToDeprovision;
            Test.stopTest();
        }

        usersToDeprovision = Database.Query(
            'SELECT ' +
            userFieldsForDeprovision() +
            ' FROM User WHERE Id IN :deprovisionedUserIds'
        );

        for (User user : usersToDeprovision) {
            assertUserDeprovisioned(user);
        }
    }

    private static void assertUserDeprovisioned(User deprovisionedUser) {
        Map<String, Deprovision_User_Configuration__c> deproivisionConfigurations = Deprovision_User_Configuration__c.getAll();

        for (String configurationName : deproivisionConfigurations.keySet()) {
            Deprovision_User_Configuration__c userConfiguration = deproivisionConfigurations.get(configurationName);
            if (configurationName.contains('UserRoleId')) {
                System.assertEquals(userConfiguration.Id__c, deprovisionedUser.UserRoleId);
            } else if (configurationName.contains('ProfileId')) {
                System.assertEquals(userConfiguration.Id__c, deprovisionedUser.ProfileId);
            } else if (configurationName.contains('RemoveValue')) {
                System.assertEquals(null, deprovisionedUser.get(userConfiguration.Name__c));
            } else if (configurationName.contains('SwitchToFalse')) {
                System.assertEquals(false, deprovisionedUser.get(userConfiguration.Name__c));
            }
        }

        System.assert(!deprovisionedUser.Processing_Notes__c.contains('Exception Thrown'));
        System.assert(!deprovisionedUser.IsActive);
        System.assert(!deprovisionedUser.Deprovision_User__c);
    }

    private static String userFieldsForDeprovision() {
        String userFields = 'UserRoleId, ProfileId, IsActive, Deprovision_User__c, Processing_Notes__c';
        Map<String, Deprovision_User_Configuration__c> deproivisionConfigurations = Deprovision_User_Configuration__c.getAll();

        for (String configurationName : deproivisionConfigurations.keySet()) {
            Deprovision_User_Configuration__c userConfiguration = deproivisionConfigurations.get(configurationName);
            if (configurationName.contains('RemoveValue') || configurationName.contains('SwitchToFalse')) {
                userFields += ', ' + userConfiguration.Name__c;
            }
        }
        return userFields;
    }

    public static User createTestUser() {
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'test.user.emperor.of.Byzantium@test.example.com',
            Email = 'test.user@test.example.com',
            Alias = 'testuser',
            CommunityNickname = 'testuserCom',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        return testUser;
    }

    public static List<User> createMultipleTestUsers(Integer numUsers) {
        List<User> userList = new List<User>();

        for (Integer i = 0; i < numUsers; i++) {
            User tUser = createTestUser();
            tUser.FirstName = 'Test' + i;
            tUser.LastName = 'User' + i;
            tUser.Username = 'test.user.emperor.of.Byzantium' + i + '@test.example.com';
            tUser.Email = 'test.user' + i + '@test.example.com';
            tUser.Alias = 'test' + i;
            tUser.CommunityNickname = 'testuser' + i;
            userList.add(tUser);
        }
        return userList;
    }
}
