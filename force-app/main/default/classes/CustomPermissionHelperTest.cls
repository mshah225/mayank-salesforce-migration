@isTest
public class CustomPermissionHelperTest {
    @TestSetup
    private static void setup() {
        // Initialize needed test users
        User testUser = TestUserHelper.createTestSysAdmin();
        insert new List<User>{ testUser };
    }

    // Tests if the current user has a specific custom permission
    @isTest
    private static void testUserHasCustomPermission() {
        Boolean userHasCustomPermission, userDoesNotHaveCustomPermission;
        Integer queriesBefore, queryRowsBefore, queriesAfter, queryRowsAfter;
        User testUser = TestUserHelper.getTestSysAdmin();

        activateCustomPerm(testUser.Id, 'Student_360_Visible');

        Test.startTest();

        System.runAs(testUser) {
            queriesBefore = Limits.getQueries();
            queryRowsBefore = Limits.getQueryRows();

            userHasCustomPermission = CustomPermissionHelper.currentUserHasCustomPermission('Student_360_Visible');
            userDoesNotHaveCustomPermission = CustomPermissionHelper.currentUserHasCustomPermission(
                'Fake_Custom_Perm_404'
            );

            queriesAfter = Limits.getQueries();
            queryRowsAfter = Limits.getQueryRows();
        }

        Test.stopTest();

        Assert.isTrue(
            userHasCustomPermission,
            'Test user should have Student_360_Visible but currentUserHasCustomPermission said they don\'t'
        );
        Assert.isFalse(
            userDoesNotHaveCustomPermission,
            'Test user should NOT have Fake_Custom_Perm_404 but currentUserHasCustomPermission said they do'
        );

        Assert.areEqual(
            queriesBefore,
            queriesAfter,
            'Should have been SOQL-free to check if current user has custom permission, but it took ' +
                (queriesAfter - queriesBefore) +
                ' queries'
        );
        Assert.areEqual(
            queryRowsBefore,
            queryRowsAfter,
            'Should have been SOQL-free to check if current user has custom permission, but it used ' +
                (queryRowsAfter - queryRowsBefore) +
                ' query rows'
        );
    }

    // Tests if a non-current user has a specific custom permission
    @isTest
    private static void testOtherUserHasCustomPermission() {
        Boolean userHasCustomPermission, userDoesNotHaveCustomPermission;
        Integer queriesBefore, queriesAfter;
        User testUser = TestUserHelper.getTestSysAdmin();

        activateCustomPerm(testUser.Id, 'Student_360_Visible');

        Test.startTest();
        queriesBefore = Limits.getQueries();

        userHasCustomPermission = CustomPermissionHelper.userHasCustomPermission('Student_360_Visible', testUser.Id);
        userDoesNotHaveCustomPermission = CustomPermissionHelper.userHasCustomPermission(
            'Fake_Custom_Perm_404',
            testUser.Id
        );

        queriesAfter = Limits.getQueries();
        Test.stopTest();

        Assert.isTrue(
            userHasCustomPermission,
            'Test user should have Student_360_Visible but currentUserHasCustomPermission said they don\'t'
        );
        Assert.isFalse(
            userDoesNotHaveCustomPermission,
            'Test user shouldn\'t have Fake_Custom_Perm_404 but currentUserHasCustomPermission said they do'
        );

        Assert.areEqual(
            queriesBefore + 3,
            queriesAfter,
            'Should have taken 3 SOQL queries (1 per custom perm + 1 for user\'s permission sets) to check if current user has custom permission, but it took ' +
                (queriesAfter - queriesBefore) +
                ' queries'
        );
    }

