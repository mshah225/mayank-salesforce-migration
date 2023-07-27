public class PermissionsHelper {
    public static Boolean userHasProfile(String profileName) {
        if (profileName != null) {
            return [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name == profileName
                ? true
                : false;
        }
        return false;
    }

    public static Boolean userHasPermissionSet(String permissionSetName) {
        if (permissionSetName != null) {
            return [
                    SELECT COUNT()
                    FROM PermissionSetAssignment
                    WHERE PermissionSet.Name = :permissionSetName AND AssigneeId = :UserInfo.getUserId()
                    LIMIT 1
                ] == 1
                ? true
                : false;
        }
        return false;
    }
}