@isTest
public class UserDeprovisionTest {
    private static final String icAgentConsoleId = '050d0000000Wl7IAAS';
    private static final String changeToUserRoleId = '00Ed00000017bQ5EAI';
    private static final String changeToProfileId = '00ed00000019yCpAAI';

    @TestSetup
    private static void setupTestData() {
        UserRole testRole = new UserRole(Name = 'TestRole');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testRole;
        }

        // Test user
        User testUser = new User(
            FirstName = 'Test User Deprovision User',
            LastName = 'Test',
            Username = 'user.deprovision@test.test',
            Email = 'user.deprovision@test.test',
            Alias = 'testUsr1',
            CommunityNickname = 'user.deprovision',
            TimeZoneSidKey = 'America/Phoenix',
            UserRoleId = testRole.Id,
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = RecordIdHelper.getProfileId('Standard User'),
            AboutMe = 'Some text field',
            Sandbox_DEV__c = true,
            LanguageLocaleKey = 'en_US'
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testUser;
        }

        // Create related records

        // Groups
        List<Group> testGroups = new List<Group>();
        List<GroupMember> testGroupMembers = new List<GroupMember>();
        for (Integer i = 0; i < 5; i++)
            testGroups.add(new Group(Name = 'Test Group ' + i, Type = 'Queue'));
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testGroups;
        }
        // and Members
        for (Group g : testGroups)
            testGroupMembers.add(new GroupMember(UserOrGroupId = testUser.Id, GroupId = g.Id));
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testGroupMembers;
        }

        // Permission Sets
        List<PermissionSet> testPermSets = new List<PermissionSet>();
        List<PermissionSetAssignment> testPSAs = new List<PermissionSetAssignment>();
        for (Integer i = 0; i < 5; i++)
            testPermSets.add(new PermissionSet(Name = 'Test_PS_' + i, Label = 'Test PS ' + i));
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testPermSets;
        }
        // and Assignments
        for (PermissionSet ps : testPermSets)
            testPSAs.add(new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id));
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testPSAs;
        }

        // Licenses
        UserPackageLicense testLicense = new UserPackageLicense(
            UserId = testUser.Id,
            PackageLicenseId = Id.valueOf(icAgentConsoleId)
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testLicense;
        }

        // And scheduled jobs - one every 15 minutes
        for (Integer i = 0; i < 4; i++) {
            System.runAs(testUser) {
                Schedulable job = new ScheduledStalledSMSDetector();
                String sch = '0 ' + 15 * i + ' * * * ?';
                System.Schedule('UserDeproJob-' + i, sch, job);
            }
        }

        // Chatter Groups
        List<CollaborationGroup> testChatterGroups = new List<CollaborationGroup>();
        List<CollaborationGroupMember> testChatterGroupMembers = new List<CollaborationGroupMember>();
        for (Integer i = 0; i < 5; i++)
            testChatterGroups.add(new CollaborationGroup(Name = 'Test Chatter Grp-' + i, CollaborationType = 'Public'));
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testChatterGroups;
        }
        // and Members
        for (CollaborationGroup chatterGroup : testChatterGroups)
            testChatterGroupMembers.add(
                new CollaborationGroupMember(MemberId = testUser.Id, CollaborationGroupId = chatterGroup.Id)
            );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testChatterGroupMembers;
        }

        // User Login
        UserLogin testUserLogin = [
            SELECT Id, UserId, IsFrozen
            FROM UserLogin
            WHERE UserId = :testUser.Id
            LIMIT 1
        ];
        testUserLogin.IsFrozen = true;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update testUserLogin;
        }

        // Campaigns
        List<Campaign> campaigns = new List<Campaign>();
        for (Integer i = 0; i < 5; i++) {
            campaigns.add(new Campaign(Name = 'Test Campaign #' + (i + 1), OwnerId = testUser.Id));
        }
        insert campaigns;

        // Cases
        List<Case> casesToAdd = new List<Case>();
        // the functional group
        Case_Classification__c privateFunctionalGroup = new Case_Classification__c(
            Name = 'Test Functional Group',
            Is_Functional_Group_Private__c = true,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group'),
            Active__c = true,
            Visible__c = true,
            Queue_Id__c = UserInfo.getUserId()
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert privateFunctionalGroup;
        }
        // and the cases
        for (Integer i = 0; i < 100; i++)
            casesToAdd.add(
                new Case(
                    Subject = 'Test Case ' + i,
                    Description = 'Description',
                    CC_Functional_Group__c = privateFunctionalGroup.Id,
                    OwnerId = testUser.Id
                )
            );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert casesToAdd;
        }

        // The custom settings
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
            new Deprovision_User_Configuration__c(Name = 'RemoveValue_AboutMe', Name__c = 'AboutMe')
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
        deproivisionConfigurations.add(
            new Deprovision_User_Configuration__c(Name = 'AbortCronJob_Schuduled_Apex', Name__c = '7')
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert deproivisionConfigurations;
        }
    }
    private static void setupCustomMetadata() {
        UserRole testRole = [SELECT Id, Name FROM UserRole WHERE Name = 'TestRole' LIMIT 1];

        UserDeprovisionOrganizer.deprovisionUserReassignmentMetadata = new Map<String, Deprovision_User_Campaign_Reassignment__mdt>{
            'Reassign_TestRole' => new Deprovision_User_Campaign_Reassignment__mdt(
                Target_Role_Id__c = testRole.Id,
                Target_Role_Name__c = testRole.Name,
                New_Default_Owner_Id__c = UserInfo.getUserId(),
                New_Default_Owner_Name__c = '[New Campaign Owner Name]'
            )
        };
    }

    @isTest
    public static void testUserFields() {
        setupCustomMetadata();
        // Get test user
        User testUser = [
            SELECT
                Id,
                IsActive,
                Deprovision_User__c,
                UserRoleId,
                ProfileId,
                AboutMe,
                Sandbox_DEV__c,
                Processing_Notes__c
            FROM User
            WHERE Alias = 'testUsr1'
            LIMIT 1
        ];

        // Check fields are not already post-deprovision values (otherwise we won't be able to tell if the process changed the values or not)
        Assert.areNotEqual(changeToUserRoleId, testUser.UserRoleId);
        Assert.areNotEqual(changeToProfileId, testUser.ProfileId);
        Assert.areNotEqual(null, testUser.AboutMe);
        Assert.areNotEqual(false, testUser.Sandbox_DEV__c);
        Assert.areNotEqual(false, testUser.IsActive);

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [
            SELECT
                Id,
                IsActive,
                Deprovision_User__c,
                UserRoleId,
                ProfileId,
                AboutMe,
                Sandbox_DEV__c,
                Processing_Notes__c
            FROM User
            WHERE Id = :testUser.Id
        ];

        // Check user fields
        Assert.areEqual(changeToUserRoleId, testUser.UserRoleId);
        Assert.areEqual(changeToProfileId, testUser.ProfileId);
        Assert.areEqual(null, testUser.AboutMe);
        Assert.areEqual(false, testUser.Sandbox_DEV__c);
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('UserId: ' + UserInfo.getUserId()),
            'Expected processing notes to have running user id, but it did not'
        );
        Assert.areEqual(false, testUser.IsActive);
        Assert.areEqual(false, testUser.Deprovision_User__c);
    }

    @isTest
    public static void testRemoveFromGroups() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Check they are currently a member of some groups
        List<GroupMember> groupMemberships = [
            SELECT Id, Group.Name
            FROM GroupMember
            WHERE UserOrGroupId = :testUser.Id
        ];
        List<String> groupNames = new List<String>();
        for (GroupMember groupMembership : groupMemberships) {
            groupNames.add(groupMembership.Group.Name);
        }
        Assert.isFalse(groupMemberships.isEmpty(), 'This user should have some group memberships pre-deprovision');

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Check group memberships have been removed
        groupMemberships = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id];
        Assert.isTrue(groupMemberships.isEmpty(), 'Should have deleted group memberships');
        // and processing notes indicate groups were removed
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Removed user from Public Groups:'),
            'The deletion of group memberships should have been recorded on the user'
        );
        for (String groupName : groupNames) {
            Assert.isTrue(
                testUser.Processing_Notes__c.contains(groupName),
                'Expected processing notes to include names of groups user was removed from but it was missing "' +
                    groupName +
                    '"'
            );
        }
    }

    @isTest
    public static void testRemoveFromPermissionSets() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Check they have some permission sets
        List<PermissionSetAssignment> permissionSetAssignments = [
            SELECT Id, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId = :testUser.Id AND PermissionSet.IsOwnedByProfile = FALSE
        ];
        List<String> permSetNames = new List<String>();
        for (PermissionSetAssignment psa : permissionSetAssignments) {
            permSetNames.add(psa.PermissionSet.Name);
        }
        Assert.isFalse(
            permissionSetAssignments.isEmpty(),
            'This user should have some permission set assignments pre-deprovision'
        );

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Check permission set assignments have been removed
        permissionSetAssignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :testUser.Id AND PermissionSet.IsOwnedByProfile = FALSE
        ];
        Assert.isTrue(permissionSetAssignments.isEmpty(), 'Should have removed user from permission sets');
        // and processing notes indicate permission set assignments were removed
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Removed user from Permission Sets:'),
            'The deletion of permission set assignments should have been recorded on the user'
        );
        for (String permSetName : permSetNames) {
            Assert.isTrue(
                testUser.Processing_Notes__c.contains(permSetName),
                'Expected processing notes to include names of permission sets user was removed from but it was missing "' +
                    permSetName +
                    '"'
            );
        }
    }

    @isTest
    public static void testRemoveLicenses() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Check they have some licenses
        List<UserPackageLicense> packageLicenses = [
            SELECT UserId, PackageLicense.NamespacePrefix
            FROM UserPackageLicense
            WHERE UserId = :testUser.Id AND PackageLicenseId = :icAgentConsoleId
        ];
        List<String> uplNames = new List<String>();
        for (UserPackageLicense upl : packageLicenses) {
            uplNames.add(upl.PackageLicense.NamespacePrefix);
        }
        Assert.isFalse(packageLicenses.isEmpty(), 'This user should have a license pre-deprovision');

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Check licenses have been removed
        packageLicenses = [
            SELECT UserId, PackageLicense.NamespacePrefix
            FROM UserPackageLicense
            WHERE UserId = :testUser.Id AND PackageLicenseId = :icAgentConsoleId
        ];
        Assert.isTrue(packageLicenses.isEmpty(), 'Should have deleted license');
        // and processing notes indicate licenses that were removed
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Removed user from Package Licenses:'),
            'The deletion of package licenses should have been recorded on the user'
        );
        for (String uplName : uplNames) {
            Assert.isTrue(
                testUser.Processing_Notes__c.contains(uplName),
                'Expected processing notes to include names of package licenses that were removed from user, but it was missing "' +
                    uplName +
                    '"'
            );
        }
    }

    @isTest
    public static void testAbortCronJobs() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Check they have some cron jobs
        List<CronTrigger> scheduledJobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE OwnerId = :testUser.Id];
        List<String> jobNames = new List<String>();
        for (CronTrigger cronJob : scheduledJobs) {
            jobNames.add(cronJob.CronJobDetail.Name);
        }
        Assert.isFalse(scheduledJobs.isEmpty(), 'This user should have a license pre-deprovision');

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Check jobs have been aborted
        scheduledJobs = [SELECT Id FROM CronTrigger WHERE OwnerId = :testUser.Id];
        Assert.isTrue(scheduledJobs.isEmpty(), 'Did not abort scheduled jobs');
        // and processing notes indicate cron jobs that were aborted
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Removed user from Package Licenses:'),
            'The deletion of package licenses should have been recorded on the user'
        );
        for (String jobName : jobNames) {
            Assert.isTrue(
                testUser.Processing_Notes__c.contains(jobName),
                'Expected processing notes to include names of package licenses that were removed from user, but it was missing "' +
                    jobName +
                    '"'
            );
        }
    }

    @isTest
    public static void testRemoveFromChatterGroups() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Check they are currently a member of some chatter groups
        List<CollaborationGroupMember> collaborationGroupMembers = [
            SELECT Id, CollaborationGroup.Name
            FROM CollaborationGroupMember
            WHERE MemberId = :testUser.Id
        ];
        List<String> groupNames = new List<String>();
        for (CollaborationGroupMember groupMembership : collaborationGroupMembers) {
            groupNames.add(groupMembership.CollaborationGroup.Name);
        }
        Assert.isFalse(
            collaborationGroupMembers.isEmpty(),
            'This user should have some chatter group memberships pre-deprovision'
        );

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Check group memberships have been removed
        collaborationGroupMembers = [SELECT Id FROM CollaborationGroupMember WHERE MemberId = :testUser.Id];
        Assert.isTrue(collaborationGroupMembers.isEmpty(), 'Should have deleted chatter group memberships');
        // and processing notes indicate groups were removed
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Removed user from Chatter Groups:'),
            'The deletion of chatter group memberships should have been recorded on the user'
        );
        for (String groupName : groupNames) {
            Assert.isTrue(
                testUser.Processing_Notes__c.contains(groupName),
                'Expected processing notes to include names of chatter groups user was removed from but it was missing "' +
                    groupName +
                    '"'
            );
        }
    }

    @isTest
    public static void testUnfreezeUserLogin() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Check they are currently have a frozen UserLogin
        UserLogin userLogin = [
            SELECT Id, IsFrozen
            FROM UserLogin
            WHERE UserId = :testUser.Id
        ];
        Assert.areEqual(true, userLogin.IsFrozen, 'This user should have a frozen user login pre-deprovision');

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Check user login was unfrozen
        userLogin = [
            SELECT Id, IsFrozen
            FROM UserLogin
            WHERE UserId = :testUser.Id
        ];
        Assert.areEqual(false, userLogin.IsFrozen, 'Should have unfrozen user login');
        // and processing notes indicate user was unfrozen were removed
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Unfroze related UserLogin'),
            'Unfreezing the UserLogin should have been recorded on the user'
        );
    }

    @isTest
    public static void testReassignCampaigns() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Check they have campaigns assigned
        List<Campaign> campaigns = [
            SELECT Id
            FROM Campaign
            WHERE OwnerId = :testUser.Id
        ];

        Assert.isFalse(campaigns.isEmpty(), 'This user should have some campaigns pre-deprovision');

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Id, Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Check sender id was renamed
        campaigns = [
            SELECT Id, OwnerId
            FROM Campaign
            WHERE Id IN :new Map<Id, Campaign>(campaigns).keySet()
        ];
        Assert.isFalse(campaigns.isEmpty(), 'Should NOT have deleted Campaigns');
        for (Campaign cam : campaigns) {
            Assert.areNotEqual(testUser.Id, cam.OwnerId, 'Campaigns should have been reassigned');
            Assert.areEqual(UserInfo.getUserId(), cam.OwnerId, 'Campaigns should have been reassigned');
        }

        // and processing notes indicate Campaigns were reassigned

        Assert.isTrue(
            testUser.Processing_Notes__c.contains(
                'Reassigned ' + campaigns.size() + ' campaigns to [New Campaign Owner Name]'
            ),
            'Reassigned campaigns should be recorded on the user'
        );
    }

    @isTest
    public static void testReassignCases() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Check they are currently have some cases
        List<Case> usersCases = [
            SELECT Id, OwnerId, CC_Functional_Group__r.Queue_Id__c
            FROM Case
            WHERE OwnerId = :testUser.Id
        ];
        Assert.isFalse(usersCases.isEmpty(), 'This user should have some cases assigned pre-deprovision');
        Integer caseCount = usersCases.size();
        Id transferToId = usersCases[0].CC_Functional_Group__r.Queue_Id__c;

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Check cases were reasssigned
        usersCases = [SELECT Id, OwnerId FROM Case WHERE Id IN :new Map<Id, Case>(usersCases).keySet()];
        for (Case c : usersCases) {
            Assert.areEqual(
                transferToId,
                c.OwnerId,
                'Should have reassigned case ' + c.Id + ' to ' + transferToId + ' but it was not'
            );
        }

        // and processing notes indicate cases were reassigned
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Successfully transferred ' + caseCount + ' private cases to queue'),
            'Case transfers should have been recorded on the user'
        );
    }

    @isTest
    public static void testEmptyUser() {
        setupCustomMetadata();

        // Test user no records
        User testUser = new User(
            FirstName = 'Test User Deprovision User NO RECORDS',
            LastName = 'Test',
            Username = 'user.deprovision.no.records@test.test',
            Email = 'user.deprovision.no.records@test.test',
            Alias = 'testUsr2',
            CommunityNickname = 'user.deprovision.no.records',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = RecordIdHelper.getProfileId('Standard User'),
            AboutMe = 'Some text field',
            Sandbox_DEV__c = true,
            LanguageLocaleKey = 'en_US'
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testUser;
        }

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [
            SELECT Id, IsActive, Deprovision_User__c
            FROM User
            WHERE Id = :testUser.Id
        ];

        // Check set to inactive
        Assert.areEqual(false, testUser.IsActive);
        Assert.areEqual(false, testUser.Deprovision_User__c);
    }

    @isTest
    public static void testRejectByProfile() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Alias = 'testUsr1' LIMIT 1];
        String profileId = testUser.ProfileId, profileName = testUser.Profile.Name;

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Add custom setting to reject based on profile
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new Deprovision_User_Configuration__c(
                Name = 'ProfileToIgnore_1',
                Id__c = profileId,
                Name__c = profileName
            );
        }

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Id, IsActive, Deprovision_User__c, Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // processing notes should include rejection reason
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Profile matched to: ' + profileName + ', Stopping User Deprovision'),
            'Expected processing notes to be on user'
        );
        Assert.areEqual(true, testUser.IsActive, 'Should NOT have deactivated user');
        Assert.areEqual(false, testUser.Deprovision_User__c, 'Should have unchecked deprovision user field');
    }

    @isTest
    public static void testRejectByPermSet() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];
        PermissionSetAssignment psa = [
            SELECT PermissionSetId, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId = :testUser.Id AND PermissionSet.Name LIKE 'Test_PS_%'
            LIMIT 1
        ];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Add custom setting to reject based on perm set
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new Deprovision_User_Configuration__c(
                Name = 'PermissionSetToIgnore_1',
                Id__c = psa.PermissionSetId,
                Name__c = psa.PermissionSet.Name
            );
        }

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Id, IsActive, Deprovision_User__c, Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // processing notes should include rejection reason
        Assert.isTrue(
            testUser.Processing_Notes__c.contains(
                'Permission set matched to: ' + psa.PermissionSet.Name + ', Stopping User Deprovision'
            ),
            'Expected processing notes to be on user'
        );
        Assert.areEqual(true, testUser.IsActive, 'Should NOT have deactivated user');
        Assert.areEqual(false, testUser.Deprovision_User__c, 'Should have unchecked deprovision user field');
    }

    @isTest
    public static void testRejectByAdminDevRole() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id, Role_Administrator_Developer__c FROM User WHERE Alias = 'testUsr1' LIMIT 1];
        testUser.Role_Administrator_Developer__c = true;
        update testUser;

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Id, IsActive, Deprovision_User__c, Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // processing notes should include rejection reason
        Assert.isTrue(
            testUser.Processing_Notes__c.contains(
                'Detected SF Developer or Admin based on PeopleSoft Roles Administrator/Developer. Stopping User Deprovision'
            ),
            'Expected processing notes to be on user'
        );
        Assert.areEqual(true, testUser.IsActive, 'Should NOT have deactivated user');
        Assert.areEqual(false, testUser.Deprovision_User__c, 'Should have unchecked deprovision user field');
    }

    @isTest
    public static void testRejectByDelegratedAdmin() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id, Sandbox_Delagated_Administrator__c FROM User WHERE Alias = 'testUsr1' LIMIT 1];
        testUser.Sandbox_Delagated_Administrator__c = true;
        update testUser;

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Id, IsActive, Deprovision_User__c, Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // processing notes should include rejection reason
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Detected Delegated Administrator. Stopping User Deprovision'),
            'Expected processing notes to be on user'
        );
        Assert.areEqual(true, testUser.IsActive, 'Should NOT have deactivated user');
        Assert.areEqual(false, testUser.Deprovision_User__c, 'Should have unchecked deprovision user field');
    }

    @isTest
    public static void testErrorRemovingFromGroups() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        UserDeprovisioner.FORCE_LOCK = true; // Prevent deprovisioners from refreshing data

        // Do it
        Test.startTest();

        update testUser;

        // Delete data the deprovisioners rely on
        System.runAs(new User(Id = UserInfo.getUserId())) {
            delete UserDeprovisionOrganizer.getGroupMemberships(new List<Id>{ testUser.Id }).get(testUser.Id);
        }

        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Processing notes were updated to include error details
        Assert.isTrue(
            testUser.Processing_Notes__c.contains(
                'Error while deleting the GroupMember objects during user deprovisioning'
            ),
            'Should contain exception details on user'
        );

        // Check for error logger case
        List<Case> errorLoggerCase = [SELECT Id, Subject, Description FROM Case WHERE Subject LIKE 'Apex Exception:%'];
        Assert.isFalse(errorLoggerCase.isEmpty(), 'Should have created error logger case, but did not');
        Assert.isTrue(
            errorLoggerCase[0].Description.contains('GroupMember'),
            'Error logger description should indicate object type'
        );
    }

    @isTest
    public static void testErrorRemovingFromPermissionSets() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        UserDeprovisioner.FORCE_LOCK = true; // Prevent deprovisioners from refreshing data

        // Do it
        Test.startTest();

        update testUser;

        // Delete data the deprovisioners rely on
        System.runAs(new User(Id = UserInfo.getUserId())) {
            delete UserDeprovisionOrganizer.getPermissionSetAssignments(new List<Id>{ testUser.Id }).get(testUser.Id);
        }

        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Processing notes were updated to include error details
        Assert.isTrue(
            testUser.Processing_Notes__c.contains(
                'Error while deleting the PermissionSetAssignment objects during user deprovisioning'
            ),
            'Should contain exception details on user'
        );

        // Check for error logger case
        List<Case> errorLoggerCase = [SELECT Id, Subject, Description FROM Case WHERE Subject LIKE 'Apex Exception:%'];
        Assert.isFalse(errorLoggerCase.isEmpty(), 'Should have created error logger case, but did not');
        Assert.isTrue(
            errorLoggerCase[0].Description.contains('PermissionSetAssignment'),
            'Error logger description should indicate object type'
        );
    }

    @isTest
    public static void testErrorRemovingLicenses() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        UserDeprovisioner.FORCE_LOCK = true; // Prevent deprovisioners from refreshing data

        // Do it
        Test.startTest();

        update testUser;

        // Delete data the deprovisioners rely on
        System.runAs(new User(Id = UserInfo.getUserId())) {
            delete UserDeprovisionOrganizer.getUserPackageLicenses(new List<Id>{ testUser.Id }).get(testUser.Id);
        }

        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Processing notes were updated to include error details
        Assert.isTrue(
            testUser.Processing_Notes__c.contains(
                'Error while deleting the UserPackageLicense objects during user deprovisioning'
            ),
            'Should contain exception details on user'
        );

        // Check for error logger case
        List<Case> errorLoggerCase = [SELECT Id, Subject, Description FROM Case WHERE Subject LIKE 'Apex Exception:%'];
        Assert.isFalse(errorLoggerCase.isEmpty(), 'Should have created error logger case, but did not');
        Assert.isTrue(
            errorLoggerCase[0].Description.contains('UserPackageLicense'),
            'Error logger description should indicate object type'
        );
    }

    @isTest
    public static void testErrorAbortingCronJobs() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        UserDeprovisioner.FORCE_LOCK = true; // Prevent deprovisioners from refreshing data

        // Do it
        Test.startTest();

        update testUser;

        // Abort the jobs early
        System.runAs(new User(Id = UserInfo.getUserId())) {
            for (
                CronTrigger cronJob : UserDeprovisionOrganizer.getCronJobs(new List<Id>{ testUser.Id }).get(testUser.Id)
            ) {
                System.abortJob(cronJob.Id);
            }
        }

        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Processing notes were updated to include error details
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Error while aborting the cron jobs during user deprovisioning'),
            'Should contain exception details on user'
        );

        // Check for error logger case
        List<Case> errorLoggerCase = [SELECT Id, Subject, Description FROM Case WHERE Subject LIKE 'Apex Exception:%'];
        Assert.isFalse(errorLoggerCase.isEmpty(), 'Should have created error logger case, but did not');
        Assert.isTrue(
            errorLoggerCase[0].Description.contains('Job does not exist or is already aborted'),
            'Error logger description should indivate job was already aborted'
        );
    }

    @isTest
    public static void testErrorReassigningCampaigns() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        UserDeprovisioner.FORCE_LOCK = true; // Prevent deprovisioners from refreshing data

        // Do it
        Test.startTest();

        update testUser;

        // Delete data the deprovisioners rely on
        System.runAs(new User(Id = UserInfo.getUserId())) {
            delete UserDeprovisionOrganizer.getCampaigns(new List<Id>{ testUser.Id }).get(testUser.Id);
        }

        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Processing notes were updated to include error details
        Assert.isTrue(
            testUser.Processing_Notes__c.contains(
                'Error while updating the Campaign objects during user deprovisioning'
            ),
            'Should contain exception details on user'
        );

        // Check for error logger case
        List<Case> errorLoggerCase = [SELECT Id, Subject, Description FROM Case WHERE Subject LIKE 'Apex Exception:%'];
        Assert.isFalse(errorLoggerCase.isEmpty(), 'Should have created error logger case, but did not');
        Assert.isTrue(
            errorLoggerCase[0].Description.contains('Campaign'),
            'Error logger description should indicate object type'
        );
    }

    @isTest
    public static void testErrorWhenReassignCases() {
        setupCustomMetadata();
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testUsr1' LIMIT 1];

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Setup functional group to have invalid queue id - this causes an error when reassigning
        Group testGroup = new Group(Name = 'Test Group - Functional Group Queue');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testGroup;
        }

        // Setup functional group to point at this misconfigured group
        Case_Classification__c privateFunctionalGroup = [
            SELECT Id, Queue_Id__c
            FROM Case_Classification__c
            WHERE Id IN (SELECT CC_Functional_Group__c FROM Case)
        ];
        privateFunctionalGroup.Queue_Id__c = testGroup.Id;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update privateFunctionalGroup;
        }

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Processing notes were updated to include error details
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Exception Thrown for case ID'),
            'Should contain exception details on user'
        );

        // Check for error logger case
        List<Case> errorLoggerCase = [SELECT Id, Subject, Description FROM Case WHERE Subject LIKE 'Apex Exception:%'];
        Assert.isFalse(errorLoggerCase.isEmpty(), 'Should have created error logger case, but did not');

        Assert.isTrue(
            errorLoggerCase[0].Description.contains('System.DmlException'),
            'Error logger description should be DML exception'
        );
    }
}