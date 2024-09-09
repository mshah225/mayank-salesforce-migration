@isTest
public class ProfileHelperTest {
    @TestSetup
    private static void setup() {
        // Initialize needed test users
        User testSysAdmin = TestUserHelper.createTestSysAdmin();
        USer testStandardUser = TestUserHelper.createTestStandardUser();

        insert new List<User>{ testSysAdmin, testStandardUser };
    }

    // Tests if the current user has a specific profile
    @isTest
    private static void testUserHasProfile() {
        Boolean userIsSysAdmin, userIsNotSysAdmin, userIsSysAdminById, userIsNotSysAdminById;
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        Test.startTest();
        System.runAs(TestUserHelper.getTestSysAdmin()) {
            userIsSysAdmin = ProfileHelper.currentUserHasProfile('System Administrator');
            userIsSysAdminById = ProfileHelper.currentUserHasProfileId(p.Id);
        }
        System.runAs(TestUserHelper.getTestStandardUser()) {
            userIsNotSysAdmin = ProfileHelper.currentUserHasProfile('System Administrator');
            userIsNotSysAdminById = ProfileHelper.currentUserHasProfileId(p.Id);
        }
        Test.stopTest();

        Assert.isTrue(
            userIsSysAdmin,
            'Expected userid' +
                TestUserHelper.getTestSysAdmin().Id +
                ' to be a sys admin, but currentUserHasProfile says they are NOT'
        );
        Assert.isFalse(
            userIsNotSysAdmin,
            'Expected userid' +
                TestUserHelper.getTestStandardUser().Id +
                ' to NOT be a sys admin, but currentUserHasProfile says they ARE'
        );
        Assert.isTrue(
            userIsSysAdminById,
            'Expected userid' +
                TestUserHelper.getTestSysAdmin().Id +
                ' to be a sys admin, but currentUserHasProfileId says they are NOT'
        );
        Assert.isFalse(
            userIsNotSysAdminById,
            'Expected userid' +
                TestUserHelper.getTestStandardUser().Id +
                ' to NOT be a sys admin, but currentUserHasProfileId says they ARE'
        );
    }

    // Tests if the current user has an empty or null profile name
    @isTest
    private static void testUserHasNullOrEmptyProfile() {
        Boolean currentUserHasEmptyProfile, currentUserHasNullProfile;

        Test.startTest();
        System.runAs(TestUserHelper.getTestSysAdmin()) {
            currentUserHasEmptyProfile = ProfileHelper.currentUserHasProfile('');
            currentUserHasNullProfile = ProfileHelper.currentUserHasProfile(null);
        }
        Test.stopTest();

        Assert.isFalse(currentUserHasEmptyProfile);
        Assert.isFalse(currentUserHasNullProfile);
    }

    // Tests getProfileId, ALL in cache
    @isTest
    private static void testValidProfileName() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile p2 = [SELECT Id, Name FROM Profile WHERE Name != 'System Administrator' LIMIT 1];

        // Empty cache
        List<Profile_Ids__c> profileIds = Profile_Ids__c.getAll().values();
        if (profileIds.size() > 0)
            delete profileIds;
        // And add both to cache
        profileIds = new List<Profile_Ids__c>{
            new Profile_Ids__c(Name = p.Name, Name__c = p.Name, Id__c = p.Id),
            new Profile_Ids__c(Name = p2.Name, Name__c = p2.Name, Id__c = p2.Id)
        };
        insert profileIds;

        // Run test
        Test.startTest();
        Boolean valid1 = ProfileHelper.isValidProfileName(p.Name);
        Boolean valid2 = ProfileHelper.isValidProfileName(p2.Name);
        Boolean invalid1 = ProfileHelper.isValidProfileName('INVALID PROFILE [TEST] (exa)');
        Boolean invalid2 = ProfileHelper.isValidProfileName('INVALID PROFILE [TEST] (exb)');
        Test.stopTest();