    // Tests Exception is thrown when at SOQL query limit
    @isTest
    private static void testUserHasCustomPermissionErrorQueries() {
        User testUser = TestUserHelper.getTestSysAdmin();
        Exception thrownException = null;

        Test.startTest();
        // Get to SOQL governor limit
        while (Limits.getQueries() < Limits.getLimitQueries()) {
            Profile tmpProfile = [SELECT Id FROM Profile LIMIT 1];
        }

        // Try and fail
        try {
            CustomPermissionHelper.userHasCustomPermission('Student_360_Visible', testUser.Id);
        } catch (Exception ex) {
            thrownException = ex;
        }
        Test.stopTest();

        // Assert
        Assert.isInstanceOfType(
            thrownException,
            CustomPermissionHelper.CustomPermissionHelperSoqGovernorLimitException.class,
            'Expected to throw an exception of type CustomPermissionHelper.CustomPermissionHelperSoqGovernorLimitException, but actually threw ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('Already at SOQL query limit'),
            'Expected error message to contain "Already at SOQL query limit", but it instead said "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    // Tests Exception is thrown when near SOQL query limit
    @isTest
    private static void testUserHasCustomPermissionErrorQueriesMinus1() {
        User testUser = TestUserHelper.getTestSysAdmin();
        Exception thrownException = null;

        Test.startTest();
        // Get to SOQL governor limit - 1 (needs a minimum of 2 to check when caches are empty)
        while (Limits.getQueries() < Limits.getLimitQueries() - 1) {
            Profile tmpProfile = [SELECT Id FROM Profile LIMIT 1];
        }

        // Try and fail
        try {
            CustomPermissionHelper.userHasCustomPermission('Student_360_Visible', testUser.Id);
        } catch (Exception ex) {
            thrownException = ex;
        }
        Test.stopTest();

        // Assert
        Assert.isInstanceOfType(
            thrownException,
            CustomPermissionHelper.CustomPermissionHelperSoqGovernorLimitException.class,
            'Expected to throw an exception of type CustomPermissionHelper.CustomPermissionHelperSoqGovernorLimitException, but actually threw ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('Already at SOQL query limit'),
            'Expected error message to contain "Already at SOQL query limit", but it instead said "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    // Tests Exception is thrown when at SOQL query row limit
    @isTest
    private static void testUserHasCustomPermissionErrorQueryRows() {
        User testUser = TestUserHelper.getTestSysAdmin();
        Exception thrownException = null;

        Test.startTest();

        // Get to SOQL governor limit (we have >10k users so this should hit pretty fast)
        while (Limits.getQueryRows() < Limits.getLimitQueryRows()) {
            Integer remainingLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
            List<User> tempUsers = [SELECT Id FROM User LIMIT :remainingLimit];
            tempUsers = null;
        }

        // Try and fail
        try {
            CustomPermissionHelper.userHasCustomPermission('Student_360_Visible', testUser.Id);
        } catch (Exception ex) {
            thrownException = ex;
        }

        Test.stopTest();

        // Assert
        Assert.isInstanceOfType(
            thrownException,
            CustomPermissionHelper.CustomPermissionHelperSoqGovernorLimitException.class,
            'Expected to throw an exception of type CustomPermissionHelper.CustomPermissionHelperSoqGovernorLimitException, but actually threw ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('Too close to SOQL row query limit'),
            'Expected error message to contain "Too close to SOQL row query limit", but it instead said "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    /**
     * Expensive per-test activate a custom permission for a user.
     *
     * Because of how FeatureManagement.checkPermission works, we need to create a new permission set that grants the permission
     * and assign the user that permission set in order to get it to detect the custom permission.
     * We CANNOT use an already existing permission set.
     *
     */
    public static void activateCustomPerm(String userId, String permissionName) {
        PermissionSet ps = new PermissionSet(
            Name = permissionName + '_Enabled_' + permSetIndx,
            Label = permissionName + ' Enabled ' + permSetIndx
        );
        insert ps;
        permSetIndx += 1;

        SetupEntityAccess sea = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = [
                SELECT Id
                FROM CustomPermission
                WHERE DeveloperName = :permissionName
                LIMIT 1
            ]
            .Id
        );

        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);

        insert new List<SObject>{ sea, psa };
    }
    private static Integer permSetIndx = 0;
}
