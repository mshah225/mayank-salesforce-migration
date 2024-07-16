@isTest
private class PermissionsHelperTest {
    // Tests if the current user has a specific profile
    @isTest
    private static void testUserHasProfile() {
        Boolean userHasProfile = false;
        Boolean userDoesNotHaveProfile = true;

        Test.startTest();
        userHasProfile = PermissionsHelper.currentUserHasProfile('System Administrator');
        userDoesNotHaveProfile = PermissionsHelper.currentUserHasProfile('Test Profile');
        Test.stopTest();

        System.assertEquals(true, userHasProfile);
        System.assertEquals(false, userDoesNotHaveProfile);
    }

    // Tests if the current user has an empty or null profile name
    @isTest
    private static void testNullOrEmptyProfile() {
        Boolean currentUserHasEmptyProfile = true;
        Boolean currentUserHasNullProfile = true;
        Boolean userHasEmptyProfile = true;
        Boolean userHasNullProfile = true;

        Test.startTest();
        currentUserHasEmptyProfile = PermissionsHelper.currentUserHasProfile('');
        currentUserHasNullProfile = PermissionsHelper.currentUserHasProfile(null);
        userHasEmptyProfile = PermissionsHelper.userHasProfile('', UserInfo.getUserId());
        userHasNullProfile = PermissionsHelper.userHasProfile(null, UserInfo.getUserId());
        Test.stopTest();

        System.assertEquals(false, currentUserHasEmptyProfile);
        System.assertEquals(false, currentUserHasNullProfile);
        System.assertEquals(false, userHasEmptyProfile);
        System.assertEquals(false, userHasNullProfile);
    }

    // Tests if the current user has a specific permission set
    @isTest
    private static void testUserHasPermissionSet() {
        Boolean userHasPermissionSet = false;
        Boolean userDoesNotHavePermissionSet = true;

        PermissionSet ps = new PermissionSet(Label = 'Test Permission Set', Name = 'Test_Permission_Set');
        insert ps;

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = UserInfo.getUserId(),
            PermissionSetId = ps.id
        );
        insert psa;

        Test.startTest();
        userHasPermissionSet = PermissionsHelper.currentUserHasPermissionSet('Test_Permission_Set');
        userDoesNotHavePermissionSet = PermissionsHelper.currentUserHasPermissionSet('Test_Permission_Set_2');
        System.debug(userDoesNotHavePermissionSet);
        Test.stopTest();

        System.assertEquals(true, userHasPermissionSet);
        System.assertEquals(false, userDoesNotHavePermissionSet);
    }

    // Tests if the current user has an empty or null permission set name
    @isTest
    private static void testNullOrEmptyPermissionSet() {
        Boolean currentUserHasEmptyPermissionSet = true;
        Boolean currentUserHasNullPermissionSet = true;
        Boolean userHasEmptyPermissionSet = true;
        Boolean userHasNullPermissionSet = true;

        Test.startTest();
        currentUserHasEmptyPermissionSet = PermissionsHelper.currentUserHasPermissionSet('');
        currentUserHasNullPermissionSet = PermissionsHelper.currentUserHasPermissionSet(null);
        userHasEmptyPermissionSet = PermissionsHelper.userHasPermissionSet('', UserInfo.getUserId());
        userHasNullPermissionSet = PermissionsHelper.userHasPermissionSet(null, UserInfo.getUserId());
        Test.stopTest();

        System.assertEquals(false, currentUserHasEmptyPermissionSet);
        System.assertEquals(false, currentUserHasNullPermissionSet);
        System.assertEquals(false, userHasEmptyPermissionSet);
        System.assertEquals(false, userHasNullPermissionSet);
    }
}