        // Assert
        Assert.isTrue(valid1, 'Expected profile name ' + p.Name + ' to be valid, but it was not');
        Assert.isTrue(valid2, 'Expected profile name ' + p2.Name + ' to be valid, but it was not');
        Assert.isFalse(invalid1, 'Expected profile name INVALID PROFILE [TEST] (exa) to be invalid, but it was valid');
        Assert.isFalse(invalid2, 'Expected profile name INVALID PROFILE [TEST] (exb) to be invalid, but it was valid');
    }

    // Tests getProfileId, ALL in cache
    @isTest
    private static void testGetProfileIdAllInCache() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile p2 = [SELECT Id, Name FROM Profile WHERE Name != 'System Administrator' LIMIT 1];

        // Empty cache
        List<Profile_Ids__c> profileIds = Profile_Ids__c.getAll().values();
        if (profileIds.size() > 0)
            delete profileIds;
        // And add both to cache
        profileIds = new List<Profile_Ids__c>{
            new Profile_Ids__c(Name = p.Name, Name__c = p.Name, Id__c = p.Id),
            new Profile_Ids__c(Name = p2.Name, Name__c = p2.Name, Id__c = p2.Id)
        };
        insert profileIds;

        // Run test
        Test.startTest();
        Integer queriesBefore = Limits.getQueries();
        Integer queryRowsBefore = Limits.getQueryRows();
        Integer queuedJobsBefore = Limits.getQueueableJobs();

        String profileId = ProfileHelper.getProfileId(p.Name);
        String profileId2 = ProfileHelper.getProfileId(p2.Name);

        Integer queriesAfter = Limits.getQueries();
        Integer queryRowsAfter = Limits.getQueryRows();
        Integer queuedJobsAfter = Limits.getQueueableJobs();
        Test.stopTest();

        // Assert
        Assert.areEqual(p.Id, profileId, 'Expected profile id=' + p.Id + ' but got profile id=' + profileId);
        Assert.areEqual(p2.Id, profileId2, 'Expected profile id=' + p2.Id + ' but got profile id=' + profileId2);
        Assert.areEqual(
            queriesBefore,
            queriesAfter,
            'Profile should have been found in the cache and shouldn\'t have required any SOQL queries, but SOQL queries were run'
        );
        Assert.areEqual(
            queryRowsBefore,
            queryRowsAfter,
            'Profile should have been found in the cache and shouldn\'t have required any SOQL queries, but SOQL queries were run'
        );
        Assert.areEqual(
            queuedJobsBefore,
            queuedJobsAfter,
            'Profile should have been found in the cache and therefore no job should have been queued'
        );
    }

    // Tests getProfileId, EMPTY cache
    @isTest
    private static void testGetProfileIdEmptyCache() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile p2 = [SELECT Id, Name FROM Profile WHERE Name != 'System Administrator' LIMIT 1];

        Integer numberOfProfiles = [SELECT COUNT() FROM Profile];

        // Empty cache
        List<Profile_Ids__c> profileIds = Profile_Ids__c.getAll().values();
        if (profileIds.size() > 0)
            delete profileIds;

        // Run test
        Test.startTest();
        Integer queriesBefore = Limits.getQueries();
        Integer queryRowsBefore = Limits.getQueryRows();
        Integer queuedJobsBefore = Limits.getQueueableJobs();

        String profileId = ProfileHelper.getProfileId(p.Name);
        String profileId2 = ProfileHelper.getProfileId(p2.Name);

        Integer queriesAfter = Limits.getQueries();
        Integer queryRowsAfter = Limits.getQueryRows();
        Integer queuedJobsAfter = Limits.getQueueableJobs();
        Test.stopTest();

        // Assert
        Assert.areEqual(p.Id, profileId, 'Expected profile id=' + p.Id + ' but got profile id=' + profileId);
        Assert.areEqual(p2.Id, profileId2, 'Expected profile id=' + p2.Id + ' but got profile id=' + profileId2);
        Assert.areEqual(
            queriesBefore + 2,
            queriesAfter,
            'Should have done a one query to get all profiles for cache and one before queuing the update job'
        );
        Assert.areEqual(
            queryRowsBefore + numberOfProfiles,
            queryRowsAfter,
            'Number of query rows should be increased by number of profiles'
        );
        Assert.areEqual(
            queuedJobsBefore + 1,
            queuedJobsAfter,
            'Cache was out of date, so an update job should have been queued'
        );
    }

    // Tests getProfileId, only some in cache
    @isTest
    private static void testGetProfileIdSomeInCache() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile p2 = [SELECT Id, Name FROM Profile WHERE Name != 'System Administrator' LIMIT 1];

        Integer numberOfProfiles = [SELECT COUNT() FROM Profile];

        // Empty cache
        List<Profile_Ids__c> profileIds = Profile_Ids__c.getAll().values();
        if (profileIds.size() > 0)
            delete profileIds;
        // And only System Admin to cache
        profileIds = new List<Profile_Ids__c>{ new Profile_Ids__c(Name = p.Name, Name__c = p.Name, Id__c = p.Id) };
        insert profileIds;

        // Run test
        Test.startTest();
        Integer queriesBefore = Limits.getQueries();
        Integer queryRowsBefore = Limits.getQueryRows();
        Integer queuedJobsBefore = Limits.getQueueableJobs();

        String profileId = ProfileHelper.getProfileId(p.Name);
        String profileId2 = ProfileHelper.getProfileId(p2.Name);

        Integer queriesAfter = Limits.getQueries();
        Integer queryRowsAfter = Limits.getQueryRows();
        Integer queuedJobsAfter = Limits.getQueueableJobs();
        Test.stopTest();

        // Assert
        Assert.areEqual(p.Id, profileId, 'Expected profile id=' + p.Id + ' but got profile id=' + profileId);
        Assert.areEqual(p2.Id, profileId2, 'Expected profile id=' + p2.Id + ' but got profile id=' + profileId2);
        Assert.areEqual(
            queriesBefore + 2,
            queriesAfter,
            'Should have done a one query to get all profiles for cache and one before queuing the update job'
        );
        Assert.areEqual(
            queryRowsBefore + (numberOfProfiles - 1),
            queryRowsAfter,
            'Number of query rows should be increased by number of profiles minus one because system admin was already in the cache'
        );
        Assert.areEqual(
            queuedJobsBefore + 1,
            queuedJobsAfter,
            'Cache was out of date, so an update job should have been queued'
        );
    }

    // Tests getProfileId, ensures queueable refreshes cache
    @isTest
    private static void testGetProfileIdUpdateCacheQueuedJob() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile p2 = [SELECT Id, Name FROM Profile WHERE Name != 'System Administrator' LIMIT 1];

        Integer numberOfProfiles = [SELECT COUNT() FROM Profile];

        // Empty cache
        List<Profile_Ids__c> profileIds = Profile_Ids__c.getAll().values();
        if (profileIds.size() > 0)
            delete profileIds;

        // Run test
        Test.startTest();
        ProfileHelper.getProfileId(p.Name);
        ProfileHelper.getProfileId(p2.Name);
        Test.stopTest();

        // Assert
        profileIds = Profile_Ids__c.getAll().values();
        Boolean foundP1 = false, foundP2 = false;
        for (Profile_Ids__c profileId : profileIds) {
            if (profileId.Id__c == p.Id)
                foundP1 = true;
            if (profileId.Id__c == p2.Id)
                foundP2 = true;
        }

        Assert.isFalse(profileIds.isEmpty(), 'Expected enqueued job to refresh cache - but it did not');
        Assert.isTrue(foundP1, 'Expected cache to include ' + p.Name + ' (' + p.Id + ') but it did not');
        Assert.isTrue(foundP2, 'Expected cache to include ' + p2.Name + ' (' + p2.Id + ') but it did not');
    }

    // Tests getProfileId, ensures doesn't double enqueue the same job
    @isTest
    private static void testGetProfileIdDuplicateUpdateCacheQueuedJob() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile p2 = [SELECT Id, Name FROM Profile WHERE Name != 'System Administrator' LIMIT 1];

        Integer numberOfProfiles = [SELECT COUNT() FROM Profile];

        // Empty cache
        List<Profile_Ids__c> profileIds = Profile_Ids__c.getAll().values();
        if (profileIds.size() > 0)
            delete profileIds;

        // Run test
        Test.startTest();

        // Setup queueable like some previous call has already enqueued it
        System.enqueueJob(new ProfileHelperQueueable());

        // And actually get profile ids
        Integer queuedJobsBefore = Limits.getQueueableJobs();

        ProfileHelper.getProfileId(p.Name);
        ProfileHelper.getProfileId(p2.Name);

        Integer queuedJobsAfter = Limits.getQueueableJobs();

        Test.stopTest();

        // Assert
        Assert.areEqual(
            queuedJobsBefore,
            queuedJobsAfter,
            'Cache was out of date, but a job already had been queued, so an update job should NOT have been queued'
        );
    }

    // Tests getProfileId, cannot queue because near SOQL limit
    @isTest
    private static void testGetProfileIdCannotQueueDueToQueueableLimit() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile p2 = [SELECT Id, Name FROM Profile WHERE Name != 'System Administrator' LIMIT 1];

        Integer numberOfProfiles = [SELECT COUNT() FROM Profile];

        // Empty cache
        List<Profile_Ids__c> profileIds = Profile_Ids__c.getAll().values();
        if (profileIds.size() > 0)
            delete profileIds;

        // Run test
        Test.startTest();

        // Get to queueable job limit
        while (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new EmptyQueueable());
        }

        // And actually get profile ids
        Integer queuedJobsBefore = Limits.getQueueableJobs();

        ProfileHelper.getProfileId(p.Name);
        ProfileHelper.getProfileId(p2.Name);

        Integer queuedJobsAfter = Limits.getQueueableJobs();

        Test.stopTest();

        // Assert
        Assert.areEqual(
            queuedJobsBefore,
            queuedJobsAfter,
            'Cache was out of date, but there wasn\'t enough SOQL queries to queue a job to update it (SOQL is needed to prevent queueing duplicate jobs)'
        );
    }

    // Tests getProfileId, cannot queue because near SOQL limit
    @isTest
    private static void testGetProfileIdCannotQueueDueToSoqlLimit() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile p2 = [SELECT Id, Name FROM Profile WHERE Name != 'System Administrator' LIMIT 1];

        Integer numberOfProfiles = [SELECT COUNT() FROM Profile];

        // Empty cache
        List<Profile_Ids__c> profileIds = Profile_Ids__c.getAll().values();
        if (profileIds.size() > 0)
            delete profileIds;

        // Run test
        Test.startTest();

        // Get to one less than SOQL query limit
        // enough space to get results but not enough to queue the update job
        while (Limits.getQueries() < Limits.getLimitQueries() - 1) {
            Profile tmpProfile = [SELECT Id FROM Profile LIMIT 1];
        }

        // And actually get profile ids
        Integer queuedJobsBefore = Limits.getQueueableJobs();

        ProfileHelper.getProfileId(p.Name);
        ProfileHelper.getProfileId(p2.Name);

        Integer queuedJobsAfter = Limits.getQueueableJobs();

        Test.stopTest();

        // Assert
        Assert.areEqual(
            queuedJobsBefore,
            queuedJobsAfter,
            'Cache was out of date, but there wasn\'t enough SOQL queries to queue a job to update it (SOQL is needed to prevent queueing duplicate jobs)'
        );
    }

    // Tests getProfileId, at SOQL query limit
    @isTest
    private static void testGetProfileIdGovernorErrorQueries() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile p2 = [SELECT Id, Name FROM Profile WHERE Name != 'System Administrator' LIMIT 1];

        Integer numberOfProfiles = [SELECT COUNT() FROM Profile];

        // Empty cache
        List<Profile_Ids__c> profileIds = Profile_Ids__c.getAll().values();
        if (profileIds.size() > 0)
            delete profileIds;

        Exception thrownException = null;

        // Run test
        Test.startTest();

        // Get to SOQL governor limit
        while (Limits.getQueries() < Limits.getLimitQueries()) {
            Profile tmpProfile = [SELECT Id FROM Profile LIMIT 1];
        }

        // Try and fail to get profile id
        try {
            String profileId = ProfileHelper.getProfileId(p.Name);
        } catch (Exception ex) {
            thrownException = ex;
        }

        Test.stopTest();

        // Assert
        Assert.isInstanceOfType(
            thrownException,
            ProfileHelper.ProfileHelperSoqlGovernorLimitException.class,
            'Expected to throw an exception of type ProfileHelper.ProfileHelperSoqlGovernorLimitException, but actually threw ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('Already at SOQL query limit'),
            'Expected error message to contain "Already at SOQL query limit", but it instead said "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    // Tests getProfileId, at SOQL row limit
    @isTest
    private static void testGetProfileIdGovernorErrorQueryRows() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile p2 = [SELECT Id, Name FROM Profile WHERE Name != 'System Administrator' LIMIT 1];

        Integer numberOfProfiles = [SELECT COUNT() FROM Profile];

        // Empty cache
        List<Profile_Ids__c> profileIds = Profile_Ids__c.getAll().values();
        if (profileIds.size() > 0)
            delete profileIds;

        Exception thrownException = null;

        // Run test
        Test.startTest();

        // Get to SOQL governor limit (we have >10k users so this should hit pretty fast)
        while (Limits.getQueryRows() < Limits.getLimitQueryRows()) {
            Integer remainingLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
            List<User> tempUsers = [SELECT Id FROM User LIMIT :remainingLimit];
            tempUsers = null;
        }

        // Try and fail to get profile id
        try {
            String profileId = ProfileHelper.getProfileId(p.Name);
        } catch (Exception ex) {
            thrownException = ex;
        }

        Test.stopTest();

        // Assert
        Assert.isInstanceOfType(
            thrownException,
            ProfileHelper.ProfileHelperSoqlGovernorLimitException.class,
            'Expected to throw an exception of type ProfileHelper.ProfileHelperSoqlGovernorLimitException, but actually threw ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('Too close to SOQL row query limit'),
            'Expected error message to contain "Too close to SOQL row query limit", but it instead said "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    private class EmptyQueueable implements Queueable {
        public EmptyQueueable() {
        }
        public void execute(QueueableContext context) {
        }
    }
}
