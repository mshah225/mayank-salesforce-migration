@isTest
public class PermissionSetHelperTest {
    @TestSetup
    private static void setup() {
        // Initialize needed test users
        User testSysAdmin = TestUserHelper.createTestSysAdmin();
        insert new List<User>{ testSysAdmin };

        PermissionSet ps = new PermissionSet(Label = 'Test Permission Set', Name = 'Test_Permission_Set');
        insert ps;

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testSysAdmin.Id,
            PermissionSetId = ps.id
        );
        insert psa;
    }

    // Tests if the current user has a specific permission set
    @isTest
    private static void testUserHasPermissionSet() {
        Boolean userHasPermissionSet,
            userDoesNotHavePermissionSet,
            userHasPermissionSetById,
            userDoesNotHavePermissionSetById;
        Integer queriesBefore, queryRowsBefore, queriesAfter, queryRowsAfter;
        User testUser = TestUserHelper.getTestSysAdmin();
        Integer properNumberOfPermSetAssignments = [
            SELECT COUNT()
            FROM PermissionSetAssignment
            WHERE AssigneeId = :testUser.Id
        ];

        PermissionSet permHas = [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Id IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id)
            LIMIT 1
        ];
        PermissionSet permHasNot = [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Id NOT IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id)
            LIMIT 1
        ];

        Test.startTest();

        System.runAs(testUser) {
            queriesBefore = Limits.getQueries();
            queryRowsBefore = Limits.getQueryRows();

            userHasPermissionSet = PermissionSetHelper.currentUserHasPermissionSet(permHas.Name);
            userDoesNotHavePermissionSet = PermissionSetHelper.currentUserHasPermissionSet(permHasNot.Name);
            userHasPermissionSetById = PermissionSetHelper.currentUserHasPermissionSetId(permHas.Id);
            userDoesNotHavePermissionSetById = PermissionSetHelper.currentUserHasPermissionSetId(permHasNot.Id);

            queriesAfter = Limits.getQueries();
            queryRowsAfter = Limits.getQueryRows();
        }

        Test.stopTest();

        Assert.isTrue(
            userHasPermissionSet,
            'Test user should have ' + permHas.Name + ' but currentUserHasPermissionSet said they don\'t'
        );
        Assert.isFalse(
            userDoesNotHavePermissionSet,
            'Test user shouldn\'t have ' + permHasNot.Name + ' but currentUserHasPermissionSet said they do'
        );

        Assert.isTrue(
            userHasPermissionSetById,
            'Test user should have ' + permHas.Id + ' but currentUserHasPermissionSetId said they don\'t'
        );
        Assert.isFalse(
            userDoesNotHavePermissionSetById,
            'Test user shouldn\'t have ' + permHasNot.Id + ' but currentUserHasPermissionSetId said they do'
        );

        Assert.areEqual(
            queriesBefore + 1,
            queriesAfter,
            'Should have only needed one SOQL query to get all permission sets for this user, but it took ' +
            (queriesAfter - queriesBefore)
        );
        Assert.areEqual(
            queryRowsBefore + properNumberOfPermSetAssignments,
            queryRowsAfter,
            'Should have only returned the permissions sets for that single user, which is ' +
                properNumberOfPermSetAssignments +
                ' records, but it used ' +
                (queryRowsAfter - queryRowsBefore) +
                ' query rows'
        );
    }

    // Tests if the current user has an empty or null permission set name
    @isTest
    private static void testUserHasNullOrEmptyPermissionSet() {
        Boolean currentUserHasEmptyPermissionSet, currentUserHasNullPermissionSet, currentUserHasNullPermissionSetById;

        Test.startTest();
        System.runAs(TestUserHelper.getTestSysAdmin()) {
            currentUserHasEmptyPermissionSet = PermissionSetHelper.currentUserHasPermissionSet('');
            currentUserHasNullPermissionSet = PermissionSetHelper.currentUserHasPermissionSet(null);
            currentUserHasNullPermissionSetById = PermissionSetHelper.currentUserHasPermissionSetId(null);
        }
        Test.stopTest();

        Assert.isFalse(currentUserHasEmptyPermissionSet);
        Assert.isFalse(currentUserHasNullPermissionSet);
        Assert.isFalse(currentUserHasNullPermissionSetById);
    }

    // Tests Exception is thrown when at SOQL query row limit
    @isTest
    private static void testUserHasPermissionSetErrorQueries() {
        Exception thrownException = null;

        Test.startTest();

        System.runAs(TestUserHelper.getTestSysAdmin()) {
            // Get to SOQL governor limit
            while (Limits.getQueries() < Limits.getLimitQueries()) {
                Profile tmpProfile = [SELECT Id FROM Profile LIMIT 1];
            }

            // Try and fail
            try {
                PermissionSetHelper.currentUserHasPermissionSet('Test_Permission_Set');
            } catch (Exception ex) {
                thrownException = ex;
            }
        }

        Test.stopTest();

        // Assert
        Assert.isInstanceOfType(
            thrownException,
            PermissionSetHelper.PermissionSetHelperSoqlGovernorLimitException.class,
            'Expected to throw an exception of type PermissionSetHelper.PermissionSetHelperSoqlGovernorLimitException, but actually threw ' +
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
    private static void testUserHasPermissionSetErrorQueryRows() {
        Exception thrownException = null;

        Test.startTest();

        System.runAs(TestUserHelper.getTestSysAdmin()) {
            // Get to SOQL governor limit (we have >10k users so this should hit pretty fast)
            while (Limits.getQueryRows() < Limits.getLimitQueryRows()) {
                Integer remainingLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
                List<User> tempUsers = [SELECT Id FROM User LIMIT :remainingLimit];
                tempUsers = null;
            }

            // Try and fail
            try {
                PermissionSetHelper.currentUserHasPermissionSet('Test_Permission_Set');
            } catch (Exception ex) {
                thrownException = ex;
            }
        }

        Test.stopTest();

        // Assert
        Assert.isInstanceOfType(
            thrownException,
            PermissionSetHelper.PermissionSetHelperSoqlGovernorLimitException.class,
            'Expected to throw an exception of type PermissionSetHelper.PermissionSetHelperSoqlGovernorLimitException, but actually threw ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('Too close to SOQL row query limit'),
            'Expected error message to contain "Too close to SOQL row query limit", but it instead said "' +
                thrownException?.getMessage() +
                '"'
        );
    }
}
