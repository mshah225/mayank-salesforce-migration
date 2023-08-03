public class PermissionsHelper {
    public static Boolean currentUserHasProfile(String profileName) {
        return userHasProfile(profileName, UserInfo.getUserId());
    }

    public static Boolean userHasProfile(String profileName, Id userId) {
        return (profileName != null &&
            profileName != '' &&
            userId != null &&
            ([
                SELECT Profile.Name
                FROM User
                WHERE Id = :userId
            ]
            .Profile.Name == profileName))
            ? true
            : false;
    }

    public static Boolean currentUserHasProfileId(Id profileId) {
        return userHasProfileId(profileId, UserInfo.getUserId());
    }

    public static Boolean userHasProfileId(Id profileId, Id userId) {
        return (profileId != null &&
            userId != null &&
            ([
                SELECT Profile.Id
                FROM User
                WHERE Id = :userId
            ]
            .Profile.Id == profileId))
            ? true
            : false;
    }

    public static Boolean currentUserHasPermissionSet(String permissionSetName) {
        return userHasPermissionSet(permissionSetName, UserInfo.getUserId());
    }

    public static Boolean userHasPermissionSet(String permissionSetName, Id userId) {
        return (permissionSetName != null &&
            permissionSetName != '' &&
            userId != null &&
            ([
                SELECT COUNT()
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = :permissionSetName AND AssigneeId = :userId
                LIMIT 1
            ] == 1))
            ? true
            : false;
    }

    public static Boolean currentUserHasPermissionSetId(Id permissionSetId) {
        return userHasPermissionSetId(permissionSetId, UserInfo.getUserId());
    }

    public static Boolean userHasPermissionSetId(Id permissionSetId, Id userId) {
        return (permissionSetId != null &&
            userId != null &&
            ([
                SELECT COUNT()
                FROM PermissionSetAssignment
                WHERE PermissionSet.Id = :permissionSetId AND AssigneeId = :userId
                LIMIT 1
            ] == 1))
            ? true
            : false;
    }
}