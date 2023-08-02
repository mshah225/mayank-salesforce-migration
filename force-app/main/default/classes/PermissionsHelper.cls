public class PermissionsHelper {
    public static Boolean currentUserHasProfile(String profileName) {
        return userHasProfile(profileName, UserInfo.getUserId());
    }

    public static Boolean userHasProfile(String profileName, Id userId) {
        return (profileName != null &&
            profileName != '' &&
            ([
                SELECT Profile.Name
                FROM User
                WHERE Id = :userId
            ]
            .Profile.Name == profileName))
            ? true
            : false;
    }

    public static Boolean currentUserHasPermissionSet(String permissionSetName) {
        return userHasPermissionSet(permissionSetName, UserInfo.getUserId());
    }

    public static Boolean userHasPermissionSet(String permissionSetName, Id userId) {
        return (permissionSetName != null &&
            permissionSetName != '' &&
            ([
                SELECT COUNT()
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = :permissionSetName AND AssigneeId = :userId
                LIMIT 1
            ] == 1))
            ? true
            : false;
    }
}