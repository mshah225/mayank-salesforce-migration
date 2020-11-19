@isTest
public class UserDeprovisionOrganizerTest {
    private static List<User> usersToDeprovision;
    private static Map<Id, Sobject> oldUsersMap;
    private static List<Sobject> newUsers;
    private static UserDeprovisionOrganizer deprovisionOrganizer;

    private static void setupTestData(Integer numberOfUsers) {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        usersToDeprovision = (List<User>) userCreator.create(numberOfUsers);

        Id standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;

        for (User user : usersToDeprovision) {
            user.ProfileId = standardProfile;
        }
        insert usersToDeprovision;

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

        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(
                Name = 'RemovePackageLicense_icAgentConsole',
                Id__c = '050d0000000Wl7IAAS'
            )
        );
        insert deproivisionConfigurations;

        oldUsersMap = new Map<Id, User>();
        newUsers = new List<User>();

        for (User user : usersToDeprovision) {
            user.Deprovision_User__c = false;
            oldUsersMap.put(user.Id, user);
            newUsers.add(new User(Id = user.Id, Deprovision_User__c = true));
        }

        deprovisionOrganizer = new UserDeprovisionOrganizer();
        deprovisionOrganizer.setOldUsersMap(oldUsersMap);
        deprovisionOrganizer.setNewUsers(newUsers);
    }

    @isTest
    public static void checkDeprovisionUsersAfterUpdate() {
        setupTestData(5);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            deprovisionOrganizer.deprovisionUsersAfterUpdate();
            Test.stopTest();
        }

        usersToDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id IN :oldUsersMap.keySet()];

        for (User user : usersToDeprovision) {
            System.assert(user.Processing_Notes__c.contains('UserName'));
            System.assert(!user.Processing_Notes__c.contains('Exception'));
        }
    }

    @isTest
    public static void checkUserDeprovisionedWithPublicGroupMemberships() {
        setupTestData(1);
        Integer numberOfGroups = 2;
        List<Group> groupsToAdd = new List<Group>();
        List<GroupMember> groupMembers = new List<GroupMember>();
        List<Id> groupIds = new List<Id>();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            for (Integer i = 0; i < numberOfGroups; i++) {
                groupsToAdd.add(new Group(Name = 'testGroup' + i));
            }
            insert groupsToAdd;

            for (Integer i = 0; i < numberOfGroups; i++) {
                groupMembers.add(
                    new GroupMember(UserOrGroupId = usersToDeprovision[0].Id, GroupId = groupsToAdd[i].Id)
                );
                groupIds.add(groupsToAdd[i].Id);
            }
            insert groupMembers;
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            deprovisionOrganizer.deprovisionUsersAfterUpdate();
            Test.stopTest();
        }

        groupMembers = [SELECT Id FROM GroupMember WHERE GroupId IN :groupIds];
        System.assert(groupMembers.isEmpty());

        usersToDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id IN :oldUsersMap.keySet()];
        System.assert(usersToDeprovision[0].Processing_Notes__c.contains('Removed user from Public Groups:'));
    }

    @isTest
    public static void checkUserDeprovisionedWithPermissionSetAssignments() {
        setupTestData(1);
        Integer numberOfPermissionSets = 2;
        List<PermissionSet> permissionSetsToAdd = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        List<Id> permissionSetIds = new List<Id>();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            for (Integer i = 0; i < numberOfPermissionSets; i++) {
                permissionSetsToAdd.add(new PermissionSet(Name = 'testPermissionSet' + i, Label = 'testLabel' + i));
            }
            insert permissionSetsToAdd;

            for (Integer i = 0; i < numberOfPermissionSets; i++) {
                permissionSetAssignments.add(
                    new PermissionSetAssignment(
                        AssigneeId = usersToDeprovision[0].Id,
                        PermissionSetId = permissionSetsToAdd[i].Id
                    )
                );
                permissionSetIds.add(permissionSetsToAdd[i].Id);
            }
            insert permissionSetAssignments;
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            deprovisionOrganizer.deprovisionUsersAfterUpdate();
            Test.stopTest();
        }

        permissionSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN :permissionSetIds];
        System.assert(permissionSetAssignments.isEmpty());

        usersToDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id IN :oldUsersMap.keySet()];
        System.assert(usersToDeprovision[0].Processing_Notes__c.contains('Removed user from permissionSets:'));
    }

    @isTest
    public static void checkUserDeprovisionedWithChatterGroups() {
        setupTestData(1);
        Integer numberOfChatterGroups = 2;
        List<CollaborationGroup> collaborationGroupsToAdd = new List<CollaborationGroup>();
        List<CollaborationGroupMember> collaborationGroupMembers = new List<CollaborationGroupMember>();
        List<Id> collaborationGroupMemberIds = new List<Id>();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            for (Integer i = 0; i < numberOfChatterGroups; i++) {
                collaborationGroupsToAdd.add(
                    new CollaborationGroup(Name = 'testChatterGroup' + i, CollaborationType = 'Public')
                );
            }
            insert collaborationGroupsToAdd;

            for (Integer i = 0; i < numberOfChatterGroups; i++) {
                collaborationGroupMembers.add(
                    new CollaborationGroupMember(
                        MemberId = usersToDeprovision[0].Id,
                        CollaborationGroupId = collaborationGroupsToAdd[i].Id
                    )
                );
            }
            insert collaborationGroupMembers;

            for (CollaborationGroupMember groupMember : collaborationGroupMembers) {
                collaborationGroupMemberIds.add(groupMember.Id);
            }
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            deprovisionOrganizer.deprovisionUsersAfterUpdate();
            Test.stopTest();
        }

        collaborationGroupMembers = [SELECT Id FROM CollaborationGroupMember WHERE Id IN :collaborationGroupMemberIds];
        System.assert(collaborationGroupMembers.isEmpty());

        usersToDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id IN :oldUsersMap.keySet()];
        System.assert(usersToDeprovision[0].Processing_Notes__c.contains('Removed user from Chatter Groups:'));
    }

    @isTest
    public static void checkUserDeprovisionedWithCases() {
        setupTestData(1);
        Integer numberOfCases = 2;
        List<Case> casesToAdd = new List<Case>();

        List<String> sObjectTypes = new List<String>();
        sObjectTypes.add('Case');
        Group testGroup = TestDataFactory.createTestGroupAndQueue(sObjectTypes);

        Case_Classification__c privateFunctionalGroup = new Case_Classification__c();
        privateFunctionalGroup.Name = 'Test FG';
        privateFunctionalGroup.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Functional Group'].Id;
        privateFunctionalGroup.Active__c = true;
        privateFunctionalGroup.Visible__c = true;
        privateFunctionalGroup.Is_Functional_Group_Private__c = true;
        privateFunctionalGroup.Queue_Id__c = testGroup.Id;
        insert privateFunctionalGroup;

        for (Integer i = 0; i < numberOfCases; i++) {
            casesToAdd.add(
                new Case(
                    Subject = 'Test Subject ' + i,
                    Description = 'Test Description ' + i,
                    CC_Functional_Group__c = privateFunctionalGroup.Id,
                    OwnerId = usersToDeprovision[0].Id
                )
            );
        }
        insert casesToAdd;

        List<Id> caseIds = new List<Id>();
        for (Case testCase : casesToAdd) {
            caseIds.add(testCase.Id);
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            deprovisionOrganizer.deprovisionUsersAfterUpdate();
            Test.stopTest();
        }

        casesToAdd = [SELECT Id, OwnerId FROM Case WHERE Id IN :caseIds];
        System.assertEquals(numberOfCases, casesToAdd.size());
        for (Case testCase : casesToAdd) {
            System.assertEquals(testGroup.Id, testCase.OwnerId);
        }

        usersToDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id IN :oldUsersMap.keySet()];
        System.assert(
            usersToDeprovision[0]
                .Processing_Notes__c.contains('to Functional Group queue: ' + privateFunctionalGroup.Name)
        );
    }

    @isTest
    public static void checkUserDeprovisionedWithPackageLicenses() {
        setupTestData(1);

        Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration = Deprovision_User_Configuration__c.getAll();
        List<Id> packageLicenseIds = new List<Id>();

        for (String deprovisionConfigurationName : deprovisionUserConfiguration.keySet()) {
            if (deprovisionConfigurationName.contains('RemovePackageLicense')) {
                packageLicenseIds.add(Id.valueOf(deprovisionUserConfiguration.get(deprovisionConfigurationName).Id__c));
            }
        }

        UserPackageLicense license = new UserPackageLicense(
            UserId = usersToDeprovision[0].Id,
            PackageLicenseId = packageLicenseIds[0]
        );

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert license;
            Test.startTest();
            deprovisionOrganizer.deprovisionUsersAfterUpdate();
            Test.stopTest();
        }

        List<UserPackageLicense> packageLicenseThatWasDeleted = [
            SELECT UserId, PackageLicense.NamespacePrefix
            FROM UserPackageLicense
            WHERE UserId = :usersToDeprovision[0].Id AND PackageLicenseId = :packageLicenseIds[0]
        ];

        System.assertEquals(0, packageLicenseThatWasDeleted.size(), 'The license should have been deleted.');
    }

    @isTest
    public static void checkDeleteSobjectRecordsSuccess() {
        setupTestData(1);

        User testUser = usersToDeprovision[0];

        CaseFactory.DefaultCase caseCreator = new CaseFactory.DefaultCase();
        List<Case> casesToDelete = (List<Case>) caseCreator.create(4);

        for (Case testCase : casesToDelete) {
            testCase.OwnerId = testUser.Id;
        }
        insert casesToDelete;

        List<Id> caseIds = new List<Id>();
        for (Case testCase : casesToDelete) {
            caseIds.add(testCase.Id);
        }

        Test.startTest();
        UserDeprovisionOrganizer.deleteSobjectRecords('OwnerId', casesToDelete, null);
        Test.stopTest();

        casesToDelete = [SELECT Id FROM Case WHERE Id IN :caseIds];

        System.assert(casesToDelete.isEmpty());
    }

    @isTest
    public static void checkDeleteSobjectRecordsErrors() {
        setupTestData(2);

        CaseFactory.DefaultCase caseCreator = new CaseFactory.DefaultCase();
        List<Case> casesToDelete = (List<Case>) caseCreator.create(7);
        for (Integer i = 0; i < casesToDelete.size(); i++) {
            casesToDelete[i].OwnerId = usersToDeprovision[math.mod(i, 2)].Id;
        }

        insert casesToDelete;
        delete casesToDelete[1];

        List<Id> caseIds = new List<Id>();
        for (Case testCase : casesToDelete) {
            caseIds.add(testCase.Id);
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            UserDeprovisionOrganizer.deleteSobjectRecords('OwnerId', casesToDelete, null);
            Test.stopTest();
        }

        usersToDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id IN :oldUsersMap.keySet()];

        for (User testUser : usersToDeprovision) {
            if (testUser.Id == casesToDelete[1].OwnerId) {
                System.assertEquals(true, testUser.Processing_Notes__c.contains('The following errors have occurred:'));
            } else {
                System.assertEquals(null, testUser.Processing_Notes__c);
            }
        }

        casesToDelete = [SELECT Id, OwnerId FROM Case WHERE Id IN :caseIds];
        System.assert(casesToDelete.isEmpty());
    }

    @isTest
    public static void checkUpdateSobjectRecordsErrors() {
        setupTestData(2);

        CaseFactory.DefaultCase caseCreator = new CaseFactory.DefaultCase();
        List<Case> casesToUpdate = (List<Case>) caseCreator.create(7);
        for (Integer i = 0; i < casesToUpdate.size(); i++) {
            casesToUpdate[i].OwnerId = usersToDeprovision[math.mod(i, 2)].Id;
        }

        insert casesToUpdate;

        List<Id> caseIds = new List<Id>();
        for (Case testCase : casesToUpdate) {
            testCase.Subject = 'Test update subject';
            caseIds.add(testCase.Id);
        }
        casesToUpdate[1].CC_Functional_Group__c = '0050W000006Wgnk';
        Id errorCaseId = casesToUpdate[1].Id;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            UserDeprovisionOrganizer.updateSobjectRecords('OwnerId', casesToUpdate, null);
            Test.stopTest();
        }

        usersToDeprovision = [SELECT Processing_Notes__c FROM User WHERE Id IN :oldUsersMap.keySet()];

        for (User testUser : usersToDeprovision) {
            if (testUser.Id == casesToUpdate[1].OwnerId) {
                System.assertEquals(true, testUser.Processing_Notes__c.contains('The following errors have occurred:'));
            } else {
                System.assertEquals(null, testUser.Processing_Notes__c);
            }
        }

        casesToUpdate = [SELECT Id, Subject, OwnerId FROM Case WHERE Id IN :caseIds];
        for (Case testCase : casesToUpdate) {
            if (testCase.Id == errorCaseId) {
                System.assert(!testCase.Subject.contains('Test update subject'));
            } else {
                System.assert(testCase.Subject.contains('Test update subject'));
            }
        }
    }
}
