@isTest
public class UserDeprovisionOrganizerTest {
    private static final Integer numberOfGroups = 2;
    private static final Integer numberOfPermissionSets = 2;
    private static final Integer numberOfChatterGroups = 2;
    private static final Integer numberOfCases = 2;

    private static final String icAgentConsoleId = '050d0000000Wl7IAAS';
    private static final String changeToUserRoleId = '00Ed00000017bQ5EAI';
    private static final String changeToProfileId = '00ed00000019yCpAAI';

    @TestSetup
    private static void setupTestData() {
        // 5 Users
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        List<User> usersToDeprovision = (List<User>) userCreator.create(5);
        Id standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        for (Integer i = 0; i < usersToDeprovision.size(); i++) {
            User user = usersToDeprovision[i];
            user.ProfileId = standardProfile;
            user.FirstName = 'userDepro.testUser' + i;
            user.Username = 'userDepro.testUser' + i + '@test.example.com';
            user.CommunityNickname = 'userDepro.testUser' + i;
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert usersToDeprovision;
        }
        List<Id> uids = new List<Id>();
        for (User u : usersToDeprovision) {
            uids.add(u.Id);
        }

        // The custom setting
        List<Deprovision_User_Configuration__c> deproivisionConfigurations = new List<Deprovision_User_Configuration__c>();
        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(
                Name = 'Change UserRoleId To',
                Id__c = changeToUserRoleId,
                Name__c = 'Z Unassigned (Temporary Role)'
            )
        );
        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(
                Name = 'Change ProfileId To',
                Id__c = changeToProfileId,
                Name__c = 'ASU Chatter User'
            )
        );
        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(Name = 'RemoveValue_CallCenter', Name__c = 'CallCenterId')
        );
        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(Name = 'SwitchToFalse_Sandbox_DEV', Name__c = 'Sandbox_DEV__c')
        );
        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(
                Name = 'RemovePackageLicense_icAgentConsole',
                Id__c = icAgentConsoleId
            )
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert deproivisionConfigurations;
        }

        // Groups
        List<Group> groupsToAdd = new List<Group>();
        List<GroupMember> groupMembers = new List<GroupMember>();
        for (Integer i = 0; i < numberOfGroups; i++) {
            groupsToAdd.add(new Group(Name = 'userDepro.testGroup' + i));
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert groupsToAdd;
        }
        // and Members
        for (Integer i = 0; i < numberOfGroups; i++) {
            groupMembers.add(new GroupMember(UserOrGroupId = usersToDeprovision[0].Id, GroupId = groupsToAdd[i].Id));
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert groupMembers;
        }

        // Permission Sets
        List<PermissionSet> permissionSetsToAdd = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        for (Integer i = 0; i < numberOfPermissionSets; i++) {
            permissionSetsToAdd.add(
                new PermissionSet(Name = 'userDepro_testPermissionSet' + i, Label = 'userDepro_testPermissionSet' + i)
            );
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert permissionSetsToAdd;
        }
        // and Assignments
        for (Integer i = 0; i < numberOfPermissionSets; i++) {
            permissionSetAssignments.add(
                new PermissionSetAssignment(
                    AssigneeId = usersToDeprovision[0].Id,
                    PermissionSetId = permissionSetsToAdd[i].Id
                )
            );
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert permissionSetAssignments;
        }

        // Licenses
        UserPackageLicense license = new UserPackageLicense(
            UserId = usersToDeprovision[0].Id,
            PackageLicenseId = Id.valueOf(icAgentConsoleId)
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert license;
        }

        // Chatter Groups
        List<CollaborationGroup> collaborationGroupsToAdd = new List<CollaborationGroup>();
        List<CollaborationGroupMember> collaborationGroupMembers = new List<CollaborationGroupMember>();
        for (Integer i = 0; i < numberOfChatterGroups; i++) {
            collaborationGroupsToAdd.add(
                new CollaborationGroup(Name = 'userDepro.testChatterGroup' + i, CollaborationType = 'Public')
            );
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert collaborationGroupsToAdd;
        }
        // and Members
        for (Integer i = 0; i < numberOfChatterGroups; i++) {
            collaborationGroupMembers.add(
                new CollaborationGroupMember(
                    MemberId = usersToDeprovision[0].Id,
                    CollaborationGroupId = collaborationGroupsToAdd[i].Id
                )
            );
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert collaborationGroupMembers;
        }
        // Cases
        List<Case> casesToAdd = new List<Case>();
        // the functional group
        Case_Classification__c privateFunctionalGroup = new Case_Classification__c();
        privateFunctionalGroup.Name = 'userDepro.FunctionalGroup';
        privateFunctionalGroup.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Functional Group'].Id;
        privateFunctionalGroup.Active__c = true;
        privateFunctionalGroup.Visible__c = true;
        privateFunctionalGroup.Is_Functional_Group_Private__c = true;
        privateFunctionalGroup.Queue_Id__c = usersToDeprovision[1].Id;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert privateFunctionalGroup;
        }

        // and the cases
        for (Integer i = 0; i < numberOfCases; i++) {
            casesToAdd.add(
                new Case(
                    Subject = 'userDepro.CaseSubject ' + i,
                    Description = 'userDepro.CaseDescription ' + i,
                    CC_Functional_Group__c = privateFunctionalGroup.Id,
                    OwnerId = usersToDeprovision[0].Id
                )
            );
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert casesToAdd;
        }

        UserLogin freezeFirstUserLogin = [SELECT Id, UserId, IsFrozen FROM UserLogin WHERE UserId = :uids[0]][0];
        freezeFirstUserLogin.IsFrozen = true;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update freezeFirstUserLogin;
        }
    }

    @isTest
    public static void checkDeprovisionUsersAfterUpdate() {
        List<User> usersToDeprovision;
        Map<Id, User> oldUsersMap = new Map<Id, User>();
        List<User> newUsers = new List<User>();

        for (User user : [SELECT Id FROM User WHERE FirstName LIKE 'userDepro.testUser%' ORDER BY FirstName ASC]) {
            user.Deprovision_User__c = false;
            oldUsersMap.put(user.Id, user);
            newUsers.add(new User(Id = user.Id, Deprovision_User__c = true));
        }
        UserDeprovisionOrganizer deprovisionOrganizer = new UserDeprovisionOrganizer(
            (Map<Id, User>) oldUsersMap,
            (List<User>) newUsers
        );

        Test.startTest();
        deprovisionOrganizer.deprovisionUsersAfterUpdate();
        Test.stopTest();

        usersToDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id IN :oldUsersMap.keySet()];

        for (User user : usersToDeprovision) {
            System.assert(user.Processing_Notes__c.contains('UserName'), 'Should have deleted user and noted as much');
            System.assert(
                !user.Processing_Notes__c.contains('Exception'),
                'Should have no errors during these deletions'
            );
        }
    }

    @isTest
    public static void checkUserDeprovisionedWithPublicGroupMemberships() {
        Map<Id, User> oldUsersMap = new Map<Id, User>();
        List<User> newUsers = new List<User>();
        User theUser = [SELECT Id FROM User WHERE FirstName = 'userDepro.testUser0'][0];

        theUser.Deprovision_User__c = false;
        oldUsersMap.put(theUser.Id, theUser);
        newUsers.add(new User(Id = theUser.Id, Deprovision_User__c = true));

        UserDeprovisionOrganizer deprovisionOrganizer = new UserDeprovisionOrganizer(
            (Map<Id, User>) oldUsersMap,
            (List<User>) newUsers
        );

        List<GroupMember> groupMemberships = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :theUser.Id];
        System.assert(!groupMemberships.isEmpty(), 'This user should have some group memberships pre-deprovision');

        Test.startTest();
        deprovisionOrganizer.deprovisionUsersAfterUpdate();
        Test.stopTest();

        groupMemberships = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :theUser.Id];
        System.assert(groupMemberships.isEmpty(), 'Should have deleted group memberships');

        User theUserPostDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id = :theUser.Id][0];
        System.assert(
            theUserPostDeprovision.Processing_Notes__c.contains('Removed user from Public Groups:'),
            'The deletion of group memberships should have been recorded on the user'
        );
    }

    @isTest
    public static void checkUserDeprovisionedWithPermissionSetAssignments() {
        Map<Id, User> oldUsersMap = new Map<Id, User>();
        List<User> newUsers = new List<User>();
        User theUser = [SELECT Id FROM User WHERE FirstName = 'userDepro.testUser0'][0];

        theUser.Deprovision_User__c = false;
        oldUsersMap.put(theUser.Id, theUser);
        newUsers.add(new User(Id = theUser.Id, Deprovision_User__c = true));

        UserDeprovisionOrganizer deprovisionOrganizer = new UserDeprovisionOrganizer(
            (Map<Id, User>) oldUsersMap,
            (List<User>) newUsers
        );

        List<PermissionSetAssignment> permissionSetAssignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :theUser.Id
        ];
        System.assert(
            !permissionSetAssignments.isEmpty(),
            'This user should have some permission set assignments pre-deprovision'
        );
        Integer permSetsForThisUser = permissionSetAssignments.size();

        Test.startTest();
        deprovisionOrganizer.deprovisionUsersAfterUpdate();
        Test.stopTest();

        permissionSetAssignments = [
            SELECT Id, PermissionSet.Label, Assignee.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId = :theUser.Id
        ];
        System.assertEquals(
            permSetsForThisUser - numberOfPermissionSets,
            permissionSetAssignments.size(),
            'Should have deleted permission set assignments'
        );

        User theUserPostDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id = :theUser.Id][0];
        System.assert(
            theUserPostDeprovision.Processing_Notes__c.contains('Removed user from permissionSets:'),
            'The deletion of permission set assignments should have been recorded on the user'
        );
    }

    @isTest
    public static void checkUserDeprovisionedWithChatterGroups() {
        Map<Id, User> oldUsersMap = new Map<Id, User>();
        List<User> newUsers = new List<User>();
        User theUser = [SELECT Id FROM User WHERE FirstName = 'userDepro.testUser0'][0];

        theUser.Deprovision_User__c = false;
        oldUsersMap.put(theUser.Id, theUser);
        newUsers.add(new User(Id = theUser.Id, Deprovision_User__c = true));

        UserDeprovisionOrganizer deprovisionOrganizer = new UserDeprovisionOrganizer(
            (Map<Id, User>) oldUsersMap,
            (List<User>) newUsers
        );

        List<CollaborationGroupMember> collaborationGroupMembers = [
            SELECT Id
            FROM CollaborationGroupMember
            WHERE MemberId = :theUser.Id
        ];
        System.assert(
            !collaborationGroupMembers.isEmpty(),
            'This user should have some chatter group memberships pre-deprovision'
        );

        Test.startTest();
        deprovisionOrganizer.deprovisionUsersAfterUpdate();
        Test.stopTest();

        collaborationGroupMembers = [SELECT Id FROM CollaborationGroupMember WHERE MemberId = :theUser.Id];
        System.assert(collaborationGroupMembers.isEmpty(), 'Should have deleted chatter group memberships');

        User theUserPostDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id = :theUser.Id][0];
        System.assert(
            theUserPostDeprovision.Processing_Notes__c.contains('Removed user from Chatter Groups:'),
            'The deletion of chatter group memberships should have been recorded on the user'
        );
    }

    @isTest
    public static void checkUserDeprovisionedWithCases() {
        Map<Id, User> oldUsersMap = new Map<Id, User>();
        List<User> newUsers = new List<User>();
        User theUser = [SELECT Id FROM User WHERE FirstName = 'userDepro.testUser0'][0];

        theUser.Deprovision_User__c = false;
        oldUsersMap.put(theUser.Id, theUser);
        newUsers.add(new User(Id = theUser.Id, Deprovision_User__c = true));

        UserDeprovisionOrganizer deprovisionOrganizer = new UserDeprovisionOrganizer(
            (Map<Id, User>) oldUsersMap,
            (List<User>) newUsers
        );

        List<Case> usersCases = [SELECT Id, OwnerId FROM Case WHERE OwnerId = :theUser.Id];
        System.assert(!usersCases.isEmpty(), 'This user should have some cases assigned pre-deprovision');

        Test.startTest();
        deprovisionOrganizer.deprovisionUsersAfterUpdate();
        Test.stopTest();

        usersCases = [SELECT Id, OwnerId FROM Case WHERE OwnerId = :theUser.Id];
        System.assert(usersCases.isEmpty(), 'Should have deleted chatter group memberships');

        User theUserPostDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id = :theUser.Id][0];
        System.assert(
            theUserPostDeprovision.Processing_Notes__c.contains(
                'Transferred ' +
                numberOfCases +
                ' private cases to queue.'
            ),
            'The transfer of cases should have been recorded on the user'
        );
    }

    @isTest
    public static void checkUserDeprovisionedWithPackageLicenses() {
        Map<Id, User> oldUsersMap = new Map<Id, User>();
        List<User> newUsers = new List<User>();
        User theUser = [SELECT Id FROM User WHERE FirstName = 'userDepro.testUser0'][0];

        theUser.Deprovision_User__c = false;
        oldUsersMap.put(theUser.Id, theUser);
        newUsers.add(new User(Id = theUser.Id, Deprovision_User__c = true));

        UserDeprovisionOrganizer deprovisionOrganizer = new UserDeprovisionOrganizer(
            (Map<Id, User>) oldUsersMap,
            (List<User>) newUsers
        );

        List<UserPackageLicense> packageLicenses = [
            SELECT UserId, PackageLicense.NamespacePrefix
            FROM UserPackageLicense
            WHERE UserId = :theUser.Id AND PackageLicenseId = :icAgentConsoleId
        ];
        System.assert(!packageLicenses.isEmpty(), 'This user should have a license pre-deprovision');

        Test.startTest();
        deprovisionOrganizer.deprovisionUsersAfterUpdate();
        Test.stopTest();

        packageLicenses = [
            SELECT UserId, PackageLicense.NamespacePrefix
            FROM UserPackageLicense
            WHERE UserId = :theUser.Id AND PackageLicenseId = :icAgentConsoleId
        ];
        System.assert(packageLicenses.isEmpty(), 'Should have deleted license');

        User theUserPostDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id = :theUser.Id][0];
        System.assert(
            theUserPostDeprovision.Processing_Notes__c.contains('Removed user from Package Licenses:'),
            'The deletion of license should have been recorded on the user'
        );
    }

    @isTest
    public static void checkStopEarly() {
        List<User> usersToDeprovision;
        Map<Id, User> oldUsersMap = new Map<Id, User>();
        List<User> newUsers = new List<User>();

        Id standardProfile = IDHelper.getProfileId('Standard User');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Deprovision_User_Configuration__c deproConfig = new Deprovision_User_Configuration__c(
                Name = 'ProfileToIgnore',
                Id__c = standardProfile,
                Name__c = ''
            );
            insert deproConfig;
        }

        Integer counter = 0;
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        for (User user : [
            SELECT Id, ProfileId
            FROM User
            WHERE FirstName LIKE 'userDepro.testUser%'
            ORDER BY FirstName ASC
        ]) {
            counter++;
            if (counter < 2) {
                // Test stopping for profile matches
                newUsers.add(new User(Id = user.Id, ProfileId = user.ProfileId, Deprovision_User__c = true));
            } else if (counter < 3) {
                // Stop on admin/developer checkboxes
                newUsers.add(
                    new User(Id = user.Id, Role_Administrator_Developer__c = true, Deprovision_User__c = true)
                );
            } else {
                // Stop on Delegated Admin users
                psas.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = '0PSd0000000qzf4GAA'));
                newUsers.add(new User(Id = user.Id, Deprovision_User__c = true));
            }
            user.Deprovision_User__c = false;
            oldUsersMap.put(user.Id, user);
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert psas;
        }

        UserDeprovisionOrganizer deprovisionOrganizer = new UserDeprovisionOrganizer(
            (Map<Id, User>) oldUsersMap,
            (List<User>) newUsers
        );

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            deprovisionOrganizer.deprovisionUsersAfterUpdate();
            Test.stopTest();
        }

        usersToDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id IN :oldUsersMap.keySet()];

        for (User user : usersToDeprovision) {
            System.debug(user.Processing_Notes__c);
            Boolean properException = false;
            if (user.Processing_Notes__c.contains('Profile matched to')) {
                properException = true;
            } else if (
                user.Processing_Notes__c.contains(
                    'Detected SF Developer or Admin based on PeopleSoft Roles Administrator/Developer'
                )
            ) {
                properException = true;
            } else if (user.Processing_Notes__c.contains('Detected Delegated Administrator')) {
                properException = true;
            }
            System.assert(properException, 'Error was of incorrect type');
        }
    }

    @isTest
    public static void checkDeleteSobjectRecordsSuccess() {
        Map<Id, User> oldUsersMap = new Map<Id, User>();
        List<User> newUsers = new List<User>();
        User theUser = [SELECT Id FROM User WHERE FirstName = 'userDepro.testUser0'][0];

        theUser.Deprovision_User__c = false;
        oldUsersMap.put(theUser.Id, theUser);
        newUsers.add(new User(Id = theUser.Id, Deprovision_User__c = true));

        UserDeprovisionOrganizer deprovisionOrganizer = new UserDeprovisionOrganizer(
            (Map<Id, User>) oldUsersMap,
            (List<User>) newUsers
        );

        List<Case> usersCases = [SELECT Id, OwnerId FROM Case WHERE OwnerId = :theUser.Id];

        usersCases = [SELECT Id FROM Case WHERE OwnerId = :theUser.Id];
        System.assert(!usersCases.isEmpty(), 'Should have some cases');

        Test.startTest();
        UserDeprovisionOrganizer.deleteSobjectRecords('OwnerId', usersCases, null);
        Test.stopTest();

        usersCases = [SELECT Id FROM Case WHERE OwnerId = :theUser.Id];
        System.assert(usersCases.isEmpty(), 'Should have deleted cases');
    }

    @isTest
    public static void checkDeleteSobjectRecordsErrors() {
        Map<Id, User> oldUsersMap = new Map<Id, User>();
        List<User> newUsers = new List<User>();
        User theUser = [SELECT Id FROM User WHERE FirstName = 'userDepro.testUser0'][0];

        theUser.Deprovision_User__c = false;
        oldUsersMap.put(theUser.Id, theUser);
        newUsers.add(new User(Id = theUser.Id, Deprovision_User__c = true));

        UserDeprovisionOrganizer deprovisionOrganizer = new UserDeprovisionOrganizer(
            (Map<Id, User>) oldUsersMap,
            (List<User>) newUsers
        );

        List<Case> usersCases = [SELECT Id, OwnerId FROM Case WHERE OwnerId = :theUser.Id];

        delete usersCases;
        Test.startTest();
        UserDeprovisionOrganizer.deleteSobjectRecords('OwnerId', usersCases, null);
        Test.stopTest();

        User theUserPostDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id = :theUser.Id][0];
        System.assert(theUserPostDeprovision.Processing_Notes__c.contains('The following errors have occurred:'));

        List<Case> generatedErrorLoggerCases = [
            SELECT Id, Subject, Description
            FROM Case
            WHERE Subject LIKE '%DatabaseErrorException%'
        ];
        System.assertEquals(2, generatedErrorLoggerCases.size(), 'Should have added an ErrorLogger case for each case');
    }

    @isTest
    public static void checkUpdateSobjectRecordsErrors() {
        Map<Id, User> oldUsersMap = new Map<Id, User>();
        List<User> newUsers = new List<User>();
        User theUser = [SELECT Id FROM User WHERE FirstName = 'userDepro.testUser0'][0];

        theUser.Deprovision_User__c = false;
        oldUsersMap.put(theUser.Id, theUser);
        newUsers.add(new User(Id = theUser.Id, Deprovision_User__c = true));

        UserDeprovisionOrganizer deprovisionOrganizer = new UserDeprovisionOrganizer(
            (Map<Id, User>) oldUsersMap,
            (List<User>) newUsers
        );

        List<Case> usersCases = [SELECT Id, OwnerId FROM Case WHERE OwnerId = :theUser.Id];

        delete usersCases;
        Test.startTest();
        UserDeprovisionOrganizer.updateSobjectRecords('OwnerId', usersCases, null);
        Test.stopTest();

        User theUserPostDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id = :theUser.Id][0];
        System.assert(theUserPostDeprovision.Processing_Notes__c.contains('The following errors have occurred:'));

        List<Case> generatedErrorLoggerCases = [
            SELECT Id, Subject, Description
            FROM Case
            WHERE Subject LIKE '%DatabaseErrorException%'
        ];
        System.assertEquals(2, generatedErrorLoggerCases.size(), 'Should have added an ErrorLogger case for each case');
    }

    @isTest
    private static void testExtractingInvalidCustomSetting() {
        User user = [
            SELECT Id, ProfileId
            FROM User
            WHERE FirstName LIKE 'userDepro.testUser%'
            ORDER BY FirstName ASC
            LIMIT 1
        ];
        Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration = new Map<String, Deprovision_User_Configuration__c>();
        deprovisionUserConfiguration.put(
            'KeyName',
            new Deprovision_User_Configuration__c(Name = 'KeyName', Name__c = 'ContactId')
        );

        Test.startTest();
        UserDeprovisioner userDepro = new UserDeprovisioner(deprovisionUserConfiguration, user);
        String suspectedResponsibleSetting = userDepro.whichSettingDetailIsResponsible(
            'Invalid field ContactId for User'
        );
        String suspectedResponsibleSetting2 = userDepro.whichSettingDetailIsResponsible('');
        String suspectedResponsibleSetting3 = userDepro.whichSettingDetailIsResponsible(
            'Invalid field UnextractableField__c for User'
        );
        Test.stopTest();

        System.assertEquals('KeyName', suspectedResponsibleSetting);
        System.assertEquals('', suspectedResponsibleSetting2);
        System.assertEquals('', suspectedResponsibleSetting3);
    }
}
