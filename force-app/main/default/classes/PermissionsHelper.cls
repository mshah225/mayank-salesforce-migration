public class PermissionsHelper {
    public static Boolean currentUserHasProfile(String profileName) {
        if (profileName != null && profileName != '') {
            return userHasProfile(profileName, UserInfo.getUserId());
        }
        return false;
    }

    public static Boolean userHasProfile(String profileName, Id userId) {
        if (profileName != null && profileName != '') {
            return [
                    SELECT Profile.Name
                    FROM User
                    WHERE Id = :userId
                ]
                .Profile.Name == profileName
                ? true
                : false;
        }
        return false;
    }

    public static Boolean currentUserHasPermissionSet(String permissionSetName) {
        if (permissionSetName != null && permissionSetName != '') {
            return userHasPermissionSet(permissionSetName, UserInfo.getUserId());
        }
        return false;
    }

    public static Boolean userHasPermissionSet(String permissionSetName, Id userId) {
        if (permissionSetName != null && permissionSetName != '') {
            return [
                    SELECT COUNT()
                    FROM PermissionSetAssignment
                    WHERE PermissionSet.Name = :permissionSetName AND AssigneeId = :userId
                    LIMIT 1
                ] == 1
                ? true
                : false;
        }
        return false;
    }
}